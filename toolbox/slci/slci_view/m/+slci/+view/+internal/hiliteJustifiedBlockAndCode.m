



function hiliteJustifiedBlockAndCode(aModelName,aBlockSID,codeTraceObj,fileNames)

    set_param(0,'HiliteAncestorsData',...
    struct('HiliteType','user1',...
    'ForegroundColor','blue',...
    'BackgroundColor','yellow'));

    Simulink.ID.hilite(aBlockSID,'user1',true);
    drawnow;

    codeLineArray=str2double(codeTraceObj);
    sortcodeLineArray=sort(codeLineArray);
    if~isempty(codeTraceObj)
        title=Simulink.ID.getFullName(aBlockSID);

        input=containers.Map('KeyType','char','ValueType','any');
        for iFile=1:numel(fileNames)
            input(fileNames{iFile})=sortcodeLineArray;
        end

        slci.view.internal.hiliteCode(aModelName,title,input);
    end
end
