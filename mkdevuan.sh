#!/bin/bash

DEBUG="yes"

########################################################################
# environment: variabili script
########################################################################

TEMP_REPOSITORY="repo"
LOG="$(pwd)/mkdevuan.log"
PATH_SCRIPTS=$(dirname $0)
FRONTEND=noninteractive
VERBOSE=
STAGE=1
CLEAN=0
COMPILE_BOOTSTRAP=1
DEBOOTSTRAP_BIN=/usr/sbin/debootstrap
SNAPSHOT=
CLEAN_SNAPSHOT=0
KEYBOARD=it
LOCALE="it_IT.UTF-8 UTF-8"
LANG="it_IT.UTF-8"
TIMEZONE="Europe/Rome"
LANGUAGE="italian"
ARCHIVE=$(pwd)
DE=kde
ARCH=amd64
DIST=ascii
ROOT_DIR=devuan
PACKAGES_FILE="packages_xfce"
INCLUDES="linux-image-$ARCH grub-pc locales console-setup ssh firmware-linux wireless-tools devuan-keyring rpl mc"
APT_OPTS="--assume-yes"
INSTALL_DISTRO_DEPS="git sudo parted rsync squashfs-tools xorriso live-boot live-boot-initramfs-tools live-config-sysvinit live-config syslinux isolinux"
ISO_DEBUG=1
if [ $ISO_DEBUG == 1 ]; then
    PACKAGES="shellcheck $PACKAGES" 
fi

