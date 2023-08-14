function[folderStats,reportPath,reportdate,helpPath]=getFolderStats(modelId,folderId)

    appObj=Advisor.Manager.getApplication('id',modelId);
    targetObj=appObj.getMAObjs{1,1};
    selectedNode=targetObj.getTaskObj(folderId);

    folderStats=modeladvisorprivate('modeladvisorutil2','getNodeSummaryInfo',selectedNode);


    C=strsplit(pwd,'\\');
    root='';
    for i=1:size(C,2)-1
        root=strcat(root,C(1,i),'\');
    end
    roots=root{1,1}(1:end-1);

    contentUrlPath=connector.addStaticContentOnPath('root',roots);
    reportName=targetObj.generateReport(selectedNode);



    C=strsplit(reportName,'\\');
    reportAdd='';
    for i=1:size(C,2)
        reportAdd=strcat(reportAdd,C{1,i},'\');
        if strcmp(reportAdd(1:end-1),roots)
            reportAdd='\';
        end
    end
    reportAdd=reportAdd(1:end-1);

    reportPathORG=connector.getUrl([contentUrlPath,reportAdd]);
    reportPath=strrep(reportPathORG,'\','/');


    reportFileInfo=dir(reportName);
    reportdate=reportFileInfo.date;

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
                    if strcmp(helpAdd(1:end-1),roots)
                        helpAdd='\';
                    end
                end
                helpAdd=helpAdd(1:end-1);
                helpPathORG=connector.getUrl([helpAdd]);
                helpPath=strrep(helpPathORG,'\','/');
            end
        end
    catch
    end

end

