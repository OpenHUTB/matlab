classdef ParameterBuilder<autosar.mm.mm2sl.ObjectBuilder





    properties
        CreatedSystemConsts;
        CreatedPostBuildCrits;
        SlLUTParamToM3iTypeMap;
        SLMatcher;
        InitValueParamSet;
    end

    properties(SetAccess=private)
        RequiresLegacyMemorySectionDefinitions;
    end

    properties(Access=private)
        M3IConnectedPortFinder autosar.mm.mm2sl.utils.M3IConnectedPortFinder;
    end

    properties(Access=private,Transient)
        ForceLegacyWorkspaceBehavior;
    end

    properties(Constant,Access=private)
        NonUpdatableParameterClasses={
'AUTOSAR.DualScaledParameter'
        };
    end

    methods



        function self=ParameterBuilder(m3iModel,m3iConnectedPortFinder,typeBuilder,constBuilder,changeLogger)
            self@autosar.mm.mm2sl.ObjectBuilder(m3iModel,typeBuilder,constBuilder,changeLogger);
            self.M3IConnectedPortFinder=m3iConnectedPortFinder;
            self.CreatedSystemConsts={};
            self.CreatedPostBuildCrits={};
            self.SlLUTParamToM3iTypeMap=containers.Map();
            self.InitValueParamSet=autosar.mm.util.Set(...
            'InitCapacity',20,...
            'KeyType','char',...
            'HashFcn',@(x)x);
            self.SLMatcher=[];
            self.ForceLegacyWorkspaceBehavior=false;
            self.RequiresLegacyMemorySectionDefinitions=false;
            self.bind('Simulink.metamodel.arplatform.interface.ParameterData',@walkParameterData,[]);
            self.bind('Simulink.metamodel.arplatform.variant.VariationPointProxy',@walkVariationPointProxy,[]);
            self.bind('Simulink.metamodel.arplatform.behavior.Runnable',@walkObjWithVariationPoint,[]);
            self.bind('Simulink.metamodel.arplatform.port.Port',@walkObjWithVariationPoint,[]);
            self.bind('Simulink.metamodel.arplatform.variant.SystemConstValue',@walkSystemConstValue,[]);
            self.bind('Simulink.metamodel.types.Matrix',@walkMatrixDimensions,[]);
            self.bind('Simulink.metamodel.arplatform.behavior.ComponentParameterAccess',@mmWalkComponentParameterAccess,[]);
            self.bind('Simulink.metamodel.arplatform.behavior.PortParameterAccess',@mmWalkPortParameterAccess,[]);
        end







        function slParams=buildParameterInterface(self,workSpace,modelWorkSpace,m3iContainer,forceLegacyWorkspaceBehavior)
            narginchk(5,5);

            if isempty(modelWorkSpace)
                forceLegacyWorkspaceBehavior=true;
            end

            if isa(m3iContainer,'Simulink.metamodel.arplatform.interface.PortInterface')
                m3iIf=m3iContainer;
                m3iPort=[];
            elseif isa(m3iContainer,'Simulink.metamodel.arplatform.port.ParameterReceiverPort')||...
                isa(m3iContainer,'Simulink.metamodel.arplatform.port.ParameterSenderPort')
                m3iPort=m3iContainer;
                if m3iPort.isvalid()
                    m3iIf=m3iPort.Interface;
                else
                    assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',3,'Port'));
                end
            else
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',3,'Port'));
            end

            if~isa(m3iIf,'Simulink.metamodel.arplatform.interface.ParameterInterface')||...
                ~m3iIf.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',3,'Interface'));
            end

            self.ForceLegacyWorkspaceBehavior=forceLegacyWorkspaceBehavior;
            slParams=self.applySeq(m3iIf.DataElements,m3iPort);


            for ii=1:numel(slParams)
                pName=slParams{ii}.name;


                if slParams{ii}.willBeAssigned
                    if isempty(slParams{ii}.codeProperties.paramType)

                        assignin(workSpace,pName,slParams{ii}.slObj);
                        continue;
                    end
                    switch slParams{ii}.codeProperties.paramType
                    case 'PortParameter'
                        assignin(modelWorkSpace,pName,slParams{ii}.slObj);
                    otherwise
                        assignin(workSpace,pName,slParams{ii}.slObj);
                    end
                end
            end

        end





        function slParams=buildParameterComponent(self,workSpace,modelWorkspace,m3iComp,forceLegacyWorkspaceBehavior)
            if isempty(m3iComp)||...
                ~isa(m3iComp,'Simulink.metamodel.arplatform.component.ParameterComponent')||...
                ~m3iComp.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgComponent',3));
            end

            slParams=[];
            for ii=1:m3iComp.ParameterSenderPorts.size()
                m3iPort=m3iComp.ParameterSenderPorts.at(ii);
                if nargout<1
                    self.buildParameterInterface(workSpace,modelWorkspace,m3iPort,forceLegacyWorkspaceBehavior);
                else
                    params=self.buildParameterInterface(workSpace,modelWorkspace,m3iPort,forceLegacyWorkspaceBehavior);
                    slParams=[slParams,params];%#ok<AGROW>
                end
            end

        end





        function slParams=buildComponentParameter(self,workSpace,modelWorkSpace,m3iComp,createPortCalPrm,modelMappingHelper,initValueParamSet,forceLegacyWorkspaceBehavior)
            self.InitValueParamSet=initValueParamSet;
            if isempty(modelWorkSpace)
                forceLegacyWorkspaceBehavior=true;
            end
            self.SLMatcher=modelMappingHelper;
            if isempty(m3iComp)||...
                ~isa(m3iComp,'Simulink.metamodel.arplatform.component.AtomicComponent')||...
                ~m3iComp.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgComponent',3));
            end

            m3iBehavior=m3iComp.Behavior;
            slParams=[];
            if m3iBehavior.isvalid()
                self.ForceLegacyWorkspaceBehavior=forceLegacyWorkspaceBehavior;
                slParams=self.applySeq(m3iBehavior.Parameters);


                for ii=1:numel(slParams)
                    pName=slParams{ii}.name;

                    if slParams{ii}.willBeAssigned
                        if isempty(slParams{ii}.codeProperties.paramType)

                            assignin(workSpace,pName,slParams{ii}.slObj);
                            continue;
                        end
                        switch slParams{ii}.codeProperties.paramType
                        case{'ConstantMemory','SharedParameter','PerInstanceParameter','PortParameter'}
                            assignin(modelWorkSpace,pName,slParams{ii}.slObj);
                        otherwise
                            assignin(workSpace,pName,slParams{ii}.slObj);
                        end
                    end
                end

                vpps=self.applySeq(m3iBehavior.variationPointProxy);
                runnables=self.applySeq(m3iBehavior.Runnables);
                rPortVPs=self.applySeq(m3iComp.ReceiverPorts);
                sPortVPs=self.applySeq(m3iComp.SenderPorts);
                srPortVPs=self.applySeq(m3iComp.SenderReceiverPorts);
                mrPortVPs=self.applySeq(m3iComp.ModeReceiverPorts);
                clientPortVPs=self.applySeq(m3iComp.ClientPorts);
                serverPortVPs=self.applySeq(m3iComp.ServerPorts);

                slVariants=[vpps,runnables,rPortVPs,sPortVPs,...
                srPortVPs,mrPortVPs,clientPortVPs,serverPortVPs];


                for ii=1:numel(slVariants)
                    slVariantItem=slVariants{ii};
                    for jj=1:numel(slVariantItem)

                        if slVariantItem(jj).willBeAssigned
                            pName=slVariantItem(jj).name;
                            assignin(workSpace,pName,slVariantItem(jj).slObj);
                        end
                    end
                end
                slParams=[slParams,slVariants];


                matricies=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(...
                self.m3iModel,Simulink.metamodel.types.Matrix.MetaClass(),...
                true);
                slVariants=self.applySeq(matricies);

                for ii=1:numel(slVariants)
                    slVariantItem=slVariants{ii};
                    for jj=1:numel(slVariantItem)

                        if slVariantItem(jj).willBeAssigned
                            pName=slVariantItem(jj).name;
                            assignin(workSpace,pName,slVariantItem(jj).slObj);
                        end
                    end
                end
                slParams=[slParams,slVariants];
            end

            if createPortCalPrm
                for ii=1:m3iComp.ParameterReceiverPorts.size()
                    m3iPort=m3iComp.ParameterReceiverPorts.at(ii);
                    if~isa(m3iPort,'Simulink.metamodel.arplatform.port.ParameterReceiverPort')
                        continue
                    end
                    if nargout<1
                        self.buildParameterInterface(workSpace,modelWorkSpace,m3iPort,forceLegacyWorkspaceBehavior);
                    else
                        params=self.buildParameterInterface(workSpace,modelWorkSpace,m3iPort,forceLegacyWorkspaceBehavior);
                        slParams=[slParams,params];%#ok<AGROW>
                    end
                end
            end
            self.updateBreakpointsForReferenceAxisLookupTableParams(workSpace,modelWorkSpace);
        end

        function buildVariantConfigurations(self,workSpace,modelName,predefinedVariant)
            if numel(self.CreatedSystemConsts)>0||numel(self.CreatedPostBuildCrits)>0
                m3iPredefinedVariants=Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(...
                self.m3iModel,Simulink.metamodel.arplatform.variant.PredefinedVariant.MetaClass(),...
                true);
                variantConfig=Simulink.VariantConfigurationData;
                for ii=1:m3iPredefinedVariants.size()
                    m3iPredefinedVariant=m3iPredefinedVariants.at(ii);

                    sysConstsValueMap=...
                    autosar.api.Utils.createSystemConstantMapFromPDV(m3iPredefinedVariant);
                    pbVarCritsValueMap=...
                    autosar.api.Utils.createPostBuildVariantCriterionMapFromPDV(m3iPredefinedVariant);

                    configName=m3iPredefinedVariant.Name;

                    variantConfig.addConfiguration(configName);
                    self.populateVariantConfig(sysConstsValueMap,modelName,configName,variantConfig,false);
                    self.populateVariantConfig(pbVarCritsValueMap,modelName,configName,variantConfig,true);
                end
                if m3iPredefinedVariants.size()>0
                    if~isempty(predefinedVariant)
                        parts=strsplit(predefinedVariant,'/');
                        defaultConfig=parts{end};
                        variantConfig.setPreferredConfiguration(defaultConfig)
                    end
                    if strcmp(workSpace,'base')
                        assignin(workSpace,modelName,variantConfig);
                    else
                        slprivate('assigninScopeSection',modelName,modelName,variantConfig,'Configurations');
                    end
                    autosar.mm.mm2sl.SLModelBuilder.set_param(self.ChangeLogger,modelName,...
                    'VariantConfigurationObject',modelName);
                end
            end
        end




        function paramName=buildArgSpecParam(this,workSpace,m3iArg)

            switch m3iArg.Direction.toString()
            case 'Error'
                slParam=this.walkStdReturnTypeParameter();
            otherwise
                slParam=this.walkParameterData(m3iArg);
            end

            paramName=slParam.name;

            if slParam.willBeAssigned
                assignin(workSpace,paramName,slParam.slObj);
            end
        end

    end

    methods(Access='protected')


        function ctx=newContext(~)
            ctx=struct();
            ctx.name='';
            ctx.slObj=[];
            ctx.willBeAssigned=false;

            ctx.codeProperties=struct();
            ctx.codeProperties.paramType='';
            ctx.codeProperties.Const='';
            ctx.codeProperties.Volatile='';
            ctx.codeProperties.AdditionalNativeTypeQualifier='';
            ctx.codeProperties.SwAddrMethod='';
            ctx.codeProperties.SwCalibAccess='';
            ctx.codeProperties.DisplayFormat='';
            ctx.codeProperties.LongName='';
            ctx.codeProperties.Port='';
            ctx.codeProperties.DataElement='';
        end








        function result=syscParamToZero(self,symbol)
            if any(ismember(self.createdSystemConsts,symbol))
                result='0';
            else
                result=symbol;
            end
        end



        function slObjInfo=createSystemConstants(self,sysConsts,datatype,isPostBuild)

            function value=getValueFromMap(valueMap,sysc,createdObjName,isPostBuild)
                if valueMap.isKey(sysc)
                    values=valueMap(sysc);
                    if numel(values)>1
                        value=values(1);
                        if isempty(self.(createdObjName))||~any(ismember(self.(createdObjName),sysc))
                            values=strjoin(arrayfun(@(arg)num2str(arg),values,'UniformOutput',false),',');
                            if isPostBuild
                                self.msgStream.createWarning('autosarstandard:importer:ambiguousPostBuildVariantCriterionValue',{values,sysc,num2str(value)});
                            else
                                self.msgStream.createWarning('autosarstandard:importer:ambiguousSystemConstantValue',{values,sysc,num2str(value)});
                            end
                        end
                    else
                        value=values;
                    end
                else
                    value=[];
                    if isempty(self.(createdObjName))||~any(ismember(self.(createdObjName),sysc))
                        if isPostBuild
                            autosar.mm.util.MessageReporter.createWarning(...
                            'autosarstandard:importer:undefinedPostBuildVariantCriterionValue',sysc);
                        else
                            autosar.mm.util.MessageReporter.createWarning(...
                            'autosarstandard:importer:undefinedSystemConstantValue',sysc);
                        end
                    end
                end
            end

            if length(sysConsts)<1
                slObjInfo=[];
                return;
            end
            slObjInfo(length(sysConsts))=self.newContext();
            if isPostBuild
                valueMap=self.slTypeBuilder.getPostBuildCritsValueMap();
            else
                valueMap=self.slTypeBuilder.getSysConstsValueMap();
            end

            for ii=1:length(sysConsts)
                sysc=sysConsts{ii};

                if isPostBuild
                    createdObjName='CreatedPostBuildCrits';
                else
                    createdObjName='CreatedSystemConsts';
                end

                if isPostBuild
                    value=getValueFromMap(valueMap,sysc,createdObjName,isPostBuild);
                    [slParam,isCreated]=self.createOrUpdateMatlabVariable(sysc,value);
                    slObjInfo(ii)=self.newContext();
                    slObjInfo(ii).name=sysc;
                    slObjInfo(ii).slObj=value;
                    slObjInfo(ii).willBeAssigned=self.getWillBeAssignedBool(isCreated,slParam,sysc);
                    continue;
                end

                [slParam,isCreated]=self.createOrUpdateObject(sysc,'AUTOSAR.Parameter');
                slParam.CoderInfo.StorageClass='Custom';
                slParam.CoderInfo.CustomStorageClass='SystemConstant';

                if isCreated
                    slParam.DataType='int32';
                    if~isempty(datatype)
                        slParam.DataType=datatype;
                    end
                end

                value=getValueFromMap(valueMap,sysc,createdObjName,isPostBuild);
                self.(createdObjName)=unique([self.(createdObjName),sysc]);
                switch slParam.DataType
                case{'int32','uint32','int16','uint16','int8',...
                    'uint8','single','double'}
                    slParam.Value=cast(value,slParam.DataType);
                case 'boolean'
                    slParam.Value=cast(value,'logical');
                otherwise
                    slParam.Value=value;
                end

                if slfeature('ModelArgumentValueInterface')>=1&&...
                    ~isCreated&&isempty(slParam.Value)

                    slParam.Dimensions=[0,0];
                end


                slObjInfo(ii)=self.newContext();
                slObjInfo(ii).name=sysc;
                slObjInfo(ii).slObj=slParam;
                slObjInfo(ii).willBeAssigned=self.getWillBeAssignedBool(isCreated,slParam,sysc);
            end
        end



        function slObjInfo=walkVariationPointProxy(self,m3iData,~)
            slObjInfo=[];
            if~m3iData.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',...
                2,'VariationPointProxy'));
            end

            hasPreBuildCondition=~isempty(m3iData.ConditionAccess)||~isempty(m3iData.ValueAccess);
            hasPostBuildCondition=~m3iData.PostBuildVariantCondition.isEmpty();

            if hasPostBuildCondition&&~slfeature('AUTOSARPostBuildVariant')
                DAStudio.error('autosarstandard:importer:UnsupportedPostBuildBindingTime',m3iData.Name);
            end

            if hasPreBuildCondition&&hasPostBuildCondition
                DAStudio.error('autosarstandard:importer:VppMixedBindTime',m3iData.Name);
            end

            if~isempty(m3iData.PostBuildValueAccess)
                DAStudio.error('autosarstandard:importer:UnsupportedPostBuildValueAccess',m3iData.Name);
            end

            if~isempty(m3iData.ConditionAccess)
                slObjInfo=self.getConditionByFormulaSysC(m3iData.Name,m3iData.ConditionAccess);
            end

            if~isempty(m3iData.ValueAccess)&&m3iData.ValueAccess.SysConst.size>0
                types={'Numerical','auto';...
                'Integer','int32';...
                'PositiveInteger','uint32';...
                'UnlimitedInteger','int32';...
                'Float','double';...
                'Boolean','boolean';...
                'Limit','double';...
                };

                m3iType=class(m3iData.ValueAccess);
                dtype='int32';
                for t=types'
                    fullname=['Simulink.metamodel.arplatform.variant.',t{1},'ValueVariationPoint'];
                    if strcmp(m3iType,fullname)
                        dtype=t{2};
                        break;
                    end
                end

                sysConsts{m3iData.ValueAccess.SysConst.size}='';
                for ii=1:m3iData.ValueAccess.SysConst.size
                    sysConsts{ii}=m3iData.ValueAccess.SysConst.at(ii).Name;
                end
                isPostBuild=false;
                slObjInfo=self.createSystemConstants(sysConsts,dtype,isPostBuild);
            end

            if~m3iData.PostBuildVariantCondition.isEmpty()
                slObjInfo=self.getPostBuildConditions(m3iData.Name,m3iData.PostBuildVariantCondition);
            end
        end

        function slObjInfo=walkObjWithVariationPoint(self,m3iData)




            if isa(m3iData,'Simulink.metamodel.arplatform.behavior.Runnable')
                self.applySeq(m3iData.compParamRead);
                self.applySeq(m3iData.portParamRead);
            end
            if~m3iData.isvalid()
                [~,~,ext]=fileparts(class(m3iData));
                objType=ext(2:end);
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',...
                2,objType));
            end

            slObjInfo={};
            if isempty(m3iData.variationPoint)
                return;
            end

            hasPreBuildCondition=~isempty(m3iData.variationPoint.Condition);
            hasPostBuildCondition=~m3iData.variationPoint.PostBuildVariantCondition.isEmpty();

            if hasPreBuildCondition&&hasPostBuildCondition
                DAStudio.error('autosarstandard:importer:VpMixedBindTime',m3iData.variationPoint.Name);
            end

            if hasPreBuildCondition
                slObjInfo=self.getConditionByFormulaSysC(...
                m3iData.variationPoint.Name,m3iData.variationPoint.Condition);
            end

            if hasPostBuildCondition
                slObjInfo=self.getPostBuildConditions(m3iData.variationPoint.Name,m3iData.variationPoint.PostBuildVariantCondition);
            end
        end

        function slObjInfo=getConditionByFormulaSysC(self,name,m3iConditionByFormula)




            if~m3iConditionByFormula.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',...
                2,'ConditionByFormula'));
            end

            sysConsts={};
            if m3iConditionByFormula.SysConst.size>0
                for ii=m3iConditionByFormula.SysConst.size:-1:1
                    sysConsts{ii}=m3iConditionByFormula.SysConst.at(ii).Name;
                end
            end
            isPostBuild=false;
            slObjInfo=self.createSystemConstants(sysConsts,'',isPostBuild);
            slName=self.getOrCreateSlParamName(name);
            [slParam,isCreated]=self.createOrUpdateObject(slName,'Simulink.Variant');

            condExpr=autosar.mm.util.extractCondExpressionFromM3iCondAccess(...
            m3iConditionByFormula);

            condExpr=regexprep(condExpr,'!=','~=');
            condExpr=regexprep(condExpr,'!','~');

            sysConstsValueMap=self.slTypeBuilder.getSysConstsValueMap();
            if sysConstsValueMap.isKey(condExpr)


                condExpr=sprintf('%s ~= 0',condExpr);
            end
            slParam.Condition=condExpr;


            if isempty(slObjInfo)
                slObjInfo=self.newContext();
            else
                slObjInfo(end+1)=self.newContext();
            end
            slObjInfo(end).name=slName;
            slObjInfo(end).slObj=slParam;
            slObjInfo(end).willBeAssigned=self.getWillBeAssignedBool(isCreated,slParam,slName);
        end

        function slObjInfo=getPostBuildConditions(self,name,m3iPostBuildVariantConditionSeq)




            if~m3iPostBuildVariantConditionSeq.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',...
                2,'PostBuildVariantCondition'));
            end

            pbConsts={};
            if m3iPostBuildVariantConditionSeq.size>0
                for ii=m3iPostBuildVariantConditionSeq.size:-1:1
                    pbConsts{ii}=m3iPostBuildVariantConditionSeq.at(ii).MatchingCriterion.Name;
                end
            end
            isPostBuild=true;
            slObjInfo=self.createSystemConstants(pbConsts,'',isPostBuild);
            if isa(m3iPostBuildVariantConditionSeq.at(1).containerM3I,'Simulink.metamodel.arplatform.variant.VariationPointProxy')

                slName=self.getOrCreateSlParamName(name);
                [slParam,isCreated]=self.createOrUpdateObject(slName,'Simulink.Variant');

                condExpr='';
                for ii=1:m3iPostBuildVariantConditionSeq.size
                    if ii>1
                        condExpr=[condExpr,' && '];%#ok<AGROW>
                    end
                    condExpr=[condExpr,m3iPostBuildVariantConditionSeq.at(ii).MatchingCriterion.Name,' == ',num2str(m3iPostBuildVariantConditionSeq.at(ii).Value)];%#ok<AGROW>
                end

                sysConstsValueMap=self.slTypeBuilder.getSysConstsValueMap();
                if sysConstsValueMap.isKey(condExpr)


                    condExpr=sprintf('%s ~= 0',condExpr);
                end
                slParam.Condition=condExpr;


                if isempty(slObjInfo)
                    slObjInfo=self.newContext();
                else
                    slObjInfo(end+1)=self.newContext();
                end
                slObjInfo(end).name=slName;
                slObjInfo(end).slObj=slParam;
                slObjInfo(end).willBeAssigned=self.getWillBeAssignedBool(isCreated,slParam,slName);
            end
        end



        function slObjInfo=walkMatrixDimensions(self,m3iMatrix,~)
            slObjInfo=[];
            if~m3iMatrix.isvalid()
                assert(false,DAStudio.message('RTW:autosar:mmInvalidArgObject',...
                2,'Matrix'));
            end

            for ii=1:m3iMatrix.SymbolicDimensions.size
                m3iExpr=m3iMatrix.SymbolicDimensions.at(ii);
                [~,sysconsts]=autosar.mm.util.extractSystemConstantExpressionFromM3I(m3iExpr);
                isPostBuild=false;
                newSLObjInfo=self.createSystemConstants(sysconsts,'',isPostBuild);
                slObjInfo=[slObjInfo,newSLObjInfo];%#ok<AGROW>
            end
        end



        function slObjInfo=walkParameterData(self,m3iData,m3iContainer)

            assert(m3iData.isvalid(),DAStudio.message('RTW:autosar:mmInvalidArgObject',2,'Parameter'));
            assert(~isempty(m3iData.Name),DAStudio.message('RTW:autosar:mmUnnamedObject','Parameter'));
            if nargin<3||isempty(m3iContainer)

                m3iContainer=m3iData.containerM3I;
            end
            assert(m3iContainer.isvalid(),'container for parameter is not valid')

            slObjInfo=self.newContext();

            if~m3iData.Type.isvalid()

                self.msgStream.createWarning('RTW:autosar:unspecifiedDataType',...
                {'CalprmElement',...
                m3iData.Name,...
                'CalibrationParameterInterface',...
                m3iData.containerM3I.Name});
                return
            end

            codePropertiesParamKind=self.getCodePropertiesParamKind(m3iData,m3iContainer);
            if strcmp(codePropertiesParamKind,'SlFunctionCallerParameter')&&...
                ~self.isFunctionCallerSlParameterNeeded(m3iData.Type)

                return;
            end

            slCalPrmName=self.getParameterName(m3iData,m3iContainer,codePropertiesParamKind);


            isParameterUsedAsInitValue=self.InitValueParamSet.isKey(slCalPrmName);
            useLegacyWorkflow=isParameterUsedAsInitValue||self.ForceLegacyWorkspaceBehavior;

            if~useLegacyWorkflow
                slObjInfo=self.setCodeProperties(codePropertiesParamKind,m3iData,slObjInfo,m3iContainer);
            end

            slParamClassName=self.getSlParameterClassName(m3iData,codePropertiesParamKind,useLegacyWorkflow);
            isLookupType=strcmp(slParamClassName,'Simulink.LookupTable')||strcmp(slParamClassName,'Simulink.Breakpoint')||...
            autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxisLUT(m3iData.Type);

            [requiresManualUpdate,slCalPrm,isCreated]=self.createOrUpdateSlParameter(slCalPrmName,slParamClassName,codePropertiesParamKind);
            if requiresManualUpdate
                slObjInfo=[];
                return;
            end

            [~,~,inModelWorkspace]=self.objectExistsInModelScope(slCalPrmName);

            existingBaseWsObj=~isCreated&&~inModelWorkspace;

            if existingBaseWsObj




                slObjInfo.codeProperties.paramType='';
            end

            if~isLookupType&&(useLegacyWorkflow||existingBaseWsObj)
                self.updateSlCalPrmCoderInfo(slCalPrm,m3iData,m3iContainer,codePropertiesParamKind,useLegacyWorkflow);
            end

            if isLookupType


                m3iType=m3iData.Type;
                self.SlLUTParamToM3iTypeMap(slCalPrmName)=m3iType;




                if autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxisLUT(m3iType)
                    for axisIdx=1:m3iType.Axes.size()
                        m3iAxisType=m3iType.Axes.at(axisIdx);
                        if autosar.mm.mm2sl.TypeBuilder.hasValidInputVariableType(m3iAxisType)
                            self.slTypeBuilder.buildType(m3iAxisType.InputVariableType);
                        else
                            self.slTypeBuilder.buildType(m3iAxisType.BaseType);
                        end
                    end
                end
            end
            m3iImpType=self.getM3iImplementationType(m3iData.Type);
            m3iInitValue=autosar.mm.mm2sl.parameter.getM3IInitValue(m3iData,m3iContainer,self.M3IConnectedPortFinder,m3iImpType);
            slCalPrmUpdater=autosar.mm.mm2sl.parameter.AbstractParamUpdater.getParamUpdater(slCalPrm,...
            slCalPrmName,...
            m3iData,...
            m3iInitValue,...
            m3iImpType,...
            self.slConstBuilder,...
            self.slTypeBuilder);
            slCalPrmUpdater.update();


            slObjInfo.name=slCalPrmName;
            slObjInfo.slObj=slCalPrmUpdater.SlCalPrm;
            slObjInfo.willBeAssigned=self.getWillBeAssignedBool(isCreated,slCalPrmUpdater.SlCalPrm,slCalPrmName);
        end

        function[requiresManualUpdate,slCalPrm,isCreated]=createOrUpdateSlParameter(self,slParamName,targetSlParamClassName,codePropertiesParamKind)
            slCalPrm=[];
            isCreated=false;


            [varExists,oldObject,existsInModelWorkspace]=self.objectExistsInModelScope(slParamName);


            requiresManualUpdate=varExists&&self.parameterRequiresManualUpdate(oldObject);
            if requiresManualUpdate
                self.ChangeLogger.logModification('Manual','',class(oldObject),slParamName);
                return;
            end


            isUpdateMode=~isempty(self.SLMatcher);
            objectRequiresCreation=~isUpdateMode||~varExists;


            if~varExists||~self.existingParameterIsCompatible(slParamName,targetSlParamClassName)
                objectRequiresCreation=true;
            else

                targetSlParamClassName=class(oldObject);
            end


            targetModelWS=existsInModelWorkspace||objectRequiresCreation;

            isConstantMemory=strcmp(codePropertiesParamKind,'ConstantMemory');
            [slCalPrm,isCreated]=self.createOrUpdateObject(slParamName,...
            targetSlParamClassName,isConstantMemory,objectRequiresCreation,targetModelWS);
        end

        function isCompatible=existingParameterIsCompatible(self,slParamName,targetClassName)
            [varExists,oldObject,existsInModelWorkspace]=self.objectExistsInModelScope(slParamName);
            assert(varExists,'This should only be called for parameters know to exist');
            if any(strcmp(targetClassName,{'Simulink.LookupTable','Simulink.Breakpoint'}))...
                &&isa(oldObject,'Simulink.Parameter')

                if self.ForceLegacyWorkspaceBehavior
                    isCompatible=false;
                else
                    isCompatible=true;
                end
                return;
            elseif any(strcmp(targetClassName,{'Simulink.LookupTable','Simulink.Breakpoint'}))...
                &&isa(oldObject,targetClassName)&&~existsInModelWorkspace


                isCompatible=true;
                return;
            elseif isa(oldObject,'AUTOSAR.Parameter')

                isCompatible=true;
                return;
            end


            isCompatible=isa(oldObject,targetClassName)&&existsInModelWorkspace;
        end

        function requiresManualUpdate=parameterRequiresManualUpdate(self,oldObject)
            requiresManualUpdate=any(cellfun(@(x)isa(oldObject,x),self.NonUpdatableParameterClasses));
        end

        function slCalPrmName=getParameterName(self,m3iData,m3iPort,codePropertiesParamKind)
            switch codePropertiesParamKind
            case 'PortParameter'

                slCalPrmName=self.getOrCreateSlParamName(sprintf('%s_%s',m3iPort.Name,m3iData.Name));
            case 'SlFunctionCallerParameter'

                slCalPrmName=self.getOrCreateSlParamName(sprintf('P_%s',m3iData.Type.Name));
            case{'ConstantMemory','SharedParameter','PerInstanceParameter'}
                slCalPrmName=self.getOrCreateSlParamName(m3iData.Name);
            otherwise
                assert(false,sprintf('Unknown codePropertiesParamKind: %s',codePropertiesParamKind));
            end
        end

        function updateSlCalPrmCoderInfo(self,slCalPrm,m3iData,m3iPort,codePropertiesParamKind,useLegacyWorkflow)

            if useLegacyWorkflow
                slCalPrm.SwCalibrationAccess=autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iData.SwCalibrationAccess);
                slCalPrm.CoderInfo.StorageClass='Custom';
                slCalPrm.DisplayFormat=m3iData.DisplayFormat;
            end
            switch codePropertiesParamKind
            case 'ConstantMemory'
                if isa(slCalPrm,'AUTOSAR4.Parameter')

                    self.RequiresLegacyMemorySectionDefinitions=true;
                end
                if useLegacyWorkflow
                    slCalPrm.CoderInfo.CustomStorageClass='Global';
                    if autosar.mm.mm2sl.utils.isCompatibleSwAddrMethod(m3iData.SwAddrMethod)
                        try
                            slCalPrm.CoderInfo.CustomAttributes.MemorySection=m3iData.SwAddrMethod.Name;
                        catch
                        end
                    end
                end
            case 'SharedParameter'
                instanceBehav='Parameter shared by all instances of the Software Component';
                slCalPrm.CoderInfo.CustomStorageClass='InternalCalPrm';
                slCalPrm.CoderInfo.CustomAttributes.PerInstanceBehavior=instanceBehav;
            case 'PerInstanceParameter'
                instanceBehav='Each instance of the Software Component has its own copy of the';
                slCalPrm.CoderInfo.CustomStorageClass='InternalCalPrm';
                slCalPrm.CoderInfo.CustomAttributes.PerInstanceBehavior=instanceBehav;
            case 'PortParameter'
                slCalPrm.CoderInfo.CustomStorageClass='CalPrm';
                slCalPrm.CoderInfo.CustomAttributes.ElementName=m3iData.Name;
                if isa(m3iPort,'Simulink.metamodel.arplatform.port.Port')
                    portName=m3iPort.Name;
                    interfacePathQName=autosar.api.Utils.getQualifiedName(m3iPort.Interface);
                else
                    portName='';
                    interfacePathQName=autosar.api.Utils.getQualifiedName(m3iPort);
                end
                slCalPrm.CoderInfo.CustomAttributes.PortName=portName;
                slCalPrm.CoderInfo.CustomAttributes.InterfacePath=interfacePathQName;
                if isa(m3iPort.containerM3I,'Simulink.metamodel.arplatform.component.ParameterComponent')
                    slCalPrm.CoderInfo.CustomAttributes.CalibrationComponent=autosar.api.Utils.getQualifiedName(m3iPort.containerM3I);
                    slCalPrm.CoderInfo.CustomAttributes.ProviderPortName=m3iPort.Name;
                end
            case 'SlFunctionCallerParameter'

            otherwise
                assert(false,sprintf('Invalid Parameter Kind: %s',codePropertiesParamKind));
            end
        end

        function updateBreakpointsForReferenceAxisLookupTableParams(self,globalWorkSpace,modelWorkSpace)


            for key=keys(self.SlLUTParamToM3iTypeMap)
                slTableParamName=key{1};
                m3iType=self.SlLUTParamToM3iTypeMap(slTableParamName);
                m3iAxesNames=self.getSharedAxesNamesFromM3iType(m3iType);
                if~isempty(m3iAxesNames)
                    numberOfM3iAxes=numel(m3iAxesNames);
                    slBreakPointNames=cell(numberOfM3iAxes,0);
                    for axisIndex=1:numberOfM3iAxes
                        m3iAxisName=m3iAxesNames{axisIndex};
                        breakpointName=self.getSlBreakpointNameFromM3iSharedAxisTypeName(m3iAxisName);
                        if~isempty(breakpointName)
                            slBreakPointNames{axisIndex}=breakpointName;
                        end
                    end
                    numberOfSlBreakpoints=numel(slBreakPointNames);
                    if numberOfSlBreakpoints>0
                        if numberOfSlBreakpoints~=numberOfM3iAxes
                            DAStudio.error('autosarstandard:importer:UnableToSetLUTParam',...
                            slTableParamName);
                        end
                    else




                    end
                    self.assignBreakpointsToSlLookupTableParam(slBreakPointNames,slTableParamName,globalWorkSpace,modelWorkSpace);
                end
            end
        end

        function slBreakpointName=getSlBreakpointNameFromM3iSharedAxisTypeName(self,m3iAxisName)


            slBreakpointName={};
            for key=keys(self.SlLUTParamToM3iTypeMap)
                slParamName=key{1};
                m3iType=self.SlLUTParamToM3iTypeMap(slParamName);
                if strcmp(m3iType.Name,m3iAxisName)&&...
                    isa(m3iType,'Simulink.metamodel.types.SharedAxisType')
                    slBreakpointName=slParamName;
                    break;
                end
            end
        end

        function assignBreakpointsToSlLookupTableParam(self,unSwappedBreakPointNames,lookupTableName,globalWorkSpace,modelWorkSpace)



            numberOfBreakpoints=numel(unSwappedBreakPointNames);
            swappedBreakpointNames=cell(numberOfBreakpoints,0);
            for ii=1:numberOfBreakpoints
                swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfBreakpoints,ii);
                swappedBreakpointNames{swappedIndex}=unSwappedBreakPointNames{ii};
            end
            if numberOfBreakpoints>0
                slName=self.getOrCreateSlParamName(lookupTableName);
                [~,paramObj,inModelWorkspace]=self.objectExistsInModelScope(slName);
                if isa(paramObj,'Simulink.LookupTable')
                    paramObj.BreakpointsSpecification='Reference';
                    paramObj.Breakpoints=swappedBreakpointNames;
                    if inModelWorkspace
                        assignin(modelWorkSpace,slName,paramObj);
                    else
                        assignin(globalWorkSpace,slName,paramObj);
                    end
                end
            end
        end

        function ret=mmWalkComponentParameterAccess(self,m3iAccess)
            ret=[];
            m3iInstanceRef=m3iAccess.instanceRef;
            if~m3iInstanceRef.DataElements.isvalid()
                return
            end
            if strcmp(m3iInstanceRef.DataElements.category,'VAL_BLK')
                return;
            end
            if isa(m3iInstanceRef.DataElements.Type,'Simulink.metamodel.types.LookupTableType')...
                ||isa(m3iInstanceRef.DataElements.Type,'Simulink.metamodel.types.SharedAxisType')
                paramName=self.getOrCreateSlParamName(m3iInstanceRef.DataElements.Name);
                self.SlLUTParamToM3iTypeMap(paramName)=m3iInstanceRef.DataElements.Type;
            end
        end

        function ret=mmWalkPortParameterAccess(self,m3iAccess)
            ret=[];
            m3iInstanceRef=m3iAccess.instanceRef;
            if~m3iInstanceRef.Port.isvalid()||~m3iInstanceRef.DataElements.isvalid()
                return;
            end
            if strcmp(m3iInstanceRef.DataElements.category,'VAL_BLK')
                return;
            end
            if isa(m3iInstanceRef.DataElements.Type,'Simulink.metamodel.types.LookupTableType')...
                ||isa(m3iInstanceRef.DataElements.Type,'Simulink.metamodel.types.SharedAxisType')
                slParamName=self.getOrCreateSlParamName([m3iInstanceRef.Port.Name,'_',m3iInstanceRef.DataElements.Name]);
                self.SlLUTParamToM3iTypeMap(slParamName)=m3iInstanceRef.DataElements.Type;
            end
        end


        function slObjInfo=walkStdReturnTypeParameter(self)


            name='P_Std_ReturnType';

            [slCalPrm,isCreated]=self.createOrUpdateObject(name,'Simulink.Parameter');

            typeStr='Std_ReturnType';
            slCalPrm.DataType=typeStr;
            slCalPrm.Value=0;


            slObjInfo=self.newContext();
            slObjInfo.name=name;
            slObjInfo.slObj=slCalPrm;
            slObjInfo.willBeAssigned=self.getWillBeAssignedBool(isCreated,slCalPrm,name);

        end

        function ret=isGlobalMemory(~,object)
            ret=autosar.mm.util.getIsAutosarConstantMemoryObject(object);
        end

        function slObjInfo=setCodeProperties(self,codePropertiesParamKind,m3iData,slObjInfo,m3iPort)
            if nargin<5
                m3iPort=[];
            end

            if~isempty(m3iData.SwAddrMethod)
                slObjInfo.codeProperties.SwAddrMethod=m3iData.SwAddrMethod.Name;
            end
            slObjInfo.codeProperties.SwCalibAccess=m3iData.SwCalibrationAccess.toString;
            slObjInfo.codeProperties.DisplayFormat=m3iData.DisplayFormat;
            if slfeature('AUTOSARLongNameAuthoring')
                slObjInfo.codeProperties.LongName=...
                autosar.ui.codemapping.PortCalibrationAttributeHandler.getLongNameValueFromMultiLanguageLongName(m3iData.longName);
            end

            switch codePropertiesParamKind
            case 'ConstantMemory'
                slObjInfo.codeProperties.paramType='ConstantMemory';

                m3iType=self.getM3iImplementationType(m3iData.Type);
                if isempty(m3iType)
                    m3iType=self.slTypeBuilder.getUnderlyingType(m3iData.Type);
                end

                if m3iType.IsConst
                    slObjInfo.codeProperties.Const='true';
                else
                    slObjInfo.codeProperties.Const='false';
                end
                if m3iType.IsVolatile
                    slObjInfo.codeProperties.Volatile='true';
                else
                    slObjInfo.codeProperties.Volatile='false';
                end
                slObjInfo.codeProperties.AdditionalNativeTypeQualifier=m3iType.Qualifier;
            case{'SharedParameter','PerInstanceParameter'}
                slObjInfo.codeProperties.paramType=codePropertiesParamKind;
            case 'PortParameter'
                slObjInfo.codeProperties.paramType='PortParameter';
                slObjInfo.codeProperties.Port=m3iPort.Name;
                slObjInfo.codeProperties.DataElement=m3iData.Name;
            case 'SlFunctionCallerParameter'

            otherwise
                assert(false,sprintf('Unknown codePropertiesParamKind: %s',codePropertiesParamKind));
            end
        end

        function slParamName=getOrCreateSlParamName(self,arParam)
            slMatcher=self.SLMatcher;
            if~isempty(slMatcher)
                slParamName=slMatcher.getSlParamName(arParam);
            else
                slParamName=arParam;
            end

            exists=isvarname(slParamName)&&self.objectExistsInModelScope(slParamName);

            if~exists
                slParamName=arxml.arxml_private('p_create_aridentifier',...
                arParam,...
                namelengthmax);
            end
        end

        function m3iImpType=getM3iImplementationType(self,m3iType)
            if m3iType.IsApplication
                impQName=self.slTypeBuilder.getImplementationDataType(m3iType.qualifiedName);
                if isempty(impQName)
                    m3iImpType=[];
                else
                    m3iSeq=autosar.mm.Model.findObjectByName(self.m3iModel,impQName);
                    m3iImpType=m3iSeq.at(1);
                end
            else
                m3iImpType=m3iType;
            end
        end

    end

    methods(Access=private,Static)
        function populateVariantConfig(variantMap,modelName,configName,variantConfig,isPostBuild)
            variantConKeys=variantMap.keys;
            variantConValues=variantMap.values;
            for jj=1:numel(variantConKeys)
                exists=false;
                dataType='int32';


                [paramExists,slParam]=autosar.utils.Workspace.objectExistsInModelScope(modelName,variantConKeys{jj});
                if paramExists
                    if slParam.Value==cast(variantConValues{jj},slParam.DataType)
                        exists=true;
                    end
                    dataType=slParam.DataType;
                end
                if~exists


                    slParam=AUTOSAR.Parameter;
                    slParam.DataType=dataType;
                    slParam.CoderInfo.StorageClass='Custom';
                    if isPostBuild
                        slParam.CoderInfo.CustomStorageClass='PostBuild';
                    else
                        slParam.CoderInfo.CustomStorageClass='SystemConstant';
                    end
                    slParam.Value=cast(variantConValues{jj},dataType);
                end
                variantConfig.addControlVariables(configName,...
                struct('Name',variantConKeys{jj},'Value',slParam));
            end
        end

        function sharedAxesNames=getSharedAxesNamesFromM3iType(m3iType)


            sharedAxesNames={};
            if isa(m3iType,'Simulink.metamodel.types.LookupTableType')&&...
                m3iType.Axes.at(1).SharedAxis.isvalid()
                m3iAxisSeq=m3iType.Axes;
                axisCount=m3iAxisSeq.size();
                sharedAxesNames=cell(axisCount,0);
                for axisIndex=1:axisCount
                    m3iAxisType=m3iAxisSeq.at(axisIndex).SharedAxis;
                    sharedAxesNames(axisIndex)={m3iAxisType.Name};
                end
            end
        end

        function slParamClassName=getSlParameterClassName(m3iData,codePropertiesParamKind,useLegacyWorkflow)
            if strcmp(codePropertiesParamKind,'SlFunctionCallerParameter')
                slParamClassName='Simulink.Parameter';
            elseif isa(m3iData.Type,'Simulink.metamodel.types.LookupTableType')
                if autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxisLUT(m3iData.Type)
                    slParamClassName='Simulink.Parameter';
                else
                    slParamClassName='Simulink.LookupTable';
                end
            elseif isa(m3iData.Type,'Simulink.metamodel.types.SharedAxisType')...
                &&(isempty(m3iData.category)||strcmp(m3iData.category,'COM_AXIS'))
                slParamClassName='Simulink.Breakpoint';
            elseif useLegacyWorkflow
                if strcmp(codePropertiesParamKind,'ConstantMemory')
                    slParamClassName='AUTOSAR4.Parameter';
                else
                    slParamClassName='AUTOSAR.Parameter';
                end
            else
                slParamClassName='Simulink.Parameter';
            end
        end

        function isNeeded=isFunctionCallerSlParameterNeeded(m3iType)


            m3iBottomType=autosar.mm.mm2sl.TypeBuilder.getUnderlyingType(m3iType);
            isBuiltInType=(autosar.mm.util.BuiltInTypeMapper.isARBuiltIn(m3iType)||...
            autosar.mm.util.BuiltInTypeMapper.isARBuiltIn(m3iBottomType)&&...
            (isa(m3iType,'Simulink.metamodel.types.Matrix')&&...
            isequal(m3iType.BaseType,m3iBottomType)))||...
            (isa(m3iType,'Simulink.metamodel.types.Enumeration')||...
            isa(m3iBottomType,'Simulink.metamodel.types.Enumeration'));
            if isBuiltInType
                isNeeded=false;
            else
                isNeeded=true;
            end
        end

        function codePropertiesParamKind=getCodePropertiesParamKind(m3iData,m3iContainer)
            if isa(m3iContainer,'Simulink.metamodel.arplatform.interface.Operation')


                codePropertiesParamKind='SlFunctionCallerParameter';
            elseif isa(m3iContainer,'Simulink.metamodel.arplatform.port.Port')||...
                isa(m3iContainer,'Simulink.metamodel.arplatform.interface.ParameterInterface')
                codePropertiesParamKind='PortParameter';
            else
                switch m3iData.Kind
                case Simulink.metamodel.arplatform.behavior.ParameterKind.Const
                    codePropertiesParamKind='ConstantMemory';
                case Simulink.metamodel.arplatform.behavior.ParameterKind.Shared
                    codePropertiesParamKind='SharedParameter';
                case Simulink.metamodel.arplatform.behavior.ParameterKind.Pim
                    codePropertiesParamKind='PerInstanceParameter';
                otherwise
                    assert(false,sprintf(['Unknown Parameter Kind: %s '...
                    ,'or unexpected container for calibration parameter %s'],m3iData.Kind,m3iData.Name));
                end
            end
        end

    end
end





