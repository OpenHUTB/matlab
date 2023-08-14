function var=mcb_isSimVar()









    var=rtwenvironmentmode(bdroot(gcbh))==1||exist('sldvisactive','file')~=0&&sldvisactive(bdroot(gcbh));
end