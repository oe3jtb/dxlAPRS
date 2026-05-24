
from PIL import Image, ImageDraw, ImageChops, ImageFont
import socket
import sys
from os import rename

CONTRAST=3.0
BRIGHTNESS=30.0
VERB=False
YSIZE=500
FN="/tmp/w1.png"
PORT=18501
FONTSIZE=12
FONTCOL=150
RENAME=""
SAVEEVERY=1
NICE=0

def genpalette():                        # make nice colours for gains
  pal=[]
  for i in range(0,256):
    r=0
    g=0
    b=0
    if i<64:
      b=i*4
    elif i<128:
      b=255-(i-64)*4
      g=(i-64)*4 
      r=g
    elif i<192:
      g=255-(i-128)*4 
      r=255
    else:
      r=255
      g=(i-192)*4
      b=g
#    pal+=[(r,g,b)]
    pal+=[r,g,b]
  return pal

def getv(d, pos):
  return (d[pos+3]<<24)+(d[pos+2]<<16)+(d[pos+1]<<8)+d[pos]

argc=len(sys.argv)
i=1
while i<argc:
  if sys.argv[i]=="-h":
    print("-b <brightness>   (40)")
    print("-C <fontcolour>   (100)")
    print("-c <contrast>     (3.0)")
    print("-e <lines>        save image every (1)")
    print("-f <fontsize>     (12)")
    print("-h                this")
    print("-i <imagefile>    (/tmp/w.png)") 
    print("-n <n>            (0) remove constant signals 1 fast, 100 slow")
    print("-p <listen port>  (18500)")
    print("-r <to filename>  rename complete written image ()") 
    print("-v                verbous")
    print("-y <ysize>        (500)")
    quit()
  elif  sys.argv[i]=="-v":
    VERB=True
  elif  sys.argv[i]=="-i" and i+1<argc:
    i=i+1
    FN=sys.argv[i]
  elif  sys.argv[i]=="-r" and i+1<argc:
    i=i+1
    RENAME=sys.argv[i]
  elif  sys.argv[i]=="-p" and i+1<argc:
    i=i+1
    PORT=int(sys.argv[i])
  elif  sys.argv[i]=="-y" and i+1<argc:
    i=i+1
    YSIZE=int(sys.argv[i])
  elif  sys.argv[i]=="-b" and i+1<argc:
    i=i+1
    BRIGHTNESS=float(sys.argv[i])
  elif  sys.argv[i]=="-c" and i+1<argc:
    i=i+1
    CONTRAST=float(sys.argv[i])
  elif  sys.argv[i]=="-f" and i+1<argc:
    i=i+1
    FONTSIZE=int(sys.argv[i])
  elif  sys.argv[i]=="-C" and i+1<argc:
    i=i+1
    FONTCOL=int(sys.argv[i])
  elif  sys.argv[i]=="-e" and i+1<argc:
    i=i+1
    SAVEEVERY=int(sys.argv[i])
  elif  sys.argv[i]=="-n" and i+1<argc:
    i=i+1
    NICE=int(sys.argv[i])
  else:
    print(sys.argv[i], "? use -h")
    quit()
  i=i+1

IP=("0.0.0.0",PORT)
if VERB:
  print("listen on", IP)
  print("image:", FN, " ysize:", YSIZE)
  print("brightness:", BRIGHTNESS, " contrast:", CONTRAST)
      
yhead=FONTSIZE+2      
fnt = ImageFont.truetype("/usr/share/fonts/truetype/liberation/LiberationMono-Regular.ttf", FONTSIZE)

lut=genpalette() 
#print("lut:",lut[0]) 
lines=0
sock=socket.socket(socket.AF_INET,socket.SOCK_DGRAM)
sock.bind(IP)

#im=Image.new("RGB",(400,600))

types={"M10":20000,"M20":20000,"DFM":6000}       # bandwidths of sondes for scanner to start rx
def bw(typ):
  try: return types[typ]
  except: return 12000


sondes={}
starthz=0
xsize=0
savecnt=0
med=[]
while True:
  data, addr=sock.recvfrom(1500)
