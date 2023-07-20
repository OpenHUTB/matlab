






classdef(Abstract)FigureObject<handle&matlab.mixin.Heterogeneous
    properties(Transient=true)
CanvasId
Metadata
    end

    properties(Dependent)
Title
    end

    properties
        DataSourceLabels(1,1)=struct
    end

    properties(Hidden=true)
MATLABFigure
        TestingMode=false
    end

    properties(Access=protected)
MATLABFigureAxes
DataFormatter
    end

    properties(Hidden=true,SetAccess=private,Transient=true)
DataModel
    end

    properties(Access=protected,Transient=true)
Sync
MF0Channel
CommandModel
CommandSync
MF0CommandChannel
FigureObjectConnector
    end

    properties(Abstract,Transient=true)
FigureProperties
    end

    properties(Access=private)
DataModelJSON
    end

    events
FigureCreated
FigureClicked
AxesClicked
    end

    methods
        function obj=FigureObject(MATLABFig,figPropertiesDataModel)
            if~isempty(MATLABFig)
                ef=MATLABFig;
                obj.MATLABFigureAxes=ef.CurrentAxes;
            else
                ef=matlab.ui.internal.embeddedfigure;
                obj.MATLABFigureAxes=axes(ef);
                obj.MATLABFigure.Color=[1,1,1];
                obj.MATLABFigureAxes.Box='on';
            end
            ef.AutoResizeChildren='off';

            efPacket=matlab.ui.internal.FigureServices.getEmbeddedFigurePacket(ef);
            obj.MATLABFigure=ef;
            obj.Metadata=jsonencode(efPacket);

            obj.setupFigurePropertyListeners();

            obj.setupDataModel(figPropertiesDataModel);
        end

        function out=get.Title(obj)
            out=obj.MATLABFigureAxes.Title.String;
        end

        function set.Title(obj,newTitle)
            obj.updateFigureTitle(newTitle);
        end

        function dataLabel=getLabelFromId(obj,sourceId)
            if isfield(obj.DataSourceLabels,sourceId)
                dataSourceLabel=obj.DataSourceLabels.(sourceId);
            else
                dataSourceLabel=sourceId;
            end
            dataLabel=regexprep(dataSourceLabel,'[{}_]','\\$0');
            dataLabel=strrep(dataLabel,newline,'\newline');
        end


        function finalizeDataSources(obj)
            obj.FigureProperties.DataSourcesFinalized=true;
        end

        function savedObj=saveobj(obj)
            savedObj=obj;
            serializer=mf.zero.io.JSONSerializer;
            savedObj.DataModelJSON=serializer.serializeToString(obj.DataModel);
        end
    end

    methods(Abstract)


        selectRuns(obj,runIds)


        deselectRuns(obj,runIds)
        createConnector(obj)
        commandHandler(obj,report)
        addDataSources(obj,dataSources)
        reset(obj)
    end

    methods
        function delete(obj)
            if obj.TestingMode
                return;
            end

            delete(obj.MATLABFigure);
            delete(obj.FigureObjectConnector);
            delete(obj.Sync);
            delete(obj.DataModel);
            delete(obj.CommandSync);
            delete(obj.CommandModel);
        end
    end

    methods(Access=private)
        function updateFigureTitle(obj,newTitle)
            obj.MATLABFigureAxes.Title.String=newTitle;
            obj.FigureProperties.Title=newTitle;
        end

        function setupFigurePropertyListeners(obj)
            addlistener(obj.MATLABFigureAxes.Title,'String','PostSet',@(~,propEvent)obj.titleChangeHandler(propEvent));
            addlistener(obj.MATLABFigureAxes,'MarkedClean',@obj.markedCleanCB);
        end

        function titleChangeHandler(obj,propEvent)
            obj.FigureProperties.Title=propEvent.AffectedObject.String;
        end

        function setupDataModel(obj,figPropertiesDataModel)
            if isempty(figPropertiesDataModel)
                obj.DataModel=mf.zero.Model;
            else
                obj.DataModel=figPropertiesDataModel;
                obj.FigureProperties=obj.DataModel.topLevelElements;
            end
            obj.CanvasId=obj.DataModel.UUID;

            obj.CommandModel=mf.zero.Model;
            obj.CommandModel.addObservingListener(@obj.commandHandler);

            syncChannel=['/slsim/design/simmanager/figure/',obj.CanvasId];
            connectorChannel=mf.zero.io.ConnectorChannelMS(syncChannel,syncChannel);
            obj.Sync=mf.zero.io.ModelSynchronizer(obj.DataModel,connectorChannel);
            obj.MF0Channel=connectorChannel;
            obj.Sync.start();

            commandSyncChannel=[syncChannel,'/command'];
            commandChannel=mf.zero.io.ConnectorChannelMS(commandSyncChannel,commandSyncChannel);
            obj.CommandSync=mf.zero.io.ModelSynchronizer(obj.CommandModel,commandChannel);
            obj.MF0CommandChannel=commandChannel;
            obj.CommandSync.start();
        end
    end

    methods(Access=protected)
        function markedCleanCB(~,~,~)



        end
    end
end