USERNAME=devuan
PASSWORD=devuan
SHELL=/bin/bash
HOSTNAME=devuan
CRYPT_PASSWD=$(perl -e 'printf("%s\n", crypt($ARGV[0], "password"))' "$PASSWORD")
MIRROR=http://pkgmaster.devuan.org/merged
SPLASH="iVBORw0KGgoAAAANSUhEUgAAAoAAAAHgCAYAAAA10dzkAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
WXMAAA3XAAAN1wFCKJt4AAAAB3RJTUUH4AUSEC4NgfB3pwAAIABJREFUeNrt3eti4kqaZuE3TgLX
/c6PuYa5322kiC9ifkjYYGOnsREIaT3d2VWdtSsP2MAiju7//p//1wQAuIOm/tCr1qrdfifvg4a+
V7fbzf47W62yIauYqVVe9ufiY1CXonwIcs7xgGCxIg8BANyL026/P/uZEO/zMhy8V9h3CrWpFlPJ
RbVWviQ3VovpYFXee6UUFGIkBEEAAgA+hFkIdw3Q4J1C5xVTlBVTPoZgY1TwZlpTNVNvJuezYgiK
KcoHL4kYBAEIAHgQ55xiioopqFpVzlmlEII3b8HalGtRLqYQvBLTwyAAAQALSEH5ELQLXrE2WSkq
ubBO8OYl2GTFZMWm6eGokJgeBgEIAHhwCI7Tw51SSrJSlLOpmvHQ3FitVX0/yGWmh0EAAgCWkoLO
KaakEKOqjesEzZgevjWmh0EAAgAWGYIhRoU4rhMsuXCMzCwlyPQwCEAAwPJSUD4EdSEo1Ko67R5u
HCNzc+fTw1GhCwqe6WEQgACAeySfc2oXpnyD9wrdOEpVSlEeTLWyTvDWxunhrFyKQvRKKSmwThAE
IABgTsdDor+chjxZJ2jTOsHKOsEZSrDJssnKdLh0FxVYJwgCEAAwh58GhnNOMUbFaZ3gkLOM8wRn
CcFqpv51XCcY07g203vPYwMCEADwsGSUD0H74Kd7h9kwMpdaq4Z+kMtOMYyHeXOMDAhAAMBDQzD4
oLAfN4xwsPR8Pq4T7FIiBEEAAgAea9wwMh4sXfIYgpWdwzOU4LhO8HVaJ9h1nCcIAhAA8GDOOaUu
KaY43jDCzuHZQrCa6fBq8iGM5wlGQhAEIADgwSF4tnN4KFw1N5Nqpt7eN4xEDpYGAQgAeHgITjuH
rZgGjpCZLwSnDSM552nncJwOlgYBCADAY1JQIUa9HI+QGTJ3Ds+k1abcZ+VclEJQTJENIwQgAACP
DUEfgvYvnrME51abci3Kxdg5TAACALCgEAxjCJY8hgohOIOTncMheKWOq+YIQAAAFhCCXQiKZoTg
3CFYTGZVPnh1085hQpAABABg9gjRFztUCcH7fQ1qMR3KdIQMdw4TgAAAzNoeklSr3De7U48hGKrJ
hqJsJnG7yCze7hzmLEECEACAuTjn9NOUe79mbgpBRgTnDcHpLMHUjUfIEIIEIAAAN41ASWqtqdYq
J327O/XsvuEhE4JzhmCt6g+DvC+EIAEIAMA8IRhC+PE/H7xX2O8YESQEQQDeSzv+78kLl8TOKQC4
v+OIIJtFCEEQgHN/TpVck5NUaxt3ULX2vpnNO3nniUIAuKNxs4hX5EBpQhAE4KwRKMn74zf8GICt
VlmpslrGf8p7Oe+mLfUEIQDM/dp8eqA0IXjHEExRIRGCBOAGX3Sck1wI8iGMB2y2qnY80X4ock4K
ISgEP4YhTxIAmD0EzarykGXFeFjmDMF+kM+MCBKAm3/tcQouSH68eLvWpmqmUkw5Zzk5heAV4hiM
v3uitLMp6N/wzn3abVdtPBneeac4w6nwbTp9Xq3JxaBwcv6X1Sor4+hpiEHBh5v8fiUXtdoU0xTo
f/q1xkvrYxy/trcf1X0fTa61qbWmVpveV506Oe/knJP3bvowITG6DFwOwRCCwosfX3+HomqE4Kwh
+DY1nDhHkADkBch7J++9YoqyOp66XrIpl0HOSTEE+Rh+dPr6MaByLqq1Tl3w++mNbtcpdektwPpD
PwWH1HZJqetuGje5H5TzGHk+B+3/t5v+zk1DP6hOn9KtVO1f/j5SmvusnLMkqVjR/mUv/82hsz/9
tayY5JxijDd7bKyYcimqVscZq3+FvRtHnr33b4e2EoLA5dfhGKNiDITg3UKwf7tZJIbw5Y0vIAC3
82nUO4VufMMuZipl2rWWy1skhhguRopV03DIN33hKsWUunEky72NNk3Bk4t8jGejdH96UbA6/l2P
/3+raq2Nh8FOo17voVtvE1Xt9NfUr9cCWR3j7DwIy02uTLJalfvh+imqafORVZMVk49Buy79aZQT
2EIIhhBkZVyeU2vlYZkrBKebRfIxBPmQSgBCb6NHMQbV41rBYhr6QS47xRAUuvQWX9VM/WE4i6Rb
CN69PSGd9/Lev70gttpkQ1bY724SY0POZwEWgj/ZSLNsNpRP8Vin8Bqngv/wAnmjr2stpkOt2u93
RCDw7cuvU0xJIcbxtTfnsw+/mCkE43jFHCFIAGL6RHp66fmQsyybch2DMMWomMLlSHDj1LLz41Pp
2pevceownb0opi6pP/RvP5eLKVT783q8auMO6dM/e9elp3gRqGZnI5en8pB/vc6ltXb56+rdeMht
8HLTF9dPv35t0zmUrcnMVGs9e+NqtelwGLR/2f16qhvYUgimLimmOC7xsMI9w3O+lhZTX0wlBnVd
+vbGFxCAm3LctVbiOBLYalPOeZx6PBt9ckrpOELo3n7uFo4bU96mmVuTDUVh/5cnatMwfBj9i356
8i/d+DX4auq4ThtX4klI/1Tuhw/TTx+/rp8f79NHLGncYFSGcvY90mpVGbK6fceLK/DDEOz2nUIN
3CpyB1ZMr1YVoleXWLZy99bgIVjsS5FijNq97N+fFB9eiLpdGl+s/DHKbvcmP34iPv98kIup2u+n
KEsZdxaf/Cbq0rOM/lWVDyOXH1+s8lDUrnyzaK2pfFjL+fnr+u/vFe+9un2n3S59+poZIxnAdR+A
fVC37/Tysps2VWG+z9ZNlk2vr72GQy9jLSYBiOMLkR+n8T5+MpqO/5gznmIcdyWfPlGHnPW73cZt
3PV7EkgphqcZ/bu0brHbd3In06u1Vlku130CNjubuj3ulvvt1zWm+Olr1owXVOA3H8J9CNq/7LR7
2cl7QnDuEMy5qH89aBiGqz9MgwBc58uQc+r2STrdKNGa+n6Y+QgDp5Ti2bZ9K/VXo4BW7O1ol2PA
znN+3u1dWreYpo056cPGj5yvGwX8uOA8xL+uhRk3Dn388wP4w3MqRu3/t9Nu18l5llPM2oG1KfdZ
r/+9Kg+ZECQAEXxQ+vDGflzoP+fxBTGOt5achucwXDkK2JqG4XxkLMXwJOs9LqxbDP7tMYkpfhoF
LFeMArYPj6O/QRB/3ojCCyhwi+dV7JJe/veitEucZ3eHEBz6QYf/DuMh/oQgAbjpL9aFtSitVuVh
mPFNftqlezoKaFXlirPqitn5SKV3Cl16isfcrH5et3iya9k597dRwDrLlwzAjCHYddP6wMTBxnM7
HiZ9eO2nG6IIQQJwkx+JLn/jl1JnXejvg1eM56OAefjZE7G9/bPvUrjdodIzP+A/2rWcUjw7aqVd
OQoI4AnfPEPQfr/Tft+xe/UeIWimw+sYguOAAiFIAG6n/r4edWtNmnXnlBvPCXQf7gr+wSiglfPR
P+edYvccpw/Zx13PX+1avjgKyNoVYP2cQozjRhHWB97tdXncMTywY5gA3IZPR6h8eh2a94XHB6/0
YQp6uHArxnmXNuUhn/3cx9GyJQf3x79f/ObMwvBpFLAxCghsJQNP1wd+2DiHOV6e33cM5yFzViMB
uF7VxgOhv/omd97dIaqcQhfPdiJXs2/XAlo5v1/Teferg5If9SnzbN2im0ZBv1hgd/HcxJy5XxRY
XXs0fTX9OJ7YsNPLy+7imm3c+GsxbRR5/e+gwqwLAbiyb2+VUnQ49N/eT5lS+tUVZNcadyJ/iJyv
Dj++tPbvTn/OW3y6vLxr+funS4ifRwHHRcsA1sI598+jlXwIennZabffnZ0SgHmMG0UGHV57FTaK
EIBr+JQ5HIbpjtj2TXSETyNPc4pdPFvnUqtdjJycP47++encv+X7tGv5h2cWXh4FLIwCAmuLQO+n
yGjfxMb4uvHyv/2nNdSYKQTN1B8G9YdeVo0HhAB8vvArw3QIZv5+jZ0PQbv9Tvc898NfOvz4wyhg
m9ZnnOpSfIrRv4u7lq+4seTSKGBhFBBYVwC68Ram1v69/Ox4vzDTwnd7EVfJ447hPAysDyQAnyT8
ctbhv4P6/vtRvzE0ximGR0RVTOnDKOD5FWglF7WTUS/vvcJVo38z/J1++Bpwae1fuOJqNjfdEnKq
5MJuNWClIfjT1+D3aeGOaeF7qE1Dn6f1gUwLE4DLy75xg8dh0Ot/r+qvuNUjxscdQOreNkS8G6bR
ynH078PO3+660T93/mHuLCZ/+YHw06fA5i5H+KXRv3DlHaDhwy0nrTbZwCgggHEj3DgtzG7hu3Tg
yUHSnB/4oSN4CB4QfbWpFlMuNgbfL4ao82AK8XHTqjFFlZP1ba3W8QYMtbPRS++DQvz5t5lzTi64
9xsyWpNZ/dNBq7VW1ZPH2Dkn7z5/9hl3LZ+fWfibG0uOawH71/dfK5eiUJ/lAGwAc3+I7vadolX1
fZ75TneMr++mV6tKMSh26UmOI5sXj8Cdos9qHad4X3u9vo7TvNXsR/Hn/HTQ8IfNF7kfHrbt/dIV
aMOQP4+gdddHagyff93f7qa1WjUczteBxOA//Zkujf7FP9xYEsKHu45bk304ExHApjNwvE3kZaeO
Q6Tv9FY8rk8/vB5UBo6NYQRwpuAbL+eo01l59Xcjfc6NU5BdGkNkGJT794jIuchaU0pR8Rgbv34N
uf6/GFKUP93l+uHv50NQ+MWi5xCDvPdnv+7hMCh1VSFGBe/+8ecdH38rRcNwvh7xfU3fh1DMF84s
/MPu6sujgKZQ7eopZQArzsBp3bCPXrnPP7phCX98h65NfT/IF1O3SwrBa4uXqBOANwy+VqvMqszG
qd1La89+Gn4xeqWUpt2n4zdmSklW6tl0QS2mvpgG7+Tkrl9T0iTnpa5LV0+zHl+4+kN/8T//zejf
26+7S+pPR+5aU+7HEUbvvYJ3ct6Pj4wb/x5N09egNbVaL26k6br0KcBaa+MaxtMnxg1uLIkxKIfw
/vVq41rAsCcAAXz44OuDwotXyaZh+PdGQPzdeL/wdqeFCcA/hl/JRbnYl8FxFe+UQhjj48InkuO6
keEwfFoz0mpT++3i1ioNkvYv138KOm54+Pjn8SGMG1V+HU9R2kn9xxtQ2rhx5jdHPKVdunhm4sdd
y8678ff/+2d7dV3U4cMoYDTj8ngAF18zjq//ZcjKxTjGZPa38XFauJip69L42r+RzTkE4B/ibzgM
n867+9VT3nvFFKbpzX/cNuG99i875X646YvDb3+ZS1OdktRdcXTKl9+cKcp79+dF0t57pV2agtR9
jvgPUy4p3e6T4KdAvsGmFgDr5r1Xt+/kiyn3XCl5l3f02tQfBuVg2u3SJl6jCcBfKsX+Fn/OvR2q
fO2RLqc7yEouMjvf5fqLP8q0oeN3wRZjUInhbe3KGLO3efKMZ2d5mZlKKarWxr/rd39f5+Tc+CIa
Y1SI4dup6ODd24iiv/mNJU7dLunw+r4G9HSxd4heubjxP3PuxwdO/+sDhfNuHJF2jtgEntI4ExFC
uPkHfnytmul1mhZOu+45ri8lAO//aeF3b85O8Ztp3mteHHwI6kJQm87f+8Mw3h9HvJx2+53MbDxi
xd94Qa1z4+hojGqtqbY6rvk7/p3b8bdzkpP88c/wtkDw+z972nXywas1yf8jFn8jhHHUtlqV9+4s
jo8Heler8sHfJNaC99rvd6q1ynk/LXAG8JQZOH3gD8U0MBp4pzf447RwHaeFU9AaN4kQgL9Onit4
pzCNLMVw+wOcrzmNfs4Xqdusm/v37xNcuP2fPaVZv1tCCAoX424M+VuP0s3xawJ43DtOiFF7RgPv
24HTIdKlBKVdWt0JDgTgb99gY5DL/utbKo5TvDHIxfCDo0sAAPj+wyqjgfdn06UNKSXFJ7nXngCc
MwC9137fjRsUjmf8+Sn6QpCLftrQQfQBAG6WgYwGPkCrTUM/qKzo7EAC8C8RGIL2L+MoYJs+nXlG
+gAAc2fgNBrop9HAxmjgXbyfHRiVdumpRwMJwBs8CR1rrQAA938HUozjofXDMMgyt4jcRWvKOcvM
vjlibPnYHggAwBPz087/3b47uzMe86q1qj8MGg7DU94rTAACAPD0xtMMXvY7TgC4p+nImNf/Diql
SHqeECQAAQBYiXFt+k5plzZzpdkiOrBW9a+9+kP/NLuzCUAAAFbEOaeu67Tbd3Ket/l7Ktl0eD2o
5OWPBvKdAQDACsUYtX/ZKSSmhO9pvFe41+G1ly14NJAABABgpY4bRLpdx5TwnVkx9a8HlZy1xNFA
AhAAgFVzSl3Sy8vuj/e+41rjaOCwyLWBfCcAALABPgTt/7dnSvgBxrWB/aJ2ChOAAABshHOOKeEH
aQs7N5CbQAAA2FYGKnVJzjvl4332uFMFjucGmtWH3yLCCCAAAKtujsujTTFG7V528pEp4Xt7v0Uk
P2w0kAAE/vI52n31w42zK8ywAHj469TXL0THXcIpcXD0A8pcOWcdXntVu/89zgQg8Lfn7/uP8/9E
khv/xzv5kx/HQAQw5wcynmPXBGK3T9qxLvAhqpleX3uV4b7HxbAGEP98QX3CO64fVIOXIvCtBcf/
c/LG5Jwb/4mmp7xIHFjiB7Ljc8s5yXk3Pb94jv3g1V4xRXnv1B8G1gU+4Ju37wcVM3W77i7H9TAC
iB+9oOLvj2NrTa021drGf9/GLnRObyODAG7xfGuqralNDXMchXeeJ9k/oyAE1gU+kJXxuBi7w3Ex
BCDwwCA8jUG54xQxb1LA359kJ8+xOr6ROp5jPwuDt3WBTBI+5Fu3Vh3usEGEAAQWEoNtisHjGxUb
SIBbPcc+hOA0Igh9Oc0zrgvsOC/wgV+XuTeIEIDAEmPw864SADcOQZZe6B9xN54XuN93TJ8/SDXT
4dCr5NtPCROAAIDthWBr4/4sx5Tw6eNyKTJCjNrvuUf4YV+X2tQf+pvfIMJXEwCwwXdVvS274NiY
kXNOtV6OQB+CupedfGBzyKPkXG46JUwAAgC224FNqm9b8nk8vPdfnv4QvNfLy04hEYGPUs30eqMp
YQIQALDxChxHAx0FKOkfo6HOabdjh/BjK/A2U8IEIAAA0tt0MN4fj0uB8b5DOPEgPdBxStjq76aE
CUAAAN6iR0wFn4Te16OB4w5hro97rGqm/rVXKYUABADgbxXIQ/DDRFQkAh//7Vqb+sOgPAxXffMS
gAAA4NdiitrticDHVmDT0GcdDv2P1wUSgAAA4G8RGMcI5MDox7JsOvx3+NFRMQQgAAC4UQTuiMAH
q7Xq9fXfR8UQgAtwPIT0eD8l1xMBAJ5RCEF7IvDxWlPfD8pD/jICCcCFxJ/3TsF7ee/lnFNbyyJk
x7IQANgS/xaBJMajI/C7dYF8dRZQSG+jf8HJBXfTu/4W0H/ctQkAm4xA1gQugWW7eIUcAbiUUJoi
qVmd7mJc1V9Oju80ANhgBDIdvATVTIfD+XmBvC0/3HvstdZktsIDqFpjFBAAiEA88q14Oi+wTOsC
CcAFMaurmv49zVuncZ0jAIAIxKPelMfNIf2hJwCX8zVpqrbu4+d58gN46tcwXsL+FIEdN4YsRslG
AC6pytc2+nfpxZNpYADYpuNh0UTgQqKch2AZVrfx4y1sj/8y3rDuA098ANh0BO4SEUgA4hhHqw3A
YwNOfz3Pkx7As76WNR6Dm0RgSuq6xANBAKLV1ReumsZ1jnLj2YAAgO1KXVRKRCABSAKu/G/XTtY4
OonNIMBqMKiPX37nqNsnxRR4KAjA7abf6qcVxv6bfrT7bQThjQkAlh2Bu518IAIJwK0W4Bb+mq2p
1fGHu9Nfmv4D5n+SsS4Of/oWck67fSfPvcEEINbcuvc/6obpKYAPsFh4iHivHfcGE4BY95tFmzaE
3ONpPrYmLygAsPgY4aBoAhBrb8BjAbq7/Y68ngDA8sUYOR6GAMSKC3CaNbrP3BHrkwDgeaQuKrAz
mADEeiPw3r8do4AA8Aycdrsdm0IIQKy3AN19fzuJ5YAA8AwJOO0M5pM7AYjVRuAdf7dG/wHA08RJ
CNqxHpAABOl3qwgEADyHyHpAAhBrxHgcAOD79wnWAxKAWBNG4gAAP0lA55R2ifWABCBW8qEOAIAf
iTEqdZEHggDE02MEEADw1VvEhQXbKSX5wHpAAhDPza18NN8xWwEAv34JdU611k8/t2MqmADEs3+8
W/mO3Onv5ryTn35wyTkAXBeBn4IlBKaCCUA89zN7/R/iWnufxnBujMAQPCEIAL8MQGmaCmZXMAGI
Z62jjZzJN0Vga+19VFDMYADAzz9Mt09h2DEVTADiWT/abenFa/qhkx9sggGAXwsxKEbyhQDEE1bR
2//Zzl/4tAQBAD8bL7g40ucUu44lNQQgnu8Zvb3ebW/JSwECwF8F75USdwUTgGuPpY8/vouqZ4ir
rTXQcUMIc793GjFgeRCwupfRWj+9hsYU2RBCABKFTxN/xyfzJiOQBrzLc2N6UhCBwIqe2t6r1no2
JeycU+oYBSQAVxwOV/8Atv5m4Z7sExGAfweL9592BccYuCGEAATAB6bpXza30QjYzCe7Tz/XcTg0
AQgArTU1NabbgY0IMchHRgEJQAAg/oANcUqJUUACEAAAbAprAQlAAACwOU6JtYAE4OK+LTmXDACA
WYXAKCABuNBPJwAAYKZ3WeeUEgFIAC6w/xgFBABgPiFG7ggmAJej6Tj+xzclAABzcc4pBtYCEoCL
+8ZkFBAAgDnFFHizJQAXounkm5FvSgAAZgub4OUDeUMALiYCG59IAACYnVOKTAMTgIv6lpwakA4E
AGA2IQY2gxCAy9COF5M6R/8BADAj58Q0MAG4kAA8/9bkAQEAYL4EVGQamABcSgE2NaaBAQC4gxCY
BiYAFxSB759NAADAXJyTvCdzCMAl9N+0DtAxBAgAwNwJqBi5Go4AXEQAnkYgDQgAwKwJGDxHsBGA
y4nA988mfFMCADBb5DgvTwASgIsIQLVxKSDfkAAAzMo5p8BxMATgQgrwOBc8nQzNQwIAwGyhE1gH
SAAuRD2ZB6b/AACYMXS8Y9aNAFyIdr4WEAAAzMN5T/8RgAtqwNamcwH5rgQAYLYAdGMEggBcUgbq
4yVxAADgpgmo4MgdAnBJ+dfIPwAAZo+dwGwbAbi4CuQhAABgTkwBE4AAAGBzBchOYAIQAABsSnCO
/iMAAQDA1nD9KgEIAAC2VX+SJwAJQAAAftoOLB9bzdcRWwlAvtgAgD9q3N60iiDwRMF2AtDJEYEA
AEAEwbm4+q81n9qA+zzd3PuTronnHoCFYdHbNgLQvQ3+uePbEfDwDyRO65tKeg+/939/8lPT35co
BPDol2BGADcRgOO7rWPhBu4eeG8vNe4YSO8/21pTW8v35IUVFq19/vnTKGxno/KfH4fjf1/EIgAQ
gL9tP+d4D8FM32LuZMTLvY94fbnutK0s/o5/J32IOffx56/79Qg/ACAA/9J/wAzRN353nUafe19r
MEXg+6hze4uksYhqretvG+INAAjAhyYgw3+YMfwujfY1SarH+GtvI2HtGH58PwIACMA536wltXHR
eWMNIP7yOUIn8Xeq6X1z0em/nHy/tcb3HwAsBRtCVx6Ap2++DLngj68WehvPa9OHi9bU3MdhP51t
bKD5AGCBKi/O6w3At2Mn+CJjrg8VYmc5ADzhJ/rKoNCKA7Ax5gcAAC43At5xLjYAAFh//xGABCAA
ANhW/LVWeSAIQAAAsJ0AZIMeAQgAALZWgDwGBCAAANiSWhsRSAACAIAt4Xg4AhAAAGwr/2RmPAwE
IAAA2Ez+NalxCwgBCAAAtqO2psoUMAEIAAC2o9XKBhACEAAAbEmtHABNAAIAgA1pskIAEoAAAGAz
am2qXAFHAAIAgC0FYJXYAUwAAgCAFfpik0ctnP9HAAIAgHVy7kITNpkx/UsAAgCAzWi1sgOYAAQA
AFtSMtO/BCAAANiMcfqXACQAAQDAZpgZ078EIAAA2BJ2/xKAAABgQ1prKkz/EoAAAGA7LBc1Dn8m
AAEAwDa01pSZ/iUAAQDAdpiZKtO/BCAAANiKppILDwMBCAAAtqJa5eo3AhAAAGzHNPrX2PxBAAIA
gE2oVtn8QQACAIAtYfSPAAQAABti1Rj9IwABAMB2NJUhM/pHAAIAgK2oVlUKO38JQAAAsBFNA6N/
BCAAANiOUkzG2j8CEAAAbENrTbnn1g8CEAAAbEbJRbUy+kcAAgCATbBqyjnzQBCAAABgG5pyn9Uq
Gz8IQAAAsCq1VjnnPv18yWz8IAABAMDqtNbknVP7cLxLrXU89gU3EXkIAADAUlwa+ZOa8jCoVQ59
vhVGAAEAwKKVbCqZqV8CEAAAbILVqmEYeCAIQAAAsA1NuR/Y9UsAAgCArShDYdcvAQgAALaimqln
1y8BCAAA1mU86qVd/Pn+MEiNqV8CEAAArCz+JOnjsS9Nfd+rcuTLrDgHEAAA3N3l8/6kPBQZR77M
jhFAAACwCFYKt30QgAAAYG2+mtq1aup71v0RgAAAYF1auzj121rTcMic93dHrAEEAAD34dynLR9q
06YPY93fPTECCAAAHqRp6DObPghAAACwFWUoyplNHwQgAADYRvyVwk0fBCAAANiKaqaBHb8EIAAA
2E78HQ49O34fjF3AAADgLqxWDYeB+FsARgABAMDs6hR/3PFLAAIAgA1orak/DJz1RwACAICtxN/h
lYOeCUAAALCZ+OsPxB8BCAAANhV/Vog/AhAAABB/IAABAADxh/viHEAAAHCz+GPDBwEIAAA2otbK
US8EIAAA2IrjDR/EHwEIAAA2EX+m4ZUbPghAAACwCdVM/WFQI/4IQAAAsCZNkvv0s1aK+n5Qq42H
iAAEAADr8jn+Sh7jT434IwABAMDKNeWhaBgy8UcAAgCALcTfMGTlPvNQEIAAAGD16dea+r6XZY55
IQABAMDqccYfAQgAAFamTWv5nPu82YNjXghAAACwQpfCT5LKdMyLOOaFAAQAAGvHTl8CEAAAbKj9
xs0ehc0eBCAAAFhT47WL075WTcMhs9mDAASrllgLAAAQ6klEQVQAAGtzKf5KKRq41o0ABAAAW8B6
PwIQAABsJ/043JkABAAA23E8369yvh8BCAAA1q6pDEU9U74EIA8BAAAbSL/WNHDECwhAAAC2YZzy
zaqV+AMBCADAyjHlCwIQAIDNqLVqGAZ2+YIABABgC6wUDX1mly8IQAAA1q61ppKzhqEw5QsCEACA
tatm6nvu8gUBCADABowbPYacucsXBCAAAGtntSr3g6ww6gcCEACAlWsq2TQMA6N+IAABAFi7Wqvy
MHCjBwhAAADWr6kU09BnNY53AQEIAMC6MeoHAhAAgM04jvqx1g8EIAAAq2fTqB9XuYEABABg9ZpK
LhoGzvUDAQgAwOpVMw1D5lw/EIAAAKzdeIfvOOrHHb4gAAEAWHf6yaxq4A5fEIAAAGwg/VpT7gfl
Yoz6gQAEAGDl6aeSTXnIqhzoDAIQAIB1Y5MHCEAAADaitaacs/JQmO4FAQgAwArqTnLuq/9QpZhy
z3QvCEAAAFbDea92YVSP6V4QgAAArNTH+GO6FwQgAADbSUF294IABABgK+FXrarnMGcQgAAArJ/V
KhsyhzmDAAQAYO2Od/fmnNUq4QcCEACANZffeKwL6/xAAAIAsPryY50fCEAAALbCqqkMWaVU1vmB
AAQAYM1aa8p9VrYisc4PBCAAAOsOPzZ4gAAEAGAj4VetaugHNniAAAQAYOXpJ7OqgQ0eIAABAFh/
+FWr6oesWgg/EIAAAKw+/IacZezsBQEIAMC6WTXZULi6DQQgDwEAYP3hx529AAEIANiEWqtKKSq5
cKQLQAACANYeflaKMuEHEIAAgHXjEGeAAAQAEH4ACEAAAOEHgAAEADxx+BU1rm0DCEAAAOEHgAAE
ADw5dvUCBCAAYEPhxzl+AAEIANiA8eaOomKEH0AAAgBWrKlaHdf4mUmEH0AAAgA2EH7c1QvMyzvt
ukQAAgAeG35DzrJSCT9gZs477fY7hRAIQADA/cPPiinnIjPCD7gHH4K6fVLwQRJTwACAe2VfazIz
5aGomvGAAHcSYtBuv5Nz7u3nCEAAwPzhNx3eXDm8GbirlKLSrjuLPwIQADCb8fBm455e4BGcU9cl
pS5Kcp/+YwIQAHBD7eQMPyP8gEe0n3fa7TqF+HXmEYAAgJuEHzt6gcfz3mu37+RD+PafIwABAL/P
vuPGjlxU2dELPNSlzR4EIADgtuHHxg5gMVJKSrv0o/gjAAEA12SfrDZZKSqZO3qBRXBOu11STJc3
exCAAIBfh1+1qpyzCuv7gMXw3qvbdwr/WO9HAAIAfp597Rh+RWbc0QssKv5i0G7XyXv/q/8+AQgA
+BR+x/P7qrG+D1iarw53JgABANeHX60quSgX1vcBi/TL9X4EIADgk1qn9X2ZaV5gqX56vh8BCAD4
0nF9X5nW9zXCD1isa873IwABAJ/Db5rmLWas7wOWzjmlLqrrkv465UsAAsDWou+4m7cUWWGaF3iK
9vvBfb4EIABsL+v+MSIwHtpcS1HOpsZtHcDT8CGM5/v98ogXAhAAVht8l+PveDdvKUXGoc3Ac3FO
KcarrnQjAAFgjdk3Bdy/3gxqrarFlIupmvHAAc/Wft6p23WKMejW6/0IQAB4ugGB76d5jzt5ixln
9wFPyoeg3S7d7IgXAhAAnkxr7Z+jfeNNHePavlqZ5gWe+BPe3aZ8CUAAWPT7wVdvAoz2Aat6rt95
ypcABIAnwmgfsD4+BnW7eXf5EoAA8HzZx2gfsEbOqevGu3zvPeVLAALAUrOP0T5gtbz3SrukGJeR
XgQgADy2+lQro33AmsUU1O12Dx/1IwAB4LHVp1rb+7l9jPYBq+T8+5TvIzZ6EIAAsITsa03VbLyT
16rEaB+wWo84248ABIDlZJ+sVtUyTvNW7uQF1s05pS4qpbSoKV8CEADukX2tycp0J68xxQtsgfde
3b5TWOioHwEIAFeEnFqT+8l5XWzoADYrpai06xY96kcAAsA/ou/4Iu69HyPw639aNm3oKGzoADbn
0Td6EIAAcKsX9JNP8F/FX2tNZqaSi6yyoQPYohCD0oNv9CAAAWB2xxs6bJriZUMHsMkPid6pS0mx
W97xLgQgANwo+pjiBXDkY9CuW+7xLgQgAPwl+9jFC+DUgu7xJQAB4MbRV2uVsYsXwImlH+pMAALA
9dk3ruszk2XjoGYA71Y26kcAAth89FltatzFC+ALaxz1IwABrPKT+r8i7uzoFtb1AfjitWSto34E
IID1+ea8vmo2buhgXR+Ab6x91I8ABLDyFmxqdTyvz4x1fQD+YSOjfgQggDVmn6rVaYrXVKc7fAHg
O1sa9SMAAawm+tjMAeA33m7zSHFcQ7wxBCCAp4u+Wsd1fbmYKps5AFxpvMM3Kfiw2ceAAATwFNHX
mt5v5qhVYjMHgCs579R1nWIKetY7fAlAANuIPhujr1plBy+A3wdPCkpdJ+89DwYBCGBx2Ted1WfT
HbxEH4C/8N4r7ZJiZNSPAASwyOirnNUH4FacU4pRaZc2c7QLAQiA6AOwWVs92oUABPAE0VfVOKAZ
wA0575TStg50JgABLD76zCq3cgCYRUhBqdv20S4EIICHR1+tVZYL0QdgVmzyIAABPDj6mN4FcDds
8iAAARB9ALbjfZOHF6N+BCCA+ZPv7XBmzukDcG/H+3sDmzwIQABEH4C1l59TikGxS9zkQQACmDP6
am2qVlWMa9gAPI4PQamLbPIgAAHMFX1Wm5qZSjHVSvQBeBzO9CMAAcwYfdWqzOpb9KkRfQAeWX7j
dG/okgLTvQQggBslX2tqlegDsDw+BHW7pMDuXgIQwG2ibzyupY7/2hrRB2Ax2N1LAAK4TfKpNama
yTijD8Biy4/dvQQggD9HHzt3ATwLDnMmAAH8uvnGO3erVWWb1vMRfQAWzHmnrksKkeleAhDAFc03
buIoZrJS2cQB4EnKj+leAhDANcl3tp7PrLKJA8BTCTGo65J8CDwYBCCA76KPQ5kBPDvvg7pdVOAW
DwIQwBfJx/l8AFaCWzwIQGAb8TYdseKuWtcyTu2O5/MxtQtgDeXHOj8CEFh18TXp5FOtC+GH4cbU
LoB1el/nx7EuBCCw4k+5n4Lwy1Y8Tu2aCrt2AayM915plxRZ50cAAts2Hchcq+rxFg6mdgGs7XMw
6/wIQGAtaq1yunYt3/so3/FA5sbULoDVlh/r/AhA4IkdR+VOY89fsZaPs/kAbC38QvCc50cAAk8Y
fWpy0xoVNw71fazCb4PxOMpXjA0cALbDh6DURdb5EYDAk36APXvh+teLGKN8ADYeft4rdZF7ewlA
YOXatHmDUT4AW/6wPG3wSCl+PvUABCCwguI7GeWr0ygfx7QA2Gr5jRs8QpcU2OBBAAKrSr6TK9eM
UT4AYIMHAQisMvnOzuVjLR8AvGODBwEIrCb4WtPbKN/xyjWCDwBOws97pW66wYN1fgQg8JzN12St
qk3TumaN2zcA4ALnvboUFbjBgwAEnrD4zjdvVO7YBYDvw4+r20AA4hmT72TzRimm1ti8AQD/Lj+u
bgMBiCcLvjpN6xYzVaZ1AeCq8AvRq0vs7AUBiGUnn2qdRvnYrQsAvxZimI508WJnLwhALC741CSr
08aNUpnWBYA/8CGo66ICR7qAAMSiko9DmAFglvDjLD8QgFhU8LGODwBmCj/vlbqoENnZCwIQj00+
WW1qVscjWljHBwA3x1l+IADx+1Rr7QYvHKfXrHEeHwDMG36c5QcCEH+Ov98FX2t6W79nheADgHuE
X0xRKSXCDwQgfh57ks5eNH7+AvIefK228V7dViU2bgDA/LxTClGhiwoc4gwCENd9cvRXjNBNV6zV
kzV87NQFgDu/cI+3d4zhxyHOIABx1mpNTT8Yzfs2/k6Db9yp2wg+AHho+MUUub0DBCCOHTeeoff2
ouDcL057GoOPs/gAYFnhF6NXStzeAQIQn18f5K7+RMgIHwAQfgAB+MyvFFcHHyN8ALDM8AvRqyP8
QADid0536VYV7tMFgGWHX/DqOsIPBCCuDL6PBy8TfABA+AEE4JpyrzXVdnK12hR/HLwMAM8TfqlL
CoQfCEB8kXtvO3RrndbvWeMuXQAg/AACcI3B934kSxtv7iD4AIDwAwjAdQTf2/q9KfparWPrEXwA
8PThxxo/EIDE3ngcS6tq1t7W77FhAwAIP4AAXFnwteP5e5X1ewBA+AEE4Lpyb9qdqzoexWJv5++N
MQgAIPwAAvC5c0863q7xdsNGZXQPALYUftzcAQJw5bn3cXSPzRoAsNnw465eEIDrzD3W7gEAPoVf
ikExRcIPBOAaYu99KpeduQCAD7xTCkGhiwo+8HiAAFxEvF31Cex8ZK/W+h57TOUCAE447xRDnMLP
84CAAFzQ0/Pfydfah1s1iD0AwPfhl1JUiFGe8AMBOI92EmLO3WI9xXSzhlWZFZlxjRoA4KfhlxRT
vNH7EUAAngXf6RPr/d/+5ck2Tu1aMZVSZFYJPgDAj3jvFVMk/EAAzht/nz5z/eUXVDGTTdHHpg0A
wDXhl7pxqpfwA2YMwFs9wWqt02ifqZrxFQMA/Dz8QpjW+AXCD7hHAP6V1SobiooVRvsAAD/n3NuI
XwxBIvyA5QegVZMNRbkYa/sAAFeFXwheqUsKHN4MPEcA1lpVhkz4AQCuDj+uawOeLABbayq5KOfM
VC8A4OemWzu4rg14qgBsKsWU+6xaK18JAMCPOO8Up8ObubUDeKIAtFqVh0GW2dULAPgZzvADnjYA
m0o2DcPAdC8A4IfhF5S6wBl+wDMGYJ1G/QqjfgCAfzk5yiUEzvADnjIAzUzDYWCtHwDgn+HHUS7A
0wdgUxmK+iFztAsA4NvwS5EdvcDTB2BrTbkflHPhUQYAXO6+sx29jvADnjkAa63q+0G1sN4PAPCZ
9368o5cdvcA6ArCaqWe9HwDgEycfpvCLbOwAVhOA1UyHQ88RLwCAk+4bN3bEFBVjENO8wIoCkPgD
AHwMPzZ2ACsOwFKKhp7DnQEAkvNeKQV5rmoD1huA1Yz4AwCMN3akwMYOYO0BOE77En8AsFnuZGMH
N3YA6w/AWqv6w6DGbl8A2GT4sb4P2FgAttY46gUAtth9HNwMbDUAxxs+qnHIMwBshQ/T+r7I+j5g
kwGYh8L1bgCwBdP5fSlFedb3AdsNwFKKhiHzqAHAysOP9X0AAShp3PSR+yw1dvwCwBp57xU5vw8g
AN81DQObPgBgdZyT99zPCxCAF5RcZJlNHwCwpvAL0SulpMA0L0AAfmS1su4PANbSfW/HuIRpmpfw
AwjAT8YjX7jpAwCemw9BKXJNG4AfBGDJJitM/QLAU+IYFwDXBmBrjalfAHjG7vNOMcRxRy/r+wBc
E4A5Z+75BYAn4v10WwfTvAB+E4BWK7d9AMAzYJoXwM0CcMgSGz8AYLndN+3mjYFpXgA3CMBqpszG
DwBYYvbJBz9O80ameQHcMABLLlz3BgCL6j6nGL1CjApM8wK4dQBarcrG6B8ALKL7/DjaN97N68Q0
L4B5ArAU1v4BwEOrb5rmjVExBonRPgCzBmBr4/QvAOD+3eedYgiKKbKpA8D9ArCUwpVvAHBn3gfF
FBRikPeeBwTAPQOwKWfW/gHAXXB2H4AlBGC1qsqtHwAwb/d5/zbaFzzTvAAeHIBmlaNfAGCW6nPy
fhztC5HRPgALCcDWmgoHPwPAbbuPTR0AFh2AlelfALhN9U2jfTEoJG7qALDgACzZmP4FgL90nx83
dYQ43s3L2X0AFh+Axs0fAPDr8Ispjle0cVMHgCfy/wFwHzHv4QJ5QwAAAABJRU5ErkJggg==
"

