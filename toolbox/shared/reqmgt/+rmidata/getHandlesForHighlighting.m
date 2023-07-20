function[slHs,sfHs,sfFade,indirectHs]=getHandlesForHighlighting(modelH,filterSettings)




    if nargin<2
        filterSettings=rmi.settings_mgr('get','filterSettings');
    end

    [slHs,sfHs]=rmidata.getLinkedHandles(modelH,filterSettings);
    if~isempty(sfHs)

        sfCharts=obj_chart(sfHs);
        indirectHs=sf('Private','chart2block',sfCharts);
    else
        indirectHs=[];
    end

    modelName=get_param(modelH,'Name');



    artifactPath=get_param(modelH,'FileName');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(artifactPath);
    if~isempty(linkSet)
        textItemIds=linkSet.getTextItemIds();
        if~isempty(textItemIds)
            for i=1:length(textItemIds)
                textItemSID=[modelName,textItemIds{i}];
                if rmisl.isHarnessIdString(textItemSID)



                    continue;
                else
                    try
                        mfHandle=Simulink.ID.getHandle(textItemSID);
                    catch ex
                        if strcmp(ex.identifier,'Simulink:utility:objectDestroyed')

                            continue;
                        else
                            rethrow(ex);
                        end
                    end
                    if isa(mfHandle,'Stateflow.Object')
                        indirectHs=[indirectHs;sf('Private','chart2block',mfHandle.Chart.Id)];%#ok<AGROW>
                        sfId=mfHandle.Id;
                        if~any(sfHs==sfId)
                            sfHs(end+1)=sfId;%#ok<AGROW>
                        end
                    else
                        indirectHs=[indirectHs;mfHandle];%#ok<AGROW>
                    end
                end
            end
        end
    end




    modelObj=get_param(modelH,'Object');
    linkedReferencedBlocks=rmisl.getIndirectlyLinkedHandles(modelObj,filterSettings);
    if~isempty(linkedReferencedBlocks)
        indirectHs=[indirectHs(:);linkedReferencedBlocks];
    end



    if rmisf.isStateflowLoaded()
        sfFilter=rmisf.sfisa('isaFilter');
        sfObjs=find(modelObj,sfFilter);
        allSfHs=get(sfObjs,'Id');
        if iscell(allSfHs)
            allSfHs=cell2mat(allSfHs);
        end
        sfFade=setdiff(allSfHs,sfHs);
    else
        sfFade=[];
    end
end
