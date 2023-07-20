classdef FolderRunManager<handle

    properties(SetAccess=protected)
subscriptionN
subscriptionS
clientId
clientName
UI
targetObj

    end
    methods
        function obj=FolderRunManager(clientId,clientName,UI)
            obj.clientId=clientId;
            obj.clientName=clientName;
            obj.UI=UI;
            obj.subscriptionN=message.subscribe(strcat('/',obj.UI,'/',clientId,'/runNode'),@(msg)obj.runNode(msg));
            obj.subscriptionS=message.subscribe(strcat('/',obj.UI,'/',clientId,'/syncNode'),@(msg)obj.syncNode(msg));

            appObj=Advisor.Manager.getApplication('id',clientId);
            obj.targetObj=appObj.getMAObjs{1,1};

        end
        function cleanup(obj)
            message.unsubscribe(obj.subscriptionN);
            message.unsubscribe(obj.subscriptionS);
        end


        function runNode(obj,msg)
            selectedNode=obj.targetObj.getTaskObj(msg{1,1});
            selectedNode.runTaskAdvisor;

            if isa(selectedNode,'ModelAdvisor.Task')
                isFolder=false;
            else
                isFolder=true;
            end

            if isFolder||isempty(selectedNode.Check.Action)
                actioninfo=struct('actionname','','actiondescription','','actionenable','');
            else
                actioninfo=struct('actionname',selectedNode.Check.Action.Name,'actiondescription',selectedNode.Check.Action.Description,'actionenable',selectedNode.Check.Action.Enable);
            end

            nodesinfo=repmat(struct('id','','state','','icon',''),0);

            if isFolder
                nodesinfo(end+1)=struct('id',selectedNode.ID,'state',selectedNode.State,'icon',selectedNode.getDisplayIcon);
            end

            parentNode=selectedNode.getParent;
            while~isempty(parentNode)
                nodesinfo(end+1)=struct('id',parentNode.ID,'state',parentNode.State,'icon',parentNode.getDisplayIcon);%#ok<AGROW>
                parentNode=parentNode.getParent;
            end

            if isFolder
                resultinhtml='';
                childrenNodes=selectedNode.getAllChildren;

                for i=1:numel(childrenNodes)
                    if childrenNodes{i}.Selected
                        nodesinfo(end+1)=struct('id',childrenNodes{i}.ID,'state',childrenNodes{i}.State,'icon',childrenNodes{i}.getDisplayIcon);%#ok<AGROW>
                    end
                end
            else
                resultinhtml=selectedNode.Check.ResultInHTML;
            end









            reportName=obj.targetObj.generateReport(selectedNode);
            C=strsplit(pwd,'\\');
            root='';
            for i=1:size(C,2)-1
                root=strcat(root,C(1,i),'\');
            end
            roots=root{1,1}(1:end-1);

            contentUrlPath=connector.addStaticContentOnPath('root',roots);



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
            reportpath=strrep(reportPathORG,'\','/');
            reporttime=date;

            dataStruct=struct('state',selectedNode.State,'iconUri',selectedNode.getDisplayIcon,'resultinhtml',resultinhtml,...
            'actioninfo',actioninfo,'nodesinfo',nodesinfo,'reportpath',reportpath,'reporttime',reporttime);

            result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonencode(dataStruct));
            resultJSON=jsonencode(result);
            message.publish(strcat('/',obj.UI,'/',obj.clientId,'/runNodeResult'),resultJSON);
        end

        function syncNode(obj,msg)
            selectedNode=obj.targetObj.getTaskObj(msg{1});
            selectedNode.changeSelectionStatus(msg{2});
        end
    end
end