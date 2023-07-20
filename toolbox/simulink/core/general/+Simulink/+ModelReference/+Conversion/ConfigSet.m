


classdef ConfigSet<handle
    properties(SetAccess=protected,GetAccess=protected)
        System='';
        Logger=[];
        IsConfigSetRef=false;
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
        function this=ConfigSet(varargin)
            narginchk(0,1);
            if(nargin==1)
                this.System=varargin{1};
                if iscell(this.System)
                    this.System=this.System{:};
                end
            end
        end

        function setup(this,activeConfigSet,model,modelRefHandle,logger,isCopyContent)
            this.setLogger(logger);
            this.configure(model,modelRefHandle,isCopyContent);
            this.splitModifiedConfigSet(activeConfigSet,modelRefHandle,logger);
        end
        function copy(this,srcModel,dstModel)
            this.updateReferencedModelConfigSet(srcModel,dstModel);
            this.copyBlockDiagramParameters(srcModel,dstModel);
        end

        function configure(this,srcModel,dstModel,isCopyContent)
            this.copy(srcModel,dstModel);
            this.updateBlockDiagramParams(srcModel,dstModel);
            this.updateConfigSetParams(dstModel,isCopyContent,srcModel);
        end

        function setLogger(this,logger)
            this.Logger=logger;
        end
    end

    methods(Static,Access=public)
        function obj=create(varargin)
            switch nargin
            case 0
                obj=Simulink.ModelReference.Conversion.ConfigSet;
            case 1
                obj=Simulink.ModelReference.Conversion.ConfigSet(varargin{1});
            otherwise
                assert(false,'Cannot construct ConfigSet class!');
            end
        end

        function newConfigSet=createConfigSetCopy(modelHandle,csName)
            srcConfigSet=getActiveConfigSet(modelHandle);
            newConfigSet=srcConfigSet.copy;
            newConfigSet.setPropEnabled('Name',true);
            newConfigSet.Name=csName;
        end

        function csName=getUniqueConfigSetName(allNames,csName)
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
    end
    methods(Access=public)

    end


    methods(Static,Access=protected)
        function attachConfigSetToModel(srcModel,activeConfigSet)
            oldConfigset=getActiveConfigSet(srcModel);
            attachConfigSet(srcModel,activeConfigSet,true);
            setActiveConfigSet(srcModel,activeConfigSet.Name);
            detachConfigSet(srcModel,oldConfigset.Name);
        end

        function resetAttachedDataset(modelHandle)
            set_param(modelHandle,'MinMaxOverflowArchiveData',[]);
        end

        function turnOffOptimizeModelRefInitCode(subsys,modelHandle,modelRef)


            optMdlRefInit=get_param(modelHandle,'OptimizeModelRefInitCode');
            if strcmp(optMdlRefInit,'on')
                compiledInfo=get_param(subsys,'CompiledRTWSystemInfo');




                if~isempty(compiledInfo)&&(compiledInfo(6)>0)
                    set_param(modelRef,'OptimizeModelRefInitCode','off');
                end
            end
        end
    end

    methods(Access=protected)
        function resolveConfigSetReferenceWarning(this,modelRefHandle,activeConfigSet,logger)
            modelRefName=get_param(modelRefHandle,'Name');
            logger.addWarning(message('Simulink:modelReference:convertToModelReference_configSetReferenceResolved',...
            activeConfigSet.Name,Simulink.ModelReference.Conversion.MessageBeautifier.beautifyModelName(modelRefName)));
        end

        function splitModifiedConfigSet(this,activeConfigSet,modelRefHandle,logger)
            newActiveConfigSet=[];
            if isa(activeConfigSet,'Simulink.ConfigSetRef')
                newActiveConfigSet=getRefConfigSet(activeConfigSet);
            end
            if~isempty(newActiveConfigSet)
                [configSetEqual,~]=isequal(getActiveConfigSet(get_param(modelRefHandle,'Name')),getRefConfigSet(activeConfigSet));
                if configSetEqual
                    attachConfigSetCopy(get_param(modelRefHandle,'Name'),activeConfigSet,true)
                    setActiveConfigSet(modelRefHandle,activeConfigSet.Name);
                    detachConfigSet(modelRefHandle,configSet.DefaultConfigSetName);
                end

                if~configSetEqual
                    this.resolveConfigSetReferenceWarning(modelRefHandle,activeConfigSet,logger)
                end
            end
        end

        function setDataTypeOverrideCompiled(this,subsys,modelRef)


            dTypeOverride=get_param(subsys,'DataTypeOverride_Compiled');
            set_param(modelRef,'DataTypeOverride',dTypeOverride);
        end

        function updateReferencedModelConfigSet(this,srcModel,dstModel)
            currentConfigSets=getConfigSets(dstModel);
            csName=this.getUniqueConfigSetName(currentConfigSets,Simulink.ModelReference.Conversion.ConfigSet.DefaultConfigSetName);
            newConfigSet=this.createConfigSetCopy(srcModel,csName);
            this.attachConfigSetToModel(dstModel,newConfigSet);


            paramNames={'ObfuscateCode'};
            cellfun(@(aPrm)set_param(dstModel,aPrm,get_param(srcModel,aPrm)),paramNames);
        end
        function checkSolverMode(this,modelHandle)
            solverType=get_param(modelHandle,'SolverType');
            if strcmpi(solverType,'Fixed-step')
                stConstraint=get_param(modelHandle,'SampleTimeConstraint');
                stInd=strcmpi(stConstraint,'STIndependent');
                if~stInd
                    if strcmpi(get_param(modelHandle,'SolverMode'),'MultiTasking')
                        set_param(modelHandle,'SolverMode','Auto');
                    end
                end
            end
        end

        function turnOffLogging(this,modelHandle)



            set_param(modelHandle,'SaveTime','off');
            set_param(modelHandle,'SaveOutput','off');
        end

        function setModelReferenceNumInstancesAllowed(this,modelRef,srcModel)






            set_param(modelRef,'ModelReferenceNumInstancesAllowed','Multi');
        end

        function setMinAlgLoopOccurrencesParameters(this,subsys,modelRef)


            ssMinAlgLoop=get_param(subsys,'MinAlgLoopOccurrences');
            set_param(modelRef,'ModelReferenceMinAlgLoopOccurrences',ssMinAlgLoop);



            cmbOutputUpdate=get_param(modelRef,'CombineOutputUpdateFcns');
            if strcmpi(ssMinAlgLoop,'on')&&strcmpi(cmbOutputUpdate,'on')
                set_param(modelRef,'CombineOutputUpdateFcns','off');
            end
        end


        function updateBlockDiagramParams(this,srcModel,dstModel)
            this.resetAttachedDataset(dstModel);
            this.setDataTypeOverrideCompiled(this.System,dstModel);
            this.turnOffOptimizeModelRefInitCode(this.System,srcModel,dstModel);
        end

        function updateConfigSetParamsSolver(this,dstModel,isCopyContent)
            Simulink.ModelReference.Conversion.CopySolverInfo(this.System,dstModel,isCopyContent);
        end

        function updateConfigSetParams(this,dstModel,isCopyContent,srcModel)
            this.checkSolverMode(dstModel);
            this.turnOffLogging(dstModel);
            this.setModelReferenceNumInstancesAllowed(dstModel,srcModel);
            this.setMinAlgLoopOccurrencesParameters(this.System,dstModel);
            this.updateConfigSetParamsSolver(dstModel,isCopyContent)
        end

        function copyBlockDiagramParameters(this,srcModel,dstModel)
            srcPrms=get_param(srcModel,'ObjectParameters');
            dstPrms=get_param(dstModel,'ObjectParameters');

            srcConfigSet=getActiveConfigSet(srcModel);
            srcCSPrms=get_param(srcConfigSet,'ObjectParameters');

            srcPrmNames=fieldnames(srcPrms);
            srcCSPrmNames=fieldnames(srcCSPrms);
            blkDiagPrms=setdiff(srcPrmNames,srcCSPrmNames);


            numberOfParameters=length(blkDiagPrms);
            for idx=1:numberOfParameters
                this.copyBlockDiagramParameterIfNeccesary(srcModel,dstModel,srcPrms,dstPrms,blkDiagPrms{idx});
            end
        end

        function copyBlockDiagramParameterIfNeccesary(this,srcModel,dstModel,srcPrms,dstPrms,thisPrm)


            if~any(strcmp(this.SkipParameters,thisPrm))&&any(strcmp(srcPrms.(thisPrm).Attributes,'read-write'))
                val=get_param(srcModel,thisPrm);
                if~isfield(dstPrms,thisPrm)
                    add_param(dstModel,thisPrm,val);
                else
                    if~isequal(val,get_param(dstModel,thisPrm))
                        if~any(strcmp(this.ExcludedCallbacksParameters,thisPrm))
                            set_param(dstModel,thisPrm,val);
                            if~isempty(this.Logger)&&any(strcmp(this.CallbacksParameters,thisPrm))
                                this.Logger.addInfo(message('Simulink:modelReferenceAdvisor:CopyParameterToReferencedModel',thisPrm));
                            end
                        else

                        end
                    end
                end
            end
        end
    end
end


