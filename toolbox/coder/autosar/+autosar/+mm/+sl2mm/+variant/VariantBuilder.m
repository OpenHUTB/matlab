classdef VariantBuilder<handle




    properties(Access=private)
ModelName
        SystemConstantBuilder autosar.mm.sl2mm.variant.SystemConstantBuilder
        PostBuildVariantCriterionBuilder autosar.mm.sl2mm.variant.PostBuildVariantCriterionBuilder
        PredefinedVariantBuilder autosar.mm.sl2mm.variant.PredefinedVariantBuilder
        msgStream autosar.mm.util.MessageStreamHandler
LocalM3IModel
SharedM3IModel
        VariationPointMerger autosar.mm.util.QualifiedNameSequenceMerger
        VariationPointProxyMerger autosar.mm.util.SequenceMerger
CodeDescriptor
MaxShortNameLength
    end

    methods
        function this=VariantBuilder(modelName,localM3IModel,sharedM3IModel,dataTypePkg,m3iBehavior,m3iSWC,codeDescriptor)
            this.ModelName=modelName;
            this.msgStream=autosar.mm.util.MessageStreamHandler.instance();
            this.MaxShortNameLength=...
            get_param(modelName,'AutosarMaxShortNameLength');

            this.LocalM3IModel=localM3IModel;
            this.SharedM3IModel=sharedM3IModel;

            this.SystemConstantBuilder=autosar.mm.sl2mm.variant.SystemConstantBuilder(sharedM3IModel,dataTypePkg);
            this.PostBuildVariantCriterionBuilder=autosar.mm.sl2mm.variant.PostBuildVariantCriterionBuilder(sharedM3IModel,dataTypePkg);

            this.VariationPointProxyMerger=autosar.mm.util.SequenceMerger(this.LocalM3IModel,m3iBehavior.variationPointProxy,...
            'Simulink.metamodel.arplatform.variant.VariationPointProxy');
            this.VariationPointMerger=autosar.mm.util.QualifiedNameSequenceMerger(this.LocalM3IModel,m3iSWC,...
            'Simulink.metamodel.arplatform.variant.VariationPoint');

            this.CodeDescriptor=codeDescriptor;

            this.PredefinedVariantBuilder=...
            autosar.mm.sl2mm.variant.PredefinedVariantBuilder(...
            this.ModelName,...
            this.SystemConstantBuilder,...
            this.PostBuildVariantCriterionBuilder,...
            this.SharedM3IModel,...
            this.CodeDescriptor);
        end

        function cleanup(this)
            delete(this.VariationPointMerger);
            delete(this.VariationPointProxyMerger);
        end

        function setVariationPointViaMap(this,variationPoints)
            arRootShared=this.SharedM3IModel.RootPackage.front();
            exportVPs=autosar.mm.util.XmlOptionsAdapter.get(arRootShared,'ExportPropagatedVariantConditions');
            if strcmp(exportVPs,'All')
                keys=variationPoints.keys;
                for ii=1:length(keys)
                    portVP=variationPoints(keys{ii});
                    this.setVariationPoint(portVP);
                    this.setPostBuildVariationPoint(portVP);
                end
            end
        end

        function findOrCreatePredefinedVariants(this)
            this.PredefinedVariantBuilder.findOrCreatePredefinedVariants();
        end

        function xformPreCompileVariantAnnotations(this,variantAnnotations)
            if~isempty(variantAnnotations)
                [~,ic,~]=unique({variantAnnotations.Name});
                variantAnnotations=variantAnnotations(ic);
            end

            if~isempty(variantAnnotations)
                this.createVPPsInM3IModel(variantAnnotations,'PreCompileTime');
            end
        end

        function xformCodeGenTimeVariantAnnotations(this,codeGenTimeVariantAnnotations,preCompileVariantAnnotations)
            if isempty(codeGenTimeVariantAnnotations)
                return;
            end

            if isempty(preCompileVariantAnnotations)
                precompileNames=[];
            else
                precompileNames={preCompileVariantAnnotations.Name};
            end

            [~,ia]=setdiff({codeGenTimeVariantAnnotations.Name},precompileNames);
            codegenTimeOnlyVariants=codeGenTimeVariantAnnotations(ia);
            this.createVPPsInM3IModel(codegenTimeOnlyVariants,'CodeGenerationTime');
        end

        function xformPostBuildVariantAnnotations(this,postBuildAnnotations)
            if~isempty(postBuildAnnotations)
                [~,ic,~]=unique({postBuildAnnotations.Name});
                postBuildAnnotations=postBuildAnnotations(ic);
            end

            if~isempty(postBuildAnnotations)
                if slfeature('AUTOSARPostBuildVariant')
                    this.createPostBuildVPPsInM3IModel(postBuildAnnotations);
                else
                    DAStudio.error('autosarstandard:exporter:StartupVariantNotSupported',this.ModelName);
                end
            end
        end

        function xformValueVariants(this,m3iBehavior,codeDescParams)
            for param=codeDescParams
                implementation=param.Implementation;
                if isempty(implementation)||~isa(implementation,'coder.descriptor.AutosarCalibration')
                    continue;
                end

                dataTypeObj=implementation.Type;
                if~isempty(dataTypeObj)||~strcmp(implementation.DataAccessMode,'InternalCalPrm')
                    continue;
                end

                sysconstName=param.GraphicalName;
                existing=autosar.mm.Model.findChildByName(m3iBehavior,sysconstName,true);
                if~isempty(existing)
                    DAStudio.error('autosarstandard:validation:shortNameCaseClash',...
                    sysconstName,'Variation Point Proxy',...
                    existing.Name,sprintf('%s %s',existing.MetaClass.name,autosar.api.Utils.getQualifiedName(existing)));
                end
                this.populateValueVariant(sysconstName)
            end
        end

        function xformSymbolicDimensions(this,codeDescSymDyms)
            for symdim=codeDescSymDyms
                slObj=autosar.mm.util.getValueFromGlobalScope(this.ModelName,symdim.Name);
                if autosar.mm.sl2mm.variant.Utils.isSystemConstant(slObj)
                    this.populateValueVariant(symdim.Name);
                end
            end
        end

        function annotations=find_codegen_variants(this)





            annotations=[];


            annotations=[annotations,this.extractCGTAnnotationsFromBlocksWithType('ModelReference',@this.getSubsystemVariantAnnotations)];


            annotations=[annotations,this.extractCGTAnnotationsFromBlocksWithType('SubSystem',@this.getSubsystemVariantAnnotations)];


            annotations=[annotations,this.extractCGTAnnotationsFromBlocksWithType('VariantSource',@this.getBlockVariantAnnotations)];
            annotations=[annotations,this.extractCGTAnnotationsFromBlocksWithType('VariantSink',@this.getBlockVariantAnnotations)];
        end
    end

    methods(Access=private)
        function createVPPsInM3IModel(this,variantAnnotations,bindingTime)




            variantNames={};
            for ii=1:length(variantAnnotations)
                annotation=variantAnnotations(ii);
                if isempty(annotation)
                    continue;
                end

                if any(ismember(variantNames,annotation.Name))
                    continue;
                else
                    variantNames=[variantNames,{annotation.Name}];
                end

                if isa(annotation,'coder.descriptor.VariantAnnotation')
                    body=annotation.DynamicTypedCondition;
                else
                    body=annotation.Condition;
                end

                [simplified,isUnconditionallyTrue]=this.simplifyConditionExpression(body);
                if isUnconditionallyTrue

                    return;
                end
                if strcmp(bindingTime,'PreCompileTime')
                    body=this.expandVariantConditions(simplified,'','code compile');
                else
                    body=this.expandVariantConditions(simplified,'','update diagram analyze all choices');
                end


                m3iVpp=this.VariationPointProxyMerger.mergeByName(annotation.Name);
                m3iVpp.category='CONDITION';

                if~m3iVpp.ConditionAccess.isvalid
                    m3iVpp.ConditionAccess=Simulink.metamodel.arplatform.variant.ConditionByFormula(m3iVpp.rootModel);
                end

                this.constructCondition(m3iVpp.ConditionAccess,body);

                if strcmp(bindingTime,'PreCompileTime')
                    m3iVpp.ConditionAccess.BindingTime=Simulink.metamodel.arplatform.variant.BindingTimeKind.PreCompileTime;
                else
                    m3iVpp.ConditionAccess.BindingTime=Simulink.metamodel.arplatform.variant.BindingTimeKind.CodeGenerationTime;
                end
            end
        end

        function createPostBuildVPPsInM3IModel(this,variantAnnotations)

            variantNames={};
            for ii=1:length(variantAnnotations)
                annotation=variantAnnotations(ii);
                if isempty(annotation)
                    continue;
                end

                if any(ismember(variantNames,annotation.Name))
                    continue;
                else
                    variantNames=[variantNames,{annotation.Name}];
                end


                m3iVpp=this.VariationPointProxyMerger.mergeByName(annotation.Name);
                m3iVpp.category='CONDITION';

                this.attachPostBuildConditions(m3iVpp,annotation);
            end
        end

        function setVariationPoint(this,vp)













































            m3iElement=vp.M3IElement;
            expression=vp.Condition;

            if isempty(expression)

                return;
            end

            [simplified,isUnconditionallyTrue]=this.simplifyConditionExpression(expression);
            if isUnconditionallyTrue

                return;
            end
            vpCondition=this.expandVariantConditions(simplified,vp.BlockName,'code compile');


            variationPointName=arxml.arxml_private('p_create_aridentifier',...
            ['vp',m3iElement.Name],this.MaxShortNameLength);
            m3iVariationPoint=this.findOrCreateVariationPoint(m3iElement,variationPointName);
            if isempty(m3iVariationPoint.Condition)
                m3iVariationPoint.Condition=Simulink.metamodel.arplatform.variant.ConditionByFormula(m3iElement.rootModel);
            end
            m3iVariationPoint.Condition.BindingTime=Simulink.metamodel.arplatform.variant.BindingTimeKind.PreCompileTime;


            this.constructCondition(m3iVariationPoint.Condition,vpCondition);
        end

        function setPostBuildVariationPoint(this,vp)
            m3iElement=vp.M3IElement;
            expression=vp.PostBuildCondition;

            if(isempty(expression))
                return;
            end

            [expression,isUnconditionallyTrue]=this.simplifyConditionExpression(expression);
            if isUnconditionallyTrue

                return;
            end

            if~slfeature('AUTOSARPostBuildVariant')
                DAStudio.error('autosarstandard:exporter:StartupVariantNotSupported',this.ModelName);
            else
                variantannotations=this.CodeDescriptor.getFullComponentInterface.PostBuildVariantAnnotations.toArray;
                if isempty(variantannotations)



                    return;
                end
            end

            expression=this.expandVariantConditions(expression,vp.BlockName,'startup');

            if~this.shouldCreateVpForExpression(expression,true)
                return;
            end


            variationPointName=arxml.arxml_private('p_create_aridentifier',...
            ['vp',m3iElement.Name],this.MaxShortNameLength);
            m3iVariationPoint=this.findOrCreateVariationPoint(m3iElement,variationPointName);

            annotation=this.findMatchingPostBuildAnnotation(expression);
            this.attachPostBuildConditions(m3iVariationPoint,annotation);
        end

        function MATLABVariable=getPbConstMATLABVar(this,paramName)







            MATLABVariable='';

            if(~slfeature('AUTOSARPostBuildVariant'))
                return;
            end

            if autosar.mm.sl2mm.variant.Utils.isPostBuildVariantCriterion(this.ModelName,paramName)
                mlVar=evalinGlobalScope(this.ModelName,paramName);
                if isa(mlVar,'Simulink.VariantControl')
                    MATLABVariable=struct('Name',paramName,'Value',mlVar.Value);
                else
                    MATLABVariable=struct('Name',paramName,'Value',mlVar);
                end
            end
        end

        function[simplified,isUnconditionallyTrue]=simplifyConditionExpression(~,expression)



            expression=regexprep(expression,'~=','!=');
            expression=regexprep(expression,'~','!');


            simplified=slInternal('SimplifyVarCondExpr',expression,false);

            isUnconditionallyTrue=false;
            if isempty(simplified)
                isUnconditionallyTrue=true;
            else
                simplified=regexprep(simplified,'!=','~=');
                simplified=regexprep(simplified,'!','~');
            end
        end

        function expanded=expandVariantConditions(this,expression,blockName,activationTime)



            function expanded=expandSLVariants(slVariantName,activationTime)



                slVariantName=autosar.mm.sl2mm.variant.Utils.stripRtePrefix(slVariantName);


                variantannotations=this.CodeDescriptor.getFullComponentInterface.VariantAnnotations.toArray;
                if~isempty(variantannotations)
                    index=find(strcmp(slVariantName,{variantannotations.Name}));
                    if~isempty(index)


                        expanded=slInternal('ConvertExprBetweenMandC',variantannotations(index(1)).DynamicTypedCondition,false,false);
                        expanded=['(',expanded,')'];
                        return;
                    end
                end

                expanded=slVariantName;
                exists=existsInGlobalScope(this.ModelName,slVariantName);
                if exists

                    slObj=evalinGlobalScope(this.ModelName,slVariantName);
                    if isa(slObj,'Simulink.Variant')


                        expanded=slInternal('ConvertExprBetweenMandC',slObj.Condition,true,false);
                        expanded=['(',expanded,')'];
                        return;
                    end
                    isSimVarCtrl=isa(slObj,'Simulink.VariantControl');
                    isSimVarCtrlNumeric=isSimVarCtrl&&~isobject(slObj.Value);
                    if isSimVarCtrl
                        slObj=slObj.Value;
                    end
                    switch activationTime
                    case 'code compile'
                        if isobject(slObj)
                            if~autosar.mm.sl2mm.variant.Utils.isValidCodeCompileParam(slObj)
                                DAStudio.error('autosarstandard:exporter:UnknownVariantExpression',...
                                expression,blockName);
                            end
                        else


                            if~isSimVarCtrl
                                DAStudio.error('autosarstandard:exporter:UnknownVariantExpression',...
                                expression,blockName);
                            end
                        end
                    case 'startup'
                        if~autosar.mm.sl2mm.variant.Utils.isPostBuildVariantCriterion(this.ModelName,slVariantName)
                            DAStudio.error('autosarstandard:exporter:UnknownVariantExpression',...
                            expression,blockName);
                        end
                    otherwise

                    end
                else







                    if this.isCEnumLiteral(slVariantName)

                        slVariantName=this.getMEnumInfoFromCEnumLiteral(slVariantName);
                    end
                    value=evalinGlobalScope(this.ModelName,slVariantName);
                    if isnumeric(value)||islogical(value)
                        expanded=sprintf("%d",value);
                    end
                end
            end

            expanded=autosar.mm.util.transformFormulaExpression(...
            expression,@(x)expandSLVariants(x,activationTime));


            [expanded,isUnconditionallyTrue]=this.simplifyConditionExpression(expanded);
            assert(~isUnconditionallyTrue,'Expanded expression should be conditional');
        end

        function shouldCreateVP=shouldCreateVpForExpression(this,expression,isPostBuild)


            shouldCreateVP=true;
            if isPostBuild
                variantannotations=this.CodeDescriptor.getFullComponentInterface.PostBuildVariantAnnotations.toArray;
            else

                return;
            end



            index=find(strcmp(expression,{variantannotations.PostBuildCondition}),1);
            if isempty(index)
                shouldCreateVP=false;
                return;
            end
        end

        function annotation=findMatchingPostBuildAnnotation(this,expression)



            annotation=[];

            variantannotations=this.CodeDescriptor.getFullComponentInterface.PostBuildVariantAnnotations.toArray;
            assert(~isempty(variantannotations),'Should not reach this with no annotations');

            index=find(strcmp(expression,{variantannotations.PostBuildCondition}),1);
            if~isempty(index)
                annotation=variantannotations(index);
            end
        end

        function attachPostBuildConditions(this,m3iVpOrVpp,variantAnnotation)
















            numExistingConditions=m3iVpOrVpp.PostBuildVariantCondition.size();
            for idx=1:numExistingConditions
                m3iVpOrVpp.PostBuildVariantCondition.at(1).destroy;
            end

            pbAndTerms=variantAnnotation.PostBuildANDTerms.toArray;
            assert(~isempty(pbAndTerms));
            for condIdx=1:length(pbAndTerms)



                condTerm=pbAndTerms(condIdx);

                pbConstInfo=this.getPbConstInfo(variantAnnotation.Name,condTerm.AndTerm);
                pbConstName=pbConstInfo{1}.Name;
                pbConstValue=pbConstInfo{1}.Value;
                activeValue=condTerm.Value;

                this.PostBuildVariantCriterionBuilder.createPostBuildVariantCondition(...
                m3iVpOrVpp,pbConstName,activeValue,pbConstValue);
            end
        end

        function m3iVarationPoint=findOrCreateVariationPoint(this,m3iElement,variationPointName)


            if m3iElement.variationPoint.isvalid()
                variationPointQualifiedName=autosar.api.Utils.getQualifiedName(m3iElement.variationPoint);
            else
                variationPointQualifiedName=strcat(...
                autosar.api.Utils.getQualifiedName(m3iElement),'/',variationPointName);
            end

            if this.VariationPointMerger.isWithinScope(variationPointQualifiedName)
                m3iElement.variationPoint=this.VariationPointMerger.mergeByQualifiedName(variationPointQualifiedName);
            else
                if~m3iElement.variationPoint.isvalid()
                    m3iElement.variationPoint=Simulink.metamodel.arplatform.variant.VariationPoint(m3iElement.rootModel);
                    m3iElement.variationPoint.Name=variationPointName;
                end
            end

            m3iVarationPoint=m3iElement.variationPoint;
        end

        function constructCondition(this,m3iCondition,vpCondition)



            systemConstants=containers.Map;
            conditionStr=autosar.mm.util.transformFormulaExpression(...
            vpCondition,@(x,y)this.referenceSystemConstants(x,y,systemConstants));


            m3iCondition.SysConst.clear();


            sysConstNames=systemConstants.keys;
            for ii=1:numel(sysConstNames)
                m3iCondition.SysConst.append(systemConstants(sysConstNames{ii}));
            end

            m3iCondition.Body=conditionStr;
        end

        function[text,symbol]=referenceSystemConstants(this,text,symbol,knownSystemConstants)



            assert(isa(knownSystemConstants,'containers.Map'),'Expect a map object as it is persistent');

            [~,syscon]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,text);
            isValidSysCon=autosar.mm.sl2mm.variant.Utils.isSystemConstant(syscon);
            [isValidSimVarCtrl,simVarCtrlValue]=autosar.mm.sl2mm.variant.Utils.isSimulinkVariantControlWithSysConValue(syscon);
            if isValidSysCon||isValidSimVarCtrl
                if isValidSimVarCtrl
                    syscon=simVarCtrlValue;
                end
                sc=this.SystemConstantBuilder.findOrCreateSystemConstant(...
                text,syscon.Value);
                fullyQualified=autosar.api.Utils.getQualifiedName(sc);
                text=['<SYSC-REF DEST="SW-SYSTEMCONST">',fullyQualified,'</SYSC-REF>'];
                if~isKey(knownSystemConstants,text)
                    knownSystemConstants(text)=sc;%#ok<NASGU>
                end
            end

            if~isempty(symbol)




                symbol=regexprep(symbol,'&','&amp;');
                symbol=regexprep(symbol,'<','&lt;');
                symbol=regexprep(symbol,'>','&gt;');
                symbol=regexprep(symbol,'~=','!=');
                symbol=regexprep(symbol,'~','!');
            end
        end

        function sysConstInfo=getSysConstInfo(this,variantControlName,conditionExpression)



            sysConstInfo={};




            conditionExpression=regexprep(conditionExpression,'!=','~=');
            conditionExpression=regexprep(conditionExpression,'!','~');

            mdlH=get_param(this.ModelName,'handle');
            paramNames=Simulink.AutosarTarget.ModelMapping.parseVariantControlExpression(...
            variantControlName,conditionExpression,mdlH);

            if isempty(paramNames)
                return;
            end

            for idx=1:length(paramNames)
                paramName=paramNames{idx};
                [~,paramObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,paramName);
                if autosar.mm.sl2mm.variant.Utils.isSystemConstant(paramObj)
                    sysConstInfo{end+1}=struct('Name',paramName,'Value',paramObj.Value);
                else
                    this.msgStream.createError('autosarstandard:exporter:MixedParametersInVariantExpr',variantControlName);
                end
            end
        end

        function pbConstInfo=getPbConstInfo(this,variantControlName,conditionExpression)



            pbConstInfo={};


            conditionExpression=regexprep(conditionExpression,'!=','~=');
            conditionExpression=regexprep(conditionExpression,'!','~');

            mdlH=get_param(this.ModelName,'handle');
            paramNames=Simulink.AutosarTarget.ModelMapping.parseVariantControlExpression(...
            variantControlName,conditionExpression,mdlH);

            if isempty(paramNames)
                return;
            end

            for idx=1:length(paramNames)
                paramName=paramNames{idx};
                pbVarDef=this.getPbConstMATLABVar(paramName);
                if~isempty(pbVarDef)
                    pbConstInfo{end+1}=pbVarDef;
                else
                    this.msgStream.createError('autosarstandard:exporter:MixedParametersInVariantExpr',variantControlName);
                end
            end
        end

        function isCEnumLiteral=isCEnumLiteral(this,CEnumLiteral)
            c2mEnumInfo=this.CodeDescriptor.getFullComponentInterface.CEnumToMEnumMap;
            aMEnumInfo=c2mEnumInfo{CEnumLiteral};
            isCEnumLiteral=~isempty(aMEnumInfo);
        end

        function MEnumLiteral=getMEnumInfoFromCEnumLiteral(this,CEnumLiteral)
            MEnumLiteral='';
            c2mEnumInfo=this.CodeDescriptor.getFullComponentInterface.CEnumToMEnumMap;
            aMEnumInfo=c2mEnumInfo{CEnumLiteral};
            if~isempty(aMEnumInfo)
                MEnumLiteral=aMEnumInfo.EnumClass+"."+aMEnumInfo.EnumLiteral;
            end
        end


        function annotations=extractCGTAnnotationsFromBlocksWithType(this,blockType,extractFunction)



            mdlblocks=find_system(this.ModelName,'LookUnderMasks','all','MatchFilter',@Simulink.match.allVariants,...
            'BlockType',blockType);
            annotations=[];
            for idx=1:length(mdlblocks)
                block=mdlblocks{idx};
                gpc=get_param(block,'GeneratePreprocessorConditionals');
                if strcmp(gpc,'on')
                    continue;
                end

                activationTime='';
                switch blockType
                case{'ModelReference','SubSystem'}
                    if strcmp(get_param(block,'Variant'),'on')
                        activationTime=get_param(block,'VariantActivationTime');
                    end
                case{'VariantSource','VariantSink'}
                    activationTime=get_param(block,'VariantActivationTime');
                otherwise
                    assert(false,'Unexpected block type');
                end

                if~this.isCodegenActivationTime(activationTime)
                    continue;
                end

                annotations=[annotations,extractFunction(block,activationTime)];%#ok<*AGROW>
            end
        end

        function annotations=getBlockVariantAnnotations(this,block,activationTime)
            blockType=get_param(block,'BlockType');
            if strcmp(blockType,'TriggerPort')||strcmp(blockType,'EventListener')



                variantControlNames={get_param(block,'VariantControl')};
            else
                variantControlNames=get_param(block,'VariantControls');
            end

            annotations=struct.empty();
            for idx=1:length(variantControlNames)
                variantControlName=variantControlNames{idx};
                if strcmp(variantControlName,'(default)')
                    continue
                end

                variantControl=this.getVariantControl(variantControlName);
                if isempty(variantControl)||...
                    isa(variantControl,'logical')
                    continue
                end

                expression=variantControl.Condition;
                [simplified,isUnconditionallyTrue]=this.simplifyConditionExpression(expression);
                if isUnconditionallyTrue

                    return;
                end
                vpCondition=this.expandVariantConditions(simplified,block,activationTime);

                if~this.isCodegenActivationTime(activationTime)
                    sysConstInfo=this.getSysConstInfo(variantControlName,vpCondition);
                    if isempty(sysConstInfo)
                        continue
                    end
                end


                annotations(end+1).Name=variantControlName;
                annotations(end).Condition=variantControl.Condition;
            end
        end

        function annotations=getSubsystemVariantAnnotations(this,ssblock,activationTime)
            annotations=struct.empty();
            variant=get_param(ssblock,'Variant');
            if strcmp(variant,'off')
                return;
            end

            variants=get_param(ssblock,'Variants');
            names={variants.Name};
            for idx=length(names):-1:1
                name=names{idx};

                variantControl=this.getVariantControl(name);
                if isempty(variantControl)...
                    ||isa(variantControl,'logical')
                    continue;
                end

                expression=variantControl.Condition;
                [simplified,isUnconditionallyTrue]=this.simplifyConditionExpression(expression);
                if isUnconditionallyTrue

                    return;
                end
                vpCondition=this.expandVariantConditions(simplified,ssblock,activationTime);

                if~this.isCodegenActivationTime(activationTime)
                    sysConstInfo=this.getSysConstInfo(name,vpCondition);
                    if isempty(sysConstInfo)
                        continue
                    end
                end


                annotations(end+1).Name=name;
                annotations(end).Condition=variantControl.Condition;
            end
        end

        function variantControl=getVariantControl(this,variantControlName)
            variantControlName=this.removeMatlabComment(variantControlName);

            [objExists,variantControl]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,variantControlName);
            if~(objExists&&isa(variantControl,'Simulink.Variant'))


                variantControl=[];
            end
        end

        function uncommentedLine=removeMatlabComment(~,line)


            obj=mtree(line);
            uncommentedLine=strtrim(obj.tree2str);
        end

        function populateValueVariant(this,sysConstName)









            [~,parameterObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,sysConstName);
            [isSimVarVariable,sysConstSpecObj]=autosar.mm.sl2mm.variant.Utils.isSimulinkVariantVariableWithSysConSpec(this.ModelName,parameterObj);
            if isSimVarVariable



                Value=evalinGlobalScope(this.ModelName,[sysConstName,'*1']);
                DataType=sysConstSpecObj.DataType;
            else
                Value=parameterObj.Value;
                DataType=parameterObj.DataType;
            end


            m3iSysConst=this.SystemConstantBuilder.findOrCreateSystemConstant(...
            sysConstName,Value);
            variantControlName=sysConstName;
            [m3iVpp,action]=this.VariationPointProxyMerger.mergeByName(variantControlName);
            if strcmp(action,'preexisting')
                return;
            end
            switch DataType
            case{'double','single'}
                m3iVpp.ValueAccess=Simulink.metamodel.arplatform.variant.FloatValueVariationPoint(m3iVpp.rootModel);
            case{'int8','int16','int32'}
                m3iVpp.ValueAccess=Simulink.metamodel.arplatform.variant.IntegerValueVariationPoint(m3iVpp.rootModel);
            case{'uint8','uint16','uint32'}
                m3iVpp.ValueAccess=Simulink.metamodel.arplatform.variant.PositiveIntegerValueVariationPoint(m3iVpp.rootModel);
            case{'boolean'}
                m3iVpp.ValueAccess=Simulink.metamodel.arplatform.variant.BooleanValueVariationPoint(m3iVpp.rootModel);
            case{'auto'}
                m3iVpp.ValueAccess=Simulink.metamodel.arplatform.variant.NumericalValueVariationPoint(m3iVpp.rootModel);
            otherwise
                if Simulink.data.isSupportedEnumClass(class(Value))

                    m3iVpp.ValueAccess=Simulink.metamodel.arplatform.variant.IntegerValueVariationPoint(m3iVpp.rootModel);
                else
                    assert(false,DAStudio.message('autosarstandard:exporter:InvalidSystemConstantType',sysConstName));
                end
            end

            m3iVpp.ValueAccess.BindingTime=Simulink.metamodel.arplatform.variant.BindingTimeKind.PreCompileTime;
            m3iVpp.ValueAccess.SysConst.append(m3iSysConst);
            m3iVpp.category='VALUE';

        end

        function isCodegenTime=isCodegenActivationTime(~,activationTime)
            isCodegenTime=any(strcmp(activationTime,{'update diagram','update diagram analyze all choices'}));
        end
    end

end





