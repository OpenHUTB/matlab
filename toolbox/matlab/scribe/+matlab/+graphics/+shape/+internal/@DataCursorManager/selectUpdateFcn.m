function selectUpdateFcn(hObj)









    [fileName,pathName]=uigetfile('*.m',getString(message('MATLAB:uistring:datacursor:DialogSelectFile')));
    if fileName~=0
        if isempty(strfind(which(fileName),pathName))
            currDir=pwd;
            cd(pathName);
            [~,name]=fileparts(fileName);
            hFun=str2func(name);
            cd(currDir);
        else
            [~,name]=fileparts(fileName);
            hFun=str2func(name);
        end
        hObj.UpdateFcn=hFun;
    end
