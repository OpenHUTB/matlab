function fname=getDocFile(fName)







    hsbroot=fileparts(fileparts(fileparts(fileparts(fileparts(mfilename('fullpath'))))));
    fname=fullfile(hsbroot,fName);
