classdef LookupTableBuilder<handle




    properties(Access=private)
        ArPkg;
        ModelName;
        M3iModel;
        M3iAppDataTypePkg;
        MaxShortNameLength;
        IsInitialized;
        LutName2M3iObjMap;

    end

    methods(Access=public)
        function this=LookupTableBuilder(m3iModel,modelName)
            this.ModelName=modelName;
            this.M3iModel=m3iModel;
            this.ArPkg=m3iModel.RootPackage.at(1);
            this.IsInitialized=false;
            this.MaxShortNameLength=get_param(modelName,'AutosarMaxShortNameLength');
            this.M3iAppDataTypePkg=[];
            this.LutName2M3iObjMap=containers.Map();
        end

        function m3iLUTType=findOrCreateLookupTableType(this,slAppTypeAttributes,slBreakpointNames)
            if~this.hasValidLookupTableDataInterface(slAppTypeAttributes.LookupTableData)
                m3iLUTType=[];
                return;
            end
            switch slAppTypeAttributes.LookupTableData.BreakpointSpecification
            case 'Reference'
                m3iLUTType=this.findOrCreateLookupTableTypeForSharedAxis(slAppTypeAttributes,slBreakpointNames);
            case 'Explicit values'
                m3iLUTType=this.findOrCreateLookupTableTypeForStdAxis(slAppTypeAttributes);
            case 'Even spacing'
                m3iLUTType=this.findOrCreateLookupTableTypeForFixAxis(slAppTypeAttributes);
            otherwise
                assert(false,'Lookup table breakpoint specification not recognized');
            end
        end

        function m3iLUTType=findOrCreateLookupTableTypeForSharedAxis(this,slAppTypeAttributes,slBreakpointNames)


            [m3iLUTType,foundExisting]=this.findOrCreateM3iLUTAppType(slAppTypeAttributes);
            if foundExisting
                return;
            end

            codeDescLUTObj=slAppTypeAttributes.LookupTableData;
            numberOfBreakpoints=codeDescLUTObj.Breakpoints.Size();

            for bpIndex=1:numberOfBreakpoints

                if isempty(slBreakpointNames)
                    slBPName=codeDescLUTObj.Breakpoints(bpIndex).GraphicalName;
                else
                    slBPName=slBreakpointNames{bpIndex};
                end

                axisName=this.getApplicationDataTypeName(slBPName,this.MaxShortNameLength);
                m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
                this.ArPkg,axisName,Simulink.metamodel.types.SharedAxisType.MetaClass);
                if m3iSeq.size()==0
                    m3iSharedAxis=Simulink.metamodel.types.SharedAxisType(this.M3iModel);
                    m3iSharedAxis.Name=axisName;
                    this.appendToDataTypePkg(m3iSharedAxis);
                else
                    m3iSharedAxis=m3iSeq.at(1);
                end

                if isempty(m3iSharedAxis.Axis)
                    m3iAxis=Simulink.metamodel.types.Axis(this.M3iModel);
                    m3iSharedAxis.Axis=m3iAxis;
                    m3iSharedAxis.Axis.Name='X';
                end
                m3iSharedAxis.Axis.Dimensions=this.getBreakpointDimensions(codeDescLUTObj,bpIndex);

                swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfBreakpoints,bpIndex);
                m3iLutAxis=m3iLUTType.Axes.at(swappedIndex);
                m3iLutAxis.Name=this.getAxisNameFromIndex(numberOfBreakpoints,bpIndex);
                m3iLutAxis.SharedAxis=m3iSharedAxis;
            end
        end

        function m3iType=findOrCreateSharedAxisType(this,codeDescBPObj,calPrmName)


            if~this.IsInitialized
                LazyInitialize(this);
            end

            axisName=this.getApplicationDataTypeName(calPrmName,this.MaxShortNameLength);
            m3iSharedAxisMetaClassName=Simulink.metamodel.types.SharedAxisType.MetaClass;
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
            this.ArPkg,axisName,m3iSharedAxisMetaClassName);
            if seq.size()==0
                m3iType=Simulink.metamodel.types.SharedAxisType(this.M3iModel);
                m3iType.Name=axisName;
                this.appendToDataTypePkg(m3iType);
            else
                m3iType=seq.at(1);
            end
            if isempty(m3iType.Axis)
                m3iAxis=Simulink.metamodel.types.Axis(this.M3iModel);
                m3iType.Axis=m3iAxis;
                m3iType.Axis.Name='X';
            end
            [~,bpArrayObj]=this.getBreakpointBaseTypeObj(codeDescBPObj);
            m3iType.Axis.Dimensions=...
            autosar.mm.sl2mm.LookupTableBuilder.numelOfCodeDescArrayObj(bpArrayObj);
        end

        function m3iLUTType=findOrCreateLookupTableTypeForStdAxis(this,slAppTypeAttributes)





            [m3iLUTType,foundExisting]=this.findOrCreateM3iLUTAppType(slAppTypeAttributes);
            if foundExisting
                return;
            end

            codeDescLUTObj=slAppTypeAttributes.LookupTableData;
            numberOfBreakpoints=codeDescLUTObj.Breakpoints.Size();
            for jj=1:numberOfBreakpoints
                swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfBreakpoints,jj);
                m3iLutAxis=m3iLUTType.Axes.at(swappedIndex);
                m3iLutAxis.Name=this.getAxisNameFromIndex(numberOfBreakpoints,jj);
                m3iLutAxis.Dimensions=this.getBreakpointDimensions(codeDescLUTObj,swappedIndex);
            end
        end

        function m3iLUTType=findOrCreateLookupTableTypeForFixAxis(this,slAppTypeAttributes)



            m3iLUTType=this.findOrCreateM3iLUTAppType(slAppTypeAttributes);
            codeDescLUTObj=slAppTypeAttributes.LookupTableData;
            numberOfBreakpoints=codeDescLUTObj.Breakpoints.Size();

            for axisIndex=1:numberOfBreakpoints
                m3iAxis=m3iLUTType.Axes.at(axisIndex);
                swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfBreakpoints,axisIndex);


                m3iAxis.Name=this.getAxisNameFromIndex(numberOfBreakpoints,swappedIndex);
                m3iAxis.Dimensions=this.getBreakpointDimensions(codeDescLUTObj,swappedIndex);
                codeDescFixAxisMetadata=codeDescLUTObj.Breakpoints(swappedIndex).FixAxisMetadata;
                this.xFormCodeDescFixAxisMetadata(codeDescFixAxisMetadata,m3iAxis);
            end
        end
    end
    methods(Access=private)
        function xFormCodeDescFixAxisMetadata(this,codeDescFixAxisMetadata,m3iAxis)



            m3iAxis.Vf.clear();
            m3iAxis.SwGenericAxisParamType.clear();

            if isa(codeDescFixAxisMetadata,'coder.descriptor.NonEvenSpacingMetadata')
                m3iSwAxisType=this.findOrCreateM3iSwAxisType('List');
                this.xFormCodeDescNonEvenSpacingMetadata(codeDescFixAxisMetadata,m3iAxis,m3iSwAxisType);
            elseif isa(codeDescFixAxisMetadata,'coder.descriptor.EvenSpacingMetadata')
                if codeDescFixAxisMetadata.IsPow2
                    m3iSwAxisType=this.findOrCreateM3iSwAxisType('Power2Spacing');
                else
                    m3iSwAxisType=this.findOrCreateM3iSwAxisType('EvenSpacing');
                end
                this.xFormCodeDescEvenSpacingMetadata(codeDescFixAxisMetadata,m3iAxis,m3iSwAxisType);
            else
                assert(false,sprintf('Unknown FixAxisMetadata: %s',...
                codeDescFixAxisMetadata.MetaClass.name));
            end
        end

        function xFormCodeDescNonEvenSpacingMetadata(this,codeDescNonEvenSpacingMetadata,m3iAxis,m3iSwAxisType)
            m3iSwGenericAxisParamType=this.findOrCreateSwGenericAxisParamType(...
            m3iSwAxisType,'list');
            m3iAxis.SwGenericAxisParamType.append(m3iSwGenericAxisParamType);

            allPoints=codeDescNonEvenSpacingMetadata.AllPoints;
            for kk=1:allPoints.Size()
                m3iAxis.Vf.append(allPoints.at(kk));
            end
        end

        function xFormCodeDescEvenSpacingMetadata(this,codeDescEvenSpacingMetadata,m3iAxis,m3iSwAxisType)
            m3iSwGenericAxisParamType=this.findOrCreateSwGenericAxisParamType(m3iSwAxisType,...
            'offset');
            m3iAxis.SwGenericAxisParamType.append(m3iSwGenericAxisParamType);
            m3iAxis.Vf.append(codeDescEvenSpacingMetadata.StartingValue);

            if codeDescEvenSpacingMetadata.IsPow2
                stepCategory='shift';
            else
                stepCategory='distance';
            end
            m3iSwGenericAxisParamType=this.findOrCreateSwGenericAxisParamType(m3iSwAxisType,...
            stepCategory);
            m3iAxis.SwGenericAxisParamType.append(m3iSwGenericAxisParamType);
            m3iAxis.Vf.append(codeDescEvenSpacingMetadata.StepValue);
        end

        function m3iSwAxisType=findOrCreateM3iSwAxisType(this,categoryName)

            m3iFixAxisTypePkg=autosar.mm.Model.getOrAddARPackage(this.ArPkg,...
            ['/FixAxisTypes/',categoryName]);
            [m3iSwAxisType,isCreated]=this.findOrCreateM3iObjByNameAndMetaClass(...
            m3iFixAxisTypePkg,categoryName,Simulink.metamodel.types.SwAxisType.MetaClass);

            if isCreated
                m3iFixAxisTypePkg.packagedElement.append(m3iSwAxisType);
            else

            end
        end

        function m3iSwGenericAxisParamType=findOrCreateSwGenericAxisParamType(this,m3iSwAxisType,categoryName)
            switch categoryName
            case 'distance'
                swGenericAxisParamTypeCategory=Simulink.metamodel.types.SwGenericAxisParamTypeCategory.Distance;
            case 'shift'
                swGenericAxisParamTypeCategory=Simulink.metamodel.types.SwGenericAxisParamTypeCategory.Shift;
            case 'offset'
                swGenericAxisParamTypeCategory=Simulink.metamodel.types.SwGenericAxisParamTypeCategory.Offset;
            case 'list'
                swGenericAxisParamTypeCategory=Simulink.metamodel.types.SwGenericAxisParamTypeCategory.List;
            otherwise
                assert(false,sprintf('Unexpected swGenericAxisParam category name: %s',categoryName));
            end

            [m3iSwGenericAxisParamType,isCreated]=this.findOrCreateM3iObjByNameAndMetaClass(...
            m3iSwAxisType,categoryName,Simulink.metamodel.types.SwGenericAxisParamType.MetaClass);
            if isCreated
                m3iSwAxisType.SwAxisParamType.append(m3iSwGenericAxisParamType);
            else

            end
            m3iSwGenericAxisParamType.Category=swGenericAxisParamTypeCategory;
        end

        function[m3iLUTType,foundExisting]=findOrCreateM3iLUTAppType(this,slAppTypeAttributes)
            foundExisting=false;
            if~this.IsInitialized
                LazyInitialize(this);
            end
            codeDescLUTObj=slAppTypeAttributes.LookupTableData;
            if~isempty(slAppTypeAttributes.Name)
                lutName=this.getApplicationDataTypeName(slAppTypeAttributes.Name,this.MaxShortNameLength);
            else
                lutName=this.getApplicationDataTypeName(codeDescLUTObj.GraphicalName,this.MaxShortNameLength);
            end
            if this.LutName2M3iObjMap.isKey(lutName)
                m3iLUTType=this.LutName2M3iObjMap(lutName);
                foundExisting=true;
                return;
            end
            m3iMetaClassName=Simulink.metamodel.types.LookupTableType.MetaClass;
            m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
            this.ArPkg,lutName,m3iMetaClassName);
            if m3iSeq.size()==0
                m3iLUTType=Simulink.metamodel.types.LookupTableType(this.M3iModel);
                m3iLUTType.Name=lutName;
                this.appendToDataTypePkg(m3iLUTType);
            else
                assert(m3iSeq.size()==1,...
                sprintf('Expect only one lookup table with name: %s',lutName));
                m3iLUTType=m3iSeq.at(1);
            end
            this.LutName2M3iObjMap(lutName)=m3iLUTType;

            numberOfBreakpoints=codeDescLUTObj.Breakpoints.Size();
            if m3iLUTType.Axes.size()~=numberOfBreakpoints
                while~m3iLUTType.Axes.isEmpty()
                    m3iLUTType.Axes.at(1).destroy();
                end
                for jj=1:numberOfBreakpoints
                    lutAxis=Simulink.metamodel.types.Axis(this.M3iModel);
                    m3iLUTType.Axes.append(lutAxis);
                end
            end
        end
        function LazyInitialize(this)
            import autosar.mm.util.XmlOptionsAdapter;
            import autosar.mm.Model;

            arRoot=this.M3iModel.RootPackage.at(1);
            appTypePkg=XmlOptionsAdapter.get(arRoot,'ApplicationDataTypePackage');
            if isempty(appTypePkg)
                defaultApplPkg=[arRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.ApplicationDataTypes];
                XmlOptionsAdapter.set(arRoot,...
                'ApplicationDataTypePackage',...
                defaultApplPkg);
                appTypePkg=defaultApplPkg;
            end
            this.M3iAppDataTypePkg=Model.getOrAddARPackage(arRoot,appTypePkg);
            this.IsInitialized=true;
        end
        function appendToDataTypePkg(this,element)
            this.M3iAppDataTypePkg.packagedElement.append(element);
        end

        function[m3iObj,isCreated]=findOrCreateM3iObjByNameAndMetaClass(this,m3iPkg,objName,m3iMetaclass)%#ok<INUSD>
            m3iSeq=autosar.mm.Model.findObjectByNameAndMetaClass(...
            m3iPkg,objName,m3iMetaclass,true);
            if m3iSeq.size()==0
                m3iObj=eval([m3iMetaclass.qualifiedName,'(this.M3iModel)']);
                m3iObj.Name=objName;
                isCreated=true;
            else
                m3iObj=m3iSeq.at(1);
                isCreated=false;
            end
        end
    end

    methods(Static,Access=private)
        function numberOfElements=numelOfCodeDescArrayObj(codeDescArrayObj)

            numberOfElements=1;
            if codeDescArrayObj.CompileTimeDimensions.Size()==0
                for ii=1:codeDescArrayObj.Dimensions.Size()
                    numberOfElements=numberOfElements*codeDescArrayObj.Dimensions.at(ii);
                end
            else
                for ii=1:codeDescArrayObj.CompileTimeDimensions.Size()
                    numberOfElements=numberOfElements*codeDescArrayObj.CompileTimeDimensions.at(ii);
                end
            end
        end

        function identifier=getCodeDescBPObjIdentifier(codeDescBPObj)

            if isa(codeDescBPObj.Implementation,'coder.descriptor.AutosarCalibration')
                identifier=codeDescBPObj.GraphicalName;
            elseif isprop(codeDescBPObj.Implementation,'Identifier')
                identifier=codeDescBPObj.Implementation.Identifier;
            elseif isprop(codeDescBPObj.Implementation,'ElementIdentifier')
                identifier=codeDescBPObj.Implementation.ElementIdentifier;
            else
                identifier=[];
            end
        end

        function dimensions=getBreakpointDimensions(codeDescLUTObj,bpIndex)

            switch codeDescLUTObj.BreakpointSpecification
            case 'Explicit values'
                structElementIndex=...
                autosar.mm.sl2mm.LookupTableBuilder.getBreakpointStructElementIndex(codeDescLUTObj,bpIndex);
                codeDescBPStructElement=codeDescLUTObj.Implementation.Type.BaseType.Elements(structElementIndex);
                embeddedArrayObj=codeDescBPStructElement.Type;
                dimensions=...
                autosar.mm.sl2mm.LookupTableBuilder.numelOfCodeDescArrayObj(embeddedArrayObj);
            case 'Reference'
                codeDescBP=codeDescLUTObj.Breakpoints.at(bpIndex);
                [~,embeddedArrayObj,~]=...
                autosar.mm.sl2mm.LookupTableBuilder.getBreakpointBaseTypeObj(codeDescBP);
                dimensions=autosar.mm.sl2mm.LookupTableBuilder.numelOfCodeDescArrayObj(embeddedArrayObj);
            case 'Even spacing'
                codeDescBP=codeDescLUTObj.Breakpoints.at(bpIndex);
                if isa(codeDescBP.FixAxisMetadata,'coder.descriptor.EvenSpacingMetadata')
                    dimensions=codeDescBP.FixAxisMetadata.NumPoints;
                elseif isa(codeDescBP.FixAxisMetadata,'coder.descriptor.NonEvenSpacingMetadata')
                    dimensions=codeDescBP.FixAxisMetadata.AllPoints.Size;
                end
            otherwise
                assert(false,sprintf("Unexpected breakpoint specification: %s",...
                codeDescLUTObj.BreakpointSpecification));
            end
        end

        function baseCodeType=getStructElementBaseCodeType(parentCodeType,structElementIndex)


            if isa(parentCodeType,'coder.descriptor.types.Struct')
                elementCodeType=parentCodeType.Elements(structElementIndex).Type;
                if isa(elementCodeType,'coder.descriptor.types.Matrix')
                    baseCodeType=elementCodeType.BaseType;
                else
                    baseCodeType=elementCodeType;
                end
            elseif isa(parentCodeType,'coder.descriptor.types.Matrix')
                baseCodeType=...
                autosar.mm.sl2mm.LookupTableBuilder.getStructElementBaseCodeType(...
                parentCodeType.BaseType,structElementIndex);
            else
                assert(false,'Expected struct or a matrix type for parent code type');
            end
        end
    end

    methods(Static,Access=public)
        function axisName=getAxisNameFromIndex(axisCount,index)
            switch(index)
            case 1
                axisName='X';
            case 2
                axisName='Y';
            otherwise
                if axisCount==3
                    axisName='Z';
                else
                    axisName=['Z',num2str(index-2)];
                end
            end
        end

        function modelMajorityLabel=getModelMajorityLabel(majority,dimensions)
            if dimensions>1&&strcmp(majority,'Row-major')
                modelMajorityLabel='ROW_DIR';
            else

                modelMajorityLabel='COLUMN_DIR';
            end
        end

        function isComAxisLUT=isComAxisLookupTable(codeDescLUTParam)
            isComAxisLUT=isa(codeDescLUTParam,'coder.descriptor.LookupTableDataInterface')&&...
            strcmp(codeDescLUTParam.BreakpointSpecification,'Reference');
        end

        function comAxisBPNames=getBreakpointNamesOfComAxisLookupTable(codeDescLUTParam)



            assert(isa(codeDescLUTParam,'coder.descriptor.LookupTableDataInterface')&&...
            strcmp(codeDescLUTParam.BreakpointSpecification,'Reference'),...
            'Expect a Com Axis lookup table CodeDescriptor parameter');

            codeDescBPs=codeDescLUTParam.Breakpoints;
            numberOfBreakpoints=codeDescBPs.Size();
            comAxisBPNames=cell(numberOfBreakpoints,1);

            for bpIndex=1:numberOfBreakpoints
                codeDescBPParam=codeDescBPs(bpIndex);
                comAxisBPNames{bpIndex}=codeDescBPParam.GraphicalName;
            end
        end

        function isValid=hasValidLookupTableDataInterface(codeDescParam)
            isValid=false;
            if~isa(codeDescParam,'coder.descriptor.LookupTableDataInterface')
                return;
            end
            if isempty(codeDescParam.Implementation)
                return;
            end
            [isFixAxisLUT,isEvenSpacedLUT]=...
            autosar.mm.sl2mm.LookupTableBuilder.hasFixAxisLookupTableDataInterface(codeDescParam);
            if isEvenSpacedLUT
                if~slfeature('AUTOSARFixAxisLookupTables')


                    return;
                elseif~isFixAxisLUT
                    return;
                end
            end
            if codeDescParam.Breakpoints.Size()>3

                return;
            end
            if isa(codeDescParam.Implementation.Type.BaseType,'coder.descriptor.types.Struct')



                expectedStructElements=1+codeDescParam.Breakpoints.Size();
                if codeDescParam.SupportTunableSize
                    expectedStructElements=expectedStructElements+codeDescParam.Breakpoints.Size();
                end
                if slfeature('AUTOSARFixAxisLookupTables')&&...
                    strcmp(codeDescParam.BreakpointSpecification,'Even spacing')
                    expectedStructElements=expectedStructElements+codeDescParam.Breakpoints.Size();
                end
                if expectedStructElements~=length(codeDescParam.Implementation.Type.BaseType.Elements)
                    return;
                end
            end
            for ii=1:codeDescParam.Breakpoints.Size()
                codeDescBP=codeDescParam.Breakpoints(ii);
                if isempty(codeDescBP.Implementation)
                    if~strcmp(codeDescParam.BreakpointSpecification,'Even spacing')||...
                        isempty(codeDescBP.FixAxisMetadata)



                        return;
                    end
                elseif strcmp(codeDescParam.BreakpointSpecification,'Reference')&&...
                    ~isempty(codeDescBP.FixAxisMetadata)


                    return;
                end
            end
            isValid=true;
        end
        function codeType=getCodeTypeForBreakPoint(codeDescBP)
            bpImpl=codeDescBP.Implementation;
            codeType=[];
            if~isempty(bpImpl)
                if isempty(bpImpl.CodeType)
                    codeType=bpImpl.Type;
                else
                    codeType=bpImpl.CodeType;
                end
            end
        end
        function[isFixAxisLUT,isEvenSpacingLUT]=hasFixAxisLookupTableDataInterface(codeDescParam)





            isFixAxisLUT=false;

            if isa(codeDescParam,'coder.descriptor.LookupTableDataInterface')&&...
                strcmp(codeDescParam.BreakpointSpecification,'Even spacing')
                isEvenSpacingLUT=true;
            else
                isEvenSpacingLUT=false;
                return;
            end

            codeDescBPs=codeDescParam.Breakpoints;
            for bpIdx=1:codeDescBPs.Size()
                codeDescBP=codeDescBPs(bpIdx);
                codeType=autosar.mm.sl2mm.LookupTableBuilder.getCodeTypeForBreakPoint(codeDescParam);
                if codeDescBP.IsTunableBreakPoint&&~codeType.isStructure

                    return;
                end
            end
            isFixAxisLUT=true;
        end

        function[hasSymbolicDimensions,symbolicWidth]=getSymbolicDimensionsForSharedAxis(embeddedObj)
            hasSymbolicDimensions=false;
            symbolicWidth='';
            if embeddedObj.isMatrix
                hasSymbolicDimensions=embeddedObj.HasSymbolicDimensions;
                symbolicWidth=embeddedObj.SymbolicWidth;
                if embeddedObj.BaseType.isStructure
                    for ii=1:numel(embeddedObj.BaseType.Elements.toArray)
                        element=embeddedObj.BaseType.Elements(ii);
                        if element.Type.isMatrix
                            [hasSymbolicDimensions,symbolicWidth]=...
                            autosar.mm.sl2mm.LookupTableBuilder.getSymbolicDimensionsForSharedAxis(element.Type);
                            break;
                        end
                    end
                end
            end
        end
        function shortName=getApplicationDataTypeName(name,maxShortNameLength)
            shortName=arxml.arxml_private('p_create_aridentifier',...
            ['Appl_',name],maxShortNameLength);
        end

        function bpStructElemIndex=getBreakpointStructElementIndex(codeDescLUTObj,bpIndex)
            dimensions=codeDescLUTObj.Breakpoints.Size();
            if strcmp(codeDescLUTObj.StructOrder,'SizeBreakpointsTable')
                if codeDescLUTObj.SupportTunableSize
                    bpStructElemIndex=dimensions+bpIndex;
                else
                    bpStructElemIndex=bpIndex;
                end
            elseif strcmp(codeDescLUTObj.StructOrder,'SizeTableBreakpoints')
                assert(strcmp(codeDescLUTObj.BreakpointSpecification,'Even spacing'),...
                'Expect only Even Spacing BreakpointSpecification to be SizeTableBreakpoints');
                if codeDescLUTObj.SupportTunableSize
                    bpStructElemIndex=dimensions+2*bpIndex;
                else
                    bpStructElemIndex=2*bpIndex;
                end
            else
                bpStructElemIndex=bpIndex+1;
            end
        end

        function index=getTableValuesStructElementIndex(lookupTable)
            dimensions=lookupTable.Breakpoints.Size();
            if strcmp(lookupTable.StructOrder,'SizeBreakpointsTable')
                if lookupTable.SupportTunableSize
                    index=dimensions*2+1;
                else
                    index=dimensions+1;
                end
            elseif strcmp(lookupTable.StructOrder,'SizeTableBreakpoints')
                if lookupTable.SupportTunableSize
                    index=dimensions+1;
                else
                    index=1;
                end
            else
                index=1;
            end
        end

        function[embeddedObj,identifier,codeType]=getEmbeddedObjForTable(lookupTable)
            if strcmp(lookupTable.BreakpointSpecification,'Explicit values')||...
                (strcmp(lookupTable.BreakpointSpecification,'Even spacing')&&...
                isa(lookupTable.Implementation.Type.BaseType,'coder.descriptor.types.Struct'))
                index=autosar.mm.sl2mm.LookupTableBuilder.getTableValuesStructElementIndex(lookupTable);
                element=lookupTable.Implementation.Type.BaseType.Elements(index);
                embeddedObj=element.Type.BaseType;
                codeType=autosar.mm.sl2mm.LookupTableBuilder.getStructElementBaseCodeType(...
                lookupTable.Implementation.CodeType,index);
                identifier=element.Identifier;
            elseif strcmp(lookupTable.BreakpointSpecification,'Reference')
                embeddedObj=lookupTable.Implementation.Type.BaseType;
                codeType=lookupTable.Implementation.CodeType.BaseType;
                identifier=lookupTable.GraphicalName;
            elseif strcmp(lookupTable.BreakpointSpecification,'Even spacing')
                embeddedObj=lookupTable.Implementation.Type.BaseType;
                codeType=lookupTable.Implementation.CodeType.BaseType;
                identifier=lookupTable.GraphicalName;
            end
        end

        function[baseTypeObj,bpArrayObj,baseCodeType]=getBreakpointBaseTypeObj(codeDescBPObj)
            if codeDescBPObj.SupportTunableSize
                index=2;
                element=codeDescBPObj.Implementation.Type.BaseType.Elements(index);
                baseCodeType=autosar.mm.sl2mm.LookupTableBuilder.getStructElementBaseCodeType(...
                codeDescBPObj.Implementation.CodeType,index);
                bpArrayObj=element.Type;
            elseif~isempty(codeDescBPObj.Implementation)
                bpArrayObj=codeDescBPObj.Implementation.Type;
                if isprop(codeDescBPObj.Implementation.CodeType,'BaseType')
                    baseCodeType=codeDescBPObj.Implementation.CodeType.BaseType;
                else
                    baseCodeType=codeDescBPObj.Implementation.CodeType;
                end
            else
                assert(~isempty(codeDescBPObj.FixAxisMetadata),...
                'Expect only fix axis breakpoints to have empty codeDescriptor implementation');
                bpArrayObj=codeDescBPObj.Type;
                baseCodeType=[];
            end
            baseTypeObj=bpArrayObj.BaseType;
        end


        function[embeddedObj,embeddedArrayObj,identifier,codeType]=getEmbeddedObjForBP(codeDescLUTObj,bpIndex)
            switch codeDescLUTObj.BreakpointSpecification
            case 'Explicit values'
                structElemIdx=...
                autosar.mm.sl2mm.LookupTableBuilder.getBreakpointStructElementIndex(codeDescLUTObj,bpIndex);
                codeDescStructElement=codeDescLUTObj.Implementation.Type.BaseType.Elements(structElemIdx);
                embeddedArrayObj=codeDescStructElement.Type;
                embeddedObj=embeddedArrayObj.BaseType;
                codeType=autosar.mm.sl2mm.LookupTableBuilder.getStructElementBaseCodeType(...
                codeDescLUTObj.Implementation.CodeType,structElemIdx);
                identifier=codeDescStructElement.Identifier;
            case 'Reference'
                codeDescBPObj=codeDescLUTObj.Breakpoints.at(bpIndex);
                [embeddedObj,embeddedArrayObj,codeType]=...
                autosar.mm.sl2mm.LookupTableBuilder.getBreakpointBaseTypeObj(codeDescBPObj);
                identifier=autosar.mm.sl2mm.LookupTableBuilder.getCodeDescBPObjIdentifier(codeDescBPObj);
            case 'Even spacing'
                if isa(codeDescLUTObj.Implementation.Type.BaseType,'coder.descriptor.types.Struct')
                    structElemIdx=...
                    autosar.mm.sl2mm.LookupTableBuilder.getBreakpointStructElementIndex(codeDescLUTObj,bpIndex);
                    codeDescStructElement=codeDescLUTObj.Implementation.Type.BaseType.Elements(structElemIdx);
                    embeddedObj=codeDescStructElement.Type;
                    codeType=autosar.mm.sl2mm.LookupTableBuilder.getStructElementBaseCodeType(...
                    codeDescLUTObj.Implementation.CodeType,structElemIdx);
                    if isa(embeddedObj,'coder.descriptor.types.Matrix')
                        embeddedObj=embeddedObj.BaseType;
                    end
                    embeddedArrayObj=[];
                    identifier=codeDescStructElement.Identifier;
                else
                    codeDescBPObj=codeDescLUTObj.Breakpoints.at(bpIndex);
                    [embeddedObj,embeddedArrayObj,codeType]=...
                    autosar.mm.sl2mm.LookupTableBuilder.getBreakpointBaseTypeObj(codeDescBPObj);
                    identifier=autosar.mm.sl2mm.LookupTableBuilder.getCodeDescBPObjIdentifier(codeDescBPObj);
                end
            otherwise
                assert(false,sprintf("Unexpected breakpoint specification: %s",...
                codeDescLUTObj.BreakpointSpecification));
            end
        end
    end
end


