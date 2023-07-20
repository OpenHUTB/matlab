function obj=LibraryRpt(fileName,pathName)











    obj=feval(mfilename('class'));

    if isa(fileName,'rptgen.coutline')
        [pathName,fName,fExt]=fileparts(fileName.RptFileName);





        fileName=[fName,fExt];
    elseif nargin==1
        [pathName,fName,fExt]=fileparts(fileName);
        fileName=[fName,fExt];
    end

    obj.FileName=fileName;
    obj.pathName=pathName;

