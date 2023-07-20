function defineBlockUpgradeCompileCheck()





    slupdateCompileCheck=ModelAdvisor.Check('mathworks.design.UpdateRequireCompile');
    slupdateCompileCheck.Title=DAStudio.message('ModelAdvisor:engine:MACompileCheckUpdatesTitle');
    slupdateCompileCheck.TitleTips=DAStudio.message('ModelAdvisor:engine:MACompileCheckUpdatesTitleTips');
    slupdateCompileCheck.setCallbackFcn(@ExecCheckCompileUpdates,'Postcompile','StyleThree');
    slupdateCompileCheck.Value=false;
    slupdateCompileCheck.CSHParameters.MapKey='ma.simulink';
    slupdateCompileCheck.CSHParameters.TopicID='MACompileCheckUpdatesTitle';
    slupdateCompileAction=ModelAdvisor.Action;
    slupdateCompileAction.setCallbackFcn(@actionUpdateCompileBlocks);
    slupdateCompileAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    slupdateCompileAction.Description=DAStudio.message('ModelAdvisor:engine:ReplaceBlockAction');
    slupdateCompileCheck.setAction(slupdateCompileAction);
    slupdateCompileCheck.SupportLibrary=false;



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(slupdateCompileCheck);

end









function[ResultDescription,ResultHandles]=ExecCheckCompileUpdates(system)

    ResultDescription={};
    ResultHandles={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    mdladvObj.setActionEnable(false);


    passMsg=DAStudio.message('Simulink:tools:MAPassedMsg');

    MustBeBlockDiagram=DAStudio.message('Simulink:tools:MAMustBeBlockDiagram');
    blocksMsgDiagnostic=DAStudio.message('Simulink:tools:MABlocksMsgDiagnostic');

    itemType=get_param(system,'Type');

    if~strcmp(itemType,'block_diagram')
        ResultDescription={...
        sprintf('<p><font color="#800000">%s</font></p>',...
        MustBeBlockDiagram)};
        ResultHandles={[]};
        mdladvObj.setCheckResultStatus(false);
    else
        updateInfo=ModelUpdater.update(system,'OperatingMode','AnalyzeCompiled');
        blockList=updateInfo.blockList;

        if isempty(blockList)

            ResultDescription{end+1}=['<p /><font color="#008000">',passMsg,'</font>'];
            ResultHandles{end+1}=[];
            mdladvObj.setActionEnable(false);
            mdladvObj.setCheckResultStatus(true);

        else
            mdladvObj.setCheckResultStatus(false);


            ResultDescription{end+1}=[...
            '<p><b>',blocksMsgDiagnostic,'</b></p>'];
            ResultHandles{end+1}=[];

            uniqueReasons=unique(updateInfo.blockReasons);
            [reasonList,sortedIdx]=sort(updateInfo.blockReasons);
            blockList=blockList(sortedIdx);

            for m=1:numel(uniqueReasons)
                reasonStr=DAStudio.message('Simulink:tools:MAReasonStr',uniqueReasons{m});
                ResultDescription{end+1}=['<p>',reasonStr,'</p>'];%#ok<AGROW>

                idx=strmatch(uniqueReasons{m},reasonList,'exact');%#ok<MATCH3>
                bh=[];
                for k=1:numel(idx)
                    bh(end+1)=get_param(blockList{idx(k)},'Handle');%#ok<AGROW>
                end
                ResultHandles{end+1}=bh;%#ok<AGROW>              
            end
            mdladvObj.setActionEnable(true);
        end
    end
end