#  print(type(data[0]))
#  print(data[0],data[1],data[2],data[3])
  if chr(data[0])=='S' and chr(data[1])=='D' and chr(data[2])=='R' and chr(data[3])=='L':  # level table from sdr
    dlen=len(data)
    starthz=getv(data,4)*1000                                                              # start freq
    step=getv(data,8)                                                                      # step im hz
    if VERB: print(dlen-12, starthz//1000, step)
    db=[]
    for i in range(12,dlen): db+=[data[i]]
    x=len(db)

    if NICE>0 and x>0:
      dm=0
      for i in range(0, x): dm+=db[i]
      dm=dm/x
      for i in range(0, x):
         try:
            med[i]+=((int(db[i])-int(dm))*1000-med[i])/NICE
            db[i]-=med[i]/1000
         except: med+=[0.0]
   
    if x!=xsize:                                                                           # x size changed
      med=[]
      xsize=x
      im=Image.new("P",(xsize,YSIZE))
      im.putpalette(lut)
    px = im.load()
    pd = ImageDraw.Draw(im) 
    im.paste((20),box=(0,0,xsize,yhead),mask=None)                                         # ruler background

# ruler
    for i in range(1,xsize-1):
      h=(i-1)*step + starthz
      if h%1000000==0:
        pd.line((i,yhead,i,yhead-8), fill=(100))
        pd.text((i+1,0),str(h//1000000),font=fnt,fill=(FONTCOL))
      elif h%500000==0: pd.line((i,yhead,i,yhead-6), fill=(100))
      elif h%100000==0: pd.line((i,yhead,i,yhead-3), fill=(100))
# ruler

# automatic zero level
#    hist=[0]*256
#    for i in range(0,xsize): hist[db[i]]+=1
#   m=0
#    for i in range(0,len(hist)):
#      if m<=hist[i]:
#        m=hist[i]
#        z=i
# automatic zero level

    z=60     
    for i in range(0,xsize):
      px[i,yhead]=min(255,max(0,int((db[i]-z)*CONTRAST+BRIGHTNESS)))
#      px[i, 0]=lut[n]
#      px[i, 0]=n
    dl="";
    for i in sondes:
      if lines-sondes[i][3]>50: dl=i                        # purge not heard for a while
      else:                                                 # write name right beside freq track
        if step>0 and (lines-sondes[i][2])%100==0:
          x=sondes[i][0]*1000-starthz                       # hz from left image margin
          if x>0:
            x=(sondes[i][1]/2 + x)//step + 2                # half badwidth + freq
#           print(x,yhead+1,i)
            if x<xsize:
#             pd = ImageDraw.Draw(im) 
              pd.text((x,yhead+1),i,font=fnt,fill=(FONTCOL))
    if dl: del(sondes[dl]) 
    
    if savecnt<=1:
      im.save(FN)
      if RENAME: rename(FN, RENAME)
      savecnt=SAVEEVERY
    else: savecnt=savecnt-1
    
    im=ImageChops.offset(im, 0, 1)                          # roll image down

#    print(db, z)
    lines+=1

  elif chr(data[0])=='R' and chr(data[1])=='X':
    try:
      rf=str(data).split(",")                                 # decode info from sondeudp
      khz=int(rf[0][4:])*0.01                                 # frequency + afc  
      typ=rf[1]                                               # type for bandwidth
      name=rf[2].split("\\")[0]                               # name to show on image
      if name in sondes: since=sondes[name][2]
      else: since=lines                                       # new sonde, remember start position on image
      sondes[name]=(khz, bw(typ), since, lines)
    except: pass
    
    if VERB: print(sondes)
    
  else:
    print('unknown data')

# sdr config scanner:
#   p 4 580                          depending on preamp gain
#   p 8 0                            manual gain
#   s 402.295 404.310 2500 6 3000    from, to, step, speed (2ms*x per step), filter
# srdtst:
#   -L 127.0.0.1:18500
# sondeudp:
#   -M 127.0.0.1:18500 
# view with geeqie or www browser








