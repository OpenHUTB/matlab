classdef ConstantBuilder<autosar.mm.util.ConstantVisitor






    properties(Access=private)
        context=struct;
        numContext;
        IsHomogeneousValue;
        FirstVisitedValue;
        HasBus;
    end

    properties(Hidden=true,GetAccess=public,SetAccess=private)
        slTypeBuilder;
        msgStream;
        m3iQName2MLConstInfoMap;
        m3iTypeQName2GroundConstMap;
        m3iTypeQName2TypedGroundConstMap;
        allVarNameSet;
    end

    methods



        function self=ConstantBuilder(model,typeBuilder)

            self=self@autosar.mm.util.ConstantVisitor(model);

            self.IsHomogeneousValue=[];
            self.FirstVisitedValue=[];
            self.HasBus=[];

            self.slTypeBuilder=typeBuilder;



            self.numContext=0;
            self.context=repmat(self.newContext(),1,200);
            self.nextContext();



            self.m3iQName2MLConstInfoMap=autosar.mm.util.Map(...
            'InitCapacity',10,...
            'KeyType','char');



            self.m3iTypeQName2GroundConstMap=autosar.mm.util.Map(...
            'InitCapacity',10,...
            'KeyType','char');

            self.m3iTypeQName2TypedGroundConstMap=autosar.mm.util.Map(...
            'InitCapacity',10,...
            'KeyType','char');


            self.allVarNameSet=containers.Map('KeyType','char','ValueType','logical');


            self.msgStream=autosar.mm.util.MessageStreamHandler.instance();
        end




        function delete(self)
            self.context=[];
        end





        function[mlConstInfo,alreadyExists]=buildConst(self,m3iConst)
            assert(isa(m3iConst,'Simulink.metamodel.foundation.ValueSpecification'));
            self.context(self.numContext).reshapeMatrix=true;
            [mlConstInfo,alreadyExists]=self.createConst(m3iConst);
            mlConstInfo=rmfield(mlConstInfo,{'elems','reshapeMatrix'});

            mlConstInfo.isHomogeneousValue=self.IsHomogeneousValue;
            mlConstInfo.firstVisitedValue=self.FirstVisitedValue;
            mlConstInfo.hasBus=self.HasBus;

            self.IsHomogeneousValue=[];
            self.FirstVisitedValue=[];
            self.HasBus=[];
        end




        function initValueStr=getBlockInitialValueStringForType(self,m3iType)


            getTypedValue=true;
            initValue=self.getGroundConstForType(m3iType,getTypedValue);


            if isstruct(initValue)



                initValueStr='0';
            else

                if numel(initValue)>1
                    initValue=initValue(1);
                end


                initValueStr=mat2str(initValue);
            end
        end




        function initValueStr=getBlockInitialValueStringForConst(self,m3iConst)
            mlVarInfo=self.buildConst(m3iConst);
            if mlVarInfo.isHomogeneousValue
                if mlVarInfo.hasBus
                    if mlVarInfo.firstVisitedValue==0

                        initValue=0;
                    else

                        initValue=mlVarInfo.mlVar;
                    end
                else
                    initValue=mlVarInfo.firstVisitedValue;
                end
            else
                if mlVarInfo.hasBus



                    initValue=0;
                else
                    initValue=mlVarInfo.mlVar;
                end
            end
            initValueStr=autosar.mm.mm2sl.ConstantBuilder.convertValueToString(initValue);
        end



        function value=getGroundConstForType(self,m3iType,getTypedValue)






            slTypeInfo=self.slTypeBuilder.buildType(m3iType);
            typeQName=autosar.api.Utils.getQualifiedName(m3iType);
            if getTypedValue
                if self.m3iTypeQName2TypedGroundConstMap.isKey(typeQName)
                    value=self.m3iTypeQName2TypedGroundConstMap(typeQName);
                    return
                end
            else
                if self.m3iTypeQName2GroundConstMap.isKey(typeQName)
                    value=self.m3iTypeQName2GroundConstMap(typeQName);
                    return
                end
            end



            min=slTypeInfo.minVal;
            max=slTypeInfo.maxVal;
            if min>0
                value=min;
            elseif max<0
                value=max;
            else
                value=0;
            end

            switch class(m3iType)
            case 'Simulink.metamodel.types.Enumeration'

                enumVals=enumeration(slTypeInfo.name);


                if numel(enumVals)>0
                    value=enumVals(1);
                end
            case 'Simulink.metamodel.types.Structure'



                slBusHelper=autosar.mm.mm2sl.SLBusHelper(self.slTypeBuilder,m3iType);
                value=slBusHelper.createMATLABStruct();


                slBusHelper.delete();

            case{'Simulink.metamodel.types.Matrix',...
                'Simulink.metamodel.types.LookupTableType',...
                'Simulink.metamodel.types.SharedAxisType'}
                value=self.getGroundConstForType(...
                autosar.mm.mm2sl.TypeBuilder.getUnderlyingType(m3iType),...
                getTypedValue);
                dims=slTypeInfo.dims.evaluated();
                if numel(dims)==1

                    dims=[dims,1];
                end
                value=repmat(value,dims);

            otherwise
                if getTypedValue
                    if isa(slTypeInfo.slObj,'Simulink.NumericType')


                        value=fi(0,slTypeInfo.slObj);
                    elseif isa(slTypeInfo.slObj,'Simulink.AliasType')




                        try
                            value=self.typeCast(0,slTypeInfo.slObj.BaseType);
                        catch Me %#ok<NASGU>
                        end
                    else

                    end
                end
            end


            if getTypedValue
                self.m3iTypeQName2TypedGroundConstMap(typeQName)=value;
            else
                self.m3iTypeQName2GroundConstMap(typeQName)=value;
            end
        end



        function ret=acceptChar(~,~)
            ret=[];
        end

    end

    methods(Access='protected')


        function nextContext(self)
            numCtx=self.numContext+1;
            self.context(numCtx+1)=self.newContext();
            self.numContext=numCtx;
        end



        function prevContext(self)
            self.numContext=self.numContext-1;
        end



        function ctx=getContext(self)
            ctx=self.context(self.numContext);
        end



        function ctx=newContext(~)
            ctx=struct();
            ctx.elems=[];
            ctx.name='';
            ctx.mlVar=[];
            ctx.reshapeMatrix=false;
        end


















        function mlVar=reshapeMatrixValueSpecification(self,m3iType,cellElements)

            slTypeInfo=self.slTypeBuilder.buildType(m3iType);
            mlVar=self.getGroundConstForType(m3iType,true);



            nestedAssignCell2Matrix(cellElements,{});

            function nestedAssignCell2Matrix(currCell,idx)


                for ii=1:numel(currCell)
                    sub=[idx,{ii}];
                    if iscell(currCell{ii})

                        nestedAssignCell2Matrix(currCell{ii},sub);
                    elseif~isscalar(currCell{ii})

                        mlVar(ii,:)=currCell{ii}(:);
                    else

                        dims=slTypeInfo.dims.evaluated();
                        if numel(dims)==1
                            dims=[dims,1];
                        end
                        maxNumElements=dims(1)*dims(2);
                        if prod([sub{:}])>maxNumElements



                            return;
                        end
                        ind=sub2ind(dims,sub{:});
                        mlVar(ind)=currCell{ii};
                    end
                end
            end
        end



        function[mlConstInfo,alreadyExists]=createConst(self,m3iConst)


            if m3iConst.getMetaClass()==Simulink.metamodel.types.ConstantReference.MetaClass()
                assert(m3iConst.Value.isvalid()&&m3iConst.Value.ConstantValue.isvalid(),...
                'Unexpected invalid constant reference specification');
                if~m3iConst.Value.ConstantValue.Type.isvalid()

                    m3iConst.Value.ConstantValue.Type=m3iConst.Type;
                end
                [mlConstInfo,alreadyExists]=self.createConst(m3iConst.Value.ConstantValue);
                return
            end

            qName=autosar.api.Utils.getQualifiedName(m3iConst);
            alreadyExists=false;



            constSpecClass=Simulink.metamodel.types.ConstantSpecification.MetaClass();
            hasPkgAsParent=(m3iConst.containerM3I.getMetaClass()==constSpecClass...
            ||isa(m3iConst.containerM3I,'Simulink.metamodel.arplatform.common.Data')...
            ||isa(m3iConst.containerM3I,'Simulink.metamodel.arplatform.port.PortComSpec'));
            if hasPkgAsParent
                if self.m3iQName2MLConstInfoMap.isKey(qName)
                    mlConstInfo=self.m3iQName2MLConstInfoMap(qName);
                    alreadyExists=true;
                    return
                end
            end
            isTopLevelMatrix=self.context(self.numContext).reshapeMatrix;


            self.nextContext();

            self.context(self.numContext).reshapeMatrix=hasPkgAsParent||isTopLevelMatrix;


            self.apply(m3iConst);


            mlConstInfo=self.context(self.numContext);


            if hasPkgAsParent

                if strcmp(m3iConst.containerM3I.MetaClass.qualifiedName,'Simulink.metamodel.types.ConstantSpecification')

                    name=m3iConst.containerM3I.Name;
                else
                    name=m3iConst.Name;
                end

                mlConstInfo.name=name;


                self.m3iQName2MLConstInfoMap(qName)=mlConstInfo;
            end



            self.prevContext();
        end



        function ret=acceptEnumerationLiteralReference(self,m3iConst)
            ret=[];

            mlVar=self.getGroundConstForType(m3iConst.Type,true);
            if m3iConst.getMetaClass()==Simulink.metamodel.types.EnumerationLiteralReference.MetaClass()

                if~isempty(m3iConst.Type)&&~isempty(m3iConst.LiteralText)
                    m3iType=m3iConst.Type;
                    if m3iType.getMetaClass()==Simulink.metamodel.types.Enumeration.MetaClass()
                        for ii=1:m3iConst.Type.OwnedLiteral.size()
                            if strcmp(m3iConst.Type.OwnedLiteral.at(ii).Name,m3iConst.LiteralText)
                                m3iConst.Value=m3iConst.Type.OwnedLiteral.at(ii);
                                break;
                            end
                        end
                        if isempty(m3iConst.Value)
                            DAStudio.error('autosarstandard:ui:constantNotFoundInEnumeration');
                        end
                        mlVar(1)=m3iConst.Value.Value;
                    elseif m3iType.getMetaClass()==Simulink.metamodel.types.Boolean.MetaClass()

                        if strcmpi(m3iConst.LiteralText,'false')

                            mlVar(1)=0;
                        elseif strcmpi(m3iConst.LiteralText,'true')

                            mlVar(1)=1;
                        else
                            assert(false,'Expected true or false not %s',m3iConst.LiteralText);
                        end
                    else
                        assert(false,'Expected enumeration or boolean type for EnumerationLiteralReference');
                    end
                end
            elseif m3iConst.getMetaClass()==Simulink.metamodel.types.LiteralReal.MetaClass()

                mlVar(1)=m3iConst.Value;
            else
                assert(false,'Expecting LiteralReal or EnumerationLiteralReference');
            end
            self.context(self.numContext).mlVar=mlVar;

            self.checkHomogeneity(self.context(self.numContext).mlVar);
        end



        function ret=acceptStructure(self,m3iConst,finish)
            ret=[];
            currCtx=self.numContext;
            self.HasBus=true;
            if finish


                numElems=numel(self.context(currCtx).elems);
                for ii=1:m3iConst.Type.Elements.size()
                    if ii<=numElems
                        structElement=m3iConst.Type.Elements.at(ii);
                        if iscell(self.context(currCtx).elems{ii})


                            self.context(currCtx).mlVar.(structElement.Name)=...
                            self.reshapeMatrixValueSpecification(structElement.ReferencedType,...
                            self.context(currCtx).elems{ii});
                        else
                            self.context(currCtx).mlVar.(structElement.Name)=...
                            self.context(currCtx).elems{ii};
                        end
                    end
                end


                self.context(currCtx).elems=[];
                self.context(currCtx).name=m3iConst.Name;

            else






                if~slfeature('AUTOSARLUTRecordValueSpec')
                    if isa(m3iConst.Type,'Simulink.metamodel.types.LookupTableType')
                        if m3iConst.Type.Axes.size()>0
                            if m3iConst.Type.Axes.at(1).SharedAxis.isvalid()
                                DAStudio.error('autosarstandard:importer:unsupportedInitValueForLookups3',...
                                autosar.api.Utils.getQualifiedName(m3iConst.Type),...
                                autosar.api.Utils.getQualifiedName(m3iConst));
                            else
                                DAStudio.error('autosarstandard:importer:unsupportedInitValueForLookups2',...
                                autosar.api.Utils.getQualifiedName(m3iConst.Type),...
                                autosar.api.Utils.getQualifiedName(m3iConst));
                            end
                        end
                    elseif isa(m3iConst.Type,'Simulink.metamodel.types.SharedAxisType')
                        DAStudio.error('autosarstandard:importer:unsupportedInitValueForLookups3',...
                        autosar.api.Utils.getQualifiedName(m3iConst.Type),...
                        autosar.api.Utils.getQualifiedName(m3iConst));
                    end
                end

                if m3iConst.OwnedSlot.size()==m3iConst.Type.Elements.size()
                    self.context(currCtx).mlVar=struct;
                else
                    self.context(currCtx).mlVar=self.getGroundConstForType(m3iConst.Type,true);
                end


                self.context(currCtx).elems=cell(1,m3iConst.OwnedSlot.size());
            end
        end



        function ret=acceptStructureField(self,m3iConst,slotIdx)
            ret=[];
            mlConstInfo=self.createConst(m3iConst);
            self.context(self.numContext).elems{slotIdx}=mlConstInfo.mlVar;
        end



        function ret=acceptMatrix(self,m3iConst,finish)
            ret=[];
            currCtx=self.numContext;
            if finish


                if self.context(currCtx).reshapeMatrix


                    self.context(currCtx).mlVar=...
                    self.reshapeMatrixValueSpecification(m3iConst.Type,self.context(currCtx).elems);
                else

                    self.context(currCtx).mlVar=self.context(currCtx).elems;
                end


                self.context(currCtx).elems=[];
                self.context(currCtx).name=m3iConst.Name;

            else

                self.context(currCtx).elems=cell(1,m3iConst.ownedCell.size());
            end
        end



        function ret=acceptMatrixElement(self,m3iConst,cellIdx)
            ret=[];
            mlConstInfo=self.createConst(m3iConst);
            self.context(self.numContext).elems{cellIdx}=mlConstInfo.mlVar;
        end



        function ret=acceptLookupTableSpecification(self,m3iConst)
            ret=[];
            assignApplicationValueSpecificationData(self,m3iConst);
        end



        function ret=acceptApplicationValueSpecification(self,m3iConst)
            ret=[];
            assignApplicationValueSpecificationData(self,m3iConst);
        end



        function ret=acceptInteger(self,m3iConst)
            ret=[];
            slTypeInfo=self.slTypeBuilder.buildType(m3iConst.Type);
            if slTypeInfo.isBuiltIn
                value=self.typeCast(m3iConst.Value,slTypeInfo.name);
            elseif isa(slTypeInfo.slObj,'Simulink.AliasType')
                value=self.typeCast(m3iConst.Value,slTypeInfo.slObj.BaseType);
            elseif isa(slTypeInfo.slObj,'Simulink.ValueType')
                value=self.typeCast(m3iConst.Value,slTypeInfo.slObj.DataType);
            elseif isa(slTypeInfo.slObj,'Simulink.NumericType')

                fiObj=fi(0,slTypeInfo.slObj);
                fiObj.int=m3iConst.Value;
                value=fiObj;
            else
                assert(false,...
                'Unrecognized Simulink DataType %s associated with the constant',...
                class(slTypeInfo.slObj));
            end
            self.context(self.numContext).mlVar=value;

            self.checkHomogeneity(self.context(self.numContext).mlVar);
        end



        function ret=acceptBoolean(self,m3iConst)
            ret=[];
            self.context(self.numContext).mlVar=logical(m3iConst.Value);

            self.checkHomogeneity(self.context(self.numContext).mlVar);
        end



        function ret=acceptFloatingPoint(self,m3iConst)
            ret=[];
            bname='double';
            if m3iConst.Type.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Single
                bname='single';
            end
            self.context(self.numContext).mlVar=self.typeCast(m3iConst.Value,bname);

            self.checkHomogeneity(self.context(self.numContext).mlVar);
        end



        function ret=acceptFixedPoint(self,m3iConst)
            ret=[];
            slTypeInfo=self.slTypeBuilder.buildType(m3iConst.Type);

            fiObj=fi(0,slTypeInfo.slObj);

            if m3iConst.Type.IsApplication

                fiObj.double=m3iConst.Value;
            else

                fiObj.int=m3iConst.Value;
            end

            self.context(self.numContext).mlVar=fiObj;

            self.checkHomogeneity(m3iConst.Value);
        end
        function ret=acceptVoidPointer(self,m3iConst)
            ret=[];
            self.context(self.numContext).mlVar=m3iConst.Value;

            self.checkHomogeneity(self.context(self.numContext).mlVar);
        end
    end

    methods(Static,Access='public')
        function propName=getInitValuePropertyName(m3iObj)
            if(m3iObj.getMetaClass().getProperty('InitialValue').isvalid()&&m3iObj.InitialValue.isvalid())||...
                (m3iObj.getMetaClass().getProperty('DefaultValue').isvalid()&&m3iObj.DefaultValue.isvalid())
                if m3iObj.getMetaClass().getProperty('InitialValue').isvalid()

                    propName='InitialValue';
                else

                    propName='DefaultValue';
                end
            else

                propName='InitValue';
            end
        end






        function valueStr=convertValueToString(value)

            valueStr='';

            if ismatrix(value)&&~isscalar(value)&&~isempty(value)


                valueStr='[';
                dim=size(value);
                if length(dim)>2
                    assert(false,'Cannot display matrices with more than two dimensions');
                end
                for rowIdx=1:dim(1)
                    for colIdx=1:dim(2)
                        valueStr=[valueStr,autosar.mm.mm2sl.ConstantBuilder.convertValueToString(value(rowIdx,colIdx)),','];%#ok<*AGROW>
                    end
                    valueStr(end)=';';
                end
                valueStr(end)=']';
            else

                if isfi(value)

                    value=value.double();
                end

                if ischar(value)

                    valueStr=value;
                elseif isstruct(value)

                    valueStr='struct(';
                    single_quote='''';
                    valueFieldNames=fieldnames(value);
                    for i=1:length(valueFieldNames)
                        valueStr=[valueStr,single_quote,valueFieldNames{i},single_quote...
                        ,',',autosar.mm.mm2sl.ConstantBuilder.convertValueToString(value.(valueFieldNames{i})),...
                        ','];
                    end
                    valueStr(end)=')';
                elseif ismatrix(value)||isenum(value)
                    valueStr=mat2str(value);
                elseif isscalar(value)
                    valueStr=Simulink.metamodel.arplatform.getRealStringCompact(value);
                end
            end
        end
    end

    methods(Access='private')
        function mlVar=assignAxisValueSpecificationData(self,m3iConst,m3iConstType)
            mlVar=[];
            baseType=[];
            if isa(m3iConstType,'Simulink.metamodel.types.SharedAxisType')
                if m3iConstType.ValueAxisDataType.isvalid()
                    baseType=m3iConstType.ValueAxisDataType;
                elseif autosar.mm.mm2sl.TypeBuilder.hasValidInputVariableType(m3iConstType.Axis)
                    baseType=m3iConstType.Axis.InputVariableType;
                else
                    baseType=m3iConstType.Axis.BaseType;
                end
                if~isa(m3iConst,'Simulink.metamodel.types.ApplicationValueSpecification')&&...
                    ~isa(m3iConst,'Simulink.metamodel.types.CompositeSpecification')
                    DAStudio.error('autosarstandard:importer:unsupportedInitValueForLookups',...
                    autosar.api.Utils.getQualifiedName(m3iConstType),...
                    autosar.api.Utils.getQualifiedName(m3iConst));
                end
            elseif isa(m3iConstType,'Simulink.metamodel.types.LookupTableType')
                if~isa(m3iConst,'Simulink.metamodel.types.ApplicationValueSpecification')&&...
                    ~isa(m3iConst,'Simulink.metamodel.types.CompositeSpecification')
                    DAStudio.error('autosarstandard:importer:unsupportedInitValueForLookups',...
                    autosar.api.Utils.getQualifiedName(m3iConstType),...
                    autosar.api.Utils.getQualifiedName(m3iConst));
                end
                if m3iConstType.ValueAxisDataType.isvalid()
                    baseType=m3iConstType.ValueAxisDataType;
                else
                    baseType=m3iConstType.BaseType;
                end
            elseif isa(m3iConstType,'Simulink.metamodel.types.Axis')
                if autosar.mm.mm2sl.TypeBuilder.hasValidInputVariableType(m3iConstType)
                    baseType=m3iConstType.InputVariableType;
                else
                    baseType=m3iConstType.BaseType;
                end
            end

            switch class(baseType)
            case 'Simulink.metamodel.types.FixedPoint'
                fiObj=fi(0,fixdt(baseType.IsSigned,baseType.Length.value,baseType.slope,baseType.Bias));

                for ii=1:m3iConst.V.size()
                    fiObj.double=str2double(m3iConst.V.at(ii));
                    mlVar=[mlVar,fiObj];
                end
            case 'Simulink.metamodel.types.Integer'
                if baseType.IsSigned
                    typeCast='int';
                else
                    typeCast='uint';
                end
                typeCast=[typeCast,num2str(baseType.Length.value)];
                for ii=1:m3iConst.V.size()
                    value=self.typeCast(m3iConst.V.at(ii),typeCast);
                    mlVar=[mlVar,value];
                end
            case 'Simulink.metamodel.types.FloatingPoint'
                if baseType.Kind==Simulink.metamodel.types.FloatingPointKind.IEEE_Single
                    typeCast='single';
                else
                    typeCast='double';
                end
                for ii=1:m3iConst.V.size()
                    value=self.typeCast(m3iConst.V.at(ii),typeCast);
                    mlVar=[mlVar,value];
                end
            case 'Simulink.metamodel.types.Boolean'
                typeCast='logical';
                for ii=1:m3iConst.V.size()
                    value=self.typeCast(m3iConst.V.at(ii),typeCast);
                    mlVar=[mlVar,value];
                end
            case 'Simulink.metamodel.types.Enumeration'
                typeCast=baseType.Name;
                for ii=1:m3iConst.V.size()
                    value=self.typeCast(m3iConst.V.at(ii),typeCast);
                    mlVar=[mlVar,value];
                end
            otherwise
                assert(false,'Unsupported type %s.',class(baseType));
            end

            if isa(m3iConstType,'Simulink.metamodel.types.LookupTableType')
                dims=[];
                axisCount=m3iConstType.Axes.size();
                for ii=1:axisCount
                    index=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,ii);
                    if~isempty(m3iConstType.Axes.at(ii).SharedAxis)
                        d=self.slTypeBuilder.getSLDimensions(m3iConstType.Axes.at(index).SharedAxis.Axis,self.slTypeBuilder.getSysConstsValueMap());
                        dims=[dims,d.evaluated()];
                    else
                        d=self.slTypeBuilder.getSLDimensions(m3iConstType.Axes.at(index),self.slTypeBuilder.getSysConstsValueMap());
                        dims=[dims,d.evaluated()];
                    end
                end
                if m3iConstType.Axes.size()==1
                    dims=[dims,1];
                end
            elseif isa(m3iConstType,'Simulink.metamodel.types.SharedAxisType')
                if m3iConst.Dimensions.size()==1
                    d=self.slTypeBuilder.getSLDimensions(m3iConstType.Axis,self.slTypeBuilder.getSysConstsValueMap());
                    dims=[d.evaluated(),1];
                else
                    d=autosar.mm.util.Dimensions(m3iConst.Dimensions);
                    dims=d.evaluated();
                end
            elseif isa(m3iConstType,'Simulink.metamodel.types.Axis')
                d=self.slTypeBuilder.getSLDimensions(m3iConstType,self.slTypeBuilder.getSysConstsValueMap());
                dims=[d.evaluated(),1];
            end
            if numel(mlVar)~=prod(dims)

                DAStudio.error('autosarstandard:importer:ConstantDimensionDontMatchType',...
                autosar.api.Utils.getQualifiedName(m3iConst),...
                num2str(size(mlVar)),...
                autosar.api.Utils.getQualifiedName(m3iConstType),...
                num2str(dims));
            end
            mlVar=reshape(mlVar,dims);
        end
        function assignApplicationValueSpecificationData(self,m3iConst)
            currCtx=self.numContext;
            integratedAxis=false;
            if isa(m3iConst.Type,'Simulink.metamodel.types.LookupTableType')
                for axisIndex=1:m3iConst.Type.Axes.size()
                    m3iAxis=m3iConst.Type.Axes.at(axisIndex);
                    if~(m3iAxis.SharedAxis.isvalid()||...
                        autosar.mm.mm2sl.utils.LookupTableUtils.isFixAxis(m3iAxis))
                        integratedAxis=true;
                    end
                    break;
                end
            end
            if integratedAxis
                self.context(currCtx).mlVar=struct();
                self.context(currCtx).mlVar.('Table')=self.assignAxisValueSpecificationData(m3iConst,m3iConst.Type);
                axisCount=m3iConst.Axes.size();
                for axisIndex=1:axisCount


                    swappedIndex=autosar.mm.util.getLookupTableMemberSwappedIndex(axisCount,axisIndex);
                    self.context(currCtx).mlVar.(['Breakpoint',num2str(axisIndex)])=...
                    self.assignAxisValueSpecificationData(m3iConst.Axes.at(swappedIndex),m3iConst.Type.Axes.at(swappedIndex));
                end
            else
                self.context(currCtx).mlVar=self.assignAxisValueSpecificationData(m3iConst,m3iConst.Type);
            end
        end

        function checkHomogeneity(self,value)

            if isempty(self.IsHomogeneousValue)
                self.IsHomogeneousValue=true;
                self.FirstVisitedValue=value;
            elseif self.IsHomogeneousValue

                self.IsHomogeneousValue=...
                (double(self.FirstVisitedValue)==double(value));
            end
        end
    end

    methods(Static,Access='private')
        function out=typeCast(valueIn,valueType)


            if~ischar(valueIn)

                out=feval(valueType,valueIn);
                return;
            end



            floatingPointTypes={'single','double'};
            if any(strcmp(valueType,floatingPointTypes))
                if strcmpi(valueIn,'inf')

                    valueIn='inf';
                end
            end

            out=eval(sprintf('%s(%s)',valueType,valueIn));

        end
    end
end



