classdef Utils<handle




    methods(Static)
        function[accelRefMdls,accelMdlBlks]=getMdlRefAccelOnly(mdlRefGraphObj)
            graphAnalyzer=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
            onlyAccelTable=graphAnalyzer.analyze(mdlRefGraphObj,'OnlyAccel','IncludeTopModel',true);
            accelRefMdls=onlyAccelTable.RefModel';
            accelMdlBlks=onlyAccelTable.BlockPath';
        end

        function[checkObj]=execStowawayDoubleCheck(model)

            p=ModelAdvisor.Preferences();
            p.CommandLineRun=true;

            maObj=Simulink.ModelAdvisor.getModelAdvisor(model,'new');

            maObj.CmdLine=true;
            maObj.runInBackground=false;
            maObj.ShowExclusions=false;
            maObj.treatAsMdlref=false;






            checkID='mathworks.design.StowawayDoubles';
            checkObj=maObj.getCheckObj(checkID);


            maObj.runCheck({checkID});
        end


        function err=compileModel(model)
            err={};

            if strcmp(get_param(model,'SimulationStatus'),'stopped')
                try
                    init(get_param(model,'ObjectAPI_FP'),'MODEL_API');
                catch ME
                    errMsg=message('SimulinkFixedPoint:singleconverter:UpdateDiagramFailed',model).getString();
                    err=DataTypeWorkflow.Utils.addCauses(MException('DataTypeWorkflow:Single:UpdateDiagramFailed',errMsg),ME);
                end
            end
        end


        function err=termModel(model)
            err={};

            if strcmp(get_param(model,'SimulationStatus'),'paused')
                try
                    term(get_param(model,'ObjectAPI_FP'));
                catch ME
                    errMsg=message('SimulinkFixedPoint:singleconverter:TerminateSimFailed',model).getString();
                    err=DataTypeWorkflow.Utils.addCauses(MException('DataTypeWorkflow:Single:TerminateSimFailed',errMsg),ME);
                end
            end
        end



        function baseE=addCauses(baseE,causeE)
            for i=1:numel(causeE.cause)
                baseE=baseE.addCause(causeE.cause{i});
            end
        end


        function isFPTrump=isFloatingPointTrump(result)



            curObject=result.getUniqueIdentifier.getObject;
            [~,~,paramNames]=result.getAutoscaler.gatherSpecifiedDT(curObject,result.getElementName);
            if~isfield(paramNames,'modeStr')||isempty(paramNames.modeStr)
                isFPTrump=false;
            else
                if isa(curObject,'SimulinkFixedPoint.DataObjectWrapper')
                    isFPTrump=false;
                else

                    propValues=curObject.getPropAllowedValues(paramNames.modeStr);
                    isFPTrump=~DataTypeWorkflow.Utils.isFltptAllowed(propValues);
                end
            end
        end

        function isFltptAllow=isFltptAllowed(propValues)
            isFltptAllow=any(strcmpi('double',propValues))||any(strcmpi('single',propValues));
        end

        function updateDirtyModels(models,flag)
            if iscell(models)
                cellfun(@(x)(set_param(x,'Dirty',flag)),models);
            else
                throw(MException('MATLAB:cellRefFromNonCell',message('MATLAB:cellRefFromNonCell').getString()));
            end
        end



        function isDataTypeAppliable=checkIfDataTypeApplyPossible(dsRecord)









            isDataTypeAppliable=true;


            entity=dsRecord.getUniqueIdentifier.getObject;


            entityAutoscaler=dsRecord.getAutoscaler;


            pathItem=dsRecord.getUniqueIdentifier.getElementName;










            comments=entityAutoscaler.checkComments(entity,pathItem);




            if~isempty(comments)
                isDataTypeAppliable=false;
            end
        end

        function simIn=updateSimulationInputObject(simIn,unsupportedConstructs)



            blockParams=simIn.BlockParameters;
            for bIdx=1:length(blockParams)
                blockParam=blockParams(bIdx);

                path=convertStringsToChars(blockParam.BlockPath);

                if any(strcmp(unsupportedConstructs,path))
                    paramValue=blockParam.Value;
                    paramName=blockParam.Name;


                    newBlockPath=[path,'/',DataTypeWorkflow.Advisor.internal.ReplacementSetUp.SourceBlockName];
                    simIn=simIn.removeBlockParameter(path,paramName);
                    simIn=simIn.setBlockParameter(newBlockPath,paramName,paramValue);
                end
            end
        end

    end
end




