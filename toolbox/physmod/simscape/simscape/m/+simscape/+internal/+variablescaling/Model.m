classdef Model<simscape.internal.variablescaling.Base




    properties(SetAccess=private)
        Name=char.empty;
        Status simscape.internal.variablescaling.ModelStatus;
        Data=Simulink.SimulationData.Dataset.empty;
        WarningMessage='';
        ErrorMessage='';
    end

    properties(Access=private)
        ModelCloser=onCleanup.empty;
        ListenerHandles=event.listener.empty;
        VariableUnitsInfo;
        Solver='';
        StateNames;
    end

    properties(Constant,Access=private)
        InternalDataSettings=struct("ReturnWorkspaceOutputs",'on',...
        "ReturnWorkspaceOutputsName",'out',...
        "SaveState",'on',...
        "StateSaveName",'analyzer_xout',...
        "SaveFormat",'Dataset',...
        "LimitDataPoints",'off',...
        "SimulationMode",'normal',...
        "FastRestart",'off');
    end

    events
StatusChanged
ValueChanged
    end

    methods
        function obj=Model(name)

            obj.Status=simscape.internal.variablescaling.ModelStatus.Uninitialized;
            if nargin>0
                obj.mustBeSimulinkModelName(name);
                obj.open(name);
            end
        end

        function obj=open(obj,fullname)
            oldStatus=obj.Status;
            try
                if~isempty(fullname)


                    [~,name,ext]=fileparts(fullname);
                    if~isempty(ext)&&~strcmpi(ext,'.slx')&&~strcmpi(ext,'.mdl')
                        pm_error('physmod:simscape:simscape:variablescaling:ErrorInvalidModel',fullname);
                    end
                    if~bdIsLoaded(name)
                        obj.setModelStatus('Opening');
                        open_system(name);

                        obj.ModelCloser=onCleanup(@()obj.closeModel);
                    else





                        if~strcmp(obj.Name,name)
                            obj.setModelStatus('Opening');
                            delete(obj.ModelCloser);
                        end
                    end

                    obj.Name=name;
                    obj.initialize;
                end
            catch ME
                obj.setModelStatus(oldStatus);
                rethrow(ME);
            end
        end

        function result=getNominalUnitForState(obj,stateName)
            idx=obj.getInfoIndexForState(stateName);
            if isempty(idx)
                result=obj.getStandardCatalogMessage('Unknown');
            else
                value=obj.VariableUnitsInfo(idx).nominalValue;



                if obj.VariableUnitsInfo(idx).isNominalSourceDerived
                    unit=obj.getSimpleEquivalentUnit(obj.VariableUnitsInfo(idx).nominalUnit);
                else
                    unit=obj.VariableUnitsInfo(idx).nominalUnit;
                end
                result="{"+string(value)+", '"+string(unit)+"'}";
            end
        end

        function result=getBlockNameForState(obj,stateName)
            idx=obj.getInfoIndexForState(stateName);
            if isempty(idx)
                result=obj.getStandardCatalogMessage('Unknown');
            else
                result=obj.VariableUnitsInfo(idx).object;
            end
        end

        function value=startTime(obj)
            obj.assertReady;
            t=get_param(obj.Name,"StartTime");
            value=obj.evalExpression(t);
        end

        function value=stopTime(obj)
            obj.assertReady;
            t=get_param(obj.Name,"StopTime");
            value=obj.evalExpression(t);
        end

        function run(obj)
            obj.assertReady;
            obj.setModelStatus('Running');
            statusCleaner=onCleanup(@()obj.setModelStatus('Ready'));
            try
                warningState=warning('off','all');
                warnCleaner=onCleanup(@()(warning(warningState)));
                lastwarn('');
                storeObsState=simscape.internal.storeObservablesFlag(1);
                obsStateCleaner=onCleanup(@()(simscape.internal.storeObservablesFlag(storeObsState)));
                oldCaching=simscape.internal.cacheMethod(simscape.internal.CacheMethodType.None);
                cachingCleaner=onCleanup(@()(simscape.internal.cacheMethod(oldCaching)));
                out=sim(obj.Name,obj.InternalDataSettings);
                obj.ErrorMessage='';
                obj.VariableUnitsInfo=simscape.internal.getObservables(obj.Name);
                obj.updateStateNames;
            catch ME
                obj.ErrorMessage=ME.message;
            end
            obj.Solver=get_param(obj.Name,'CompiledSolverName');
            if isempty(obj.ErrorMessage)
                obj.WarningMessage=lastwarn;
                obj.Data=out.analyzer_xout;
            end
            delete(statusCleaner);
            notify(obj,'ValueChanged');
        end

        function result=absTol(obj)

            obj.assertReady;
            result=get_param(obj.Name,"AbsTol");
            if strcmpi(result,'auto')
                rtol=obj.relTol;
                if obj.isDaesscSolver
                    result=rtol;
                else
                    if rtol>1e-3
                        result=1e-6;
                    else
                        result=rtol*1e-3;
                    end
                end
            else
                result=obj.evalExpression(result);
            end
        end

        function result=relTol(obj)
            obj.assertReady;
            result=get_param(obj.Name,"RelTol");
            if strcmpi(result,'auto')
                result=1e-3;
            else
                result=obj.evalExpression(result);
            end
        end

        function result=autoAbsTolValues(obj,state)
            if~isvector(state)
                pm_error('physmod:simscape:simscape:variablescaling:ErrorVectorState');
            end
            result=zeros(size(state));
            result(1)=obj.absTol;
            maxstate=cummax(abs(state));
            result(2:end)=obj.relTol*maxstate(1:(end-1));
        end

        function result=isAutoScaleAbsTol(obj)
            obj.assertReady;
            p=get_param(obj.Name,'AutoScaleAbsTol');
            result=strcmpi(p,'on')&&~obj.isDaesscSolver;
        end

        function result=isEnabledNominalValues(obj)
            obj.assertReady;
            p=get_param(obj.Name,'SimscapeNormalizeSystem');
            result=strcmpi(p,'on');
        end

        function delete(obj)
            delete(obj.ListenerHandles);
            delete(obj.ModelCloser);
            delete(obj.Status);
        end
    end

    methods(Access=private)
        function updateStatus(obj,~,local_event)
            if isvalid(obj)
                switch local_event.EventName
                case 'SLGraphicalEvent::CLOSE_MODEL_EVENT'
                    if strcmp(local_event.Source.Name,obj.Name)
                        obj.setModelStatus('Closed');
                        obj.ModelCloser=onCleanup.empty;
                        obj.ListenerHandles=event.listener.empty;
                        obj.VariableUnitsInfo=struct.empty;
                    end
                otherwise
                    pm_error('physmod:simscape:simscape:variablescaling:UnrecognizedEvent');
                end
            end
        end

        function assertReady(obj)
            import simscape.internal.variablescaling.ModelStatus;
            if obj.Status~=ModelStatus.Ready&&obj.Status~=ModelStatus.Running
                pm_error('physmod:simscape:simscape:variablescaling:InaccessibleModel');
            end
        end

        function initialize(obj)
            import simscape.internal.variablescaling.ModelStatus;
            if obj.Status~=ModelStatus.Ready
                obj.setModelStatus('Ready');
                obj.Data=Simulink.SimulationData.Dataset.empty;
                obj.WarningMessage='';
                obj.ErrorMessage='';
                obj.VariableUnitsInfo=[];
                obj.StateNames=[];
                obj.Solver='';
            end


            internalObject=get_param(obj.Name,'InternalObject');
            if~isempty(obj.ListenerHandles)
                if isvalid(obj.ListenerHandles(1))
                    delete(obj.ListenerHandles(1));
                end
            end
            obj.ListenerHandles(1)=listener(internalObject,'SLGraphicalEvent::CLOSE_MODEL_EVENT',@(source,event)obj.updateStatus(source,event));
        end

        function setModelStatus(obj,status)
            import simscape.internal.variablescaling.ModelStatus;
            if obj.Status~=ModelStatus(status)
                obj.Status=ModelStatus(status);
                notify(obj,'StatusChanged');
            end
        end

        function closeModel(obj)
            import simscape.internal.variablescaling.ModelStatus;
            if obj.Status~=ModelStatus.Closed...
                &&obj.Status~=ModelStatus.Uninitialized
                doClose=true;
                if bdIsDirty(obj.Name)
                    answer=questdlg(obj.getStandardCatalogMessage('SaveConfirmation',obj.Name),...
                    obj.getStandardCatalogMessage('MessageDialog'),...
                    obj.getStandardCatalogMessage('Yes'),...
                    obj.getStandardCatalogMessage('No'),...
                    obj.getStandardCatalogMessage('Cancel'),...
                    obj.getStandardCatalogMessage('Yes'));
                    switch answer
                    case obj.getStandardCatalogMessage('Yes')
                        save_system(obj.Name);
                    case obj.getStandardCatalogMessage('Cancel')
                        doClose=false;
                    otherwise

                    end
                end
                if doClose

                    close_system(obj.Name,0);
                end
            end
        end

        function index=getInfoIndexForState(obj,state)
            if~isempty(obj.VariableUnitsInfo)
                if iscell(state)
                    cdex=find(char(state{1})=='.',1,'first');
                    state=state{1}((cdex+1):end);
                else
                    charstate=char(state);
                    cdex=find(charstate=='.',1,'first');
                    state=charstate((cdex+1):end);
                end

                index=find(strcmp(state,obj.StateNames));
                if length(index)>1
                    pm_error('physmod:simscape:simscape:variablescaling:TooManyStates');
                end
            else
                index=[];
            end
        end

        function result=isDaesscSolver(obj)
            switch obj.Solver
            case 'daessc'
                result=true;
            case{'','VariableStepAuto','FixedStepAuto'}
                pm_warning('physmod:simscape:simscape:variablescaling:SolverNameNotUpdated');
                result=false;
            otherwise
                result=false;
            end
        end

        function updateStateNames(obj)
            if~isempty(obj.VariableUnitsInfo)
                obj.StateNames=arrayfun(@(x)(x.fullpath),obj.VariableUnitsInfo,'UniformOutput',false);
            else
                obj.StateNames=[];
            end
        end

        function result=evalExpression(obj,expr)
            result=expr;
            [val,isResolved]=slResolve(expr,obj.Name);
            if isResolved
                result=val;
            else
                h=errordlg(obj.getStandardCatalogMessage('UnrecognizedVariable',expr));
                uiwait(h);
            end
        end
    end
end
