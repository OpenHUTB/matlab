classdef Editor<lutdesigner.service.RemotableObject

    properties(Hidden,Constant)
        Channel=struct(...
        'Base','/lutdesigner/editor',...
        'PeerWrite','peerWrite',...
        'ChartFailure','chartFailure'...
        );
    end

    properties(SetAccess=immutable)
Access
    end

    properties(SetAccess=private)
Proxy
ReadRestrictions
WriteRestrictions
DataTransactionStrategy
Model
Chart
    end

    properties(SetAccess=immutable,GetAccess=private)
MessageService
    end

    properties(SetAccess=immutable)
PeerWriteEventChannel
ChartFailureEventChannel
    end

    properties(Access=private)
DirtyStateChangeListener
ChartFailureListeners
    end

    methods
        function this=Editor(access,testDepConfig)
            if~exist('testDepConfig','var')
                testDepConfig=struct;
            end

            if isfield(testDepConfig,'MessageService')
                this.MessageService=testDepConfig.MessageService;
            else
                this.MessageService=message.internal.MessageService(this.RemoteID);
            end

            this.PeerWriteEventChannel=sprintf('%s/%s/%s',this.Channel.Base,this.RemoteID,this.Channel.PeerWrite);
            this.ChartFailureEventChannel=sprintf('%s/%s/%s',this.Channel.Base,this.RemoteID,this.Channel.ChartFailure);

            this.Access=access;
            this.updateDataProxy(access.getDataProxy());
            this.updateAccessRestrictionSnapshot();

            this.DataTransactionStrategy=lutdesigner.editor.DataTransactionStrategy.create(this.Proxy);
            this.Model=this.DataTransactionStrategy.createDataModelFor(this.Proxy);
            this.Chart=containers.Map;
            this.ChartFailureListeners=containers.Map;

            this.DirtyStateChangeListener=addlistener(this.Model,'IsDirty','PostSet',...
            @(~,eventData)this.updateDataSourceLock(eventData));
        end

        function delete(this)
            dataUsage=this.Proxy.listDataUsage();
            arrayfun(@(du)du.DataSource.unregisterPeerLockUnlockHandler(),dataUsage);
            arrayfun(@(du)du.DataSource.unregisterPeerWriteHandler(),dataUsage);
            delete(this.DirtyStateChangeListener);
            if~isempty(this.Chart)&&isvalid(this.Chart)
                chartTypes=this.Chart.keys();
                for i=1:numel(chartTypes)
                    this.removeChart(chartTypes{i});
                end
            end
            delete@lutdesigner.service.RemotableObject(this);
        end

        function changeDetails=syncDataBase(this)
            proxy=this.Access.getDataProxy();
            hasDataUsageChange=~isequal(proxy,this.Proxy);


            newDataUsage=proxy.listDataUsage();
            newReadRestrictions=arrayfun(@(du)du.DataSource.getReadRestrictions(),newDataUsage,'UniformOutput',false);
            newReadRestrictions=vertcat(newReadRestrictions{:});
            newWriteRestrictions=arrayfun(@(du)du.DataSource.getWriteRestrictions(),newDataUsage,'UniformOutput',false);
            newWriteRestrictions=vertcat(newWriteRestrictions{:});
            hasAccessRestrictionChange=~isequal(newReadRestrictions,this.ReadRestrictions)||~isequalExceptPeerLock(newWriteRestrictions,this.WriteRestrictions);

            if hasDataUsageChange
                this.updateDataProxy(proxy);
                this.DataTransactionStrategy=lutdesigner.editor.DataTransactionStrategy.create(this.Proxy);
            end

            if hasAccessRestrictionChange
                this.updateAccessRestrictionSnapshot();
            end

            result=compareBaselineData(this.Model,...
            this.DataTransactionStrategy.createDataModelFor(proxy));

            changeDetails=struct(...
            'HasDataUsageChange',hasDataUsageChange,...
            'HasAccessRestrictionChange',hasAccessRestrictionChange,...
            'HasContentChange',result.HasContentDifference,...
            'HasNumDimsChange',result.HasNumDimsDifference);
        end
    end

    methods
        function dataUsage=getDataUsage(this)
            dataUsage=toStruct(this.Proxy.listDataUsage());
            for i=1:numel(dataUsage)
                fieldPath=dataUsage(i).UsedAs;
                fieldPathParts=strsplit(fieldPath,'/');
                fieldPathParts(1)=[];
                if strcmp(fieldPathParts{1},'Axes')
                    axisIndex=str2double(fieldPathParts{2});
                    dataUsage(i).UsedAs=strjoin({'/Axes',num2str(axisIndex-1),fieldPathParts{3:end}},'/');
                elseif numel(fieldPathParts)==1&&~ismember(fieldPathParts{1},{'','Axes','Table'})

                    dataUsage(i).UsedAs=strjoin({'/Table',fieldPathParts{1}},'/');
                end
            end
        end

        function dataModelID=getDataModelId(this)
            dataModelID=this.Model.getClientID();
        end

        function applyDataChange(this)
            this.DataTransactionStrategy.writeToDataSource(this.Proxy,this.Model);
            this.Model.clearHistory();
        end

        function revertDataChange(this)
            this.DataTransactionStrategy.readFromDataSource(this.Proxy,this.Model);
        end

        function dfPacket=addChart(this,chartType)
            fig=matlab.ui.internal.divfigure(...
            'Tag',chartType,...
            'Color',[1,1,1],...
            'Units','pixels',...
            'Position',[0,0,100,100],...
            'AutoResizeChildren','off');
            this.Chart(chartType)=lutdesigner.editor.chart.Chart(fig,chartType,this.Model);
            this.ChartFailureListeners(chartType)=addlistener(this.Chart(chartType),'Failure',@(src,~)this.notifyChartFailure(src));
            startup(this.Chart(chartType));
            dfPacket=matlab.ui.internal.FigureServices.getDivFigurePacket(fig);
        end

        function removeChart(this,chartType)
            if this.ChartFailureListeners.isKey(chartType)
                if isvalid(this.ChartFailureListeners(chartType))
                    delete(this.ChartFailureListeners(chartType));
                end
            end
            if this.Chart.isKey(chartType)
                if isvalid(this.Chart(chartType))
                    if isvalid(this.Chart(chartType).Figure)
                        close(this.Chart(chartType).Figure);
                    end
                    delete(this.Chart(chartType));
                end
                this.Chart.remove(chartType);
            end
        end
    end

    methods(Access=private)
        function updateDataSourceLock(this,eventData)
            dataUsage=this.Proxy.listDataUsage();
            if eventData.AffectedObject.IsDirty
                arrayfun(@(du)lock(du.DataSource,this.Access.Path),dataUsage);
            else
                arrayfun(@(du)unlock(du.DataSource),dataUsage);
            end
        end

        function updateDataProxy(this,dataProxy)
            if~isempty(this.Proxy)
                dataUsage=this.Proxy.listDataUsage();
                arrayfun(@(du)du.DataSource.unregisterPeerLockUnlockHandler(),dataUsage);
                arrayfun(@(du)du.DataSource.unregisterPeerWriteHandler(),dataUsage);
            end

            this.Proxy=dataProxy;
            dataUsage=dataProxy.listDataUsage();
            if~isempty(this.Model)&&this.Model.isUndoActionAvailable()
                arrayfun(@(du)lock(du.DataSource,this.Access.Path),dataUsage);
            end
            arrayfun(@(du)du.DataSource.registerPeerLockUnlockHandler(@(eventData)this.reactToPeerLockUnlock()),dataUsage);
            arrayfun(@(du)du.DataSource.registerPeerWriteHandler(@()this.notifyPeerWrite(du)),dataUsage);
        end

        function updateAccessRestrictionSnapshot(this)
            dataUsage=this.Proxy.listDataUsage();
            readRestrictions=arrayfun(@(du)du.DataSource.getReadRestrictions(),dataUsage,'UniformOutput',false);
            this.ReadRestrictions=vertcat(readRestrictions{:});
            writeRestrictions=arrayfun(@(du)du.DataSource.getWriteRestrictions(),dataUsage,'UniformOutput',false);
            this.WriteRestrictions=vertcat(writeRestrictions{:});
        end

        function notifyPeerWrite(this,dataUsage)
            this.MessageService.publish(this.PeerWriteEventChannel,struct('UsedAs',dataUsage.UsedAs));
        end

        function reactToPeerLockUnlock(this)
            features=this.DataTransactionStrategy.getDisablePropertyEditFeaturesForDataSource(this.Proxy);
            this.Model.updateDisablePropertyEditFeatures(features);

            this.updateAccessRestrictionSnapshot();
        end

        function notifyChartFailure(this,src)
            this.MessageService.publish(this.ChartFailureEventChannel,struct('ChartType',src.ChartType));
        end
    end
end
