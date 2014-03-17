#!/usr/bin/env python
# -*- coding: latin-1 -*-

import sys, re, os, crypt, time, random, string, subprocess, wx, parted, parted.disk, logging
from optparse import OptionParser

# variabili globali
_ = wx.GetTranslation
padding = 5 # pixels fra gli oggetti delle box

#
def getsalt(chars=string.letters + string.digits):
  """ generate a random 2-character 'salt' """
# generate a random 2-character 'salt'
  return random.choice(chars) + random.choice(chars)

def ismount(device):
  """ controlla se il device è montato """
  for l in file('/proc/mounts'):
    d = l.split()
    if d[0] == device: return d[1]
  return ''

def blkid(device):
  """ chiama il comando blkid per ottenere l'UUID """
  command = "/sbin/blkid -o value -s UUID %s" % device
  proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
  return proc.stdout.readline().strip()

def crypt_p(password):
  """ ritorna una stringa con la password criptata """
  return crypt.crypt(password, getsalt())

def grep(namefile, string):
  """ ritorna la prima linea che contiene la stringa 'string' nel file 'namefile' """
  f = open(namefile, 'r')
  for line in f:
    if re.search(string, line):
      return line,

def edsub(namefile, string, substring, one=False):
  """ sostituisce tutte le occorrenze di 'string ' con 'substring' e la scrive nel file 'namefile' 
  Se one=True dopo la prima sostituzione esce. """
  with open(namefile, 'r') as sources:
    lines = sources.readlines()
  with open(namefile, 'w') as sources:
    for line in lines:
      sources.write(re.sub(string, substring, line))
      if one: return

def runProcess(command):
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
#

class Logger(object):
  """ Class Logger """
  @staticmethod
  def initLogging(stream, log_level):
    consoleFormat = "%(asctime)s %(levelname)s %(funcName)s %(message)s %(pathname)s %(lineno)d"
    dateFormat = "%H:%M:%S"
    logging.basicConfig(stream=stream, level=log_level, format=consoleFormat, datefmt=dateFormat)

class Glob:
  """ Class Glob """
  # action constants in alphabet order
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
  USE_HOME              = False
  CONSOLE_LOG_LEVEL     = logging.DEBUG
  PROC_ERROR            = 0
  PATH_FILE_LOG         = 'install.log'
  FILE_LOG              = ''

  # user's home dir - works for windows/unix/linux
  HOME_DIR = os.getenv('USERPROFILE') or os.getenv('HOME')

  PID = os.getpid()

  # will be set by main function
  PACKAGE_VERSION     = ''
  PACKAGE_BUGREPORT   = ''
  PACKAGE_URL         = ''
  PACKAGE_TITLE       = ''
  PACKAGE_COPYRIGHT   = ''
  DEFAULT_CONFIG_FILE = ''
  LICENSE             = ""

 
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
        print 'Problema sul file %s.' % self.file.name
        pass


