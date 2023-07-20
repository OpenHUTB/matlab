
classdef SDIInterface<handle
    properties(SetAccess=private,GetAccess=public)
ComparisionAlgorithms
    end


    properties(Constant)
        DefaultStopTime=10;
        DefaultAbsoluteTolerance=1e-6;
        DefaultRelativeTolerance=1e-3;
    end


    methods(Static,Access=public)
        function compare(baselineRun,currentRun)
            this=Simulink.SDIInterface;
            this.viewComparisonResults(baselineRun,currentRun);
            Simulink.sdi.view(Simulink.sdi.GUITabType.CompareRuns);
        end


        function absTol=calculateDefaultAbsoluteTolerance(modelName)
            absTol=Simulink.ModelReference.Conversion.SimulationTimeUtils.getValueFromGlobalScope(...
            modelName,strtrim(get_param(modelName,'absTol')),Simulink.SDIInterface.DefaultAbsoluteTolerance);
        end


        function relTol=calculateDefaultRelativeTolerance(modelName)
            relTol=Simulink.ModelReference.Conversion.SimulationTimeUtils.getValueFromGlobalScope(...
            modelName,strtrim(get_param(modelName,'relTol')),Simulink.SDIInterface.DefaultRelativeTolerance);
        end


        function stopTime=calculateStopTime(modelName,stopTimeExpression)
            if Simulink.ModelReference.Conversion.SimulationTimeUtils.isAutoStopTime(strtrim(stopTimeExpression))
                solverStopTime=get_param(modelName,'StopTime');
                defaultStopTime=Simulink.SDIInterface.DefaultStopTime;

                load_system(modelName);
                mdlWks=get_param(modelName,'ModelWorkspace');
                variableIsInModelWorkspace=false;
                vars=whos(mdlWks);
                for i=1:length(vars)
                    if(strcmp(vars(i).name,solverStopTime)==1)
                        solverStopTimeNum=evalin(mdlWks,solverStopTime);
                        variableIsInModelWorkspace=true;
                        break;
                    end
                end

                if~variableIsInModelWorkspace
                    solverStopTimeNum=evalinGlobalScope(modelName,solverStopTime);
                end
                stopTime=min(defaultStopTime,solverStopTimeNum);
            else
                isValidExpression=true;
                try
                    stopTime=evalinGlobalScope(modelName,stopTimeExpression);
                    if~(isscalar(stopTime)&&isnumeric(stopTime))||isinf(stopTime)
                        isValidExpression=false;
                    end
                catch
                    isValidExpression=false;
                end

                if~isValidExpression
                    throw(MException(message('Simulink:modelReferenceAdvisor:InfSampleTime',stopTimeExpression)));
                end
            end
        end


        function cleanup()
            Simulink.sdi.clear;
            Simulink.sdi.close;
        end
    end


    methods(Access=public)
        function this=SDIInterface
            this.ComparisionAlgorithms=[Simulink.sdi.AlignType.DataSource,Simulink.sdi.AlignType.BlockPath,Simulink.sdi.AlignType.SID];
        end


        function results=checkResults(this,baselineRun,currentRun)
            results=true;
            diff=Simulink.sdi.compareRuns(baselineRun,currentRun,this.ComparisionAlgorithms);
            numberOfComparisons=diff.count;
            for idx=1:numberOfComparisons
                diffSignal=diff.getResultByIndex(idx);
                if(~diffSignal.match)
                    results=false;
                    break;
                end
            end
        end


        function viewComparisonResults(this,baselineRun,currentRun)
            diff=Simulink.sdi.compareRuns(baselineRun,currentRun,this.ComparisionAlgorithms);
            numberOfComparisons=diff.count;
            for idx=1:numberOfComparisons
                diffSignal=diff.getResultByIndex(idx);
                if(~diffSignal.match)
                    sdiViewer=Simulink.sdi.Instance.gui;
                    sdiViewer.Show;
                    sdiViewer.changeTab(Simulink.sdi.GUITabType.CompareRuns);
                    signalID1=diffSignal.signalID1;
                    sdiViewer.plotSignalInComparedRun(signalID1);
                    break;
                end
            end
        end
    end
end
