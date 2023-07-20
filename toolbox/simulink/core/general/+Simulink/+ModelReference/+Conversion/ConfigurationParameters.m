classdef ConfigurationParameters<handle
    properties
ConversionData
ConversionParameters
Model
currentSubsystem
modelRefHandle
isCopyContent
ActiveConfigSet
NewActiveConfigSet
Logger
    end

    properties(Constant,Access=public)
        DefaultConfigSetName='ModelReferencing';
    end

    properties(Constant,Access=private)






        SkipParameters={'CurrentBlock','RTWOptions','Location','Open','LastModifiedDate','LastModifiedBy',...
        'Callbacks','CompiledNumWrappedStates','CompiledWrappedStateInfo','Name','ParameterArgumentNames','Schedule'};

        CallbacksParameters={'PreLoadFcn','PostLoadFcn','InitFcn','StartFcn','PauseFcn','ContinueFcn',...
        'StopFcn','PreSaveFcn','PostSaveFcn'};
        ExcludedCallbacksParameters={'CloseFcn'};
    end


    methods(Access=public)
        function this=ConfigurationParameters(ActiveConfigSet,ConversionData,currentSubsystem,modelRefHandle,isCopyContent)
            this.ConversionData=ConversionData;
            this.ConversionParameters=ConversionData.ConversionParameters;
            this.Model=this.ConversionParameters.Model;
            this.currentSubsystem=currentSubsystem;
            this.modelRefHandle=modelRefHandle;
            this.isCopyContent=isCopyContent;
            this.ActiveConfigSet=ActiveConfigSet;
            this.NewActiveConfigSet=[];
            this.Logger=ConversionData.Logger;
            if isa(this.ActiveConfigSet,'Simulink.ConfigSetRef')
                this.NewActiveConfigSet=getRefConfigSet(this.ActiveConfigSet);
            end
        end

        function setupConfigurationParameters(this)
            this.updateReferencedModelConfigSet;
            this.copyBlockDiagramParameters;
            this.updateBlockDiagramParams;
            this.updateConfigSetParams;
            this.detachConfigureParameterReference;
        end
    end
    methods(Access=private)
        function csName=getUniqueConfigSetName(~,allNames,csName)
            counter=0;
            tmpName=csName;
            while(true)
                counter=counter+1;
                if any(strcmp(allNames,tmpName))
                    tmpName=[csName,int2str(counter)];
                else
                    csName=tmpName;
                    break;
                end
            end
        end

        function newConfigSet=createConfigSetCopy(this,csName)
            srcConfigSet=getActiveConfigSet(this.Model);
            newConfigSet=srcConfigSet.copy;
            newConfigSet.setPropEnabled('Name',true);
            newConfigSet.Name=csName;
        end

        function attachConfigSetToModel(this,activeConfigSet)
            oldConfigset=getActiveConfigSet(this.modelRefHandle);
            attachConfigSet(this.modelRefHandle,activeConfigSet,true);
            setActiveConfigSet(this.modelRefHandle,activeConfigSet.Name);
            detachConfigSet(this.modelRefHandle,oldConfigset.Name);
        end

        function updateReferencedModelConfigSet(this)
            currentConfigSets=getConfigSets(this.modelRefHandle);
            csName=this.getUniqueConfigSetName(currentConfigSets,this.DefaultConfigSetName);
            newConfigSet=this.createConfigSetCopy(csName);
            this.attachConfigSetToModel(newConfigSet);


            paramNames={'ObfuscateCode'};
            cellfun(@(aPrm)set_param(this.modelRefHandle,aPrm,get_param(this.Model,aPrm)),paramNames);
        end

        function copyBlockDiagramParameterIfNeccesary(this,srcPrms,dstPrms,thisPrm)


            if~any(strcmp(this.SkipParameters,thisPrm))&&any(strcmp(srcPrms.(thisPrm).Attributes,'read-write'))
                val=get_param(this.Model,thisPrm);
                if~isfield(dstPrms,thisPrm)
                    add_param(this.modelRefHandle,thisPrm,val);
                else
                    if~isequal(val,get_param(this.modelRefHandle,thisPrm))
                        if~any(strcmp(this.ExcludedCallbacksParameters,thisPrm))
                            set_param(this.modelRefHandle,thisPrm,val);
                            if~isempty(this.Logger)&&any(strcmp(this.CallbacksParameters,thisPrm))
                                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:CopyParameterToReferencedModel',thisPrm));
                            end
                        end
                    end
                end
            end
        end

        function copyBlockDiagramParameters(this)
            srcPrms=get_param(this.Model,'ObjectParameters');
            dstPrms=get_param(this.modelRefHandle,'ObjectParameters');

            srcCSPrms=get_param(this.ActiveConfigSet,'ObjectParameters');

            srcPrmNames=fieldnames(srcPrms);
            srcCSPrmNames=fieldnames(srcCSPrms);
            blkDiagPrms=setdiff(srcPrmNames,srcCSPrmNames);


            numberOfParameters=length(blkDiagPrms);
            for idx=1:numberOfParameters
                this.copyBlockDiagramParameterIfNeccesary(srcPrms,dstPrms,blkDiagPrms{idx});
            end
        end

        function resetAttachedDataset(this)
            set_param(this.modelRefHandle,'MinMaxOverflowArchiveData',[]);
        end

        function setDataTypeOverrideCompiled(this)


            dTypeOverride=get_param(this.currentSubsystem,'DataTypeOverride_Compiled');
            set_param(this.modelRefHandle,'DataTypeOverride',dTypeOverride);
        end

        function turnOffOptimizeModelRefInitCode(this)


            optMdlRefInit=get_param(this.Model,'OptimizeModelRefInitCode');
            if strcmp(optMdlRefInit,'on')
                compiledInfo=get_param(this.currentSubsystem,'CompiledRTWSystemInfo');




                if~isempty(compiledInfo)&&(compiledInfo(6)>0)
                    set_param(this.modelRefHandle,'OptimizeModelRefInitCode','off');
                end
            end
        end

        function updateBlockDiagramParams(this)
            this.resetAttachedDataset;
            this.setDataTypeOverrideCompiled;
            this.turnOffOptimizeModelRefInitCode;
        end

        function setMinAlgLoopOccurrencesParameters(this)


            ssMinAlgLoop=get_param(this.currentSubsystem,'MinAlgLoopOccurrences');
            set_param(this.modelRefHandle,'ModelReferenceMinAlgLoopOccurrences',ssMinAlgLoop);



            cmbOutputUpdate=get_param(this.modelRefHandle,'CombineOutputUpdateFcns');
            if strcmpi(ssMinAlgLoop,'on')&&strcmpi(cmbOutputUpdate,'on')
                set_param(this.modelRefHandle,'CombineOutputUpdateFcns','off');
            end
        end
    end

    methods(Access=protected)


        function checkSolverModeImpl(this)
            solverType=get_param(this.modelRefHandle,'SolverType');
            if strcmpi(solverType,'Fixed-step')
                stConstraint=get_param(this.modelRefHandle,'SampleTimeConstraint');
                stInd=strcmpi(stConstraint,'STIndependent');
                if~stInd
                    if strcmpi(get_param(this.modelRefHandle,'SolverMode'),'MultiTasking')
                        set_param(this.modelRefHandle,'SolverMode','Auto');
                    end
                end
            end
        end

        function checkSolverMode(this)
            this.checkSolverModeImpl;
        end

        function setModelReferenceNumInstancesAllowed(this)






            set_param(this.modelRefHandle,'ModelReferenceNumInstancesAllowed','Multi');
        end

        function turnOffLogging(this)



            set_param(this.modelRefHandle,'SaveTime','off');
            set_param(this.modelRefHandle,'SaveOutput','off');
        end

        function copySolverInfoImpl(this)
            Simulink.ModelReference.Conversion.CopySolverInfo(this.currentSubsystem,this.modelRefHandle,this.isCopyContent);
        end

        function updateConfigSetParams(this)
            this.checkSolverMode;
            this.turnOffLogging;
            this.setModelReferenceNumInstancesAllowed;
            this.setMinAlgLoopOccurrencesParameters;
            this.copySolverInfoImpl;
        end

        function detachConfigureParameterReference(this)
            if~isempty(this.NewActiveConfigSet)
                [configSetEqual,~]=isequal(getActiveConfigSet(get_param(this.modelRefHandle,'Name')),getRefConfigSet(this.ActiveConfigSet));
                if configSetEqual
                    attachConfigSetCopy(get_param(this.modelRefHandle,'Name'),this.ActiveConfigSet,true)
                    setActiveConfigSet(this.modelRefHandle,activeConfigSet.Name);
                    detachConfigSet(this.modelRefHandle,this.DefaultConfigSetName);
                else
                    modelRefName=get_param(this.modelRefHandle,'Name');
                    this.Logger.addWarning(message('Simulink:modelReference:convertToModelReference_configSetReferenceResolved',...
                    this.ActiveConfigSet.Name,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(modelRefName)));
                end
            end
        end
    end
end