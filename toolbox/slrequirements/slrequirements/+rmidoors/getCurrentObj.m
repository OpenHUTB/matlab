function[moduleIdStr,objNum,descr]=getCurrentObj()




    if rmidoors.isAppRunning()
        hDoors=rmidoors.comApp();
        rmidoors.invoke(hDoors,'dmiActiveObjectInfo_()');
        objInfo=hDoors.Result;
    else
        moduleIdStr=[];
        objNum=[];
        descr='';
        return;
    end

    if strncmp(objInfo,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',objInfo));
    end

    [moduleIdStr,remStr]=strtok(objInfo,',');

    if nargout>1

        [objId,remStr]=strtok(remStr,',');

        tok=regexp(objId,'(\d*)','tokens');

        if isempty(tok)
            objNum=-1;
            descr='';
            return;
        else
            objNum=str2double(tok{1}{1});
        end

        if nargout>2
            customDescr=rmidoors.customLabel(moduleIdStr,objNum);
            if isempty(customDescr)
                descr=remStr(2:end);
            else
                descr=customDescr;
            end

            prefix=rmidoors.getModulePrefix(moduleIdStr);
            if~isempty(prefix)&&~isempty(tok)
                objNum=[prefix,tok{1}{1}];
            end
        end
    end
end

