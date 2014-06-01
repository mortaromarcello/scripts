#!/usr/bin/env python

import sys, re, os, time, string, subprocess, wx, parted, parted.disk, logging
import signal
import shutil
from optparse import OptionParser

# variabili globali
_ = wx.GetTranslation
padding = 5 # pixels fra gli oggetti delle box

#--------------Funzioni-----------------

def isdevmount(device):
    """
     Controlla se il device montato.
     Ritorna il path, altrimenti stringa vuota
     """
    for l in file('/proc/mounts'):
        d = l.split()
        if d[0] == device: return d[1]
    return ''

def ispathmount(path):
    """
    Controlla se il path montato. Ritorna il device, altrimenti stringa vuota
    """
    for l in file('/proc/mounts'):
        d = l.split()
        if d[1] == path: return d[0]
    return ''

def blkid(device):
    """
    Chiama il comando blkid per ottenere l'UUID
    """
    command = "/sbin/blkid -o value -s UUID %s" % device
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    return proc.stdout.readline().strip()

def crypt_password(password):
    """
    Ritorna una stringa con la password criptata
    """
    command = "perl -e \'print crypt($ARGV[0], \"password\")\' %s" % password
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    return proc.stdout.readline().strip()

def grep(namefile, string):
    """
    Ritorna la prima linea che contiene la stringa 'string'
    nel file 'namefile'
    """
    try:
        f = open(namefile, 'r')
    except:
        return None
    for line in f:
        if re.search(string, line):
            return line

def edsub(namefile, string, substring):
    """
    Sostituisce tutte le occorrenze di 'string' con 'substring'
    e la scrive nel file 'namefile'
    """
    try:
        with open(namefile, 'r') as sources:
            lines = sources.readlines()
        with open(namefile, 'w') as sources:
            for line in lines:
                sources.write(re.sub(string, substring, line))
    except:
        return -1
    return 0

def runProcess(command):
    """
    Esegue il comando 'command' e ritorna il processo
    """
    proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    while True:
        line = proc.stdout.readline()
        wx.Yield()
        if line.strip() == "":
            pass
        else:
            print line.strip()
        if not line: break
    proc.wait()
    return proc

