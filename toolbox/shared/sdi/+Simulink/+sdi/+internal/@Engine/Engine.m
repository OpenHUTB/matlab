classdef Engine<matlab.mixin.SetGet



    properties(SetAccess='private',GetAccess='public',Hidden=true)
Listeners
RecordStatus
CurrentModel
OnCreateRun
instanceID
simStatus
run1ID
run2ID
fileName
    end

    properties(Access='public',Hidden=true)

DiffRunResult


newRunIDs


warnDialogParam


runNumByRunID


comparedSignal1
comparedSignal2


comparedRun1
comparedRun2


engineViewsData


updatePlotFunctionHandle

diffRunsID1
diffRunsID2


ReportManager

slddSource
sigRepository


showRunAtTop


isUpdate


runNameModel


WksParser
FileImporter


WksExporter
FileExporter


HighlightCallbacks


IsMetaDataUpdateRegistered


        PCTSupportMode=''
PCTPoolListener
PCTProcessTimer
PCTDataQueueFromWorker
PCTDataQueueToWorker
PCTRequestedSignalStreams
        IsParPoolConnected=false
    end

    events
runNameChangeEvent
signalDeleteEvent
runDeleteEvent
clearSDIEvent
runAddedEvent
compareRunsEvent
recompareSignalsEvent
runsAndSignalsDeleteEvent
        runMetaDataUpdated;


propertyChangeEvent
treeSignalPropertyEvent


treeRunPropertyEvent


loadSaveEvent


signalsInsertedEvent


transactionBegin
transactionEnd


preDeleteEvent
    end

    properties(SetObservable,Access='public',Hidden=true)

updateFlag


loadListener


dirty


runNameTemplate
    end

    properties(Constant,Hidden=true)
        defaultRunNametemplate='Run <run_index>: <model_name>';
    end

    methods(Hidden=true)
        function setDiffRunResult(this,comparisonRunID)
            if 0==comparisonRunID
                error(message('SDI:sdi:InvalidRunID'));
            end

            this.DiffRunResult=Simulink.sdi.DiffRunResult(comparisonRunID,this);
            this.diffRunsID1=this.DiffRunResult.RunID1;
            this.diffRunsID2=this.DiffRunResult.RunID2;
            if this.DiffRunResult.Count
                ret=this.DiffRunResult.getLastComparedPairIDs();
                if~isempty(ret.compareToID)
                    this.comparedSignal1=ret.baselineID;
                    this.comparedSignal2=ret.compareToID;
                end
            end
        end
    end

    methods
        function this=Engine(varargin)

            ?Simulink.sdi.SessionSaveLoad;

            if~isempty(varargin)&&isa(varargin{1},'sdi.Repository')
                this.sigRepository=varargin{1};
                this.slddSource=this.sigRepository.getSource();
                isMainEng=true;
            else
                this.sigRepository=sdi.Repository();
                this.slddSource=this.sigRepository.getSource();
                isMainEng=false;
            end

            this.Listeners=handle.listener('','','');
            this.RecordStatus=false;

            persistent highWaterMark;


            if isempty(highWaterMark)
                highWaterMark=uint32(0);
            end


            highWaterMark=highWaterMark+1;
            this.instanceID=highWaterMark;


            this.simStatus=true;


            this.runNumByRunID=Simulink.sdi.Map(int32(0),int32(0));
            this.isUpdate=true;


            this.dirty=false;

            this.HighlightCallbacks=Simulink.sdi.Map;


            this.FileExporter=Simulink.sdi.internal.export.FileExporter;


            this.IsMetaDataUpdateRegistered=false;


            if isMainEng
                fw=Simulink.sdi.internal.SDIAppFramework(this);
                Simulink.sdi.internal.AppFramework.getSetFramework(fw);
            end
            interface=Simulink.sdi.internal.Framework.getFramework();
            interface.registerEnginePlugins(this,isMainEng);
        end

        function init(this)


            try
                isPCTWorker=~isempty(getCurrentWorker());
                if~isPCTWorker
                    opt=Simulink.sdi.getDefaultPCTSupportMode();
                    this.enablePCTSupport(opt);
                end
            catch me %#ok<NASGU>

                this.PCTSupportMode='shutdown';
                isPCTWorker=false;
            end

            if~isPCTWorker
                Simulink.sdi.internal.Engine.registerPluggableVisualizations();
            end
        end

        function delete(this)
            this.DiffRunResult=[];
            if~isempty(this.PCTPoolListener)
                delete(this.PCTPoolListener);
            end
            if~isempty(this.PCTProcessTimer)
                stop(this.PCTProcessTimer);
                delete(this.PCTProcessTimer);
            end
        end

        function setDirty(this,val,~)
            this.dirty=val;
        end





        function value=get.DiffRunResult(this)
            if isempty(this.DiffRunResult)
                this.DiffRunResult=Simulink.sdi.DiffRunResult;
            end
            value=this.DiffRunResult;
        end

        function value=get.ReportManager(this)
            if isempty(this.ReportManager)
                this.ReportManager=Simulink.sdi.internal.ReportManager(this);
            end
            value=this.ReportManager;
        end

        function set.dirty(this,value)
            if islogical(value)&&(isempty(this.dirty)||(this.dirty~=value))
                this.dirty=value;
            end
        end

        function set.runNameTemplate(this,value)
            if ischar(value)
                this.sigRepository.setRunNameTemplate(value);%#ok<MCSUP>
            else
                error(message('SDI:sdi:INVALID_SIGNATURE'));
            end
        end

        function out=get.runNameTemplate(this)
            out=this.sigRepository.getRunNameTemplate();
        end

        function set.showRunAtTop(this,value)
            this.sigRepository.setShowRunAtTop(value);%#ok<MCSUP>
        end

        function out=get.showRunAtTop(this)
            out=this.sigRepository.getShowRunAtTop();
        end

        function out=get.WksParser(~)
            out=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
        end

        function out=get.FileImporter(~)
            out=Simulink.sdi.internal.import.FileImporter.getDefault();
        end

        function out=get.WksExporter(~)
            out=Simulink.sdi.internal.export.WorkspaceExporter.getDefault();
        end

        function ret=isParallelPoolSetup(this,varargin)
            if~isempty(varargin)
                this.IsParPoolConnected=varargin{1};
            end
            ret=~isempty(this.IsParPoolConnected)&&this.IsParPoolConnected;
        end

    end

    methods(Access='private')
        out=getSignalUsingSLDD(this,sigID);
    end

    methods(Static=true)


        prefStruct=getPrefOptions(appVariant);


        ret=highlightSignal(sid,bpath,portIdx,metaData);


        [varargout]=compare(ts1,ts2,varargin);


        [tolStruct,syncStruct]=defaultTolAndSyncOptions();

        globalStruct=defaultGlobalTolOptionsForV2();


        [ts]=helperCreateTimeseriesForExport(time,data,type,bAllEmptyChunks,bCreateSeed);

        registerPluggableVisualizations();
    end

end