class MyPanel(wx.Panel):
  """ """
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
    """ """
    #img = wx.Image("image_h.png", wx.BITMAP_TYPE_ANY)
    #sb = wx.StaticBitmap(self, -1, wx.BitmapFromImage(img))
    self.sizer = wx.StaticBoxSizer(wx.StaticBox(self, -1, _(' Inizializzazione ')), wx.VERTICAL)
    
    grid_sizer1 = wx.FlexGridSizer(7, 2, padding, padding)
    grid_sizer2 = wx.FlexGridSizer(7, 2, padding, padding)
    horizontal_sizer = wx.BoxSizer(wx.HORIZONTAL)
    self.SetSizer(self.sizer)
    
    self.part_root = wx.ComboBox(self, -1, choices=self.parts, style=wx.CB_READONLY)
    self.part_home = wx.ComboBox(self, -1, choices=self.parts, style=wx.CB_READONLY)
    self.disk_inst = wx.ComboBox(self, -1, choices=self.disks, style=wx.CB_READONLY)
    self.check_format_home = wx.CheckBox(self, -1, _("Formattare la partizione di home"))
    self.check_format_home.SetValue(Glob.FORMAT_HOME)
    self.check_autologin =  wx.CheckBox(self, -1, _("Login automatico"))
    self.check_autologin.SetValue(Glob.AUTOLOGIN)
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
    self.sizer.AddWindow(wx.StaticText(self, -1, _('Le opzioni contrassegnate da un asterisco sono necessarie')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    # 1 riga
    grid_sizer1.Add(wx.StaticText(self, -1, _('Partizione di root (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer1.Add(self.part_root, 0, wx.EXPAND|wx.ALL, padding)
    # 2
    grid_sizer1.Add(wx.StaticText(self, -1, _('Partizione di home')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer1.Add(self.part_home, 0, wx.EXPAND|wx.ALL, padding)
    # 3
    grid_sizer1.Add(self.check_format_home, 0, wx.EXPAND|wx.ALL, padding)
    grid_sizer1.Add(self.check_autologin, 0, wx.EXPAND|wx.ALL, padding)
    # 4
    grid_sizer1.Add(wx.StaticText(self, -1, _('Drive di installazione (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer1.Add(self.disk_inst, 0, wx.EXPAND|wx.ALL, padding)
    # 5 
    grid_sizer1.Add(wx.StaticText(self, -1, _('Nome utente (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer1.Add(self.user, 0, wx.EXPAND|wx.ALL, padding)
    # 6
    grid_sizer1.Add(wx.StaticText(self, -1, _('Password utente (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer1.Add(self.password_user, 0, wx.EXPAND|wx.ALL, padding)
    # 7
    grid_sizer1.Add(wx.StaticText(self, -1, _('Password superuser (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer1.Add(self.password_root, 0, wx.EXPAND|wx.ALL, padding)
    # 1
    grid_sizer2.Add(wx.StaticText(self, -1, _('Locale')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer2.Add(self.locale, 0, wx.EXPAND|wx.ALL, padding)
    # 2
    grid_sizer2.Add(wx.StaticText(self, -1, _('Lingua')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer2.Add(self.lang, 0, wx.EXPAND|wx.ALL, padding)
    # 3
    grid_sizer2.Add(wx.StaticText(self, -1, _('Tastiera')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer2.Add(self.keyboard, 0, wx.EXPAND|wx.ALL, padding)
    # 4
    grid_sizer2.Add(wx.StaticText(self, -1, _('Hostname (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
    grid_sizer2.Add(self.hostname, 0, wx.EXPAND|wx.ALL, padding)
    # 5
    grid_sizer2.Add(wx.StaticText(self, -1, _('Gruppi (*)')), 0, wx.ALIGN_LEFT|wx.ALL, padding)
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
    
    #self.sizer.Add(sb, 0, wx.ALIGN_CENTER|wx.ALL, padding)
    self.sizer.Add(horizontal_sizer, 0, wx.EXPAND|wx.ALL, padding)
    self.sizer.Fit(self)
  
  def initDisks(self):
    """ """
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
    """ """
    #--------------------------------------
    Glob.ROOT_PARTITION = self.part_root.GetValue()
    Glob.HOME_PARTITION = self.part_home.GetValue()
    if Glob.HOME_PARTITION:
      Glob.UUID_HOME_PARTITION = blkid(Glob.HOME_PARTITION)
      Glob.FORMAT_HOME = self.check_format_home.GetValue()
    Glob.AUTOLOGIN = self.check_autologin.GetValue()
    if Glob.SWAP_PARTITION:
      Glob.UUID_SWAP_PARTITION = blkid(Glob.SWAP_PARTITION)
    Glob.INST_DRIVE = self.disk_inst.GetValue()
    Glob.USER = self.user.GetValue()
    if self.password_user.GetValue():
      try:
        Glob.CRYPT_USER_PASSWORD = crypt_p(self.password_user.GetValue())
      except UnicodeEncodeError:
        wx.MessageBox(_(" Hai inserito un carattere illegale nel campo 'Password utente'. "), _("Attenzione"), wx.OK | wx.ICON_INFORMATION)
        return
    else: Glob.CRYPT_USER_PASSWORD = ''
    if self.password_root.GetValue():
      try:
        Glob.CRYPT_ROOT_PASSWORD = crypt_p(self.password_root.GetValue())
      except UnicodeEncodeError:
        wx.MessageBox(_(" Hai inserito un carattere illegale nel campo 'Password superuser'. "), _("Attenzione"), wx.OK | wx.ICON_INFORMATION)
        return
    else: Glob.CRYPT_ROOT_PASSWORD = ''
    Glob.LOCALE = self.locale.GetValue()
    Glob.LANG = self.lang.GetValue()
    Glob.KEYBOARD = self.lang.GetValue()
    Glob.HOSTNAME = self.hostname.GetValue()
    Glob.GROUPS = self.groups.GetValue()
    Glob.TIMEZONE = self.timezone.GetValue()
    Glob.SHELL_USER = self.shell.GetValue()
    
    #-------------------------------------
    logging.debug("distro:%s, root partition:%s, uuid root partition:%s, home partition:%s, format home:%s, autologin:%s, uuid home partition:%s, swap partition:%s, uuid swap partition:%s, drive inst:%s, dir root inst:%s, user:%s, crypt user password:%s, crypt root password:%s, locale:%s, lang:%s, keyboard:%s, hostname:%s, groups:%s, timezone:%s, shell user:%s" % (Glob.DISTRO, Glob.ROOT_PARTITION, Glob.UUID_ROOT_PARTITION, Glob.HOME_PARTITION, Glob.FORMAT_HOME, Glob.AUTOLOGIN, Glob.UUID_HOME_PARTITION, Glob.SWAP_PARTITION, Glob.UUID_SWAP_PARTITION, Glob.INST_DRIVE, Glob.INST_ROOT_DIRECTORY, Glob.USER, Glob.CRYPT_USER_PASSWORD, Glob.CRYPT_ROOT_PASSWORD, Glob.LOCALE, Glob.LANG, Glob.KEYBOARD, Glob.HOSTNAME, Glob.GROUPS, Glob.TIMEZONE, Glob.SHELL_USER))
    return True

class MyPanelInfo(wx.Panel):
  def __init__(self, parent):
    wx.Panel.__init__(self, parent)
    self.info = wx.TextCtrl(self, size=(800, 500), style=wx.TE_MULTILINE|wx.TE_READONLY|wx.HSCROLL|wx.TE_RICH)
    self.info.SetForegroundColour(wx.BLACK)
    self.info.SetBackgroundColour(wx.SystemSettings.GetColour(wx.SYS_COLOUR_BACKGROUND))
    #self.continua = wx.Button(self, "Continua")
    sizer = wx.StaticBoxSizer(wx.StaticBox(self, -1, _(' Informazioni ')), wx.VERTICAL)
    self.SetSizer(sizer)
    sizer.Add(self.info, 0, wx.EXPAND|wx.ALL, padding)
  
  def updateInfo(self, string):
    self.info.Clear()
    self.info.WriteText(string)

class MyFrame(wx.Frame):
  """ """
  def __init__(self, parent=None, ID=-1, title=_(_("Install distro"))):
    wx.Frame.__init__(self, parent, ID, title)
    self.panel = MyPanel(self)
    self.panel_info = MyPanelInfo(self)
    self.panel_info.Hide()
    self.runInst = False
    self.CreateStatusBar()
    self.SetStatusText("Benvenuto nel programma di installazione di Livedevelop")
    self.__DoLayout()
  
  def __DoLayout(self):
    self.sizer_vertical = wx.BoxSizer(wx.VERTICAL)
    
    self.sizer = wx.BoxSizer(wx.HORIZONTAL)
    log = wx.TextCtrl(self, wx.ID_ANY, size=(-1,120), style=wx.TE_MULTILINE|wx.TE_READONLY|wx.HSCROLL|wx.TE_RICH)
    log.SetForegroundColour(wx.WHITE)
    log.SetBackgroundColour(wx.BLACK)
    self.redir = RedirectText(log, Glob.FILE_LOG)
    sys.stdout = self.redir
    Logger.initLogging(self.redir, Glob.CONSOLE_LOG_LEVEL)
    self.sizer_vertical.Add(self.panel, 1, wx.EXPAND|wx.ALL, padding)
    self.sizer_vertical.Add(self.panel_info, 1, wx.EXPAND|wx.ALL, padding)
    self.sizer_vertical.Add(log, 0, wx.EXPAND|wx.ALL, padding)
    
    self.installa = wx.Button(self, -1, "Installa")
    self.installa.Bind(wx.EVT_BUTTON, self.onClickInstalla)
    self.esci = wx.Button(self, wx.ID_EXIT)
    self.esci.Bind(wx.EVT_BUTTON, self.onClickEsci)
    sizer_buttons = wx.BoxSizer(wx.VERTICAL)
    sizer_buttons.Add(self.installa, 0, wx.EXPAND|wx.ALL, padding)
    sizer_buttons.Add(self.esci, 0, wx.EXPAND|wx.ALL, padding)
    self.sizer.Add(self.sizer_vertical, 0, wx.EXPAND|wx.ALL, padding)
    self.sizer.Add(sizer_buttons, 0, wx.EXPAND|wx.ALL, padding)
    self.SetSizer(self.sizer)
    self.sizer.Fit(self)
  
  def onClickInstalla(self, evt):
    self.installa.Disable()
    if not self.panel.SetGlob():
      self.installa.Enable()
    else:
      self.goInstall()
  
  def onClickEsci(self, evt):
    """ """
    if self.runInst:
      result = wx.MessageDialog(None, _("Attenzione! Installazione in corso! Sei Sicuro?"), _("Attenzione"), wx.YES_NO|wx.ICON_QUESTION).ShowModal()
      if result == wx.ID_YES:
        self.endInstall()
        self.Close()
      else: return
    else:
      self.endInstall()
      self.Close()
    
  def goInstall(self):
    """ """
    print 'GoInstall'
    self.SetStatusText('Inizio installazione...')
    if not self.checkRequisites():
      #---- codice controllo
      pass
      #self.installa.Enable()
      #return
      #----
    self.panel.Hide()
    self.panel_info.Show()
    self.sizer.Fit(self)
    self.panel_info.updateInfo(" Nome Distro:\t\t\t\t%s\n Root partition:\t\t\t%s\n UUID root partition:\t\t%s\n Home partition:\t\t\t%s\n Format home:\t\t\t%s\n Autologin:\t\t\t\t%s\n UUID home partition:\t\t%s\n Swap partition:\t\t\t%s\n UUID swap partition:\t\t%s\n Drive installation:\t\t\t%s\n Directory root installation:\t%s\n Name User:\t\t\t\t%s\n Crypt user password:\t\t%s\n Crypt root password:\t\t%s\n Locale:\t\t\t\t\t%s\n Lang:\t\t\t\t\t%s\n Keyboard:\t\t\t\t%s\n Hostname:\t\t\t\t%s\n Groups:\t\t\t\t\t%s\n Timezone:\t\t\t\t%s\n Shell user:\t\t\t\t%s\n" % (Glob.DISTRO, Glob.ROOT_PARTITION, Glob.UUID_ROOT_PARTITION, Glob.HOME_PARTITION, Glob.FORMAT_HOME, Glob.AUTOLOGIN, Glob.UUID_HOME_PARTITION, Glob.SWAP_PARTITION, Glob.UUID_SWAP_PARTITION, Glob.INST_DRIVE, Glob.INST_ROOT_DIRECTORY, Glob.USER, Glob.CRYPT_USER_PASSWORD, Glob.CRYPT_ROOT_PASSWORD, Glob.LOCALE, Glob.LANG, Glob.KEYBOARD, Glob.HOSTNAME, Glob.GROUPS, Glob.TIMEZONE, Glob.SHELL_USER))
    self.runInst = True
    self.createRootAndMountPartition()
    self.createHomeAndMountPartition()
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
    self.runInst = False
    #self.panel_info.updateInfo("\t<--Installazione terminata con successo-->")
  
  def checkRequisites(self):
    """ controlla che i requisiti siano rispettati """
    print 'checkRequisites'
    self.SetStatusText('Controllo i prerequisiti')
    if (not Glob.ROOT_PARTITION) or (not Glob.INST_DRIVE) or (not Glob.USER) or (not Glob.CRYPT_USER_PASSWORD) or (not Glob.CRYPT_ROOT_PASSWORD) or (not Glob.HOSTNAME) or (not Glob.GROUPS):
      wx.MessageBox(_("Non tutte le opzioni necessarie sono state assegnate. (Tutte le opzioni contrassegnate da un asterisco sono obbligatorie)"), _("Attenzione"), wx.OK | wx.ICON_INFORMATION)
      return False
    for part in (Glob.ROOT_PARTITION, Glob.HOME_PARTITION, Glob.SWAP_PARTITION):
      d = ismount(part)
      if d:
        wx.MessageBox(_("Device %s montato in %s." % (part, d)), _("Errore"), wx.OK|wx.ICON_ERROR)
        return False
    if Glob.ROOT_PARTITION == Glob.HOME_PARTITION:
      wx.MessageBox(_("La partizione di root e la partizione di home coincidono."), _("Errore"), wx.OK|wx.ICON_ERROR)
      return False
    return True
  
  def createRootAndMountPartition(self):
    """ """
    print 'createRootAndMountPartition'
    self.SetStatusText('Creo il root filesystem e lo monto')
    proc = runProcess("mkfs -t %s %s" % (Glob.TYPE_FS, Glob.ROOT_PARTITION))
    Glob.PROC_ERROR = proc.returncode
    if not Glob.PROC_ERROR:
      Glob.UUID_ROOT_PARTITION = blkid(Glob.ROOT_PARTITION)
    else: self.checkError()
    logging.debug("uuid root partition:%s" % Glob.UUID_ROOT_PARTITION)
    if not Glob.PROC_ERROR: 
      proc = runProcess("mkdir -p %s" % (Glob.INST_ROOT_DIRECTORY))
      Glob.PROC_ERROR = proc.returncode
    else: self.checkError()
    if not Glob.PROC_ERROR: 
      proc = runProcess("mount %s %s" % (Glob.ROOT_PARTITION, Glob.INST_ROOT_DIRECTORY))
      Glob.PROC_ERROR = proc.returncode
    else: self.checkError()
  
  def createHomeAndMountPartition(self):
    """ """
    print 'createHomeAndMountPartition'
    if not Glob.HOME_PARTITION:
      return
    self.SetStatusText('Creo e monto la HOME directory')
    if Glob.FORMAT_HOME:
      proc = runProcess("mkfs -t %s %s" % (Glob.TYPE_FS, Glob.HOME_PARTITION))
      Glob.PROC_ERROR = proc.returncode
      if Glob.PROC_ERROR: self.checkError()
    Glob.UUID_HOME_PARTITION = blkid(Glob.HOME_PARTITION)
    print Glob.UUID_HOME_PARTITION
    proc = runProcess("mkdir -p %s" % (Glob.INST_ROOT_DIRECTORY + '/home'))
    Glob.PROC_ERROR = proc.returncode
    if not Glob.PROC_ERROR: 
      proc = runProcess("mount %s %s" % (Glob.HOME_PARTITION, Glob.INST_ROOT_DIRECTORY + '/home'))
      Glob.PROC_ERROR = proc.returncode
      if Glob.PROC_ERROR: self.checkError()
    else: self.checkError()
  
  def copyRoot(self):
    """ """
    print 'copyRoot'
    self.SetStatusText('Copio i files (Ci può volere un pò di tempo)...')
    proc = runProcess("rsync -av %s/* %s" % (Glob.SQUASH_FS, Glob.INST_ROOT_DIRECTORY))
    Glob.PROC_ERROR = proc.returncode
    if Glob.PROC_ERROR: self.checkError()
  
  def addUser(self):
    """ """
    print 'addUser'
    self.SetStatusText('Aggiungo l\'utente')
    proc = runProcess("chroot %s useradd -G %s -s %s -m -p %s %s" % (Glob.INST_ROOT_DIRECTORY, Glob.GROUPS, Glob.SHELL_USER, Glob.CRYPT_USER_PASSWORD, Glob.USER))
    Glob.PROC_ERROR = proc.returncode
    if Glob.PROC_ERROR: self.checkError()
  
  def changeRootPassword(self):
    """ """
    print 'changeRootPassword'
    self.SetStatusText('Cambio la password di root')
    proc = runProcess("chroot %s bash -c \"echo root:%s | chpasswd -e\"" % (Glob.INST_ROOT_DIRECTORY, Glob.CRYPT_ROOT_PASSWORD))
    Glob.PROC_ERROR = proc.returncode
    if Glob.PROC_ERROR: self.checkError()
  
  def addSudoUser(self):
    """ """
    print 'addSudoUser'
    self.SetStatusText('Aggiungo l\'utente al gruppo \'sudo\'')
    proc = runProcess("chroot %s gpasswd -a %s sudo" % (Glob.INST_ROOT_DIRECTORY, Glob.USER))
    Glob.PROC_ERROR = proc.returncode
    if Glob.PROC_ERROR: self.checkError()
  
  def setAutologin(self):
    """ """
    if not Glob.AUTOLOGIN: return
    print 'setAutologin'
    self.SetStatusText('Setto l\'autologin')
    if not os.path.isfile('%s/etc/X11/default-display-manager' % Glob.INST_ROOT_DIRECTORY): return
    f = open('%s/etc/X11/default-display-manager' % Glob.INST_ROOT_DIRECTORY, 'r')
    dm = f.readline().split()
    f.close()
    if (dm == '/usr/sbin/gdm3'):
      line = grep('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, 'AutomaticLoginEnable')
      if line: edsub('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, line, 'AutomaticLoginEnable = true')
      line = grep('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, 'AutomaticLogin')
      if line: edsub('%s/etc/gdm3/daemon.conf' % Glob.INST_ROOT_DIRECTORY, line, 'AutomaticLogin = %s' % Glob.USER)
    elif (dm == '/usr/sbin/lightdm'):
      line = grep('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, 'autologin-user')
      if line: edsub('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, line, 'autologin-user=%s' % Glob.USER)
      line = grep('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, 'autologin-user-timeout')
      if line: edsub('%s/etc/lightdm/lightdm.conf' % Glob.INST_ROOT_DIRECTORY, line, 'autologin-user-timeout=0')
  
  def createFstab(self):
    """ """
    print 'createFstab'
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
    """ """
    print 'setLocale'
    self.SetStatusText('Setto locale')
    line = grep('%s/etc/locale.gen' % Glob.INST_ROOT_DIRECTORY, Glob.LOCALE)
    if line: edsub('%s/etc/locale.gen' % Glob.INST_ROOT_DIRECTORY, line, Glob.LOCALE)
    line = grep('%s/etc/default/keyboard' % Glob.INST_ROOT_DIRECTORY, 'XBLAYOUT')
    if line: edsub('%s/etc/default/keyboard' % Glob.INST_ROOT_DIRECTORY, line, 'XBLAYOUT=\"%s\"' % Glob.KEYBOARD)
    proc = runProcess("chroot %s locale-gen" % Glob.INST_ROOT_DIRECTORY)
    Glob.PROC_ERROR = proc.returncode
    if not Glob.PROC_ERROR:
      proc = runProcess("chroot %s update-locale LANG=%s" % (Glob.INST_ROOT_DIRECTORY, Glob.LANG))
      Glob.PROC_ERROR = proc.returncode
      if Glob.PROC_ERROR: self.checkError()
    else: self.checkError()
  
  def setTimezone(self):
    """" """
    print 'setTimezone'
    self.SetStatusText('Setto timezone')
    f = open('%s/etc/timezone' % Glob.INST_ROOT_DIRECTORY, 'w')
    f.write('%s\n' % Glob.TIMEZONE)
    f.close()
  
  def setHostname(self):
    """" """
    print 'setHostname'
    self.SetStatusText('Setto hostname')
    f = open('%s/etc/hostname' % Glob.INST_ROOT_DIRECTORY, 'w')
    f.write("%s\n" % Glob.HOSTNAME)
    f.close()
  
  def updateMinidlna(self):
    """ """
    if not os.path.isfile('%s/etc/minidlna.conf' % Glob.INST_ROOT_DIRECTORY): return
    print 'updateMinidlna'
    edsub('%s/etc/minidlna.conf' % Glob.INST_ROOT_DIRECTORY, 'live-user', Glob.USER)
  
  def installGrub(self):
    """ """
    print 'installGrub'
    self.SetStatusText('Installo grub')
    for dir in ['dev', 'sys', 'proc']:
      proc = runProcess("mount -B /%s %s/%s" % (dir, Glob.INST_ROOT_DIRECTORY, dir))
      Glob.PROC_ERROR = proc.returncode
      if Glob.PROC_ERROR: self.checkError()
    proc = runProcess("chroot %s grub-install --no-floppy %s" % (Glob.INST_ROOT_DIRECTORY, Glob.INST_DRIVE))
    Glob.PROC_ERROR = proc.returncode
    if Glob.PROC_ERROR: self.checkError()
    proc = runProcess("chroot %s update-grub" % Glob.INST_ROOT_DIRECTORY)
    Glob.PROC_ERROR = proc.returncode
    if Glob.PROC_ERROR: self.checkError()
    for dir in ['dev','sys', 'proc']:
      proc = runProcess("umount %s/%s" % (Glob.INST_ROOT_DIRECTORY, dir))
      Glob.PROC_ERROR = proc.returncode
      if Glob.PROC_ERROR: self.checkError()
  
  def endInstall(self):
    """ """
    print 'endInstall'
    proc = runProcess("sync")
    Glob.PROC_ERROR = proc.returncode
    if Glob.PROC_ERROR: self.checkError()
    if ismount(Glob.HOME_PARTITION):
      proc = runProcess("umount %s" % Glob.HOME_PARTITION)
      Glob.PROC_ERROR = proc.returncode
    if ismount(Glob.ROOT_PARTITION):
      proc = runProcess("umount %s" % Glob.ROOT_PARTITION)
      Glob.PROC_ERROR = proc.returncode
    Glob.FILE_LOG.close()
  
  def checkError(self):
    """ """
    print 'checkError'
    return True


class MyApp(wx.App):
  """ """
  def OnInit(self):
    """ """
    parser = OptionParser("usage: %prog [options] args")
    parser.add_option("-d", "--inst-drive", metavar="DRIVE", help="Drive of installation")
    parser.add_option("-g", "--groups", metavar="GROUPS", help="Groups of user")
    (options, args) = parser.parse_args()
    # setta i parametri opzionali
    Glob.INST_DRIVE = options.inst_drive
    if options.groups: 
      Glob.GROUPS = options.groups
    #
    Glob.FILE_LOG = open(Glob.PATH_FILE_LOG, 'w')
    Glob.FILE_LOG.write(time.strftime("%a, %d %b %Y %H:%M:%S +0000\n", time.gmtime()))
    self.frame = MyFrame(None)
    self.frame.Centre()
    self.frame.Show()
    self.SetTopWindow(self.frame)
    return True

def main():
  """ """
  app = MyApp()
  app.MainLoop()

if __name__ == '__main__':
  main()