def get_size(start_path = '.', symlink=False):
    """
    Restituisce il totale della grandezza dei file in una directory
    """
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(start_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            if not os.path.islink(fp):
                total_size += os.path.getsize(fp)
            else:
                if symlink: total_size += os.path.getsize(fp)
    return total_size

def is31rsync():
    """
    Ritorna True se la versione di rsync e' maggiore o uguale di 3.1
    """
    proc = subprocess.Popen("rsync --version", shell=True, stdout=subprocess.PIPE)
    while True:
        line = proc.stdout.readline()
        if "3.1" in line:
            return True
        if line.strip() == "":
            pass
        if not line:
            break
    return False

#-----------------------------------------------------------------------

class Logger(object):
    """
    Class Logger
    """
    @staticmethod
    def initLogging(stream, log_level):
        consoleFormat = "%(asctime)s %(levelname)s %(funcName)s %(message)s %(pathname)s %(lineno)d"
        dateFormat = "%H:%M:%S"
        logging.basicConfig(stream=stream, level=log_level, format=consoleFormat, datefmt=dateFormat)

#-----------------------------------------------------------------------
class Glob:
    """ Class Glob """
    #
    DISTRO                = 'debian'
    ROOT_PARTITION        = ''
    UUID_ROOT_PARTITION   = ''
    HOME_PARTITION        = ''
    FORMAT_HOME           = False
    UUID_HOME_PARTITION   = ''
    SWAP_PARTITION        = ''
    UUID_SWAP_PARTITION   = ''
    INST_DRIVE            = ''
    INST_ROOT_DIRECTORY   = '/mnt/' + DISTRO
    TYPE_FS               = 'ext4'
    USER                  = ''
    AUTOLOGIN             = True
    CRYPT_USER_PASSWORD   = ''
    CRYPT_ROOT_PASSWORD   = ''
    LOCALE                = 'it_IT.UTF-8 UTF-8'
    LANG                  = 'it_IT.UTF-8'
    KEYBOARD              = 'it'
    HOSTNAME              = DISTRO
    if grep('/etc/group', 'android'):
        GROUPS                = 'cdrom,floppy,audio,dip,video,plugdev,fuse,scanner,bluetooth,netdev,dialout,android'
    else:
        GROUPS                = 'cdrom,floppy,audio,dip,video,plugdev,fuse,scanner,bluetooth,netdev,dialout'
    TIMEZONE              = 'Europe/Rome'
    SHELL_USER            = '/bin/bash'
    SQUASH_FS             = '/lib/live/mount/rootfs/filesystem.squashfs'
    SQUASH_FILE           = ''
    USE_HOME              = False
    CONSOLE_LOG_LEVEL     = logging.DEBUG
    DEBUG                 = False
    UPGRADE               = False
    NOPASSWD              = False
    PROC                  = None
    PATH_FILE_LOG         = '/tmp/install.log'
    PATH_PROG             = os.path.realpath(sys.argv[0])
    PATH                  = os.path.split(PATH_PROG)[0]
    NAME_PROG             = os.path.basename(os.path.splitext(PATH_PROG)[0])
    PATH_PROG_ICON        = os.path.abspath('%s/%s.png' % (PATH, NAME_PROG))
    PATH_PROG_LANGS       = ('./locale/it/%s.mo' % NAME_PROG,)
    FILE_LOG              = None
    INSTALLED_OK          = False

    # user's home dir - works for windows/unix/linux
    HOME_DIR = os.getenv('USERPROFILE') or os.getenv('HOME')

    PID = os.getpid()

    # will be set by main function
    PACKAGE_VERSION     = '0.1'
    PACKAGE_BUGREPORT   = ''
    PACKAGE_URL         = ''
    PACKAGE_TITLE       = 'Install distro'
    PACKAGE_COPYRIGHT   = ''
    DEFAULT_CONFIG_FILE = ''
    LICENSE             = ''
    AUTHOR              = 'Mortaro Marcello'

#-----------------------------------------------------------------------
class RedirectText:
    """ redireziona l'output su una wx.TextCrtl. Se il file esiste scrive l'output sul file """
    def __init__(self,aWxTextCtrl, file=None):
        self.out=aWxTextCtrl
        self.file = file

    def write(self,string):
        self.out.WriteText(string)
        if self.file:
            try:
                self.file.write(string)
            except:
                print 'Problem on the file %s.' % self.file.name
                pass

#-----------------------------------------------------------------------
class MyPanel(wx.Panel):
    """
    Pannello
    """
    def __init__(self, parent):
        wx.Panel.__init__(self, parent)

        self.parts          = []
        self.disks          = []
        self.str_locals     = ['it_IT.UTF-8 UTF-8', 'en_US.UTF-8 UTF-8', 'es_ES.UTF-8 UTF-8', 'de_DE.UTF-8 UTF-8', 'fr_FR.UTF-8 UTF-8']
        self.str_langs      = ['it_IT.UTF-8', 'en_US.UTF-8', 'es_ES.UTF-8', 'de_DE.UTF-8', 'fr_FR.UTF-8']
        self.str_keyboards  = ['it', 'us', 'es', 'de', 'fr']
        self.str_timezones  = ['Europe/Rome', 'Europe/London', 'Europe/Madrid', 'Europe/Berlin', 'Europe/Paris', 'Etc/UTC']
        self.str_shells     = ['/bin/bash', '/bin/sh']
        self.initDisks()
        # inizializza l'interfaccia
        self.initGui()

    def initGui(self):
        """
        Inizializza l'interfaccia
        """
        self.sizer = wx.StaticBoxSizer(wx.StaticBox(self, -1, _(' Initialization ')), wx.VERTICAL)

        grid_sizer1 = wx.FlexGridSizer(7, 2, padding, padding)
        grid_sizer2 = wx.FlexGridSizer(7, 2, padding, padding)
        horizontal_sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.SetSizer(self.sizer)

        self.part_root = wx.ComboBox(self, -1, choices=self.parts, style=wx.CB_READONLY)
        self.part_home = wx.ComboBox(self, -1, choices=self.parts, style=wx.CB_READONLY)
        self.disk_inst = wx.ComboBox(self, -1, choices=self.disks, style=wx.CB_READONLY)
        self.check_format_home = wx.CheckBox(self, -1, _("Format the partition  home"))
        self.check_format_home.SetValue(Glob.FORMAT_HOME)
        self.check_autologin =  wx.CheckBox(self, -1, _("Automatic login"))
        self.check_autologin.SetValue(Glob.AUTOLOGIN)
        self.upgrade = wx.CheckBox(self, -1, _("Upgrade the system"))
        self.upgrade.SetValue(Glob.UPGRADE)
        self.nopasswd = wx.CheckBox(self, -1, _("'NOPASSWD' sudo"))
        self.nopasswd.SetValue(Glob.NOPASSWD)
        self.user = wx.TextCtrl(self, -1, 'debian-user')
        self.password_user = wx.TextCtrl(self, -1,'', style=wx.TE_PASSWORD)
        self.password_root = wx.TextCtrl(self, -1,'', style=wx.TE_PASSWORD)
        self.locale = wx.ComboBox(self, -1, choices=self.str_locals, style=wx.CB_READONLY)
        self.lang = wx.ComboBox(self, -1, choices=self.str_langs, style=wx.CB_READONLY)
        self.keyboard = wx.ComboBox(self, -1, choices=self.str_keyboards, style=wx.CB_READONLY)
        self.hostname = wx.TextCtrl(self, -1, Glob.HOSTNAME)
        self.groups = wx.TextCtrl(self, -1, Glob.GROUPS)
        self.timezone = wx.ComboBox(self, -1, choices=self.str_timezones, style=wx.CB_READONLY)
        self.shell = wx.ComboBox(self, -1, choices=self.str_shells, style=wx.CB_READONLY)
        if self.parts: self.part_root.SetStringSelection(self.parts[0])
        if self.disks:
            if Glob.INST_DRIVE:
                for disk in self.disks:
                    if Glob.INST_DRIVE == disk:
                        self.disk_inst.SetStringSelection(disk)
                        break
            else: self.disk_inst.SetStringSelection(self.disks[0])
        self.locale.SetStringSelection(self.str_locals[0])
        self.lang.SetStringSelection(self.str_langs[0])
        self.keyboard.SetStringSelection(self.str_keyboards[0])
        self.timezone.SetStringSelection(self.str_timezones[0])
        self.shell.SetStringSelection(self.str_shells[0])
        #
        self.sizer.AddWindow(wx.StaticText(self, -1, _('The options marked with an asterisk are required')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        # 1 riga
        grid_sizer1.Add(wx.StaticText(self, -1, _('Root partition (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer1.Add(self.part_root, 0, wx.EXPAND|wx.ALL, padding)
        # 2
        grid_sizer1.Add(wx.StaticText(self, -1, _('Home partition')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer1.Add(self.part_home, 0, wx.EXPAND|wx.ALL, padding)
        # 3
        grid_sizer1.Add(self.check_format_home, 0, wx.EXPAND|wx.ALL, padding)
        grid_sizer1.Add(self.check_autologin, 0, wx.EXPAND|wx.ALL, padding)
        # 4
        grid_sizer1.Add(self.upgrade, 0, wx.EXPAND|wx.ALL, padding)
        #grid_sizer1.Add(wx.StaticText(self, -1, ''), 0, wx.EXPAND|wx.ALL, padding)
        grid_sizer1.Add(self.nopasswd, 0, wx.EXPAND|wx.ALL, padding)
        # 5
        grid_sizer1.Add(wx.StaticText(self, -1, _('Installation drive (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer1.Add(self.disk_inst, 0, wx.EXPAND|wx.ALL, padding)
        # 6
        grid_sizer1.Add(wx.StaticText(self, -1, _('Username (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer1.Add(self.user, 0, wx.EXPAND|wx.ALL, padding)
        # 7
        grid_sizer1.Add(wx.StaticText(self, -1, _('User password (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer1.Add(self.password_user, 0, wx.EXPAND|wx.ALL, padding)
        # 8
        grid_sizer1.Add(wx.StaticText(self, -1, _('Root password (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer1.Add(self.password_root, 0, wx.EXPAND|wx.ALL, padding)
        # 1
        grid_sizer2.Add(wx.StaticText(self, -1, _('Locale')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer2.Add(self.locale, 0, wx.EXPAND|wx.ALL, padding)
        # 2
        grid_sizer2.Add(wx.StaticText(self, -1, _('Language')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer2.Add(self.lang, 0, wx.EXPAND|wx.ALL, padding)
        # 3
        grid_sizer2.Add(wx.StaticText(self, -1, _('Keyboard')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer2.Add(self.keyboard, 0, wx.EXPAND|wx.ALL, padding)
        # 4
        grid_sizer2.Add(wx.StaticText(self, -1, _('Hostname (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer2.Add(self.hostname, 0, wx.EXPAND|wx.ALL, padding)
        # 5
        grid_sizer2.Add(wx.StaticText(self, -1, _('Groups (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer2.Add(self.groups, 0, wx.EXPAND|wx.ALL, padding)
        # 6
        grid_sizer2.Add(wx.StaticText(self, -1, _('Timezone')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer2.Add(self.timezone, 0, wx.EXPAND|wx.ALL, padding)
        # 7
        grid_sizer2.Add(wx.StaticText(self, -1, _('Shell')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
        grid_sizer2.Add(self.shell, 0, wx.EXPAND|wx.ALL, padding)

        horizontal_sizer.Add(grid_sizer1)
        horizontal_sizer.Add((50, -1))
        horizontal_sizer.Add(grid_sizer2)
        self.sizer.Add(horizontal_sizer, 0, wx.EXPAND|wx.ALL, padding)
        self.sizer.Fit(self)

    def initDisks(self):
        """
        Inizializza le informazioni sui dischi
        """
        print 'initDisks'
        # Inizializza le informazioni dei dischi
        devices = parted.getAllDevices()
        for dev in devices:
            try:
                disk = parted.Disk(dev)
            except:
                continue
            self.disks += [disk.device.path]
            for i in disk.partitions:
                if i.fileSystem:
                    # Cerca la partizione di swap se esiste
                    if string.find(i.fileSystem.type, "linux-swap") != -1:
                        Glob.SWAP_PARTITION = i.path
                        logging.debug("swap:%s" % (Glob.SWAP_PARTITION))
                    else: self.parts += [i.path]

    def SetGlob(self):
        """
        Setta le variabili Globali
        """
        #--------------------------------------
        Glob.ROOT_PARTITION = self.part_root.GetValue()
        Glob.HOME_PARTITION = self.part_home.GetValue()
        if Glob.HOME_PARTITION:
            Glob.UUID_HOME_PARTITION = blkid(Glob.HOME_PARTITION)
            Glob.FORMAT_HOME = self.check_format_home.GetValue()
        Glob.AUTOLOGIN = self.check_autologin.GetValue()
        Glob.UPDATE = self.upgrade.GetValue()
        Glob.NOPASSWD = self.nopasswd.GetValue()
        if Glob.SWAP_PARTITION:
            Glob.UUID_SWAP_PARTITION = blkid(Glob.SWAP_PARTITION)
        Glob.INST_DRIVE = self.disk_inst.GetValue()
        Glob.USER = self.user.GetValue()
        if self.password_user.GetValue():
            try:
                Glob.CRYPT_USER_PASSWORD = crypt_password(self.password_user.GetValue())
            except UnicodeEncodeError:
                wx.MessageBox(_(" You entered an illegal character in the 'User password'. "), _("Attention"), wx.OK | wx.ICON_INFORMATION)
                return
        else: Glob.CRYPT_USER_PASSWORD = ''
        if self.password_root.GetValue():
            try:
                Glob.CRYPT_ROOT_PASSWORD = crypt_password(self.password_root.GetValue())
            except UnicodeEncodeError:
                wx.MessageBox(_(" You entered an illegal character in the 'Root password' "), _("Attention"), wx.OK | wx.ICON_INFORMATION)
                return
        else: Glob.CRYPT_ROOT_PASSWORD = ''
        Glob.LOCALE = self.locale.GetValue()
        Glob.LANG = self.lang.GetValue()
        Glob.KEYBOARD = self.keyboard.GetValue()
        Glob.HOSTNAME = self.hostname.GetValue()
        Glob.GROUPS = self.groups.GetValue()
        Glob.TIMEZONE = self.timezone.GetValue()
        Glob.SHELL_USER = self.shell.GetValue()

        #-------------------------------------
        logging.debug("distro:%s, root partition:%s, uuid root partition:%s, home partition:%s, format home:%s, autologin:%s, update:%s, nopasswd:%s, uuid home partition:%s, swap partition:%s, uuid swap partition:%s, drive inst:%s, dir root inst:%s, user:%s, crypt user password:%s, crypt root password:%s, locale:%s, lang:%s, keyboard:%s, hostname:%s, groups:%s, timezone:%s, shell user:%s" % (Glob.DISTRO, Glob.ROOT_PARTITION, Glob.UUID_ROOT_PARTITION, Glob.HOME_PARTITION, Glob.FORMAT_HOME, Glob.AUTOLOGIN, Glob.UPDATE, Glob.NOPASSWD, Glob.UUID_HOME_PARTITION, Glob.SWAP_PARTITION, Glob.UUID_SWAP_PARTITION, Glob.INST_DRIVE, Glob.INST_ROOT_DIRECTORY, Glob.USER, Glob.CRYPT_USER_PASSWORD, Glob.CRYPT_ROOT_PASSWORD, Glob.LOCALE, Glob.LANG, Glob.KEYBOARD, Glob.HOSTNAME, Glob.GROUPS, Glob.TIMEZONE, Glob.SHELL_USER))
        return True

#-----------------------------------------------------------------------
class MyPanelInfo(wx.Panel):
    """
    Pannello delle informazioni
    """
    def __init__(self, parent):
        wx.Panel.__init__(self, parent)
        self.info = wx.TextCtrl(self, size=(800, 400), style=wx.TE_MULTILINE|wx.TE_READONLY|wx.HSCROLL|wx.TE_RICH)
        self.info.SetForegroundColour(wx.BLACK)
        self.info.SetBackgroundColour(wx.SystemSettings.GetColour(wx.SYS_COLOUR_BACKGROUND))
        sizer = wx.StaticBoxSizer(wx.StaticBox(self, -1, _(' Summary ')), wx.VERTICAL)
        self.SetSizer(sizer)
        sizer.Add(self.info, 0, wx.EXPAND|wx.ALL, padding)

    def updateInfo(self, string):
        self.info.WriteText(string)

    def clearInfo(self):
        self.info.Clear()

#-----------------------------------------------------------------------
class MyFrame(wx.Frame):
    """
    """
    def __init__(self, parent=None, ID=-1, title=_(_(Glob.PACKAGE_TITLE))):
        wx.Frame.__init__(self, parent, ID, title)
        mylocale = wx.Locale()
        mylocale.AddCatalogLookupPathPrefix('./locale')
        mylocale.AddCatalogLookupPathPrefix('/usr/local/share/locale')
        mylocale.AddCatalog('it/LC_MESSAGES/install_distro')
        self.menubar = self.createMenuBar()
        self.SetMenuBar(self.menubar)
        self.panel = MyPanel(self)
        self.panel_info = MyPanelInfo(self)
        self.panel_info.Hide()
        self.runInst = False
        # statusbar
        self.statusbar = self.CreateStatusBar()
        self.statusbar.SetFieldsCount(3)
        #self.statusbar.SetStatusWidths([320, -1, -2])
        #self.progress_bar
        self.progress_bar = wx.Gauge(self.statusbar, -1, style=wx.GA_HORIZONTAL|wx.GA_SMOOTH)
        self.progress_bar.Hide()
        #self.timer
        self.timer = wx.Timer(self, 1)
        #self.progress
        self.progress = 0
        self.Bind(wx.EVT_TIMER, self.onTimer, self.timer)
        self.SetStatusText(_("Welcome to Setup Livedevelop"))
        #
        self.__DoLayout()

    def createMenuBar(self):
        """
        Crea la barra dei menu
        """
        menubar = wx.MenuBar()
        menuData = (
            (_("&File"),(wx.ID_EXIT, _("&Quit"), _("Quit"), "", self.onClickExit)),
            (_("&Help"),(wx.ID_HELP, _("&Help"), _("Help"), "", self.onClickHelp))
        )
        for eachMenuData in menuData:
            menuLabel = eachMenuData[0]
            menuItems = eachMenuData[1:]
            menubar.Append(self.createMenu(menuItems), menuLabel)
        return menubar

    def createMenu(self, menuData):
        """
        Crea i menu
        """
        menu = wx.Menu()
        for eachID, eachLabel, eachStatus, eachIcon, eachHandler in menuData:
            if not eachLabel:
                menu.AppendSeparator()
                continue
            menuItem = wx.MenuItem(menu, eachID, eachLabel, eachStatus)
            if eachIcon:
                menuItem.SetBitmap(wx.Bitmap(eachIcon))
            menu.AppendItem(menuItem)
            self.Bind(wx.EVT_MENU, eachHandler, menuItem)
        return menu

    def __DoLayout(self):
        """
        Crea il layout del pannello
        """
        self.sizer_vertical = wx.BoxSizer(wx.VERTICAL)

        self.sizer = wx.BoxSizer(wx.HORIZONTAL)
        self.log = wx.TextCtrl(self, wx.ID_ANY, size=(-1,120), style=wx.TE_MULTILINE|wx.TE_READONLY|wx.HSCROLL|wx.TE_RICH)
        self.log.SetForegroundColour(wx.WHITE)
        self.log.SetBackgroundColour(wx.BLACK)
        self.log.Hide()
        self.redir = RedirectText(self.log, Glob.FILE_LOG)
        sys.stdout = self.redir
        Logger.initLogging(self.redir, Glob.CONSOLE_LOG_LEVEL)
        self.sizer_vertical.Add(self.panel, 1, wx.EXPAND|wx.ALL, padding)
        self.sizer_vertical.Add(self.panel_info, 1, wx.EXPAND|wx.ALL, padding)
        self.sizer_vertical.Add(self.log, 0, wx.EXPAND|wx.ALL, padding)

        self.install = wx.Button(self, -1, _("Install"))
        self.install.Bind(wx.EVT_BUTTON, self.onClickInstall)
        self.exit = wx.Button(self, wx.ID_EXIT)
        self.exit.Bind(wx.EVT_BUTTON, self.onClickExit)
        sizer_buttons = wx.BoxSizer(wx.VERTICAL)
        sizer_buttons.Add(self.install, 0, wx.EXPAND|wx.ALL, padding)
        sizer_buttons.Add(self.exit, 0, wx.EXPAND|wx.ALL, padding)
        self.sizer.Add(self.sizer_vertical, 0, wx.EXPAND|wx.ALL, padding)
        self.sizer.Add(sizer_buttons, 0, wx.EXPAND|wx.ALL, padding)
        self.SetSizer(self.sizer)
        self.sizer.Fit(self)

    def onClickHelp(self, event):
        """
        """
        pass

    def onClickInstall(self, evt):
        """
        """
        self.install.Disable()
        if not self.panel.SetGlob():
            self.install.Enable()
        else:
            self.goInstall()

    def onClickExit(self, evt):
        """
        """
        if self.runInst:
            result = wx.MessageDialog(None, _("Attention! Installation is in progress! Are you sure?"), _("Attention"), wx.YES_NO|wx.ICON_QUESTION).ShowModal()
            if result == wx.ID_NO:
                return
        self.endInstall()
        self.Close()

    def goInstall(self):
        """
        """
        print 'GoInstall'
        self.SetStatusText(_('Beginning installation...'))
        if not self.checkRequisites():
            #---- codice controllo
            self.install.Enable()
            return
            #----
        self.panel.Hide()
        self.panel_info.Show()
        self.log.Show()
        self.sizer.Fit(self)
        self.panel_info.updateInfo("\n Name Distro:\t\t\t\t%s\n Root partition:\t\t\t%s\n" % (Glob.DISTRO, Glob.ROOT_PARTITION))
        if Glob.HOME_PARTITION: self.panel_info.updateInfo(" Home partition:\t\t\t%s\n" % Glob.HOME_PARTITION)
        if Glob.UUID_HOME_PARTITION: self.panel_info.updateInfo("UUID home partition:\t\t%s\n" % Glob.UUID_HOME_PARTITION)
        if Glob.SWAP_PARTITION: self.panel_info.updateInfo(" Swap partition:\t\t\t%s\n" % Glob.SWAP_PARTITION)
        if Glob.UUID_SWAP_PARTITION: self.panel_info.updateInfo(" UUID swap partition:\t\t%s\n" % Glob.UUID_SWAP_PARTITION)
        self.panel_info.updateInfo(" Drive installation:\t\t\t%s\n Directory root installation:\t%s\n Name User:\t\t\t\t%s\n Crypt user password:\t\t%s\n Crypt root password:\t\t%s\n Locale:\t\t\t\t\t%s\n Lang:\t\t\t\t\t%s\n Keyboard:\t\t\t\t%s\n Hostname:\t\t\t\t%s\n Groups:\t\t\t\t\t%s\n Timezone:\t\t\t\t%s\n Shell user:\t\t\t\t%s\n" % (Glob.INST_DRIVE, Glob.INST_ROOT_DIRECTORY, Glob.USER, Glob.CRYPT_USER_PASSWORD, Glob.CRYPT_ROOT_PASSWORD, Glob.LOCALE, Glob.LANG, Glob.KEYBOARD, Glob.HOSTNAME, Glob.GROUPS, Glob.TIMEZONE, Glob.SHELL_USER))
        result = wx.MessageDialog(None, _("Attention! The installation formats the partitions of the of the disk! Are you sure??"), _("Attention"), wx.YES_NO|wx.ICON_QUESTION).ShowModal()
        if result == wx.ID_NO:
            self.panel_info.clearInfo()
            self.panel_info.Hide()
            self.panel.Show()
            self.sizer.Fit(self)
            return
        self.runInst = True
        self.createRootAndMountPartition()
        if Glob.UUID_ROOT_PARTITION: self.panel_info.updateInfo(' UUID root partition:\t\t%s\n' % Glob.UUID_ROOT_PARTITION)
        self.createHomeAndMountPartition()
        if Glob.UUID_HOME_PARTITION: self.panel_info.updateInfo(' UUID home partition:\t\t%s\n' % Glob.UUID_HOME_PARTITION)
        self.createSwapPartition()
        if Glob.UUID_SWAP_PARTITION: self.panel_info.updateInfo(' UUID swap partition:\t\t%s\n' % Glob.UUID_SWAP_PARTITION)
        try:
            self.copyRoot()
            self.addUser()
            self.changeRootPassword()
            self.addSudoUser()
            self.setAutologin()
            self.createFstab()
            self.setLocale()
            self.setTimezone()
            self.setHostname()
            self.updateMinidlna()
            self.installGrub()
            if Glob.UPGRADE:
                   self.upgradeSystem()
            self.runInst = False
            self.panel_info.clearInfo()
            self.panel_info.updateInfo(_("\t<--installation completed successfully-->"))
            Glob.INSTALLED_OK = True
        except: pass

    def checkRequisites(self):
        """
        Controlla che i requisiti siano rispettati
        """
        print 'checkRequisites'
        self.SetStatusText(_("Checking the prerequisites"))
        if (not Glob.ROOT_PARTITION) or (not Glob.INST_DRIVE) or (not Glob.USER) or (not Glob.CRYPT_USER_PASSWORD) or (not Glob.CRYPT_ROOT_PASSWORD) or (not Glob.HOSTNAME) or (not Glob.GROUPS):
            wx.MessageBox(_("Not all required options have been assigned. (All options marked with an asterisk are required)"), _("Attention"), wx.OK | wx.ICON_INFORMATION)
            return False
        for part in (Glob.ROOT_PARTITION, Glob.HOME_PARTITION, Glob.SWAP_PARTITION):
            d = isdevmount(part)
            if d:
                wx.MessageBox(_("Device %s mounted in %s." % (part, d)), _("Error"), wx.OK|wx.ICON_ERROR)
                return False
        if Glob.ROOT_PARTITION == Glob.HOME_PARTITION:
            wx.MessageBox(_("The root partition and home partition coincide."), _("Error"), wx.OK|wx.ICON_ERROR)
            return False
        if ispathmount(Glob.SQUASH_FS) == '':
            if (Glob.SQUASH_FS != '') and (Glob.SQUASH_FILE != ''):
                Glob.PROC = runProcess("mount -t squashfs -o ro %s %s" % (Glob.SQUASH_FILE, Glob.SQUASH_FS))
        return True

    def createRootAndMountPartition(self):
        """
        """
        print 'createRootAndMountPartition'
        if Glob.DEBUG: return
        self.SetStatusText(_("I create the root filesystem, and I mount it"))
        Glob.PROC = runProcess("mkfs -t %s %s" % (Glob.TYPE_FS, Glob.ROOT_PARTITION))
        if not Glob.PROC.returncode:
            Glob.UUID_ROOT_PARTITION = blkid(Glob.ROOT_PARTITION)
        else: self.checkError()
        logging.debug("uuid root partition:%s" % Glob.UUID_ROOT_PARTITION)
        if not Glob.PROC.returncode:
            Glob.PROC = runProcess("mkdir -p %s" % (Glob.INST_ROOT_DIRECTORY))
        else: self.checkError()
        if not Glob.PROC.returncode:
            Glob.PROC = runProcess("mount %s %s" % (Glob.ROOT_PARTITION, Glob.INST_ROOT_DIRECTORY))
        else: self.checkError()

    def createHomeAndMountPartition(self):
        """
        """
        print 'createHomeAndMountPartition'
        if Glob.DEBUG: return
        if not Glob.HOME_PARTITION:
            return
        self.SetStatusText(_("I create and mount the HOME directory"))
        if Glob.FORMAT_HOME:
            Glob.PROC = runProcess("mkfs -t %s %s" % (Glob.TYPE_FS, Glob.HOME_PARTITION))
            if Glob.PROC.returncode: self.checkError()
        Glob.UUID_HOME_PARTITION = blkid(Glob.HOME_PARTITION)
        print Glob.UUID_HOME_PARTITION
        Glob.PROC = runProcess("mkdir -p %s" % (Glob.INST_ROOT_DIRECTORY + '/home'))
        if not Glob.PROC.returncode:
            Glob.PROC = runProcess("mount %s %s" % (Glob.HOME_PARTITION, Glob.INST_ROOT_DIRECTORY + '/home'))
            if Glob.PROC.returncode: self.checkError()
        else: self.checkError()

    def createSwapPartition(self):
        """
        """
        if not Glob.SWAP_PARTITION: return
        print 'createSwapPartition'
        if Glob.DEBUG: return
        Glob.PROC = runProcess("mkswap -c %s" % Glob.SWAP_PARTITION)
        if not Glob.PROC.returncode:
            Glob.UUID_SWAP_PARTITION = blkid(Glob.SWAP_PARTITION)
        if Glob.PROC.returncode: self.checkError()

    def copyRoot(self):
        """
        Copia la root
        """
        print 'copyRoot'
        self.SetStatusText(_("I copy the files (It takes time)..."))
        #preparo la progress_bar
        rect = self.statusbar.GetFieldRect(1)
        self.progress_bar.SetPosition((rect.x+2, rect.y+2))
        self.progress_bar.SetSize((rect.width-4, rect.height-4))
        self.progress_bar.Show()
        self.timer.Start(100)
        copied_files = 0
        ver31 = is31rsync()
        if ver31:
            cmd = 'rsync -a --info=stats2 --dry-run %s/* %s' % (Glob.SQUASH_FS, Glob.INST_ROOT_DIRECTORY)
        else:
            cmd = 'rsync -a --stats --dry-run %s/* %s' % (Glob.SQUASH_FS, Glob.INST_ROOT_DIRECTORY)

        proc = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
        remainder = proc.communicate()[0]
        if ver31:
            mn = re.findall(r'reg: (\d+.*? )', remainder)
            if mn: total_files = int(mn[0])
        else:
            mn = re.findall(r'Number of files: (\d+)', remainder)
            if mn: total_files = int(mn[0].replace(',', ''))
        # debug
        print total_files
        #
        if ver31:
            cmd = 'rsync -av --info=progress2,stats2 %s/* %s' % (Glob.SQUASH_FS, Glob.INST_ROOT_DIRECTORY)
        else:
            cmd = 'rsync -av --progress %s/* %s' % (Glob.SQUASH_FS, Glob.INST_ROOT_DIRECTORY)
        Glob.PROC = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE)
        while True:
            line = Glob.PROC.stdout.readline()
            wx.Yield()
            if line.strip() == "":
                pass
            if ver31:
                if 'xfr#' in line:
                    m = re.findall(r'xfr#(\d+)', line)
                    if m: copied_files = int(m[0])
                    self.progress = (100 * copied_files) / total_files
                    if copied_files == total_files:
                        break
                else:
                    print line.strip()
            else:
                if 'to-check' in line:
                    m = re.findall(r'to-check=(\d+)/(\d+)', line)
                    if m: copied_files = (int(m[0][1]) - int(m[0][0]))
                    self.progress = (100 * copied_files) / total_files
                    if copied_files == total_files:
                        break
                else:
                    print line.strip()
            if not line: break
        Glob.PROC.wait()

    def onTimer(self, evt):
        self.progress_bar.SetValue(self.progress)
        if self.progress == 100:
            self.timer.Stop()

    def addUser(self):
        """
        Aggiunge utente
        """
        print 'addUser'
        if Glob.DEBUG: return
        self.SetStatusText(_("Add user"))
        Glob.PROC = runProcess("chroot %s useradd -G %s -s %s -m -p %s %s" % (Glob.INST_ROOT_DIRECTORY, Glob.GROUPS, Glob.SHELL_USER, Glob.CRYPT_USER_PASSWORD, Glob.USER))
        if Glob.PROC.returncode: self.checkError()

    def changeRootPassword(self):
        """
        Cambia root password
        """
        print 'changeRootPassword'
        if Glob.DEBUG: return
        self.SetStatusText(_("Change the root password"))
        Glob.PROC = runProcess("chroot %s bash -c \"echo root:%s | chpasswd -e\"" % (Glob.INST_ROOT_DIRECTORY, Glob.CRYPT_ROOT_PASSWORD))
        if Glob.PROC.returncode: self.checkError()

    def addSudoUser(self):
        """
        Aggiunge user a l gruppo sudo
        """
        print 'addSudoUser'
        if Glob.DEBUG: return
        self.SetStatusText(_("Add the user to the sudo group"))
        Glob.PROC = runProcess("chroot %s gpasswd -a %s sudo" % (Glob.INST_ROOT_DIRECTORY, Glob.USER))
        if Glob.PROC.returncode: self.checkError()
        if Glob.NOPASSWD:
            line = grep("%s/etc/sudoers" % Glob.INST_ROOT_DIRECTORY, "%sudo")
            if line:
                edsub("%s/etc/sudoers" % Glob.INST_ROOT_DIRECTORY, line, "%sudo ALL=(ALL) NOPASSWD: ALL")
            else:
                f = file("%s/etc/sudoers" % Glob.INST_ROOT_DIRECTORY, 'a')
                f.write("\n# Allow members of group sudo to execute any command\n%sudo    ALL=(ALL) NOPASSWD: ALL\n")
                f.close()

    def setAutologin(self):
        """
        Setta l'autologin
        """
        if not Glob.AUTOLOGIN: return
        print 'setAutologin'
        if Glob.DEBUG: return
        self.SetStatusText(_("Set the autologin"))
        if grep('%s/etc/X11/default-display-manager' % Glob.INST_ROOT_DIRECTORY, '/usr/sbin/gdm3'):
            line = grep('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, 'AutomaticLoginEnable')
            if line: edsub('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, line, 'AutomaticLoginEnable = true\n')
            line = grep('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, 'AutomaticLogin ')
            if line: edsub('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, line, 'AutomaticLogin = %s\n' % Glob.USER)
        elif grep('%s/etc/X11/default-display-manager' % Glob.INST_ROOT_DIRECTORY, '/usr/sbin/lightdm'):
            line = grep('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, '#autologin-user=')
            if line: edsub('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, line, 'autologin-user=%s\n' % Glob.USER)
            line = grep('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, '#autologin-user-timeout=0')
            if line: edsub('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, line, 'autologin-user-timeout=0\n')

    def createFstab(self):
        """
        Crea /etc/fstab
        """
        print 'createFstab'
        if Glob.DEBUG: return
        self.SetStatusText('Creo /etc/fstab')
        buff = "# /etc/fstab: static file system information.\n#\n# Use 'blkid' to print the universally unique identifier for a\n# device; this may be used with UUID= as a more robust way to name devices\n# that works even if disks are added and removed. See fstab(5).\n#\n# <file system> <mount point> <type> <options> <dump> <pass>\nproc /proc proc defaults 0 0\nUUID=%s / %s errors=remount-ro 0 1\n" % (Glob.UUID_ROOT_PARTITION, Glob.TYPE_FS)
        if Glob.UUID_HOME_PARTITION:
            buff = buff + "UUID=%s /home %s defaults 0 2\n" % (Glob.UUID_HOME_PARTITION, Glob.TYPE_FS)
        if Glob.UUID_SWAP_PARTITION:
            buff = buff + "UUID=%s none swap sw 0 0\n" % (Glob.UUID_SWAP_PARTITION)
        print buff
        f = file("%s/etc/fstab" % Glob.INST_ROOT_DIRECTORY, 'w')
        f.write(buff)
        f.close()

    def setLocale(self):
        """
        Setta il locale
        """
        print 'setLocale'
        if Glob.DEBUG: return
        self.SetStatusText(_("Set locale"))
        line = grep('%s/etc/locale.gen' % Glob.INST_ROOT_DIRECTORY, Glob.LOCALE)
        if line: edsub('%s/etc/locale.gen' % Glob.INST_ROOT_DIRECTORY, line, '%s\n' % Glob.LOCALE)
        line = grep('%s/etc/default/keyboard' % Glob.INST_ROOT_DIRECTORY, 'XKBLAYOUT')
        if line: edsub('%s/etc/default/keyboard' % Glob.INST_ROOT_DIRECTORY, line, 'XKBLAYOUT=\"%s\"\n' % Glob.KEYBOARD)
        Glob.PROC = runProcess("chroot %s locale-gen" % Glob.INST_ROOT_DIRECTORY)
        if not Glob.PROC.returncode:
            Glob.PROC = runProcess("chroot %s update-locale LANG=%s" % (Glob.INST_ROOT_DIRECTORY, Glob.LANG))
            if Glob.PROC.returncode: self.checkError()
        else: self.checkError()

    def setTimezone(self):
        """"
        Setta timezone
        """
        print 'setTimezone'
        if Glob.DEBUG: return
        self.SetStatusText(_("Set timezone"))
        f = open('%s/etc/timezone' % Glob.INST_ROOT_DIRECTORY, 'w')
        f.write('%s\n' % Glob.TIMEZONE)
        f.close()
        # set the time
        try:
            shutil.copy("%s/usr/share/zoneinfo/%s" % (Glob.INST_ROOT_DIRECTORY,Glob.TIMEZONE), "%s/etc/localtime" % Glob.INST_ROOT_DIRECTORY)
        except shutil.Error as e:
            print('Error: %s' % e)
        # eg. source or destination doesn't exist
        except IOError as e:
            print('Error: %s' % e.strerror)

    def setHostname(self):
        """"
        Setta hostname
        """
        print 'setHostname'
        if Glob.DEBUG: return
        self.SetStatusText(_("Set hostname"))
        f = open('%s/etc/hostname' % Glob.INST_ROOT_DIRECTORY, 'w')
        f.write("%s\n" % Glob.HOSTNAME)
        f.close()
        f = open('%s/etc/hosts' % Glob.INST_ROOT_DIRECTORY, 'w')
        f.write("127.0.0.1       localhost %s\n::1             localhost ip6-localhost ip6-loopback\nfe00::0         ip6-localnet\nff00::0         ip6-mcastprefix\nff02::1         ip6-allnodes\nff02::2         ip6-allrouters\n" % Glob.HOSTNAME)
        f.close()

    def updateMinidlna(self):
        """
        Setta minidlna.conf se esiste
        """
        if not os.path.isfile('%s/etc/minidlna.conf' % Glob.INST_ROOT_DIRECTORY): return
        print 'updateMinidlna'
        if Glob.DEBUG: return
        edsub('%s/etc/minidlna.conf' % Glob.INST_ROOT_DIRECTORY, 'live-user', Glob.USER)

    def installGrub(self):
        """
        Installa grub
        """
        print 'installGrub'
        if Glob.DEBUG: return
        self.SetStatusText(_("Install grub"))
        for dir in ['dev', 'sys', 'proc']:
            Glob.PROC = runProcess("mount -B /%s %s/%s" % (dir, Glob.INST_ROOT_DIRECTORY, dir))
            if Glob.PROC.returncode: self.checkError()
        Glob.PROC = runProcess("chroot %s grub-install --no-floppy %s" % (Glob.INST_ROOT_DIRECTORY, Glob.INST_DRIVE))
        if Glob.PROC.returncode: self.checkError()
        Glob.PROC = runProcess("chroot %s update-grub" % Glob.INST_ROOT_DIRECTORY)
        if Glob.PROC.returncode: self.checkError()
        for dir in ['dev','sys', 'proc']:
            Glob.PROC = runProcess("umount %s/%s" % (Glob.INST_ROOT_DIRECTORY, dir))
            if Glob.PROC.returncode: self.checkError()

    def upgradeSystem(self):
        """
        """
        print "upgradeSystem"
        if Glob.DEBUG: return
        self.SetStatusText(_("Upgrade system"))
        runProcess("apt-get --yes update")
        runProcess("apt-get --yes -V upgrade")

    def endInstall(self):
        """
        Finisce l'installazione
        """
        print 'endInstall'
        if Glob.DEBUG: return
        if Glob.PROC:
            if Glob.PROC.returncode == None:
                Glob.PROC.terminate()
        proc = subprocess.Popen(["pgrep", "rsync"], stdout=subprocess.PIPE)
        for pid in proc.stdout:
            os.kill(int(pid), signal.SIGKILL)
            try:
                os.kill(int(pid), 0)
#                raise Exception(""""wasn't able to kill the process\nHINT:use signal.SIGKILL or signal.SIGABORT""")
            except OSError as ex:
                continue

        Glob.PROC = runProcess("sync")
        if Glob.PROC.returncode: self.checkError()
        if Glob.INSTALLED_OK:
            if os.path.exists('%s/usr/local/share/install_distro' % Glob.INST_ROOT_DIRECTORY):
                shutil.rmtree('%s/usr/local/share/install_distro' % Glob.INST_ROOT_DIRECTORY)
            if os.path.exists('%s/usr/local/bin/install_distro' % Glob.INST_ROOT_DIRECTORY):
                os.remove('%s/usr/local/bin/install_distro' % Glob.INST_ROOT_DIRECTORY)
            if os.path.exists('%s/usr/share/applications/install_distro.desktop' % Glob.INST_ROOT_DIRECTORY):
                os.remove('%s/usr/share/applications/install_distro.desktop' % Glob.INST_ROOT_DIRECTORY)
        if isdevmount(Glob.HOME_PARTITION):
            Glob.PROC = runProcess("fuser -k %s" % Glob.HOME_PARTITION)
            Glob.PROC = runProcess("umount %s" % Glob.HOME_PARTITION)
        if isdevmount(Glob.ROOT_PARTITION):
            Glob.PROC = runProcess("fuser -k %s" % Glob.ROOT_PARTITION)
            Glob.PROC = runProcess("umount %s" % Glob.ROOT_PARTITION)
        Glob.FILE_LOG.close()

    def checkError(self):
        """ controlla errori """
        print 'checkError'
        logging.debug("Subprocess error:%s" % Glob.PROC.returncode)
        return True

#-----------------------------------------------------------------------
class MyApp(wx.App):
    """
    """
    def OnInit(self):
        """ """
        self.checkRoot()
        parser = OptionParser("usage: %prog [options] args")
        parser.add_option("-d", "--inst-drive", metavar="DRIVE", help="Drive of installation")
        parser.add_option("-g", "--groups", metavar="GROUPS", help="Groups of user")
        (options, args) = parser.parse_args()
        # setta i parametri opzionali
        Glob.INST_DRIVE = options.inst_drive
        if options.groups:
            Glob.GROUPS = options.groups
        #
        if ispathmount(Glob.INST_ROOT_DIRECTORY):
            Glob.PROC = runProcess("umount %s" % Glob.INST_ROOT_DIRECTORY)
        #
        Glob.FILE_LOG = open(Glob.PATH_FILE_LOG, 'w')
        Glob.FILE_LOG.write(time.strftime("%a, %d %b %Y %H:%M:%S +0000\n", time.gmtime()))
        icon = wx.Icon(Glob.PATH_PROG_ICON, wx.BITMAP_TYPE_PNG)
        self.frame = MyFrame(None)
        self.frame.SetIcon(icon)
        self.frame.Centre()
        self.frame.Show()
        self.SetTopWindow(self.frame)
        return True

    def checkRoot(self):
        """
        """
        if os.getuid() != 0:
            wx.MessageDialog(None, _("You need to have root privileges to run this script.\nPlease try again, this time using 'sudo'. Exiting."), _("Attention"), wx.OK).ShowModal()
            exit()

#-----------------------------------------------------------------------
def main():
    """
    """
    app = MyApp()
    app.MainLoop()

#-----------------------------------------------------------------------
if __name__ == '__main__':
    main()
