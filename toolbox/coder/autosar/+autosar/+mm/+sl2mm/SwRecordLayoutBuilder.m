classdef SwRecordLayoutBuilder<handle








    properties(Access=private)
        ModelName;
        M3iModel;
        ModelMajority;
        MaxShortNameLength;
        M3iRecordLayoutPkg;



        SwRecordLayoutRefMap;
    end

    methods
        function this=SwRecordLayoutBuilder(m3iModel,modelName,modelMajority)
            import autosar.mm.util.XmlOptionsAdapter;

            this.ModelName=modelName;
            this.M3iModel=m3iModel;
            this.ModelMajority=modelMajority;
            this.MaxShortNameLength=get_param(this.ModelName,'AutosarMaxShortNameLength');
            arRoot=this.M3iModel.RootPackage.at(1);
            appTypePkg=XmlOptionsAdapter.get(arRoot,'ApplicationDataTypePackage');
            if isempty(appTypePkg)
                defaultApplPkg=[arRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.ApplicationDataTypes];
                appTypePkg=defaultApplPkg;
            end
            recordLayoutPkg=XmlOptionsAdapter.get(arRoot,'SwRecordLayoutPackage');
            if isempty(recordLayoutPkg)
                recordLayoutPkg=[appTypePkg,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.SwRecordLayouts];
                XmlOptionsAdapter.set(arRoot,'SwRecordLayoutPackage',recordLayoutPkg);
            end
            this.M3iRecordLayoutPkg=autosar.mm.Model.getOrAddARPackage(arRoot,recordLayoutPkg);
            this.SwRecordLayoutRefMap=this.createSwRecordLayoutRefMap();
        end

        function m3iSwRecordLayout=buildM3iSwRecordLayout(this,codeDescObj,m3iImpType)


            assert(isa(codeDescObj,'coder.descriptor.LookupTableDataInterface')||...
            isa(codeDescObj,'coder.descriptor.BreakpointDataInterface'),...
            'SwRecordLayoutBuilder only supports Lookup tables and Breakpoints');

            swRecordLayoutName=this.getSwRecordLayoutName(codeDescObj);
            if this.SwRecordLayoutRefMap.isKey(swRecordLayoutName)
                m3iSwRecordLayout=this.SwRecordLayoutRefMap(swRecordLayoutName);
            else
                m3iSwRecordLayout=...
                this.findOrCreateM3iSwRecordLayoutByName(swRecordLayoutName);
                if slfeature('AUTOSARFixAxisLookupTables')>0&&...
                    autosar.mm.sl2mm.LookupTableBuilder.hasFixAxisLookupTableDataInterface(codeDescObj)
                    m3iSRLGroup=...
                    this.findOrCreateNthM3iSwRecordLayoutGroup(m3iSwRecordLayout,1);
                    this.updateM3iSwRecordLayoutGroup(m3iSRLGroup,...
                    codeDescObj,m3iImpType,swRecordLayoutName);
                end
                this.SwRecordLayoutRefMap(swRecordLayoutName)=m3iSwRecordLayout;
            end
        end

    end

    methods(Access=private)

        function swRecordLayoutNameToM3iObjMap=createSwRecordLayoutRefMap(this)


            swRecordLayoutNameToM3iObjMap=containers.Map;
            arRoot=this.M3iModel.RootPackage.at(1);
            if~autosar.mm.arxml.Exporter.hasExternalReference(arRoot)
                return;
            end

            m3iSwRecordLayoutSeq=autosar.mm.Model.findObjectByMetaClass(this.M3iModel,...
            Simulink.metamodel.types.SwRecordLayout.MetaClass,true,false);
            for ii=1:m3iSwRecordLayoutSeq.size()
                m3iSwRecordLayout=m3iSwRecordLayoutSeq.at(ii);
                if~autosar.mm.arxml.Exporter.isExternalReference(m3iSwRecordLayout)

                    continue;
                end
                if strcmp(m3iSwRecordLayout.Name(1:3),'Fix')

                    continue;
                end
                m3iSRLGroup=m3iSwRecordLayout.SwRecordLayoutGroup;
                switch m3iSRLGroup.SwRecordLayoutGroup.size()
                case 0
                    if m3iSRLGroup.SwRecordLayoutV.size()>0
                        if m3iSRLGroup.SwRecordLayoutV.at(1).SwRecordLayoutVAxis==0

                            typeName=this.getSwRecordLayoutPostfix(m3iSRLGroup.SwRecordLayoutV.at(1).SwBaseType);
                            shortName=[this.getDistributedLookupTablePrefix(1),typeName];
                        else

                            typeName=this.getSwRecordLayoutPostfix(m3iSRLGroup.SwRecordLayoutV.at(1).SwBaseType);
                            shortName=['Distr_',typeName,'_M'];
                        end
                        swRecordLayoutNameToM3iObjMap(shortName)=m3iSwRecordLayout;
                    end
                case 1
                    m3iChild=m3iSRLGroup.SwRecordLayoutGroup.at(1);
                    dim=1;
                    while m3iChild.SwRecordLayoutGroup.size()>0
                        m3iChild=m3iChild.SwRecordLayoutGroup.at(1);
                        dim=dim+1;
                    end
                    swRecordLayoutV=m3iChild.SwRecordLayoutV.at(1);
                    axisIndex=swRecordLayoutV.SwRecordLayoutVAxis;
                    switch axisIndex
                    case 0
                        shortName=[this.getDistributedLookupTablePrefix(dim),typeName];
                        swRecordLayoutNameToM3iObjMap(shortName)=m3iSwRecordLayout;
                    otherwise
                        typeName=this.getSwRecordLayoutPostfix(swRecordLayoutV.SwBaseType);
                        shortName=['Distr_',typeName];
                        if m3iSRLGroup.SwRecordLayoutV.size==0
                            shortName=[shortName,'_M'];%#ok<AGROW>
                        end
                        swRecordLayoutNameToM3iObjMap(shortName)=m3iSwRecordLayout;
                    end
                otherwise

                    axisTypes='';
                    tableType='';
                    numAxes=0;

                    for jj=1:m3iSRLGroup.SwRecordLayoutGroup.size()
                        m3iChild=m3iSRLGroup.SwRecordLayoutGroup.at(jj);
                        while m3iChild.SwRecordLayoutGroup.size()>0
                            m3iChild=m3iChild.SwRecordLayoutGroup.at(1);
                        end
                        swRecordLayoutV=m3iChild.SwRecordLayoutV.at(1);
                        axisIndex=swRecordLayoutV.SwRecordLayoutVAxis;
                        switch axisIndex
                        case 0
                            tableType=this.getSwRecordLayoutPostfix(swRecordLayoutV.SwBaseType);
                        otherwise
                            axisTypes=[axisTypes,this.getSwRecordLayoutPostfix(swRecordLayoutV.SwBaseType)];%#ok<AGROW>
                            numAxes=numAxes+1;
                        end
                    end
                    shortName=this.getIntegratedLookupTablePrefix(numAxes);
                    shortName=[shortName,axisTypes,'_',tableType];%#ok<AGROW>
                    swRecordLayoutNameToM3iObjMap(shortName)=m3iSwRecordLayout;
                end
            end
        end

        function swRecordLayoutName=getSwRecordLayoutName(this,codeDescLUTObj)



            import autosar.mm.sl2mm.LookupTableBuilder;
            if isa(codeDescLUTObj,'coder.descriptor.LookupTableDataInterface')
                if(codeDescLUTObj.Implementation.Type.isStructure)||...
                    (codeDescLUTObj.Implementation.Type.BaseType.isStructure)
                    axisCount=codeDescLUTObj.Breakpoints.Size;
                    prefix=this.getIntegratedLookupTablePrefix(axisCount);
                    for ii=1:axisCount
                        codeDescBaseType=LookupTableBuilder.getEmbeddedObjForBP(codeDescLUTObj,ii);
                        prefix=[prefix,this.getBaseTypeLabel(codeDescBaseType)];%#ok<AGROW>
                    end
                    codeDescBaseType=LookupTableBuilder.getEmbeddedObjForTable(codeDescLUTObj);
                    swRecordLayoutShortName=[prefix,'_',this.getBaseTypeLabel(codeDescBaseType)];
                    if~codeDescLUTObj.SupportTunableSize



                        swRecordLayoutShortName=[swRecordLayoutShortName,'_M'];
                    end
                else
                    axisCount=codeDescLUTObj.Breakpoints.Size();
                    tablePrefix=this.getDistributedLookupTablePrefix(axisCount);
                    codeDescBaseType=LookupTableBuilder.getEmbeddedObjForTable(codeDescLUTObj);
                    swRecordLayoutShortName=[tablePrefix,this.getBaseTypeLabel(codeDescBaseType)];
                end
                if strcmp(codeDescLUTObj.BreakpointSpecification,'Even spacing')
                    swRecordLayoutShortName=['Fix',swRecordLayoutShortName];
                end
            elseif isa(codeDescLUTObj,'coder.descriptor.BreakpointDataInterface')
                prefix='Distr_';
                codeDescBaseType=LookupTableBuilder.getBreakpointBaseTypeObj(codeDescLUTObj);
                swRecordLayoutShortName=[prefix,this.getBaseTypeLabel(codeDescBaseType)];
                if~codeDescLUTObj.SupportTunableSize


                    swRecordLayoutShortName=[swRecordLayoutShortName,'_M'];
                end
            else
                assert(false,"CodeDescriptor LUT Object must be breakpoint or Lookup table");
            end
            swRecordLayoutName=arxml.arxml_private('p_create_aridentifier',...
            swRecordLayoutShortName,this.MaxShortNameLength);
        end

        function m3iSwRecordLayout=findOrCreateM3iSwRecordLayoutByName(this,recLayoutName)


            arRoot=this.M3iModel.RootPackage.at(1);
            m3iSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
            arRoot,recLayoutName,Simulink.metamodel.types.SwRecordLayout.MetaClass);
            if m3iSeq.size()==0
                m3iSwRecordLayout=Simulink.metamodel.types.SwRecordLayout(this.M3iModel);
                m3iSwRecordLayout.Name=recLayoutName;
                this.M3iRecordLayoutPkg.packagedElement.append(m3iSwRecordLayout);
            else
                m3iSwRecordLayout=m3iSeq.at(1);
            end
        end

        function updateM3iSwRecordLayoutGroup(this,m3iSRLGroup,codeDescLUTObj,m3iImpType,shortLabel)


            import autosar.mm.sl2mm.LookupTableBuilder;

            assert(~isempty(shortLabel),'Short label is necessary for SwRecordLayoutGroup');
            m3iSRLGroup.ShortLabel=shortLabel;

            if isa(m3iImpType,'Simulink.metamodel.types.Structure')
                assert(LookupTableBuilder.hasFixAxisLookupTableDataInterface(codeDescLUTObj),...
                'Only Fix Axis lookup table SwRecordLayout is updated by metamodel');




                numberOfAxes=codeDescLUTObj.Breakpoints.Size();
                if codeDescLUTObj.SupportTunableSize
                    for axisIndex=1:numberOfAxes
                        m3iOffsetStructElem=m3iImpType.Elements.at(axisIndex);
                        assert(isa(m3iOffsetStructElem.Type,'Simulink.metamodel.types.PrimitiveType'),...
                        'Expect implementation struct element type to be PrimitiveType');
                        m3iSRLV=...
                        this.findOrCreateNthM3iSwRecordLayoutV(m3iSRLGroup,axisIndex);
                        axisName=LookupTableBuilder.getAxisNameFromIndex(numberOfAxes,axisIndex);
                        countShortLabel=strcat('N',axisName);
                        this.updateM3iSwRecordLayoutV(m3iSRLV,m3iOffsetStructElem.Type,...
                        countShortLabel,'COUNT',axisIndex,axisName);
                    end
                end


                SRLGroupIndex=1;
                m3iTableSRLGroup=...
                this.findOrCreateNthM3iSwRecordLayoutGroup(m3iSRLGroup,SRLGroupIndex);


                tableValueIndex=LookupTableBuilder.getTableValuesStructElementIndex(codeDescLUTObj);
                m3iTableElement=m3iImpType.Elements.at(tableValueIndex);
                this.updateM3iSwRecordLayoutGroup(m3iTableSRLGroup,codeDescLUTObj,...
                m3iTableElement.Type,'Val');





                for axisIndex=1:numberOfAxes
                    axisName=LookupTableBuilder.getAxisNameFromIndex(numberOfAxes,axisIndex);



                    SRLGroupIndex=SRLGroupIndex+1;
                    m3iOffsetSRLGroup=...
                    this.findOrCreateNthM3iSwRecordLayoutGroup(m3iSRLGroup,SRLGroupIndex);

                    offsetShortLabel=strcat('Offset',axisName);
                    m3iOffsetSRLGroup.ShortLabel=offsetShortLabel;
                    m3iOffsetSRLV=this.findOrCreateNthM3iSwRecordLayoutV(m3iOffsetSRLGroup,1);



                    bpStructElemIndex=...
                    LookupTableBuilder.getBreakpointStructElementIndex(codeDescLUTObj,axisIndex);
                    m3iOffsetStructElem=m3iImpType.Elements.at(bpStructElemIndex);


                    this.updateM3iSwRecordLayoutV(m3iOffsetSRLV,m3iOffsetStructElem.Type,...
                    offsetShortLabel,'OFFSET',axisIndex,axisName);



                    swappedIndex=...
                    autosar.mm.util.getLookupTableMemberSwappedIndex(numberOfAxes,axisIndex);
                    codeDescFixAxisMetadata=codeDescLUTObj.Breakpoints(swappedIndex).FixAxisMetadata;
                    assert(isa(codeDescFixAxisMetadata,'coder.descriptor.EvenSpacingMetadata'),...
                    'Expect only even spaced axis to be generated with implementation as struct');
                    assert(~codeDescFixAxisMetadata.IsPow2,...
                    'Expect only Fix axis with Distance to be part of struct');



                    SRLGroupIndex=SRLGroupIndex+1;
                    m3iDistSRLGroup=...
                    this.findOrCreateNthM3iSwRecordLayoutGroup(m3iSRLGroup,SRLGroupIndex);

                    axisLabel='DIST';
                    distShortLabel=strcat('Dist',axisName);
                    m3iDistSRLGroup.ShortLabel=distShortLabel;
                    m3iDistSRLV=this.findOrCreateNthM3iSwRecordLayoutV(m3iDistSRLGroup,1);



                    m3iDistStructElem=m3iImpType.Elements.at(bpStructElemIndex+1);


                    this.updateM3iSwRecordLayoutV(m3iDistSRLV,m3iDistStructElem.Type,...
                    distShortLabel,axisLabel,axisIndex,axisName);
                end
            elseif isa(m3iImpType,'Simulink.metamodel.types.Matrix')



                numberOfAxes=codeDescLUTObj.Breakpoints.Size();

                m3iSRLGroup.Category=LookupTableBuilder.getModelMajorityLabel(...
                this.ModelMajority,numberOfAxes);


                vIndex=[];
                for axisIndex=1:numberOfAxes
                    m3iSRLGroup.ShortLabel='Val';
                    m3iSRLGroup.SwRecordLayoutGroupAxis=int32(axisIndex);
                    axisName=LookupTableBuilder.getAxisNameFromIndex(numberOfAxes,axisIndex);
                    m3iSRLGroup.SwRecordLayoutGroupIndex=axisName;
                    vIndex=[vIndex,axisName,' '];%#ok<AGROW>

                    if axisIndex~=numberOfAxes



                        m3iSubSwRecordLayoutGroup=...
                        this.findOrCreateNthM3iSwRecordLayoutGroup(m3iSRLGroup,1);
                        m3iSRLGroup=m3iSubSwRecordLayoutGroup;
                    end
                end

                m3iSRLV=this.findOrCreateNthM3iSwRecordLayoutV(m3iSRLGroup,1);
                if~isempty(m3iImpType.Reference)
                    m3iType=m3iImpType.Reference;
                else
                    m3iType=this.getM3iBaseType(m3iImpType);
                end
                this.updateM3iSwRecordLayoutV(m3iSRLV,m3iType,...
                'Val','VALUE',0,strtrim(vIndex));
            else
                assert(false,'Unexpected m3iImplementation Type');
            end
        end

        function m3iSRLGroup=findOrCreateNthM3iSwRecordLayoutGroup(this,m3iSRLParent,SRLIndex)


            if isa(m3iSRLParent,'Simulink.metamodel.types.SwRecordLayout')
                assert(SRLIndex==1,'SwRecordLayout must contain only one SwRecordLayoutGroup');
                if m3iSRLParent.SwRecordLayoutGroup.isvalid()
                    m3iSRLGroup=m3iSRLParent.SwRecordLayoutGroup;
                else
                    m3iSRLGroup=Simulink.metamodel.types.SwRecordLayoutGroup(this.M3iModel);
                    m3iSRLParent.SwRecordLayoutGroup=m3iSRLGroup;
                end
            elseif isa(m3iSRLParent,'Simulink.metamodel.types.SwRecordLayoutGroup')
                if m3iSRLParent.SwRecordLayoutGroup.size()>=SRLIndex
                    m3iSRLGroup=m3iSRLParent.SwRecordLayoutGroup.at(SRLIndex);
                else
                    numberOfSwRecordLayoutGroups=uint32(m3iSRLParent.SwRecordLayoutGroup.size()+1);

                    for ii=numberOfSwRecordLayoutGroups:uint32(SRLIndex)
                        m3iSRLGroup=Simulink.metamodel.types.SwRecordLayoutGroup(this.M3iModel);
                        m3iSRLParent.SwRecordLayoutGroup.append(m3iSRLGroup);
                    end
                end
            else
                assert(false,'Unsuitable m3iParent for creating SwRecordLayoutGroup');
            end
        end

        function m3iSwRecordLayoutV=findOrCreateNthM3iSwRecordLayoutV(this,m3iSRLParent,SRLVIndex)


            if m3iSRLParent.SwRecordLayoutV.isvalid()&&...
                m3iSRLParent.SwRecordLayoutV.size()>=SRLVIndex
                m3iSwRecordLayoutV=m3iSRLParent.SwRecordLayoutV.at(SRLVIndex);
            else
                numberOfSwRecordLayoutV=uint32(m3iSRLParent.SwRecordLayoutV.size()+1);

                for ii=numberOfSwRecordLayoutV:uint32(SRLVIndex)
                    m3iSwRecordLayoutV=Simulink.metamodel.types.SwRecordLayoutV(this.M3iModel);
                    m3iSRLParent.SwRecordLayoutV.append(m3iSwRecordLayoutV);
                end
            end
        end
    end

    methods(Access=private,Static)
        function updateM3iSwRecordLayoutV(m3iSwRecordLayoutV,m3iImpType,shortLabel,valuePropCategory,axisIndex,vIndex)
            m3iSwRecordLayoutV.ShortLabel=shortLabel;

            m3iSwRecordLayoutV.SwRecordLayoutVProp=valuePropCategory;

            m3iSwRecordLayoutV.SwRecordLayoutVAxis=axisIndex;


            m3iSwRecordLayoutV.SwRecordLayoutVIndex=vIndex;
            assert(isa(m3iImpType,'Simulink.metamodel.types.PrimitiveType'),...
            'Expect m3iImpType for SwRecordLayoutV to be PrimitiveType');
            m3iSwRecordLayoutV.SwBaseType=m3iImpType.SwBaseType;
        end

        function typeLabel=getBaseTypeLabel(codeDescBaseType)


            if codeDescBaseType.isEnum
                typeLabel=codeDescBaseType.Identifier;
            else
                if codeDescBaseType.isDouble||codeDescBaseType.isSingle
                    prefix='f';
                elseif codeDescBaseType.Signedness
                    prefix='s';
                else
                    prefix='u';
                end
                typeLabel=[prefix,num2str(codeDescBaseType.WordLength)];
            end
        end

        function shortName=getDistributedLookupTablePrefix(dims)


            switch dims
            case 1
                shortName='Cur_';
            case 2
                shortName='Map_';
            case 3
                shortName='Cuboid_';
            otherwise
                shortName=['Cube_',num2str(dims),'_'];
            end
        end

        function shortName=getIntegratedLookupTablePrefix(dims)


            shortName=strcat('Int',...
            autosar.mm.sl2mm.SwRecordLayoutBuilder.getDistributedLookupTablePrefix(dims));
        end

        function postfix=getSwRecordLayoutPostfix(m3iObj)


            postfix='';
            toolInfo=m3iObj.getExternalToolInfo('ARXML_SwBaseTypeInfo').externalId;
            if~isempty(toolInfo)
                tokens=strsplit(toolInfo,'#');
                if numel(tokens)>0
                    numElems=str2double(tokens{1});
                    index=1;
                    keyValueMap=containers.Map;
                    for ii=1:numElems
                        index=index+1;
                        key=tokens{index};
                        index=index+1;
                        value=tokens{index};
                        keyValueMap(key)=value;
                    end
                end
            end
            dataSize=keyValueMap('Size');
            switch keyValueMap('Encoding')
            case 'IEEE754'
                if strcmp(dataSize,'32')
                    postfix='f32';
                elseif strcmp(dataSize,'64')
                    postfix='f64';
                end
            case '2C'
                postfix=['s',dataSize];
            case 'NONE'
                postfix=['u',dataSize];
            case 'BOOLEAN'
                postfix='boolean';
            otherwise
                postfix='auto';
            end
        end
        function m3iBaseType=getM3iBaseType(m3iType)
            if isa(m3iType.BaseType,'Simulink.metamodel.types.Matrix')
                m3iBaseType=...
                autosar.mm.sl2mm.SwRecordLayoutBuilder.getM3iBaseType(...
                m3iType.BaseType);
            else
                m3iBaseType=m3iType.BaseType;
            end
        end
    end
end


