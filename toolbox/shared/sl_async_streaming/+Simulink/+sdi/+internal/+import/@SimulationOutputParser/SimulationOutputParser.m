classdef SimulationOutputParser<Simulink.sdi.internal.import.VariableParser





    properties
ElementName
    end


    methods


        function ret=supportsType(~,obj)
            ret=...
            isa(obj,'Simulink.SimulationOutput')&&...
            isscalar(obj);
            if ret
                vars=who(obj);
                ret=~isempty(vars);
            end
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(~)
            ret='';
        end


        function ret=getDataSource(~)
            ret='';
        end


        function ret=getBlockSource(~)
            ret='';
        end


        function ret=getSID(~)
            ret='';
        end


        function ret=getModelSource(~)
            ret='';
        end


        function ret=getSignalLabel(this)
            if isempty(this.ElementName)
                ret=this.VariableName;
            else
                ret=this.ElementName;
            end
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=[];
        end


        function ret=getSampleDims(~)
            ret=[];
        end


        function ret=getInterpolation(~)
            ret='';
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(~)
            ret=[];
        end


        function ret=getDataValues(~)
            ret=[];
        end


        function ret=isHierarchical(~)
            ret=true;
        end


        function ret=getChildren(this)



            if isempty(this.ElementName)
                names=who(this.VariableValue);
                numChildren=length(names);
                ret=cell(1,0);
                for idx=1:numChildren
                    var.VarName=sprintf('%s.get(''%s'')',this.VariableName,names{idx});
                    var.VarValue=get(this.VariableValue,names{idx});
                    childParsers=parseVariables(this.WorkspaceParser,var);
                    if isempty(childParsers)
                        continue
                    end

                    for idx2=1:numel(childParsers)
                        if isHierarchical(childParsers{idx2})
                            ret{end+1}=childParsers{idx2};%#ok<AGROW>
                        else
                            ret{end+1}=Simulink.sdi.internal.import.SimulationOutputParser;%#ok<AGROW>
                            ret{end}.VariableName=var.VarName;
                            ret{end}.ElementName=names{idx};
                            ret{end}.VariableValue=this.VariableValue;
                            ret{end}.WorkspaceParser=this.WorkspaceParser;
                        end
                        ret{end}.Parent=this;
                    end
                end
            else
                vars.VarName=this.ElementName;
                vars.VarValue=get(this.VariableValue,this.ElementName);
                ret=parseVariables(this.WorkspaceParser,vars);
                for idx=1:length(ret)
                    ret{idx}.Parent=this;
                end
            end
        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(~)
            ret=false;
        end


        function ret=getRepresentsRun(this)
            ret=isempty(this.ElementName);
        end


        function setRunMetaData(this,~,runID)
            try
                metaData=getSimulationMetadata(this.VariableValue);
            catch me %#ok<NASGU>

                return
            end


            if isempty(metaData)
                return
            end
            Simulink.sdi.internal.import.SimulationOutputParser.setMetaDataForRun(metaData,runID);
        end
    end


    methods(Static)


        function setMetaDataForRun(metaData,runID)
            solverType='';
            solverName='';
            platform='';
            stepSize='';
            stopEvent='';
            stopEventSource='';
            stopEventDesc='';
            execErrors='';
            execWarnings='';
            userString='';
            modelUpdateTime=0;
            modelSimTime=0;
            modelTermTime=0;
            modelTotalTime=0;


            slVersionStr=sprintf('%s %s %s',...
            metaData.ModelInfo.SimulinkVersion.Name,...
            metaData.ModelInfo.SimulinkVersion.Version,...
            metaData.ModelInfo.SimulinkVersion.Release);
            if isfield(metaData.ModelInfo,'Platform')
                platform=metaData.ModelInfo.Platform;
            end


            if isfield(metaData.ModelInfo,'SolverInfo')
                if isfield(metaData.ModelInfo.SolverInfo,'Type')
                    solverType=metaData.ModelInfo.SolverInfo.Type;
                end
                if isfield(metaData.ModelInfo.SolverInfo,'Solver')
                    solverName=metaData.ModelInfo.SolverInfo.Solver;
                end
                if isfield(metaData.ModelInfo.SolverInfo,'MaxStepSize')
                    stepSize=num2str(metaData.ModelInfo.SolverInfo.MaxStepSize);
                elseif isfield(metaData.ModelInfo.SolverInfo,'FixedStepSize')
                    stepSize=num2str(metaData.ModelInfo.SolverInfo.FixedStepSize);
                end
            end


            if isfield(metaData.TimingInfo,'InitializationElapsedWallTime')
                modelUpdateTime=metaData.TimingInfo.InitializationElapsedWallTime;
            end
            if isfield(metaData.TimingInfo,'ExecutionElapsedWallTime')
                modelSimTime=metaData.TimingInfo.ExecutionElapsedWallTime;
            end
            if isfield(metaData.TimingInfo,'TerminationElapsedWallTime')
                modelTermTime=metaData.TimingInfo.TerminationElapsedWallTime;
            end
            if isfield(metaData.TimingInfo,'TotalElapsedWallTime')
                modelTotalTime=metaData.TimingInfo.TotalElapsedWallTime;
            end


            if isfield(metaData.ExecutionInfo,'StopEvent')
                stopEvent=metaData.ExecutionInfo.StopEvent;
            end
            if isfield(metaData.ExecutionInfo,'StopEventDescription')
                stopEventDesc=metaData.ExecutionInfo.StopEventDescription;
            end
            if isfield(metaData.ExecutionInfo,'StopEventSource')&&~isempty(metaData.ExecutionInfo.StopEventSource)

                len=metaData.ExecutionInfo.StopEventSource.getLength();
                if len
                    stopEventSource=metaData.ExecutionInfo.StopEventSource.getBlock(len);
                end
            end
            if isfield(metaData.ExecutionInfo,'ErrorDiagnostic')&&~isempty(metaData.ExecutionInfo.ErrorDiagnostic)
                execErrors=locGetDiagString(metaData.ExecutionInfo.ErrorDiagnostic);
            end
            if isfield(metaData.ExecutionInfo,'WarningDiagnostics')&&~isempty(metaData.ExecutionInfo.WarningDiagnostics)
                execWarnings=locGetDiagString(metaData.ExecutionInfo.WarningDiagnostics);
            end


            if isfield(metaData,'UserString')||isprop(metaData,'UserString')
                userString=char(metaData.UserString);
            end


            modelDsSigFormat=0;
            if bdIsLoaded(metaData.ModelInfo.ModelName)
                if isequal(get_param(metaData.ModelInfo.ModelName,'DatasetSignalFormat'),'timetable')
                    modelDsSigFormat=1;
                end
            end


            Simulink.HMI.updateRunMetaData(...
            runID,...
            metaData.ModelInfo.ModelName,...
            metaData.ModelInfo.SimulationMode,...
            metaData.ModelInfo.StartTime,...
            metaData.ModelInfo.StopTime,...
            metaData.ModelInfo.ModelVersion,...
            metaData.ModelInfo.UserID,...
            metaData.ModelInfo.MachineName,...
            solverType,...
            solverName,...
            slVersionStr,...
            modelUpdateTime,...
            modelSimTime,...
            modelTermTime,...
            modelTotalTime,...
            modelDsSigFormat,...
            platform,...
            stepSize,...
            stopEvent,...
            stopEventSource,...
            stopEventDesc,...
            execErrors,...
            execWarnings,...
            userString);
        end
    end
end


function ret=locGetDiagString(diags)
    ret='';
    if(isempty(diags))
        return;
    else
        ret=diags(1).Diagnostic.message;
        for idx=2:numel(diags)
            ret=[ret,newline,diags(idx).Diagnostic.message];
        end
    end
end
