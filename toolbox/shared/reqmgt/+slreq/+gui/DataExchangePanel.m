











classdef DataExchangePanel<handle

    properties
    end

    properties(Constant)
    end

    methods(Static)

        function dataExchangePanel=getDialogSchema(dataReq)


            isOSLC=dataReq.isOSLC();

            dataExchangePanel=struct('Type','togglepanel','LayoutGrid',[3,4]);
            dataExchangePanel.Name=getString(message('Slvnv:slreq:DataExchangePanel'));
            dataExchangePanel.Tag='DataExchangePanel';
            dataExchangePanel.Expand=slreq.gui.togglePanelHandler('get',dataExchangePanel.Tag,true);
            dataExchangePanel.ExpandCallback=@slreq.gui.togglePanelHandler;
            dataExchangePanel.RowStretch=[0,0,0];
            dataExchangePanel.ColStretch=[0,0,0,1];



            updateButton=struct('Type','pushbutton',...
            'Tag','SyncReq',...
            'Name',getString(message('Slvnv:slreq:Synchronize')),...
            'Visible',true,...
            'Enabled',~isOSLC,...
            'RowSpan',[1,1],'ColSpan',[1,1],...
            'Alignment',1,...
            'ToolTip',getString(message('Slvnv:slreq:SynchronizeTooltip')));
            updateButton.MatlabMethod='slreq.gui.DataExchangePanel.synchronize';
            updateButton.MatlabArgs={'%dialog','%source'};


            exportButton=struct('Type','pushbutton',...
            'Tag','ExportReq',...
            'Name',getString(message('Slvnv:slreq:ImportNodeExport')),...
            'Visible',true,...
            'Enabled',true,...
            'RowSpan',[1,1],'ColSpan',[2,2],...
            'Alignment',1,...
            'ToolTip',getString(message('Slvnv:slreq:ImportNodeExportTooltip')));
            exportButton.MatlabMethod='slreq.gui.DataExchangePanel.export';
            exportButton.MatlabArgs={'%dialog','%source'};


            unlockAllButton=struct('Type','pushbutton',...
            'Tag','UnlockAllReq',...
            'Name',getString(message('Slvnv:slreq:UnlockAll')),...
            'Visible',true,...
            'Enabled',~isOSLC,...
            'RowSpan',[1,1],'ColSpan',[3,3],...
            'Alignment',1,...
            'ToolTip',getString(message('Slvnv:slreq:UnlockAllTooltip')));
            unlockAllButton.MatlabMethod='slreq.gui.DataExchangePanel.unlockAll';
            unlockAllButton.MatlabArgs={'%dialog','%source'};

            dataExchangePanel.Items={updateButton,exportButton,unlockAllButton};

            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(dataReq.domain);
            if adapter.isUpdateNotificationAvailable(dataReq)
                watchUpdateStatus=struct('Type','text','RowSpan',[2,2],'ColSpan',[1,3],...
                'Alignment',1,'Tag','UpdateStatusMessage');
                watchUpdateStatus.Name=[getString(message('Slvnv:slreq:Status'))...
                ,': ',dataReq.getPendingUpdateStatus().toString];
                dataExchangePanel.Items{end+1}=watchUpdateStatus;
            end


            if isOSLC
                [~,~,importType]=slreq.gui.DataExchangePanel.getOslcTopNodeInfo(dataReq);
                if strcmp(importType,'module')
                    buttonName=getString(message('Slvnv:slreq_import:ReimportModule'));
                else
                    buttonName=getString(message('Slvnv:slreq:ConnectDialogUpdateFromServer'));
                end
                updateFromServerButton=struct('Type','pushbutton',...
                'Tag','UpdateFromServer',...
                'Name',buttonName,...
                'Visible',true,...
                'Enabled',true,...
                'RowSpan',[1,1],'ColSpan',[4,4],...
                'Alignment',1,...
                'ToolTip',getString(message('Slvnv:slreq:ConnectDialogUpdateFromServerTooltip')));
                updateFromServerButton.MatlabMethod='slreq.gui.DataExchangePanel.updateFromServer';
                updateFromServerButton.MatlabArgs={'%dialog','%source'};

                dataExchangePanel.Items{end+1}=updateFromServerButton;
            end
        end


        function synchronize(dlg,src)%#ok<INUSL>
            if isa(src,'DAStudio.DAObjectProxy')

                src=src.getMCOSObjectReference();
            end
            rmiut.progressBarFcn('set',0.1,getString(message('Slvnv:slreq_import:UpdatingDotDot',src.CustomID)));
            pbc=onCleanup(@()rmiut.progressBarFcn('delete'));
            src.synchronize();
        end


        function updateFromServer(dlg,src)


            dlg.setEnabled('UpdateFromServer',false);


            if isa(src,'DAStudio.DAObjectProxy')

                src=src.getMCOSObjectReference();
            end


            dataTopNode=src.dataModelObj;
            [dataReqSet,projectName,importType]=slreq.gui.DataExchangePanel.getOslcTopNodeInfo(dataTopNode);
            isQueryModified=false;
            if strcmp(importType,'module')
                moduleUriOrQueryBase=dataTopNode.artifactUri;
                queryString='';
            else
                moduleUriOrQueryBase=dataReqSet.getProperty('queryBase');
                queryString=slreq.gui.DataExchangePanel.confirmQueryString(dataTopNode.artifactUri);
                if isempty(queryString)
                    return;
                else
                    isQueryModified=~strcmp(queryString,dataTopNode.artifactUri);
                end
            end

            serverName=dataReqSet.getProperty('serverName');
            slreq.internal.updateFromOslcServer(serverName,projectName,moduleUriOrQueryBase,queryString,dataTopNode);



            if isQueryModified
                dataTopNode.artifactUri=queryString;
                dataTopNode.description=getString(message('Slvnv:slreq_import:DngRawQueryStringUsed',queryString));
            end
        end

        function[dataReqSet,projectName,importType]=getOslcTopNodeInfo(dataTopNode)
            dataReqSet=dataTopNode.getReqSet();
            projectName=dataReqSet.getProperty('projectName');
            importType=dataTopNode.getProperty('importType');
        end

        function out=confirmQueryString(in)
            prompt=getString(message('Slvnv:slreq_import:DngRawQueryString'));
            name=getString(message('Slvnv:slreq:ConnectDialogUpdateFromServer'));
            options.Resize='on';
            result=inputdlg(prompt,name,1,{in},options);
            if isempty(result)
                out='';
            else
                out=result{1};
            end
        end


        function export(dlg,src)%#ok<INUSL>
            if isa(src,'DAStudio.DAObjectProxy')

                src=src.getMCOSObjectReference();
            end


            if~isempty(src)&&isa(src,'slreq.das.Requirement')
                dasReqSet=src.parent;
                if isa(dasReqSet,'slreq.das.RequirementSet')
                    dasReqSet.exportToReqIF(src);
                end
            end
        end


        function unlockAll(dlg,src)%#ok<INUSL>
            if isa(src,'DAStudio.DAObjectProxy')

                src=src.getMCOSObjectReference();
            end

            if~isempty(src)
                dasReqSet=src.parent;
                if isa(dasReqSet,'slreq.das.RequirementSet')&&isa(src,'slreq.das.Requirement')
                    src.unlockAll();
                end
            end
        end
    end
end
