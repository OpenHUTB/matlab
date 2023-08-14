function var=mcb_isCodeGenVar()









    var=~(rtwenvironmentmode(bdroot(gcbh))==1||exist('sldvisactive','file')~=0&&sldvisactive(bdroot(gcbh)));

end