


classdef WorkspaceParser<handle



    properties
        GlobalTimeVectorName=''
        GlobalTimeVectorValue=[]
        EnableLazyImport=false
        IsImportCancelled=false
    end


    methods


        function obj=WorkspaceParser()
            obj.CreatedParsers=Simulink.sdi.Map;
            obj.CustomParsers=Simulink.sdi.Map;
            obj.UncheckedParsers=Simulink.sdi.Map;
            obj.LazyImportParsers=Simulink.sdi.Map(int32(0),?handle);
            obj.LazyImportRunIDs=Simulink.sdi.Map(int32(0),logical(false));

            obj.PendingParsers={...
            'Simulink.sdi.internal.import.TimeseriesParser';...
            'Simulink.sdi.internal.import.TimetableParser';...
            'Simulink.sdi.internal.import.SimulationDatastoreParser';...
            'Simulink.sdi.internal.import.StructOfTimeseriesParser';...
            'Simulink.sdi.internal.import.StructOfTimetableParser';...
            'Simulink.sdi.internal.import.DatasetElementParser';...
            'Simulink.sdi.internal.import.DatasetParser';...
            'Simulink.sdi.internal.import.SimulationOutputParser';...
            'Simulink.sdi.internal.import.StructWithTimeParser';...
            'Simulink.sdi.internal.import.NumericArrayParser';...
            'Simulink.sdi.internal.import.FcnCallInputParser';...
            'Simulink.sdi.internal.import.CoderExecutionTimeParser';...
            'Simulink.sdi.internal.import.CoderExecutionTimeSectionParser';...
            'Simulink.sdi.internal.import.AssessmentSetParser';...
            'Simulink.sdi.internal.import.LabeledSignalSetParser';...
            'Simulink.sdi.internal.import.SLDVStructParser';...
            'Simulink.sdi.internal.import.SimscapeNodeParser';...
            'Simulink.sdi.internal.import.SimscapeSeriesParser';...
            'Simulink.sdi.internal.import.UlogreaderParser';...
            };

            fw=Simulink.sdi.internal.AppFramework.getSetFramework();
            obj.PreDeleteListener=fw.createPreRunDeleteListener(...
            @(x,y)preRepositoryDeleteCallback(obj,x,y));
        end

        registerVariableParser(this,className);
        registerCustomParser(this,obj);
        unregisterCustomParser(this,obj);

        createPendingParsers(this);

        ret=getRegisteredWorkspaceImporters(this);


        ret=parseBaseWorkspace(this);
        ret=parseMATFile(this,fname,bpath);
        out=parseVariables(this,vars);


        setVariableChecked(this,varParser,val);
        ret=isVariableChecked(this,varParser);


        runIDs=createRun(this,repo,varParsers,runName,mdlName,appName,notifyFlag);
        runIDs=addToRun(this,repo,runID,varParsers,mdlName,overwrittenRunID,addToparentID,varargin);


        addToParentSignal(this,repo,varParsers,parentID);


        resetParser(this);
    end


    methods(Static)
        ret=getDefault();
        performLazyImport(varargin);
    end


    methods(Hidden)


        preRepositoryDeleteCallback(this,h,evt)


        function startLoggingOpenModels(this)
            if isempty(this.ModelCloseUtil)
                interface=Simulink.sdi.internal.Framework.getFramework();
                this.ModelCloseUtil=getModelCloseUtil(interface);
            end
        end


        function closeOpenedModels(this)
            if~isempty(this.ModelCloseUtil)
                delete(this.ModelCloseUtil)
                this.ModelCloseUtil=[];
            end
        end


        function ret=hasLazyImportData(this)
            ret=this.LazyImportParsers.getCount()>0;
        end

    end


    methods(Access=private)
        runIDs=addToRunImpl(this,repo,runID,varParsers,onlyOneRun,mdlName,overwrittenRunID,addToparentID)
    end


    properties(Access=private)
        PendingParsers={}
CreatedParsers
CustomParsers
ModelCloseUtil
UncheckedParsers
LazyImportParsers
LazyImportRunIDs
PreDeleteListener
    end


    properties(Hidden)
ProgressTracker
    end
end
