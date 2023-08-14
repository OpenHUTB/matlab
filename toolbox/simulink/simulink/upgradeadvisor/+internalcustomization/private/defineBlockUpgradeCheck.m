function defineBlockUpgradeCheck()





    slupdateCheck=ModelAdvisor.Check('mathworks.design.Update');
    slupdateCheck.Title=DAStudio.message('ModelAdvisor:engine:MACheckUpdatesTitle');
    slupdateCheck.TitleTips=DAStudio.message('ModelAdvisor:engine:MACheckUpdatesTitleTips');
    slupdateCheck.setCallbackFcn(@ExecCheckUpdates,'None','StyleThree');
    slupdateCheck.CSHParameters.MapKey='ma.simulink';
    slupdateCheck.CSHParameters.TopicID='MACheckUpdatesTitle';
    slupdateAction=ModelAdvisor.Action;
    slupdateAction.setCallbackFcn(@actionUpdateBlocks);
    slupdateAction.Name=DAStudio.message('ModelAdvisor:engine:ModifyButton');
    slupdateAction.Description=DAStudio.message('ModelAdvisor:engine:ReplaceBlockAction');
    slupdateCheck.setAction(slupdateAction);
    slupdateCheck.SupportLibrary=true;



    modelAdvisor=ModelAdvisor.Root;
    modelAdvisor.register(slupdateCheck);

end









function[ResultDescription,ResultHandles]=ExecCheckUpdates(system)


    ResultDescription={};
    ResultHandles={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    mdladvObj.setActionEnable(false);



    docLinkSfunction=[...
    '<a href="matlab:helpview([docroot,''/toolbox/simulink/sfg/',...
    'simulink_sfg.map''],''overview'')">%s</a>'];



    passMsg=DAStudio.message('Simulink:tools:MAPassedMsg');

    MustBeBlockDiagram=DAStudio.message('Simulink:tools:MAMustBeBlockDiagram');
    passedParens=DAStudio.message('Simulink:tools:MAPassedParens');
    sfunMsgManualName=DAStudio.message('Simulink:tools:MASfunMsgManualName');
    sfunManualRefStr=sprintf(docLinkSfunction,sfunMsgManualName);
    sfunMsgDiagnostic=DAStudio.message('Simulink:tools:MASfunMsgDiagnostic',sfunManualRefStr);
    sfunStatusOK=passedParens;
    sfunStatusUpdate=DAStudio.message('Simulink:tools:MASfunStatusUpdate');
    blocksMsgDiagnostic=DAStudio.message('Simulink:tools:MABlocksMsgDiagnostic');
    sfunIsMissing=DAStudio.message('Simulink:tools:MASfunMissingFile');



    itemType=get_param(system,'Type');
    if~strcmp(itemType,'block_diagram')
        ResultDescription={...
        sprintf('<p><font color="#800000">%s</font></p>',...
        MustBeBlockDiagram)};
        ResultHandles={[]};
        mdladvObj.setCheckResultStatus(false);
    else

        updateInfo=ModelUpdater.update(system,'OperatingMode','AnalyzeReplaceBlocks');

        blockList=updateInfo.blockList;
        sfunList=updateInfo.sfunList;
        sfunOK=updateInfo.sfunOK;
        sfunType=updateInfo.sfunType;


        blockList=mdladvObj.filterResultWithExclusion(blockList);
        sfunList=mdladvObj.filterResultWithExclusion(sfunList);
        sfunOK=mdladvObj.filterResultWithExclusion(sfunOK);
        sfunType=mdladvObj.filterResultWithExclusion(sfunType);



        if isempty(blockList)&&all(sfunOK)



            ResultDescription{end+1}=['<p /><font color="#008000">',passMsg,'</font>'];
            ResultHandles{end+1}=[];
            mdladvObj.setCheckResultStatus(true);
            mdladvObj.setActionEnable(false);

        else
            mdladvObj.setCheckResultStatus(false);



            sfunMsg=['<p>',sfunMsgDiagnostic,'</p><ul>'];
            if isempty(sfunList)
                sfunMsg=[sfunMsg,...
                '<li><font color="#008000">',passMsg,'</font></li>'];
            else
                for k=1:numel(sfunList)
                    if sfunOK(k)
                        sfunStatus=sfunStatusOK;
                        colorFmt='<font color="#008000">';
                    else
                        sfunStatus=sfunStatusUpdate;
                        colorFmt='<font color="#800000">';
                    end
                    if strcmp(sfunType{k},'missing')
                        sfunMsg=[sfunMsg,'<li>',colorFmt,...
                        '(',sfunIsMissing,') ',...
                        sfunList{k},'</font></li>'];%#ok<AGROW>
                    else
                        sfunMsg=[sfunMsg,'<li>',colorFmt,...
                        '(',sfunType{k},')',...
                        sfunStatus,' ',...
                        sfunList{k},'</font></li>'];%#ok<AGROW>
                    end
                end
            end
            sfunMsg=[sfunMsg,'</ul>'];


            ResultDescription{end+1}=sfunMsg;
            ResultHandles{end+1}=[];










            if length(updateInfo.blockList)~=length(blockList)
                idx=[];
                tmpBlockList=blockList;
                blockList=updateInfo.blockList;
                diff=setdiff(blockList,tmpBlockList);
                for i=1:length(blockList)
                    for j=1:length(diff)
                        if strcmp(blockList{i},diff{j})
                            idx=[idx,i];%#ok<AGROW>
                        end
                    end
                end
                updateInfo.blockReasons(idx)=[];
            end
            uniqueReasons=unique(updateInfo.blockReasons);
            [reasonList,sortedIdx]=sort(updateInfo.blockReasons);
            blockList=blockList(sortedIdx);

            if~isempty(uniqueReasons)
                ResultDescription{end}=[ResultDescription{end},'<p><b>',blocksMsgDiagnostic,'</b></p>'];
            end

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
