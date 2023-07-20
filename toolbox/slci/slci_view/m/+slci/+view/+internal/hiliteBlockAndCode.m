


function hiliteBlockAndCode(aModelName,aBlockSID)

    set_param(0,'HiliteAncestorsData',...
    struct('HiliteType','user1',...
    'ForegroundColor','blue',...
    'BackgroundColor','yellow'));

    Simulink.ID.hilite(aBlockSID,'user1',true);
    drawnow;

    mdlHdl=get_param(aModelName,'Handle');
    vm=slci.view.Manager.getInstance;
    dmgr=vm.getData(mdlHdl);

    codeTraceObj=dmgr.getCodeTrace(aBlockSID);

    if~isempty(codeTraceObj)

        fileNames=codeTraceObj.getFileNames();
        title=Simulink.ID.getFullName(aBlockSID);

        input=containers.Map('KeyType','char','ValueType','any');
        for iFile=1:numel(fileNames)
            lineNos=codeTraceObj.getLineNumbers(fileNames{iFile});
            input(fileNames{iFile})=lineNos;
        end

        slci.view.internal.hiliteCode(aModelName,title,input);
    end
end