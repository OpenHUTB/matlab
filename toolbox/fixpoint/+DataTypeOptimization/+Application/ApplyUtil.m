classdef ApplyUtil<handle





    methods(Static)
        function modelState=applySolution(environmentProxy,problemPrototype,solution,scenarioIndex,keepOriginalModelParameters)





            coder.internal.MLFcnBlock.FPTSupport.overrideConvertedMATLABFunctionBlocks(...
            solution.simIn(1).ModelName,...
            coder.internal.MLFcnBlock.VariantOverrideEnum.OverrideUsingFixedPoint);

            if~isempty(environmentProxy)
                DataTypeOptimization.Application.ApplyUtil.applyMLFB(environmentProxy,problemPrototype,solution);
            end


            simIn=solution.simIn(scenarioIndex);
            if keepOriginalModelParameters
                simIn=DataTypeOptimization.Application.ApplyUtil.keepOriginalParameters(simIn);
            end
            modelState=Simulink.internal.TemporaryModelState(simIn,'ApplyHidden','on','EnableConfigSetRefUpdate','on');
            modelState.RevertOnDelete=false;

        end

        function simIn=keepOriginalParameters(simIn)

            params=DataTypeOptimization.EnvironmentProxy.constModelParameters(1:2:end)';


            params=[params;{'DataTypeOverride';'MinMaxOverflowLogging';'SimulationMode'}];
            for pIndex=1:numel(params)
                index=strcmpi({simIn.ModelParameters.Name},params{pIndex});
                simIn.ModelParameters(index)=[];
            end
            simIn.LoggingSpecification=[];
        end

        function applyMLFB(environmentProxy,problemPrototype,solution)
            if solution.isFullySpecified

                simIn=solution.simIn(1);
                smlfb=Simulink.SimulationInput(simIn.ModelName);
                stIndex=contains({simIn.Variables.Name},'fxpopt_stateflow');
                if any(stIndex)
                    smlfb.Variables=simIn.Variables(stIndex);
                    smlfb.applyToModel();
                end


                DataTypeOptimization.Application.ApplyUtil.setProposedDT(environmentProxy,problemPrototype,solution);


                allModels=environmentProxy.mlfbMaps.model2MLFB.keys;
                for mIndex=1:numel(allModels)
                    model=allModels{mIndex};

                    MLFBs=environmentProxy.mlfbMaps.model2MLFB(model);
                    for bIndex=1:numel(MLFBs)
                        mlfb=MLFBs{bIndex};

                        mlv=environmentProxy.mlfbMaps.mlfb2mlv([model,':::',mlfb]);
                        mlv=[mlv{:}];
                        if~isempty(mlv)

                            DataTypeOptimization.Application.ApplyUtil.convertMLFB(mlv,mlfb,DataTypeOptimization.BaselineProperties.RunName)
                        end
                    end
                end
            end
        end

        function setProposedDT(environmentProxy,problemPrototype,solution)

            allMLV=environmentProxy.mlfbMaps.mlfb2mlv.values;
            allMLV=[allMLV{:}];
            for mIndex=1:numel(allMLV)

                [~,group]=fxptds.Utils.getGroupResults(allMLV{mIndex});
                groupId=group.id;
                dvIndex=find(arrayfun(@(x)(groupId==x.group.id),problemPrototype.dv));

                dt=DataTypeOptimization.Application.ApplyUtil.getDataType(problemPrototype.dv(dvIndex),solution.definitionDomainIndex(dvIndex));

                allMLV{mIndex}.setProposedDT(dt.evaluatedDTString);
            end
        end

        function convertMLFB(results,blkSID,runName)

            mlfbDriver=coder.internal.MLFcnBlock.Float2FixedManager.getMLFBDriver(blkSID);

            mlfbFacade=mlfbDriver.getDataRepositoryFacade();

            [~,instrumentationReport,loggedVariablesData]=mlfbFacade.getReports();
            mlfbDriver.buildFcnInfoRegistry(mlfbDriver.getCompilationReport());
            mlfbDriver.State.coderReport=instrumentationReport;
            mlfbDriver.addInstrumentationData(mlfbDriver.State.coderReport,loggedVariablesData,runName);

            mlfbDriver.proposeTypes(mlfbDriver.State.fcnInfoRegistry);
            mlfbFacade.addResults(runName,results);

            mlfbDriver.apply(blkSID,mlfbFacade.getMappedResults(runName));

        end

        function[pv,sfEntries]=applyGroup(group,dtStr)

            members=group.getGroupMembers;

            pv={};
            sfEntries=Simulink.Simulation.Variable.empty(1,0);
            for mIndex=1:numel(members)
                if~members{mIndex}.getSpecifiedDTContainerInfo.traceVar()
                    ea=members{mIndex}.getAutoscaler;
                    blkObj=members{mIndex}.UniqueIdentifier.getObject;
                    pathItem=members{mIndex}.UniqueIdentifier.getElementName;
                    if isempty(ea.checkComments(blkObj,pathItem))&&...
                        ~members{mIndex}.IsLocked


                        if isa(ea,'SimulinkFixedPoint.EntityAutoscalers.StateflowEntityAutoscaler')
                            sfEntries=[sfEntries;DataTypeOptimization.Application.ApplyUtil.assignStateflow(blkObj,group.id)];%#ok<AGROW>
                            dtStr=sfEntries(end).Name;
                            ea.applyProposedScaling(blkObj,pathItem,dtStr);
                        end



                        currentPV=ea.getSettingStrategies(blkObj,pathItem,dtStr);
                        pv=[pv;currentPV];%#ok<AGROW>
                    end
                end
            end
        end

        function siEntry=assignStateflow(blkObj,groupID)

            varName=sprintf('fxpopt_stateflow_dt_s%i_g%i',blkObj.Id,groupID);

            compiledTypeStr=blkObj.CompiledType;
            varVal=compiledTypeStr;
            if~strcmpi(varVal,'unknown')
                varVal=numerictype(compiledTypeStr);
            end
            modelName=bdroot(blkObj.Machine.Path);
            modelWorkspace=get_param(modelName,'ModelWorkspace');
            assignin(modelWorkspace,varName,varVal);
            siEntry=Simulink.Simulation.Variable(varName,varVal,'Workspace',modelName);
        end

        function anyMLV=anyMATLABVariable(decisionVariable)

            anyMLV=any(cellfun(@(x)(isa(x,'fxptds.MATLABVariableResult')),decisionVariable.group.getGroupMembers));
        end

        function dataType=getDataType(decisionVariable,definitionDomainIndex)
            saf=decisionVariable.definitionDomain.slopeAdjustmentFactor;
            bias=decisionVariable.definitionDomain.bias;

            if isempty(saf)||((saf==1)&&(bias==0))

                dt=fixdt(...
                decisionVariable.definitionDomain.signedness,...
                decisionVariable.definitionDomain.wordLengthVector(definitionDomainIndex),...
                decisionVariable.definitionDomain.fractionWidthVector(definitionDomainIndex));
            else

                dt=fixdt(...
                decisionVariable.definitionDomain.signedness,...
                decisionVariable.definitionDomain.wordLengthVector(definitionDomainIndex),...
                saf,...
                -decisionVariable.definitionDomain.fractionWidthVector(definitionDomainIndex),...
                bias);

            end

            dataType=SimulinkFixedPoint.DataTypeContainer.SpecifiedDataTypeContainer(dt.tostring,[]);
        end
    end

end