########################################################################
# crea usb live
########################################################################
SYSLINUX_DIR="/usr/lib/syslinux/modules/bios"
SYSLINUX_INST="/boot/syslinux"
MBR_DIR="/usr/lib/syslinux/mbr"
SIZE_PRIMARY_PART=4096M
SIZE_SECONDARY_PART=
TYPE_SECONDARY_PART=L
TYPE_SECONDARY_FS=ext4
DEVICE_USB=
PATH_TO_MOUNT="/mnt"

########################################################################
# create_grub-uefi:
########################################################################
function create_grub-uefi() {
    git clone http://github.com/mortaromarcello/scripts.git $GIT_DIR/scripts
    cp -av $GIT_DIR/scripts/grub-uefi/* ${PATH_TO_MOUNT}/
}

########################################################################
# create_partitions:
########################################################################
function create_partitions() {
    echo "Sovrascrivo la tabella delle partizioni."
    parted -s ${DEVICE_USB} mktable msdos
    read -p "Creo la partizione primaria fat32 e la partizione secondaria ext4 (premere Invio o Crtl-c per uscire)"
    sfdisk ${DEVICE_USB} << EOF
,${SIZE_PRIMARY_PART},c,*
,${SIZE_SECONDARY_PART},${TYPE_SECONDARY_PART}
EOF
    sync && sync
    #echo -e ",4096,c,*\n,,83" | sfdisk -D -u M ${1}
    read -p "Formatto la prima partizione. (premere Invio o Crtl-c per uscire)"
    #echo -e "mkpart primary fat32 1 -1\nset 1 boot on\nq\n" | parted ${1}
    mkdosfs -F 32 ${DEVICE_USB}1
    read -p "Formatto la seconda partizione. (premere Invio o Crtl-c per uscire)"
    if [ ${TYPE_SECONDARY_FS} = "exfat" ] || [ ${TYPE_SECONDARY_FS} = "vfat" ]; then
        mkfs -t ${TYPE_SECONDARY_FS} -n persistence ${DEVICE_USB}2
    else
        mkfs -t ${TYPE_SECONDARY_FS} ${DEVICE_USB}2
    fi
    if [ ${TYPE_SECONDARY_FS} = "ext2" ] || [ ${TYPE_SECONDARY_FS} = "ext3" ] || [ ${TYPE_SECONDARY_FS} = "ext4" ]; then
        e2label ${DEVICE_USB}2 persistence
        tune2fs -i 0 ${DEVICE_USB}2
    fi
}

########################################################################
# install_syslinux:
########################################################################

function install_syslinux() {
    if [ -e /usr/bin/syslinux ]; then
        mount ${DEVICE_USB}1 ${PATH_TO_MOUNT}
        if ! mount | grep ${PATH_TO_MOUNT}; then
            echo "Errore montando ${DEVICE_USB}1 in ${PATH_TO_MOUNT}"
            exit
        fi
        if [ ! -d ${PATH_TO_MOUNT}${SYSLINUX_INST} ]; then
            echo "Creo la directory ${PATH_TO_MOUNT}${SYSLINUX_INST} (premere Invio o Crtl-c per uscire)"
            read
            mkdir -p ${PATH_TO_MOUNT}${SYSLINUX_INST}
        fi
        echo "Copio mbr in ${DEVICE_USB} (premere Invio o Crtl-c per uscire)"
        read
        cat ${MBR_DIR}/mbr.bin > ${DEVICE_USB}
        echo "Installo syslinux in ${DEVICE_USB}1 (premere Invio o Crtl-c per uscire)"
        read
        syslinux --directory ${SYSLINUX_INST} --install ${DEVICE_USB}1
        for i in chain.c32 config.c32 hdt.c32 libcom32.c32 libutil.c32 menu.c32 reboot.c32 vesamenu.c32 whichsys.c32; do
            cp -v ${SYSLINUX_DIR}/$i ${PATH_TO_MOUNT}${SYSLINUX_INST}
        done
        cp -v /usr/lib/syslinux/memdisk ${PATH_TO_MOUNT}${SYSLINUX_INST}
        echo "$SPLASH" | base64 --decode > ${SYSLINUX_INST}/splash.png

        cat > /tmp/iso/isolinux/exithelp.cfg<<EOF
label menu
    kernel ${SYSLINUX_INST}/vesamenu.c32
    config syslinux.cfg
EOF

        cat >${PATH_TO_MOUNT}${SYSLINUX_INST}/syslinux.cfg <<EOF
include menu.cfg
default ${SYSLINUX_INST}/vesamenu.c32
prompt 0
timeout 200
EOF

        cat >${PATH_TO_MOUNT}${SYSLINUX_INST}/menu.cfg <<EOF
menu hshift 6
menu width 64

menu title Live Media
include stdmenu.cfg
include live.cfg
label help
    menu label Help
    config prompt.cfg
EOF
        cat >${PATH_TO_MOUNT}${SYSLINUX_INST}/stdmenu.cfg <<EOF
menu background ${SYSLINUX_INST}/splash.png
menu color title    * #FFFFFFFF *
menu color border   * #00000000 #00000000 none
menu color sel      * #ffffffff #76a1d0ff *
menu color hotsel   1;7;37;40 #ffffffff #76a1d0ff *
menu color tabmsg   * #f9f885 #00000000 *
menu color cmdline 0 #f9f885 #00000000
menu color help     37;40 #ffdddd00 #00000000 none
menu vshift 8
menu rows 12
#menu helpmsgrow 15
#menu cmdlinerow 25
#menu timeoutrow 26
#menu tabmsgrow 14
menu tabmsg Press ENTER to boot or TAB to edit a menu entry
EOF

        cat >${PATH_TO_MOUNT}${SYSLINUX_INST}/live.cfg <<EOF
label live
menu label \${DISTRO} (default)
    kernel /live/vmlinuz
    append initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label nox
    menu label \${DISTRO} (text-mode)
    kernel /live/vmlinuz
    append initrd=/live/initrd.img boot=live \${netconfig_opt} 3 \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label nomodeset
    menu label \${DISTRO} (no modeset)
    kernel /live/vmlinuz nomodeset
    append initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label toram
    menu label \${DISTRO} (load to RAM)
    kernel /live/vmlinuz
    append initrd=/live/initrd.img boot=live \${netconfig_opt} toram \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label noprobe
    menu label \${DISTRO} (no probe)
    kernel /live/vmlinuz noapic noapm nodma nomce nolapic nosmp vga=normal\n\
    append initrd=/live/initrd.img boot=live \${netconfig_opt} \${username_opt} locales=${LOCALE} keyboard-layouts=${KEYBOARD} persistence

label memtest
    menu label Memory test
    kernel /live/memtest

label chain.c32 hd0,0
    menu label Boot hard disk
    chain.c32 hd0,0

label harddisk
    menu label Boot hard disk (old way)
    localboot 0x80
EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f1.txt<<EOF
                  0fLive Media07                                07



<09F107>   This page, the help index.
<09F207>   unused
<09F307>   Boot methods for special ways of using this CD-ROM
<09F407>   Additional boot options
<09F507>   Change default language
<09F607>   unused
<09F707>   unused
<09F807>   Where to get more help
<09F907>   unused
<09F1007> Copyrights and Warranties (Debian)
You may:
- press F2 through F9 to read about the topic
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f2.txt<<EOF
                  0fTITLE07                                07




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f3.txt<<EOF
                  0fBOOT METHODS07                                07

0fMethods list here must correspond to entries in your boot menu. 07        
                                                          09F307

0flive07
  Start the live system -- this is the default CD-ROM method.
0fnox07
  Boot to runlevel 3 (command-line-only in Refracta and some others)
0fnomodeset07
  This is useful for some sytems with nvidia graphics cards.
0ftoram07
  Copy whole read-only media to RAM before mounting root filesystem.
0fnoprobe07
  Failsafe boot method. (noapic noapm nodma nomce nolapic nosmp vga=normal)
0fmemtest07
  Start memtest to scan your RAM for errors.

To use one of these boot methods, type it at the prompt, optionally
followed by any boot parameters. For example:
  boot: live persistence acpi=off

You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f4.txt<<EOF
                  0fLive-Boot Options07                                07

___ Additional boot options ___

You can use the following boot parameters at the 0fboot:07 prompt, 
in combination with the boot method (see <09F307>).

0fpersistence07    Use persistent (read/write) partition or file
0fswapon07         Use local swap partitions
0fnofastboot07     Enable filesystem check
0fnomodeset07      Disable kernel mode setting
0ftoram07          Copy whole read-only media to RAM      
0fnoapic nolapic07 Disable buggy APIC interrupt routing   
0fsingle07         Single-user mode (runlevel 1)
0facpi=noirq07 or 0facpi=off07      (partly) disable ACPI                  

See 'man live-boot' or the kernel's kernel-parameters.txt file 
for more options and information.


You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f5.txt<<EOF
                  0fLanguage and Keyboard07                                07

You can specify the default language at the boot prompt below in combination 
with the boot method (see <09F307>) and any other options (see <09F407>). 
Examples:
  Use default boot method (live); set locale and keyboard layout for Germany:
0fboot: live config=locales,keyboard-configuration locales=de_DE.UTF-8 keyboard-layouts=de07
  Do same with refracta-lang if it is installed(experimental):
0fboot: config=refracta-lang,tzdata lang=de_DE 07

Or, at the boot menu screen, press TAB and append the boot line with the
locale options. (e.g. 0fconfig=locales locales=de_DE.UTF-807 or
0fconfig=locales,keyboard-configuration locales=de_DE.UTF-8 keyboard-layouts=de07)

  Some common locales:
France          fr_FR.UTF-8
Spain           es_ES.UTF-8
Russia          ru_RU.UTF-8

You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f6.txt<<EOF
                  0fTITLE07                                07




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f7.txt<<EOF
                  0fTITLE07                                07




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f8.txt<<EOF
                  0fRefracta!07                                07

Where to get more help:

http://www.ibiblio.org/refracta/
http://refracta.freeforums.org/
http://sourceforge.net/projects/refracta/
http://www.debian.org/
http://wiki.debian.org/
http://www.debian.org/doc/user-manuals



You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot
EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f9.txt<<EOF
0fTITLE07                                                    09F1007




You may:
- press F1 to return to the help index
- type 0fmenu07 and press ENTER to go back to the boot screen
- press ENTER to boot

EOF

        cat > ${PATH_TO_MOUNT}${SYSLINUX_INST}/f10.txt<<EOF
0fCOPYRIGHTS AND WARRANTIES07                                                    09F1007

Debian GNU/Linux is Copyright (C) 1993-2011 Software in the Public Interest,
and others.

The Debian GNU/Linux system is freely redistributable. After installation,
the exact distribution terms for each package are described in the
corresponding file /usr/share/doc/0bpackagename07/copyright.

Debian GNU/Linux comes with 0fABSOLUTELY NO WARRANTY07, to the extent
permitted by applicable law.

---


More information about the Debian Live project can be found at
<http://live.debian.net/>.





Press F1control and F then 1 for the help index, or ENTER to 
EOF

        if [ $GRUB_UEFI = 1 ]; then
            create_grub-uefi
        fi
        sync && sync
        umount -v $PATH_TO_MOUNT
        echo "Fatto!"
    else
        echo "syslinux non è installato sul tuo sistema. Esco."
    fi
}

########################################################################
# linux_firmware:
########################################################################
function linux_firmware() {
    if [ $1 ]; then
        FIRMWARE_DIR=$ARCHIVE/linux-firmware
        if [ -d $FIRMWARE_DIR ]; then
            cd $FIRMWARE_DIR
            git pull
            if [ $? != '0' ]; then
                rm -R $FIRMWARE_DIR
                git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git $FIRMWARE_DIR
            fi
            cd $ARCHIVE
        else
            git clone git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git $FIRMWARE_DIR
        fi
        cp -var $FIRMWARE_DIR/* $1/lib/firmware/
    fi
}

########################################################################
# create_pendrive_live:
########################################################################
function create_pendrive_live() {
    if mount | grep ${PATH_TO_MOUNT}; then
        umount -v ${PATH_TO_MOUNT}
    fi
    if mount | grep ${DEVICE_USB}1; then
        umount -v ${DEVICE_USB}1
    fi
    if mount | grep ${DEVICE_USB}2; then
        umount -v ${DEVICE_USB}2
    fi
    echo -e "Posso cancellare la pennetta e ricreare la partizione. Sei 
d'accordo (s/n)?"
    read sn
    if [ ${sn} = "s" ]; then
        create_partitions
    fi
    install_syslinux
}

########################################################################
# check_root:
########################################################################
function check_root() {
    if [ ${UID} != 0 ]; then
        echo "Devi essere root per eseguire questo script."
        exit
    fi
}

########################################################################
# init:
########################################################################
function init() {
    echo "init"
    check_root
    [ $CLEAN = 1 ] && rm $VERBOSE -R $ROOT_DIR
    if [ -d ${ROOT_DIR} ]; then
        mkdir -p ${ROOT_DIR}
    fi
    if [ ! -d "${TEMP_REPOSITORY}" ]; then
        mkdir -p "${TEMP_REPOSITORY}"
    fi
    if [ ! -d ${ROOT_DIR}/var/cache/apt/archives ]; then
        mkdir -p ${ROOT_DIR}/var/cache/apt/archives
    fi
    if ! mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
        mount $VERBOSE --bind ${TEMP_REPOSITORY} ${ROOT_DIR}/var/cache/apt/archives
    fi
}

########################################################################
# compile_debootstrap:
########################################################################
function compile_debootstrap() {
    DEBOOTSTRAP_DIR=$ARCHIVE/debootstrap
    export DEBOOTSTRAP_DIR
    [[ -d $DEBOOTSTRAP_DIR ]] && rm -R $DEBOOTSTRAP_DIR
    git clone https://git.devuan.org/hellekin/debootstrap.git $DEBOOTSTRAP_DIR
    cd $DEBOOTSTRAP_DIR
    make devices.tar.gz
    DEBOOTSTRAP_BIN=$DEBOOTSTRAP_DIR/debootstrap
    cd $ARCHIVE
}

########################################################################
# ctrl_c:
########################################################################
trap ctrl_c SIGINT
ctrl_c() {
    echo "*** CTRL-C pressed***"
    unbind ${ROOT_DIR}
    if mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
        umount -l ${VERBOSE} ${ROOT_DIR}/var/cache/apt/archives
    fi
    exit -1
}

########################################################################
# bind:
########################################################################
function bind() {
    if [ $1 ]; then
        dirs="dev dev/pts proc sys run"
        for dir in $dirs; do
            if ! mount | grep $1/$dir; then
                mount $VERBOSE --bind /$dir $1/$dir
            fi
        done
    fi
}

########################################################################
# unbind:
########################################################################
function unbind() {
    if [ $1 ]; then
        dirs="run sys proc dev/pts dev"
        for dir in $dirs; do
            if mount | grep $1/$dir; then
                umount -l $VERBOSE $1/$dir
            fi
        done
    fi
}

########################################################################
# log:
########################################################################
function log() {
    echo -e "Line:$1 - $(date):\n\tstage $STAGE\n\tdistribution $DIST\n\troot directory $ROOT_DIR\n\tkeyboard $KEYBOARD\n\tlocale $LOCALE\n\tlanguage $LANG\n\ttimezone $TIMEZONE\n\tdesktop $DE\n\tarchitecture $ARCH">>$LOG
}

########################################################################
# update: 
########################################################################
function update() {
    if [ $1 ]; then
        echo -e $APT_REPS > $1/etc/apt/sources.list
        chroot $1 apt update
    fi
}

########################################################################
# upgrade:
########################################################################
function upgrade() {
    if [ $1 ]; then
        bind $1
        hook_create_fake_start_stop_daemon
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS dist-upgrade"
        hook_restore_fake_start_stop_daemon
        unbind $1
    fi
}

########################################################################
# upgrade_packages:
########################################################################
function upgrade_packages() {
    if [ $1 ]; then
        bind $1
        hook_create_fake_start_stop_daemon
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $PACKAGES"
        hook_restore_fake_start_stop_daemon
        unbind $1
    fi
}

########################################################################
# add_user:
########################################################################
function add_user() {
    if [ $1 ]; then
        chroot $1 useradd -m -p $CRYPT_PASSWD -s $SHELL $USERNAME
    fi
}

########################################################################
# set_locale
########################################################################
function set_locale() {
    if [ $1 ]; then
        echo $TIMEZONE > $1/etc/timezone
        LINE=$(cat $1/etc/locale.gen|grep "${LOCALE}")
        sed -i "s/${LINE}/${LOCALE}/" $1/etc/locale.gen
        chroot $1 locale-gen
        chroot $1 update-locale LANG=${LANG}
        LINE=$(cat $1/etc/default/keyboard|grep "XKBLAYOUT")
        sed -i "s/${LINE}/XKBLAYOUT=\"${KEYBOARD}\"/" $1/etc/default/keyboard
    fi
}

########################################################################
# snapshot : necessita di montare le dirs dev sys run etc.
########################################################################
function create_snapshot() {
    if [ $1 ]; then
        cp -v $PATH_SCRIPTS/snapshot.sh $1/tmp/
        chmod -v +x $1/tmp/snapshot.sh
        #if [ ${SNAPSHOT} ]; then
        cmd="/tmp/snapshot.sh -d Devuan -k $KEYBOARD -l $LOCALE -u $USERNAME -s $SNAPSHOT"
        #else
        #    cmd="/tmp/snapshot.sh -d Devuan -k $KEYBOARD -l $LOCALE -u $USERNAME"
        #fi
        if mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
            umount -l $VERBOSE ${ROOT_DIR}/var/cache/apt/archives
        fi
        chroot $1 /bin/bash -c "${cmd}"
    fi
}

########################################################################
# set_distro_env:
########################################################################
function set_distro_env() {
    if [ $DIST = "ascii" ]; then
        APT_REPS="deb http://pkgmaster.devuan.org/merged ascii main contrib non-free\n"
    elif [ $DIST = "beowulf" ]; then
        APT_REPS="deb http://pkgmaster.devuan.org/merged ascii main contrib non-free\ndeb http://pkgmaster.devuan.org/merged beowulf main contrib non-free\n"
    fi
    if [ $COMPILE_BOOTSTRAP = 1 ]; then
        compile_debootstrap
    else
        apt-get install debootstrap
    fi
}

########################################################################
# ascii:
########################################################################

function ascii() {
    DIST="ascii"
    check_script
    fase1 $ROOT_DIR
    fase2 $ROOT_DIR
    fase3 $ROOT_DIR
    fase4 $ROOT_DIR
}

########################################################################
# beowulf:
########################################################################

function beowulf() {
    DIST="beowulf"
    check_script
    fase1 $ROOT_DIR
    fase2 $ROOT_DIR
    fase3 $ROOT_DIR
    fase4 $ROOT_DIR
}

########################################################################
# fase1:
########################################################################
function fase1() {
    if [ $1 ]; then
        log ${LINENO}
        $DEBOOTSTRAP_BIN --verbose --arch=$ARCH ${DIST} $1 $MIRROR
        if [ $? -gt 0 ]; then
            echo "Big problem!!!"
            echo -e "===============ERRORE==============">>$LOG
            log ${LINENO}
            echo -e "===================================">>$LOG
            exit
        fi
    fi
}

########################################################################
# fase2:
########################################################################
function fase2() {
    if [ $1 ]; then
        bind $1
        update $1
        upgrade $1
        hook_hostname $1
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS autoremove --purge"
        hook_create_fake_start_stop_daemon $1
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $INCLUDES"
        if [ $? -gt 0 ]; then
            echo "Big problem!!!"
            echo -e "===============ERRORE==============">>$LOG
            log ${LINENO}
            echo -e "===================================">>$LOG
            unbind $1
            exit
        fi
        linux_firmware $1
        add_user $1
        set_locale $1
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $INSTALL_DISTRO_DEPS"
        if [ $? -gt 0 ]; then
            echo "Big problem!!!"
            echo -e "===============ERRORE==============">>$LOG
            log ${LINENO}
            echo -e "===================================">>$LOG
            unbind $1
            exit
        fi
        hook_install_distro $1
        unbind $1
    fi
}

########################################################################
# fase3:
########################################################################
function fase3() {
    if [ $1 ]; then
        bind $1
        chroot $1 dpkg --configure -a --force-confdef,confnew
        chroot $1 /bin/bash -c "DEBIAN_FRONTEND=$FRONTEND apt-get $APT_OPTS install $PACKAGES"
        if [ $? -gt 0 ]; then
            echo "Big problem!!!"
            echo -e "===============ERRORE==============">>$LOG
            log ${LINENO}
            echo -e "===================================">>$LOG
            unbind $1
            exit
        fi
        hook_synaptics $1
        hook_restore_fake_start_stop_daemon $1
        unbind $1
    fi
}

########################################################################
# fase4:
########################################################################
function fase4() {
    if [ $1 ]; then
        update $1
        bind $1
        upgrade $1
        if [ $? -gt 0 ]; then
            echo "Big problem!!!"
            echo -e "===============ERRORE==============">>$LOG
            log ${LINENO}
            echo -e "===================================">>$LOG
            unbind $1
            exit
        fi
        chroot $1 apt-get $APT_OPTS autoremove --purge
        chroot $1 dpkg --purge -a
        [ $CLEAN_SNAPSHOT = 1 ] && rm $VERBOSE $ROOT_DIR/home/snapshot/* $ROOT_DIR/home/snapshot/filesystem.squashfs-*
        create_snapshot $1
        unbind $1
    fi
}

########################################################################
# HOOKS
########################################################################
########################################################################
# update_hooks:
########################################################################
function update_hooks() {
    if [ $1 ]; then
        hook_install_distro $1
        hook_hostname $1
        hook_synaptics $1
    fi
}

########################################################################
# hook_create_fake_start_stop_daemon:
########################################################################
function hook_create_fake_start_stop_daemon() {
    if [ $1 ]; then
        if [ ! -e /sbin/start-stop-daemon.orig ]; then
            chroot $1 cp -v /sbin/start-stop-daemon /sbin/start-stop-daemon.orig
            chroot $1 touch /sbin/start-stop-daemon
            chroot $1 chmod +x /sbin/start-stop-daemon
        fi
    fi
}

########################################################################
# hook_restore_fake_start_stop_daemon:
########################################################################
function hook_restore_fake_start_stop_daemon() {
    if [ $1 ]; then
        if [ -e /sbin/start-stop-daemon.orig ]; then
            chroot $1 cp -vf /sbin/start-stop-daemon.orig /sbin/start-stop-daemon
            chroot $1 rm -vf /sbin/start-stop-daemon.orig
        fi
    fi
}

########################################################################
# hook_install_distro:
########################################################################
function hook_install_distro() {
    if [ $1 ]; then
        TMP="/tmp/scripts"
        GIT_DIR="scripts"
        chroot $1 mkdir -p $TMP
        chroot $1 git clone https://github.com/mortaromarcello/scripts.git $TMP/$GIT_DIR
        mkdir -p $1/usr/local/share/install_distro
        chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/install_distro.py /usr/local/share/install_distro/
        chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/install_distro.png /usr/local/share/install_distro/
        chroot $1 cp $VERBOSE -a $TMP/$GIT_DIR/install_distro /usr/local/bin/
        cat > $1/usr/share/applications/install_distro.desktop <<EOF
[Desktop Entry]
Encoding=UTF-8
Type=Application
Terminal=false
Exec=sudo /usr/local/bin/install_distro
Name=Install Distro
Comment=
Categories=GTK;System;Settings;
Icon=/usr/local/share/install_distro/install_distro.png
EOF
        chroot $1 rm -R -f $VERBOSE ${TMP}
    fi
}

########################################################################
# hook_synaptics:
########################################################################
function hook_synaptics() {
    if [ $1 ]; then
        SYNAPTICS_CONF="# Example xorg.conf.d snippet that assigns the touchpad driver\n\
# to all touchpads. See xorg.conf.d(5) for more information on\n\
# InputClass.\n\
# DO NOT EDIT THIS FILE, your distribution will likely overwrite\n\
# it when updating. Copy (and rename) this file into\n\
# /etc/X11/xorg.conf.d first.\n\
# Additional options may be added in the form of\n\
#   Option \"OptionName\" \"value\"\n\
#\n\
\n\
Section \"InputClass\"\n\
        Identifier      \"Touchpad\"                      # required\n\
        MatchIsTouchpad \"yes\"                           # required\n\
        Driver          \"synaptics\"                     # required\n\
        Option          \"MinSpeed\"              \"0.5\"\n\
        Option          \"MaxSpeed\"              \"1.0\"\n\
        Option          \"AccelFactor\"           \"0.075\"\n\
        Option          \"TapButton1\"            \"1\"\n\
        Option          \"TapButton2\"            \"2\"     # multitouch\n\
        Option          \"TapButton3\"            \"3\"     # multitouch\n\
        Option          \"VertTwoFingerScroll\"   \"1\"     # multitouch\n\
        Option          \"HorizTwoFingerScroll\"  \"1\"     # multitouch\n\
        Option          \"VertEdgeScroll\"        \"1\"\n\
        Option          \"CoastingSpeed\"         \"8\"\n\
        Option          \"CornerCoasting\"        \"1\"\n\
        Option          \"CircularScrolling\"     \"1\"\n\
        Option          \"CircScrollTrigger\"     \"7\"\n\
        Option          \"EdgeMotionUseAlways\"   \"1\"\n\
        Option          \"LBCornerButton\"        \"8\"     # browser \"back\" btn\n\
        Option          \"RBCornerButton\"        \"9\"     # browser \"forward\" btn\n\
EndSection\n\
#\n\
Section \"InputClass\"\n\
        Identifier \"touchpad catchall\"\n\
        Driver \"synaptics\"\n\
        MatchIsTouchpad \"on\"\n\
# This option is recommend on all Linux systems using evdev, but cannot be\n\
# enabled by default. See the following link for details:\n\
# http://who-t.blogspot.com/2010/11/how-to-ignore-configuration-errors.html\n\
#       MatchDevicePath \"/dev/input/event*\"\n\
EndSection\n\
\n\
Section \"InputClass\"\n\
        Identifier \"touchpad ignore duplicates\"\n\
        MatchIsTouchpad \"on\"\n\
        MatchOS \"Linux\"\n\
        MatchDevicePath \"/dev/input/mouse*\"\n\
        Option \"Ignore\" \"on\"\n\
EndSection\n\
\n\
# This option enables the bottom right corner to be a right button on clickpads\n\
# and the right and middle top areas to be right / middle buttons on clickpads\n\
# with a top button area.\n\
# This option is only interpreted by clickpads.\n\
Section \"InputClass\"\n\
        Identifier \"Default clickpad buttons\"\n\
        MatchDriver \"synaptics\"\n\
        Option \"SoftButtonAreas\" \"50% 0 82% 0 0 0 0 0\"\n\
        Option \"SecondarySoftButtonAreas\" \"58% 0 0 15% 42% 58% 0 15%\"\n\
EndSection\n\
\n\
# This option disables software buttons on Apple touchpads.\n\
# This option is only interpreted by clickpads.\n\
Section \"InputClass\"\n\
        Identifier \"Disable clickpad buttons on Apple touchpads\"\n\
        MatchProduct \"Apple|bcm5974\"\n\
        MatchDriver \"synaptics\"\n\
        Option \"SoftButtonAreas\" \"0 0 0 0 0 0 0 0\"\n\
EndSection\n\
"
        mkdir -p $1/etc/X11/xorg.conf.d
        echo -e "$SYNAPTICS_CONF" >$1/etc/X11/xorg.conf.d/50-synaptics.conf
    fi
}

########################################################################
# hook_hostname:
########################################################################
function hook_hostname() {
    if [ $1 ]; then
        cat > $1/etc/hostname <<EOF
${HOSTNAME}
EOF
        cat > $1/etc/hosts <<EOF
127.0.0.1       localhost
127.0.1.1       ${HOSTNAME}
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF
    fi
}

########################################################################
# END HOOKS
########################################################################
########################################################################
# check_script:
########################################################################
function check_script() {
    [[ $DEBUG = "yes" ]] && set -v -x
    if [ $DIST != ascii ] && [ $DIST != beowulf ]; then
        DIST=ascii
    fi
    if [ $ARCH != i386 ] && [ $ARCH != amd64 ]; then
        ARCH=amd64
    fi
    if [ $DE != "mate" ] && [ $DE != "xfce" ] && [ $DE != "lxde" ] && [ $DE != "kde" ] && [ $DE != "cinnamon" ] && [ $DE != "gnome" ] && [ $DE != "lxqt" ]; then
        DE="xfce"
    fi
    if [ ! ${SNAPSHOT} ]; then
        SNAPSHOT=${ROOT_DIR}-${DE}
    fi
    case $DIST in
        "ascii" | "beowulf")
            PACKAGES="yad gtk3-engines-breeze $PACKAGES"
            ;;
        *)
            ;;
    esac
    case $DE in
        "mate")
            PACKAGES_FILE="packages_mate"
            ;;
        "xfce")
            PACKAGES_FILE="packages_xfce"
            ;;
        "lxde")
            PACKAGES_FILE="packages_lxde"
            ;;
        "kde")
            PACKAGES_FILE="packages_kde"
            ;;
        "cinnamon")
            PACKAGES_FILE="packages_cinnamon"
            ;;
        "gnome")
            PACKAGES_FILE="packages_gnome"
            ;;
        "lxqt")
            PACKAGES_FILE="packages_lxqt"
            ;;
    esac
    # alternativa
    if [ -e ${PACKAGES_FILE} ]; then
        PACKAGES="$(cat ./${PACKAGES_FILE}) python-wxgtk3.0 python-parted task-$LANGUAGE iceweasel-l10n-$KEYBOARD $PACKAGES"
    else
        PACKAGES="mc spyder python-rope python-wxgtk3.0 python-parted filezilla vinagre telnet ntp testdisk recoverdm myrescue gpart gsmartcontrol diskscan exfat-fuse task-laptop task-$DE-desktop task-$LANGUAGE iceweasel-l10n-$KEYBOARD cups geany geany-plugins smplayer putty pulseaudio-module-bluetooth $PACKAGES"
    fi
    set_distro_env
    if [ ${TYPE_SECONDARY_FS} = "exfat" ]; then
        TYPE_SECONDARY_PART=7
    elif [ ${TYPE_SECONDARY_FS} = "vfat" ]; then
        TYPE_SECONDARY_PART=c
    fi
    if [ -n $DEVICE_USB ]; then
        echo "device usb: $DEVICE_USB"
        echo "path to mount: $PATH_TO_MOUNT"
        echo "syslinux install path: $SYSLINUX_INST"
        echo "size primary partition: $SIZE_PRIMARY_PART"
        echo "size secondary filesystem: $SIZE_SECONDARY_PART"
        echo "tipo di  filesystem partizione secondaria: $TYPE_SECONDARY_FS"
        echo "tipo partizione secondaria: $TYPE_SECONDARY_PART"
    fi
    if [ ! -e /usr/bin/git ]; then
        apt-get -y install git
    fi
    if [ ! -e /sbin/MAKEDEV ]; then
        apt-get -y install makedev
    fi
    if [ ! -e /usr/bin/rpl ]; then
        apt-get -y install rpl
    fi
    echo "distribution: $DIST"
    echo "architecture: $ARCH"
    echo "desktop: $DE"
    echo "stage: $STAGE"
    echo "snapshot: $SNAPSHOT"
    echo "root: directory $ROOT_DIR"
    echo "locale: $LOCALE"
    echo "lang: $LANG"
    echo "language: $LANGUAGE"
    echo "keyboard: $KEYBOARD"
    echo "timezone: $TIMEZONE"
    echo -e "deb repository: $APT_REPS"
    echo "packages: $PACKAGES"
    echo "Script verificato. OK."
}

########################################################################
# help:
########################################################################
function help() {
  echo -e "
${0} <opzioni>
Crea una live Devuan
  -a | --arch <architecture>             :tipo di architettura.
  -c | --clean                           :cancella la cartella root.
  -d | --distribuition <dist>            :tipo di distribuzione.
  -D | --desktop <desktop>               :tipo di desktop mate, xfce (default), lxde o kde.
  -h | --help                            :Stampa questa messaggio.
  -k | --keyboard                        :Tipo di tastiera (default 'it').
  -l | --locale                          :Tipo di locale (default 'it_IT.UTF-8 UTF-8').
  -L | --lang                            :Lingua (default 'it_IT.UTF-8').
  -n | --hostname                        :Nome hostname (default 'devuan').
  -s | --stage <stage>                   :Numero fase:
        1) crea la base del sistema;
        2) setta lo user, hostname e la lingua e i pacchetti indispensabili;
        3) installa pacchetti aggiuntivi e il desktop;
        4) installa lo script d'installazine e crea la iso;
        min) fase 1 + fase 2 + fase 4;
        iso-update) aggiorna la iso;
        ascii)
        beowulf) crea le rispettive iso delle distribuzioni;
  -sb| --snapshot_basename               : Nome base dello snapshot.
  -r | --root-dir <dir>                  :Directory della root
  -T | --timezone <timezone>             :Timezone (default 'Europe/Rome').
  -u | --user                            :Nome utente.
"
}

########################################################################
# end:
########################################################################
function end() {
    echo "end"
    if mount | grep ${ROOT_DIR}/var/cache/apt/archives; then
        umount -l $VERBOSE ${ROOT_DIR}/var/cache/apt/archives
    fi
}

########################################################################
# main:
########################################################################

[[ -z $1 ]] && help && exit
until [ -z "${1}" ]
do
    case ${1} in
        -a | --arch)
            shift
            ARCH=${1}
            ;;
        -c | --clean)
            shift
            CLEAN=1
            ;;
        -cb | --compile-bootstrap)
            shift
            COMPILE_BOOTSTRAP=1
            ;;
        -cs | --clean-snapshoot)
            shift
            CLEAN_SNAPSHOT=1
            ;;
        -d | --distribution)
            shift
            DIST=${1}
            ;;
        -D | --desktop)
            shift
            DE=${1}
            ;;
        -h | --help)
            shift
            help
            exit
            ;;
        -k | --keyboard)
            shift
            KEYBOARD=${1}
            ;;
        -l | --locale)
            shift
            LOCALE=${1}
            ;;
        -L | --lang)
            shift
            LANG=${1}
            ;;
        -la | --language)
            shift
            LANGUAGE=${1}
            ;;
        -n | --hostname)
            shift
            HOSTNAME=${1}
            ;;
        -r | --root-dir)
            shift
            ROOT_DIR=$1
            ;;
        -s | --stage)
            shift
            STAGE=${1}
            ;;
        -T | --timezone)
            shift
            TIMEZONE=${1}
            ;;
        -u | --user)
            shift
            USERNAME=${1}
            ;;
        -v | --verbose)
            shift
            VERBOSE=-v
            ;;
# device-usb
        -du | --device-usb)
            shift
            DEVICE_USB=${1}
            ;;
        -gu | --grub-uefi)
            shift
            GRUB_UEFI=1
            ;;
        -pm | --path-to-mount)
            shift
            PATH_TO_MOUNT=${1}
            ;;
        -pi | --path-to-install-syslinux)
            shift
            SYSLINUX_INST=${1}
            ;;
        -sb | snapshot_basename)
            shift
            SNAPSHOT=${1}
            ;;
        -sp | --size-primary-part)
            shift
            SIZE_PRIMARY_PART=${1}M
            ;;
        -ss | --size-secondary-part)
            shift
            SIZE_SECONDARY_PART=${1}M
            ;;
        -ts | --type-secondary-filesystem)
            shift
            TYPE_SECONDARY_FS=${1}
            ;;
        *)
            shift
            ;;
    esac
done

init

case $STAGE in
    "")
        #;&
        help
        ;;
    1)
        check_script
        fase1 $ROOT_DIR
        ;;
    2)
        check_script
        fase2 $ROOT_DIR
        ;;
    3)
        check_script
        fase3 $ROOT_DIR
        ;;
    4)
        check_script
        fase4 $ROOT_DIR
        ;;
    min)
        check_script
        fase1 $ROOT_DIR
        fase2 $ROOT_DIR
        hook_restore_fake_start_stop_daemon $ROOT_DIR
        fase4 $ROOT_DIR
        ;;
    ascii)
        ascii
        ;;
    beowulf)
        beowulf
        ;;
    iso-update)
        check_script
        update_hooks $ROOT_DIR
        upgrade_packages $ROOT_DIR
        fase4 $ROOT_DIR
        ;;
    upgrade)
        check_script
        bind $ROOT_DIR
        update $ROOT_DIR
        upgrade $ROOT_DIR
        unbind $ROOT_DIR
        ;;
    *)
        ;;
esac

end
