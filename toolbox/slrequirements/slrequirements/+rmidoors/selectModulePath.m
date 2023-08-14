function[fullPath,uniqueId]=selectModulePath(hDoors)





    if ispc()
        reqmgt('winFocus','DOORS Database.*');
    end

    cmdStr='dmiBrowseForPath_()';
    rmidoors.invoke(hDoors,cmdStr);

    fullPath=hDoors.Result;
    if strncmp(fullPath,'DMI Error:',10)
        error(message('Slvnv:reqmgt:DoorsApiError',fullPath));
    end

    if nargout>1
        if~isempty(fullPath)


            cmdStr=['dmiModuleResolvePath_("',fullPath,'")'];
            rmidoors.invoke(hDoors,cmdStr);

            uniqueId=hDoors.Result;
            if strncmp(uniqueId,'DMI Error:',10)
                error(message('Slvnv:reqmgt:DoorsApiError',uniqueId));
            end
        else
            uniqueId='';
        end
    end



    dialogH=ReqMgr.activeDlgUtil();
    if~isempty(dialogH)
        titleStr=dialogH.getTitle;
        if ispc()
            reqmgt('winFocus',['.*',titleStr]);
        end
        ReqMgr.activeDlgUtil('clear');
    end
end
