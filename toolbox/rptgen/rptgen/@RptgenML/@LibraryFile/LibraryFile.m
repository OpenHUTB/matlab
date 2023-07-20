function obj=LibraryRpt(fileName,pathName)











    obj=feval(mfilename('class'));

    if nargin==1
        [pathName,fName,fExt]=fileparts(fileName);
        fileName=[fName,fExt];
    end

    obj.FileName=fileName;
    obj.PathName=pathName;

