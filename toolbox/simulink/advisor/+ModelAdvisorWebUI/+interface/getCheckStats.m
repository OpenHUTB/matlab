function[checkStats,checkResult,action,helpPath]=getCheckStats(modelId,checkId)

    appObj=Advisor.Manager.getApplication('id',modelId);
    targetObj=appObj.getMAObjs{1,1};

    selectedNode=targetObj.getTaskObj(checkId);


    if strcmp(selectedNode.state,'Fail')&&~selectedNode.failed
        checkStats='Warning';
    else
        checkStats=selectedNode.state;
    end


    if size(selectedNode.check.Action,2)>0
        action={selectedNode.check.Action.Name,selectedNode.check.Action.Description,selectedNode.check.Action.enable};
    else
        action={'NA','NA','NA'};
    end

    checkResult=selectedNode.check.ResultInHTML;


    contentUrlPath=connector.addStaticContentOnPath('help',docroot);
    helpPath='';
    try
        if isa(selectedNode,'ModelAdvisor.Node')&&~isempty(selectedNode.CSHParameters)
            if isfield(selectedNode.CSHParameters,'MapKey')&&...
                isfield(selectedNode.CSHParameters,'TopicID')
                mapkey=['mapkey:',selectedNode.CSHParameters.MapKey];
                topicid=selectedNode.CSHParameters.TopicID;


                if strcmp(path,'')
                    helpPath='';
                    return
                end
                C=strsplit(path,'\\');
                helpAdd='';
                for i=1:size(C,2)
                    helpAdd=strcat(helpAdd,C{1,i},'\');
                    if strcmp(helpAdd(1:end-1),docroot)
                        helpAdd='\';
                    end
                end
                helpAdd=helpAdd(1:end-1);
                helpPathORG=connector.getUrl(helpAdd);
                helpPath=strrep(helpPathORG,'\','/');
            end
        end
    catch
    end

end

