classdef ConstantBuilder<handle





    methods(Static,Access=public)
        function m3iConstantSpecification=findOrCreateConstantSpecificationFromTypeGroundValue(m3iModel,...
            m3iConstantPkg,m3iType,maxShortNameLength,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;


            initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype(m3iType.Name,maxShortNameLength);
            m3iConstantSpecification=ConstantBuilder.findOrCreateConstantSpecification(...
            m3iModel,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,[],symbolicDefinitions);
        end

        function m3iConstantSpecification=findOrCreateConstantSpecificationFromScalarValue(m3iModel,...
            m3iConstantPkg,m3iType,maxShortNameLength,initValue,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;


            initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype([m3iType.Name,'_',num2str(initValue)],maxShortNameLength);
            m3iConstantSpecification=ConstantBuilder.findOrCreateConstantSpecification(...
            m3iModel,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions);
        end

        function m3iConstantSpecification=findOrCreateConstantSpecificationFromGlobalScopeObj(...
            slModel,m3iModel,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,objectName,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;



            dataObj=autosar.mm.util.getValueFromGlobalScope(slModel,objectName);
            assert(~isempty(dataObj),'Object does not exist in Base Workspace or Model Workspace or Data Dictionary');
            if isa(dataObj,'Simulink.DataObject')
                initValue=autosar.mm.sl2mm.ConstantBuilder.getDataObjInitValueInGlobalScope(dataObj,slModel);
            elseif isa(dataObj,'AUTOSAR.DualScaledParameter')
                initValue=dataObj.CalibrationValue;
            elseif isa(dataObj,'Simulink.Parameter')
                initValue=dataObj.Value;
            else

                initValue=dataObj;
            end

            m3iConstantSpecification=ConstantBuilder.findOrCreateConstantSpecification(...
            m3iModel,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions);
        end

        function m3iValueSpec=findOrCreateValueSpecificationFromGlobalScopeObj(...
            slModelName,m3iModel,m3iValueSpec,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,objectName,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;




            initValue=autosar.mm.sl2mm.ConstantBuilder.getDataObjValue(slModelName,objectName);
            m3iValueSpec=ConstantBuilder.updateOrCreateValueSpecification(m3iModel,m3iValueSpec,...
            m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions);
        end

        function m3iValueSpec=updateOrCreateValueSpecification(m3iModel,m3iValueSpec,...
            m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;




            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel)
                m3iModelShared=autosar.dictionary.Utils.getUniqueReferencedModel(m3iModel);
                assert(m3iModel~=m3iModelShared,'value specifications must not be in the shared m3iModel.');
            end

            m3iTypeMetaClass=m3iType.getMetaClass();
            if~isempty(m3iValueSpec)&&m3iValueSpec.isvalid()
                m3iValueSpecMetaClass=m3iValueSpec.getMetaClass();
            else
                m3iValueSpecMetaClass=[];
            end
            if m3iTypeMetaClass==Simulink.metamodel.types.Matrix.MetaClass

                if~isempty(m3iValueSpecMetaClass)&&...
                    m3iValueSpecMetaClass~=Simulink.metamodel.types.MatrixValueSpecification.MetaClass

                    m3iValueSpec.destroy();
                end

                m3iValueSpec=ConstantBuilder.updateOrCreateMatrixValueSpecification(...
                m3iModel,m3iValueSpec,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions);

            elseif m3iTypeMetaClass==Simulink.metamodel.types.Structure.MetaClass

                if~isempty(m3iValueSpecMetaClass)&&...
                    m3iValueSpecMetaClass~=Simulink.metamodel.types.StructureValueSpecification.MetaClass

                    m3iValueSpec.destroy();
                end

                m3iValueSpec=ConstantBuilder.updateOrCreateStructureValueSpecification(...
                m3iModel,m3iValueSpec,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions);

            elseif m3iTypeMetaClass==Simulink.metamodel.types.LookupTableType.MetaClass
                lutWithStdAxis=true;
                for ii=1:m3iType.Axes.size()
                    m3iAxis=m3iType.Axes.at(ii);
                    if isa(m3iAxis.SharedAxis,'Simulink.metamodel.types.SharedAxisType')||m3iAxis.SwGenericAxisParamType.size()>0
                        lutWithStdAxis=false;
                        break;
                    end
                end
                if~isempty(m3iValueSpecMetaClass)&&...
                    m3iValueSpecMetaClass~=Simulink.metamodel.types.LookupTableSpecification.MetaClass

                    m3iValueSpec.destroy();
                end
                if lutWithStdAxis
                    m3iValueSpec=ConstantBuilder.updateOrCreateValueSpecificationForLUTObject(m3iModel,...
                    m3iValueSpec,m3iType,initValueName,initValue,maxShortNameLength);
                else
                    m3iValueSpec=ConstantBuilder.updateOrCreateValueSpecificationForAxis(m3iModel,...
                    m3iValueSpec,m3iType,initValueName,initValue);
                end
            elseif m3iTypeMetaClass==Simulink.metamodel.types.SharedAxisType.MetaClass
                if~isempty(m3iValueSpecMetaClass)&&...
                    m3iValueSpecMetaClass~=Simulink.metamodel.types.LookupTableSpecification.MetaClass

                    m3iValueSpec.destroy();
                end

                m3iValueSpec=ConstantBuilder.updateOrCreateValueSpecificationForAxis(m3iModel,...
                m3iValueSpec,m3iType,initValueName,initValue);
            else

                if~isempty(m3iValueSpecMetaClass)&&...
                    (m3iValueSpecMetaClass==Simulink.metamodel.types.MatrixValueSpecification.MetaClass||...
                    m3iValueSpecMetaClass==Simulink.metamodel.types.StructureValueSpecification.MetaClass)
                    m3iValueSpec.destroy();
                end

                m3iValueSpec=ConstantBuilder.updateOrCreateLiteralReal(...
                m3iModel,m3iValueSpec,m3iType,initValueName,initValue);

            end
        end




        function isUpdated=checkOrUpdateComSpecInitValue(m3iConst,m3iType,symbolicDefinitions)

            assert(~isempty(m3iType)&&m3iType.isvalid());

            if isempty(m3iConst)||~m3iConst.isvalid
                isUpdated=false;
                return;
            end


            if isa(m3iConst,'Simulink.metamodel.types.ConstantReference')
                m3iConst=m3iConst.Value.ConstantValue;
            end

            switch class(m3iType)
            case 'Simulink.metamodel.types.Matrix'

                if m3iConst.MetaClass~=Simulink.metamodel.types.MatrixValueSpecification.MetaClass
                    isUpdated=false;
                    return;
                end


                m3iConst.Type=m3iType;


                elements=m3iConst.ownedCell;
                dims=autosar.mm.util.resolveM3ITypeDimensions(symbolicDefinitions,m3iType);
                assert(length(dims)==1,'Expected array rather than matrix with dimensions %d',length(dims));
                if dims~=elements.size
                    isUpdated=false;
                    return;
                end


                for elmIdx=1:dims

                    autosar.mm.sl2mm.ConstantBuilder.checkOrUpdateComSpecInitValue(...
                    elements.at(elmIdx).Value,m3iType.BaseType,symbolicDefinitions);
                end
            case 'Simulink.metamodel.types.Structure'

                if m3iConst.MetaClass~=Simulink.metamodel.types.StructureValueSpecification.MetaClass
                    isUpdated=false;
                    return;
                end


                m3iConst.Type=m3iType;


                m3iValueSpecElements=m3iConst.OwnedSlot;
                structElements=m3iType.Elements;
                if m3iValueSpecElements.size()~=structElements.size()
                    isUpdated=false;
                    return;
                end


                for elmIdx=1:m3iValueSpecElements.size()

                    elemType=structElements.at(elmIdx).ReferencedType;

                    autosar.mm.sl2mm.ConstantBuilder.checkOrUpdateComSpecInitValue(m3iValueSpecElements.at(elmIdx).Value,...
                    elemType,symbolicDefinitions);
                end
            otherwise



                if m3iConst.MetaClass==Simulink.metamodel.types.StructureValueSpecification.MetaClass||...
                    m3iConst.MetaClass==Simulink.metamodel.types.MatrixValueSpecification.MetaClass
                    isUpdated=false;
                    return;
                end
                m3iConst.Type=m3iType;
            end


            isUpdated=true;
        end
        function objValue=getDataObjValue(slModelName,objectName)

            dataObj=autosar.mm.util.getValueFromGlobalScope(slModelName,objectName);
            assert(~isempty(dataObj),'Object does not exist in Workspace or Data Dictionary');
            if isa(dataObj,'Simulink.DataObject')
                objValue=...
                autosar.mm.sl2mm.ConstantBuilder.getDataObjInitValueInGlobalScope(dataObj,slModelName);
            elseif isa(dataObj,'AUTOSAR.DualScaledParameter')
                objValue=dataObj.CalibrationValue;
            elseif isa(dataObj,'Simulink.Parameter')
                objValue=dataObj.Value;
            else

                objValue=dataObj;
            end
        end
    end

    methods(Static,Access=private)
        function m3iConstSpec=...
            findOrCreateConstantSpecification(m3iModel,m3iConstantPkg,...
            m3iType,maxShortNameLength,...
            initValueName,initValue,symbolicDefinitions)




            import Simulink.metamodel.types.ConstantSpecification;
            import autosar.mm.sl2mm.ConstantBuilder;



            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel)
                m3iModel=autosar.dictionary.Utils.getUniqueReferencedModel(m3iModel);
                assert(m3iConstantPkg.rootModel==m3iModel,'m3iConstantPkg must be in the shared m3iModel');
            end

            m3iConstSpec=autosar.mm.Model.findChildByName(m3iConstantPkg,...
            initValueName,true);
            if isempty(m3iConstSpec)

                constMetaClass=ConstantSpecification.MetaClass;
                arPkg=m3iModel.RootPackage.at(1);
                assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
                constSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,...
                initValueName,...
                constMetaClass);
                if(constSeq.size==0)||constSeq.size>1



                    m3iConstSpec=ConstantSpecification(m3iModel);
                    m3iConstantPkg.packagedElement.append(m3iConstSpec);
                elseif(constSeq.size==1)
                    m3iConstSpec=constSeq.at(1);
                end
            end

            m3iConstSpec.ConstantValue=ConstantBuilder.updateOrCreateValueSpecification(...
            m3iModel,m3iConstSpec.ConstantValue,m3iConstantPkg,m3iType,maxShortNameLength,...
            initValueName,initValue,symbolicDefinitions);
            m3iConstSpec.Name=m3iConstSpec.ConstantValue.Name;

        end

        function m3iConstant=updateOrCreateMatrixValueSpecification(m3iModel,...
            m3iConstant,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;


            if isempty(m3iConstant)||~m3iConstant.isvalid()
                m3iConstant=Simulink.metamodel.types.MatrixValueSpecification(m3iModel);
            end
            if isa(initValue,'Simulink.LookupTable')&&strcmp(initValue.BreakpointsSpecification,'Reference')
                initValue=initValue.Table.Value;
            elseif isa(initValue,'Simulink.Breakpoint')
                initValue=initValue.Breakpoints.Value;
            end
            m3iConstant.Name=initValueName;
            m3iConstant.Type=m3iType;


            m3iBaseType=m3iType.BaseType;

            cellMerger=autosar.mm.util.SequenceMerger(m3iModel,m3iConstant.ownedCell,'Simulink.metamodel.types.Cell');

            dims=autosar.mm.util.resolveM3ITypeDimensions(symbolicDefinitions,m3iType);
            assert(length(dims)==1,'Expected array rather than matrix with dimensions %d',length(dims));




            indexLength=numel(num2str(dims))+1;
            initValueName_base=arxml.arxml_private...
            ('p_create_aridentifier',...
            [initValueName,'_',m3iType.Name],maxShortNameLength-indexLength);

            m3iBaseConstantSpecification=[];
            if isempty(initValue)&&~isempty(m3iConstantPkg)


                m3iBaseConstantSpecification=ConstantBuilder.findOrCreateConstantSpecificationFromTypeGroundValue(...
                m3iModel,m3iConstantPkg,m3iBaseType,maxShortNameLength,symbolicDefinitions);
            end


            for ii=1:dims

                initValueName_sub=[initValueName_base,'_',int2str(ii)];

                if isempty(initValue)

                    elemName=['Cell',int2str(ii-1)];
                    m3iCell=cellMerger.mergeByName(elemName);
                    if(m3iCell.index.size()==0)
                        m3iCell.index.append(ii);
                    end
                    if isempty(m3iConstantPkg)
                        if~m3iCell.Value.isvalid()
                            m3iValueSpec=ConstantBuilder.updateOrCreateValueSpecification(m3iModel,[],...
                            [],m3iBaseType,maxShortNameLength,initValueName_sub,[],symbolicDefinitions);
                            m3iCell.Value=m3iValueSpec;
                        end
                    else
                        assert(~isempty(m3iBaseConstantSpecification),...
                        'We should have a base constant to reference at this point');
                        if m3iCell.Value.isvalid()
                            assert(m3iCell.Value.getMetaClass()==Simulink.metamodel.types.ConstantReference.MetaClass,...
                            'Expected a ConstantReference');


                            m3iBaseConstantRef=m3iCell.Value;
                        else
                            m3iBaseConstantRef=Simulink.metamodel.types.ConstantReference(m3iModel);
                            m3iCell.Value=m3iBaseConstantRef;
                        end

                        m3iBaseConstantRef.Name=initValueName_sub;
                        m3iBaseConstantRef.Value=m3iBaseConstantSpecification;
                        m3iBaseConstantRef.Type=m3iBaseType;
                    end
                else
                    m3iCell=cellMerger.mergeByName(initValueName_sub);
                    if size(initValue,1)==dims

                        matrixDim=size(initValue);
                        if numel(matrixDim)>2
                            initValue_sub=reshape(initValue(ii,:),matrixDim(2:end));
                        else

                            initValue_sub=initValue(ii,:);
                        end
                    elseif numel(initValue)==dims

                        initValue_sub=initValue(ii);
                    elseif isscalar(initValue)

                        initValue_sub=initValue(1);
                    else
                        assert(false,'not sure how to set initValue_sub to initValue');
                    end
                    m3iBaseValueSpec=ConstantBuilder.updateOrCreateValueSpecification(m3iModel,...
                    m3iCell.Value,m3iConstantPkg,m3iBaseType,maxShortNameLength,...
                    initValueName_sub,initValue_sub,symbolicDefinitions);

                    m3iCell.Value=m3iBaseValueSpec;
                end
            end
        end

        function m3iConstant=updateOrCreateValueSpecificationForAxis(m3iModel,...
            m3iConstant,m3iType,initValueName,initValue)
            import autosar.mm.sl2mm.ConstantBuilder;


            if isempty(m3iConstant)||~m3iConstant.isvalid()
                m3iConstant=Simulink.metamodel.types.LookupTableSpecification(m3iModel);
            end
            if isa(initValue,'Simulink.Breakpoint')
                initValue=initValue.Breakpoints.Value;
            elseif isa(initValue,'Simulink.LookupTable')
                initValue=initValue.Table.Value;
            end
            m3iConstant.Name=initValueName;
            m3iConstant.Type=m3iType;

            ConstantBuilder.fillConstantSpecificationValues(m3iConstant,initValue);
            m3iConstant.Dimensions.clear();
            m3iConstant.Dimensions.append(m3iConstant.V.size());
        end

        function m3iConstant=updateOrCreateValueSpecificationForLUTObject(m3iModel,...
            m3iConstant,m3iType,initValueName,initValue,maxShortNameLength)
            import autosar.mm.sl2mm.ConstantBuilder;


            if isempty(m3iConstant)||~m3iConstant.isvalid()
                m3iConstant=Simulink.metamodel.types.LookupTableSpecification(m3iModel);
            end

            m3iConstant.Name=initValueName;
            m3iConstant.Type=m3iType;

            if isstruct(initValue)


                fieldNames=fieldnames(initValue);



                initValueObj=initValue.(fieldNames{1});
                ConstantBuilder.fillConstantSpecificationValues(m3iConstant,initValueObj);
                m3iConstant.Dimensions.clear();
                m3iConstant.Dimensions.append(m3iConstant.V.size());
                axisSpecificationMerger=autosar.mm.util.SequenceMerger(m3iModel,m3iConstant.Axes,'Simulink.metamodel.types.LookupTableSpecification');
                axisCount=numel(fieldNames)-1;
                for ii=1:axisCount
                    initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype(fieldNames{ii+1},maxShortNameLength);
                    m3iConstantAxis=axisSpecificationMerger.mergeByName(initValueName);

                    bpValues=initValue.(fieldNames{ii+1});
                    ConstantBuilder.fillConstantSpecificationValues(m3iConstantAxis,bpValues);
                    m3iConstant.Dimensions.append(m3iConstantAxis.V.size());
                end
            else
                ConstantBuilder.fillConstantSpecificationValues(m3iConstant,initValue.Table.Value);
                m3iConstant.Dimensions.clear();
                m3iConstant.Dimensions.append(m3iConstant.V.size());
                axisSpecificationMerger=autosar.mm.util.SequenceMerger(m3iModel,m3iConstant.Axes,'Simulink.metamodel.types.LookupTableSpecification');
                axisCount=numel(initValue.Breakpoints);
                for ii=1:axisCount
                    index=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,ii);
                    initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype(initValue.Breakpoints(index).FieldName,maxShortNameLength);
                    m3iConstantAxis=axisSpecificationMerger.mergeByName(initValueName);

                    bpValues=initValue.Breakpoints(index).Value;
                    ConstantBuilder.fillConstantSpecificationValues(m3iConstantAxis,bpValues);
                    m3iConstant.Dimensions.append(m3iConstantAxis.V.size());
                end
            end
        end
        function m3iConstant=updateOrCreateStructureValueSpecification(m3iModel,...
            m3iConstant,m3iConstantPkg,m3iType,maxShortNameLength,initValueName,initValue,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;

            if isempty(m3iConstant)||~m3iConstant.isvalid()
                m3iConstant=Simulink.metamodel.types.StructureValueSpecification(m3iModel);
            end
            m3iConstant.Name=initValueName;
            m3iConstant.Type=m3iType;

            if isempty(initValue)
                m3iConstant=ConstantBuilder.createDefaultStructureValueSpecification(m3iModel,...
                m3iConstant,m3iConstantPkg,maxShortNameLength,symbolicDefinitions);
                return;
            end

            getFieldValueFunctionH=ConstantBuilder.getStructElementFieldValueFunctionHandle(initValue);
            slotMerger=autosar.mm.util.SequenceMerger(m3iModel,m3iConstant.OwnedSlot,'Simulink.metamodel.types.Slot');
            for structElementIndex=1:m3iType.Elements.size()

                structElement=m3iType.Elements.at(structElementIndex);
                structElementName=structElement.Name;
                structElementValue=getFieldValueFunctionH(initValue,structElementName);
                assert(~isempty(structElementValue),'Empty structElementValue is not expected');

                expectedSlotName=['Slot',num2str(structElementIndex-1)];
                m3iSlot=slotMerger.mergeByName(expectedSlotName);
                m3iBaseValueSpec=ConstantBuilder.updateOrCreateValueSpecification(m3iModel,m3iSlot.Value,m3iConstantPkg,...
                structElement.ReferencedType,maxShortNameLength,structElementName,structElementValue,symbolicDefinitions);
                m3iSlot.Value=m3iBaseValueSpec;
            end
        end

        function m3iConstant=createDefaultStructureValueSpecification(m3iModel,m3iConstant,m3iConstantPkg,maxShortNameLength,symbolicDefinitions)
            import autosar.mm.sl2mm.ConstantBuilder;

            slotMerger=autosar.mm.util.SequenceMerger(m3iModel,m3iConstant.OwnedSlot,'Simulink.metamodel.types.Slot');
            m3iType=m3iConstant.Type;
            for structElementIndex=1:m3iType.Elements.size()

                structElement=m3iType.Elements.at(structElementIndex);
                elemType=structElement.ReferencedType;


                structElementName=structElement.Name;
                expectedSlotName=['Slot',num2str(structElementIndex-1)];
                m3iSlot=slotMerger.mergeByName(expectedSlotName);
                if isempty(m3iConstantPkg)
                    if~m3iSlot.Value.isvalid()
                        initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype(elemType.Name,maxShortNameLength);
                        m3iValueSpec=ConstantBuilder.updateOrCreateValueSpecification(m3iModel,[],...
                        [],elemType,maxShortNameLength,initValueName,[],symbolicDefinitions);
                        m3iSlot.Value=m3iValueSpec;
                    end
                else
                    m3iBaseConstantSpecification=ConstantBuilder.findOrCreateConstantSpecificationFromTypeGroundValue(...
                    m3iModel,m3iConstantPkg,elemType,maxShortNameLength,symbolicDefinitions);

                    if m3iSlot.Value.isvalid()&&...
                        m3iSlot.Value.getMetaClass~=Simulink.metamodel.types.ConstantReference.MetaClass


                        m3iSlot.Value.destroy();
                    end

                    if m3iSlot.Value.isvalid()

                        m3iBaseConstantRef=m3iSlot.Value;
                    else
                        m3iBaseConstantRef=Simulink.metamodel.types.ConstantReference(m3iModel);
                        m3iSlot.Value=m3iBaseConstantRef;
                    end

                    m3iBaseConstantRef.Name=structElementName;
                    m3iBaseConstantRef.Value=m3iBaseConstantSpecification;
                    m3iBaseConstantRef.Type=elemType;
                end
            end
        end

        function getFieldValueFcnH=getStructElementFieldValueFunctionHandle(initValue)



            import autosar.mm.sl2mm.ConstantBuilder;

            if isa(initValue,'Simulink.LookupTable')
                if strcmp(initValue.BreakpointsSpecification,'Even spacing')
                    getFieldValueFcnH=@ConstantBuilder.getFieldValuesFromEvenSpacingLUTObj;
                else
                    getFieldValueFcnH=@ConstantBuilder.getFieldValuesFromExplicitValuesLUTObj;
                end
            elseif isa(initValue,'Simulink.Breakpoint')
                getFieldValueFcnH=@ConstantBuilder.getFieldValuesFromBpObj;
            elseif isstruct(initValue)
                getFieldValueFcnH=@(initValue,fieldName)initValue.(fieldName);
            else

                getFieldValueFcnH=@(initValue,fieldName)initValue;
            end
        end

        function lutFieldValues=getFieldValuesFromEvenSpacingLUTObj(slLutObj,fieldName)


            if strcmp(slLutObj.Table.FieldName,fieldName)
                lutFieldValues=slLutObj.Table.Value;
                return;
            end
            numberOfBreakpoints=numel(slLutObj.Breakpoints);
            for bpIdx=1:numberOfBreakpoints
                bpObj=slLutObj.Breakpoints(bpIdx);
                switch fieldName
                case bpObj.TunableSizeName
                    lutFieldValues=...
                    autosar.mm.sl2mm.ConstantBuilder.getTunableSizeValueForEvenSpacingLUTObj(slLutObj,bpIdx);
                    return;
                case bpObj.FirstPointName
                    if isprop(bpObj.FirstPoint,'Value')
                        lutFieldValues=str2double(bpObj.FirstPoint.Value);
                    else
                        lutFieldValues=bpObj.FirstPoint;
                    end
                    return;
                case bpObj.SpacingName
                    if isprop(bpObj.Spacing,'Value')
                        lutFieldValues=str2double(bpObj.Spacing.Value);
                    else
                        lutFieldValues=bpObj.Spacing;
                    end
                    return;
                end
            end
        end

        function lutFieldValues=getTunableSizeValueForEvenSpacingLUTObj(slLutObj,bpIdx)
            tableDimensions=size(slLutObj.Table.Value);
            if numel(slLutObj.Breakpoints)==1&&numel(tableDimensions)>1&&tableDimensions(1)==1

                lutFieldValues=tableDimensions(2);
            else
                lutFieldValues=tableDimensions(bpIdx);
            end
        end

        function lutFieldValues=getFieldValuesFromExplicitValuesLUTObj(slLutObj,fieldName)


            if strcmp(slLutObj.Table.FieldName,fieldName)
                lutFieldValues=slLutObj.Table.Value;
            else
                for bpIdx=1:numel(slLutObj.Breakpoints)
                    if strcmp(slLutObj.Breakpoints(bpIdx).FieldName,fieldName)
                        lutFieldValues=slLutObj.Breakpoints(bpIdx).Value;
                        return;
                    elseif strcmp(slLutObj.Breakpoints(bpIdx).TunableSizeName,fieldName)
                        lutFieldValues=numel(slLutObj.Breakpoints(bpIdx).Value);
                        return;
                    end
                end
            end
        end

        function bpFieldValues=getFieldValuesFromBpObj(bpObj,fieldRefName)


            if strcmp(bpObj.Breakpoints.FieldName,fieldRefName)
                bpFieldValues=bpObj.Breakpoints.Value;
            elseif strcmp(bpObj.Breakpoints.TunableSizeName,fieldRefName)
                bpFieldValues=numel(bpObj.Breakpoints.Value);
            else
                assert(false,...
                sprintf("Unexpected field name %s breakpoint object",fieldRefName));
            end
        end

        function m3iConstant=updateOrCreateLiteralReal(m3iModel,m3iConstant,m3iType,initValueName,initValue)

            import autosar.mm.sl2mm.ConstantBuilder;

            if isempty(m3iConstant)||~m3iConstant.isvalid()
                if isa(m3iType,'Simulink.metamodel.types.Enumeration')
                    m3iConstant=Simulink.metamodel.types.EnumerationLiteralReference(m3iModel);
                else
                    m3iConstant=Simulink.metamodel.types.LiteralReal(m3iModel);
                end
            elseif isa(m3iConstant,'Simulink.metamodel.types.EnumerationLiteralReference')&&...
                ~isa(m3iType,'Simulink.metamodel.types.Enumeration')


                m3iConstant.destroy();
                m3iConstant=Simulink.metamodel.types.LiteralReal(m3iModel);
            end

            m3iConstant.Name=initValueName;
            m3iConstant.Type=m3iType;

            if~isempty(initValue)
                value=initValue;
            else
                value=m3iType.GroundValue;
            end

            foundLiteral=false;
            if isa(m3iType,'Simulink.metamodel.types.Enumeration')
                for ii=1:m3iType.OwnedLiteral.size()
                    if m3iType.OwnedLiteral.at(ii).Value==value
                        if m3iConstant.getMetaClass()==Simulink.metamodel.types.EnumerationLiteralReference.MetaClass
                            m3iConstant.Value=m3iType.OwnedLiteral.at(ii);
                            m3iConstant.LiteralText=m3iType.OwnedLiteral.at(ii).Name;
                        elseif m3iConstant.getMetaClass()==Simulink.metamodel.types.LiteralReal.MetaClass
                            m3iConstant.Value=m3iType.OwnedLiteral.at(ii).Value;
                        end
                        foundLiteral=true;
                        break;
                    end
                end
                if~foundLiteral&&value==0

                    m3iConstant.Value=ConstantBuilder.getConstantDefaultValue(...
                    m3iType.GroundValue,m3iType,m3iConstant.MetaClass());
                end
            else
                if~isempty(value)

                    m3iConstant.Value=ConstantBuilder.getConstantDefaultValue(...
                    value,m3iType);
                end
            end
        end

        function defaultValueOut=getConstantDefaultValue(defaultValue,m3iType,m3iConstantMetaClass)


            defaultValueOut=defaultValue;
            m3iTypeMetaClass=m3iType.getMetaClass();

            if(m3iTypeMetaClass==Simulink.metamodel.types.FixedPoint.MetaClass)

                if~isa(defaultValue,'embedded.fi')

                    defaultValue=fi(defaultValue,fixdt(m3iType.IsSigned,double(m3iType.Length.value),m3iType.slope,m3iType.Bias));
                end


                defaultValueOut=defaultValue.double;
            elseif(m3iTypeMetaClass==Simulink.metamodel.types.Integer.MetaClass)


                if isa(defaultValue,'embedded.fi')
                    defaultValueOut=defaultValue.double;
                else

                    defaultValue=fi(defaultValue,fixdt(m3iType.IsSigned,double(m3iType.Length.value),1,0));
                    defaultValueOut=defaultValue.double;
                end
            elseif(m3iTypeMetaClass==Simulink.metamodel.types.FloatingPoint.MetaClass)
                if isa(defaultValue,'embedded.fi')
                    defaultValueOut=defaultValue.double;
                end
            end

            if(m3iTypeMetaClass==Simulink.metamodel.types.Enumeration.MetaClass)&&...
                (Simulink.data.isSupportedEnumObject(defaultValue)||isnumeric(defaultValue))
                for ii=1:m3iType.OwnedLiteral.size()
                    if m3iType.OwnedLiteral.at(ii).Value==cast(defaultValue,'int32')
                        if m3iConstantMetaClass==Simulink.metamodel.types.EnumerationLiteralReference.MetaClass
                            defaultValueOut=m3iType.OwnedLiteral.at(ii);
                        elseif m3iConstantMetaClass==Simulink.metamodel.types.LiteralReal.MetaClass
                            defaultValueOut=m3iType.OwnedLiteral.at(ii).Value;
                        end
                        break;
                    end
                end
            end
        end

        function initValue=getDataObjInitValueInGlobalScope(dataObj,model)
            initValue=dataObj.Value;

            if isa(initValue,'Simulink.data.Expression')
                assert(~dataObj.getIsValueExpressionPreserved(),...
                'did not expect dataObj expression to be preserved!');
                initValue=dataObj.getResolvedNumericValue();
            end
            if isempty(initValue)&&isa(dataObj.Value,'Simulink.data.Expression')
                initValue=evalinGlobalScope(model,dataObj.Value.ExpressionString);
            end
        end

        function fillConstantSpecificationValues(m3iConstant,initValue)
            m3iConstant.V.clear();

            if isa(initValue(1),'embedded.fi')||Simulink.data.isSupportedEnumObject(initValue(1))
                arrayfun(@(x)m3iConstant.V.append(Simulink.metamodel.arplatform.getRealStringCompact(x.double)),...
                initValue,'UniformOutput',false);
            else
                arrayfun(@(x)m3iConstant.V.append(Simulink.metamodel.arplatform.getRealStringCompact(x)),...
                initValue,'UniformOutput',false);
            end
        end
    end
end



