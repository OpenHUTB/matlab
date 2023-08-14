classdef(Abstract)AbstractParamUpdater<handle





    properties(SetAccess=protected)
        SlCalPrm;
    end

    properties(SetAccess=immutable)
        SlCalPrmName;
        M3iData;
        M3iInitValue;
        M3iImpType;
        SlConstBuilder;
        MsgStream;
    end

    properties(Access=protected)
        SlTypeInfo;
        SlTypeBuilder;
    end

    methods(Abstract,Access=protected)
        assignGroundValue(obj);
        updateValues(obj,value);
        updateDimensions(obj);
        updateDataType(obj,typeStr);
        updateMinMaxValues(obj,minVal,maxVal);
        updateDescription(obj,slDesc);
    end

    methods
        function this=AbstractParamUpdater(slCalPrm,slParamName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder)
            this.SlCalPrm=slCalPrm;
            this.SlCalPrmName=slParamName;
            this.M3iData=m3iData;
            this.M3iInitValue=m3iInitValue;
            this.M3iImpType=m3iImpType;
            this.SlConstBuilder=slConstBuilder;
            this.SlTypeBuilder=slTypeBuilder;
            this.SlTypeInfo=autosar.mm.mm2sl.parameter.AbstractParamUpdater.getSlTypeInfo(slTypeBuilder,m3iData.Type);
            this.MsgStream=autosar.mm.util.MessageStreamHandler.instance();
        end

        function update(this)



            if this.assignGroundValue()
                this.setDefaultDimensions();
            end
            this.updateFieldNames();

            if~isempty(this.M3iInitValue)
                slValue=this.getM3iConstantValues();
                this.updateValues(slValue);
                this.updateDimensions();
            end


            typeStr=this.getDataTypeStr();
            this.updateDataType(typeStr);
            this.setMinMaxValues();
            this.setDescription();
        end

    end

    methods(Static)
        function slCalPrmUpdater=getParamUpdater(slCalPrm,slParamName,...
            m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder)


            slTypeInfo=autosar.mm.mm2sl.parameter.AbstractParamUpdater.getSlTypeInfo(slTypeBuilder,m3iData.Type);
            if isa(slCalPrm,'Simulink.Breakpoint')
                slCalPrmUpdater=autosar.mm.mm2sl.parameter.BreakpointParamUpdater(slCalPrm,slParamName,...
                m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
            elseif isa(slCalPrm,'Simulink.LookupTable')
                switch slTypeInfo.category
                case 'STD_AXIS'
                    slCalPrm.BreakpointsSpecification='Explicit values';
                    slCalPrmUpdater=autosar.mm.mm2sl.parameter.StdAxisLookupTableParamUpdater(slCalPrm,slParamName,...
                    m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
                case 'COM_AXIS'
                    slCalPrm.BreakpointsSpecification='Reference';
                    slCalPrmUpdater=autosar.mm.mm2sl.parameter.LookupTableParamUpdater(slCalPrm,slParamName,...
                    m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
                otherwise
                    assert(false,sprintf('Unsupported lookup table category: %s',slTypeInfo.category));
                end
            elseif isa(m3iData.Type,'Simulink.metamodel.types.LookupTableType')
                slCalPrmUpdater=autosar.mm.mm2sl.parameter.FixAxisLookupTableParamUpdater(slCalPrm,slParamName,...
                m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
            else
                slCalPrmUpdater=autosar.mm.mm2sl.parameter.DefaultParamUpdater(slCalPrm,slParamName,...
                m3iData,m3iInitValue,m3iImpType,slConstBuilder,slTypeBuilder);
            end
        end
    end

    methods(Access=protected)

        function setDefaultDimensions(this)
            this.updateObjDimensions(this.SlCalPrm);
        end

        function updateFieldNames(~)


        end

        function value=getM3iConstantValues(this)
            mlConstInfo=this.SlConstBuilder.buildConst(this.M3iInitValue);
            value=mlConstInfo.mlVar;
            if isa(value,'embedded.fi')
                value=value.double;
            elseif~isa(value,'double')&&~isa(value,'struct')&&...
                (this.SlTypeInfo.isBuiltIn...
                ||isa(this.SlTypeInfo.slObj,'Simulink.AliasType')...
                ||isa(this.SlTypeInfo.slObj,'Simulink.ValueType'))
                value=double(value);
            end
        end


        function outValue=getGroundValue(this)
            outValue=[];
            try

                getTypedValue=false;
                outValue=this.SlConstBuilder.getGroundConstForType(this.M3iData.Type,getTypedValue);
            catch ME



                this.MsgStream.createWarning('RTW:autosar:calprmInvalidValue',...
                {this.M3iData.Name,this.M3iData.Type.Name,ME.message});
                return
            end
        end

        function objWithDimensions=updateObjDimensions(this,objWithDimensions)

            if~isfield(this.SlTypeInfo,'dims')
                return
            end

            try
                objWithDimensions.Dimensions=this.SlTypeInfo.dims.dataObjStyle();
            catch ME
                this.MsgStream.createWarning('autosarstandard:importer:invalidParameterDimensions',...
                {this.SlCalPrmName,this.SlTypeInfo.dims.toString(),ME.message});
            end
        end
    end

    methods(Access=private)

        function typeStr=getDataTypeStr(this)

            if this.SlTypeInfo.hasAnonStructName
                typeStr='struct';
            else
                typeStr=this.SlTypeBuilder.getSLBlockDataTypeStr(this.M3iData.Type);
            end
        end

        function setMinMaxValues(this)

            if~isa(this.M3iData,'Simulink.metamodel.arplatform.interface.ArgumentData')
                m3iType=this.M3iData.Type;
                assert(m3iType.isvalid(),'Expect a valid m3iType');
                if m3iType.IsApplication
                    [isSupported,minVal,maxVal]=...
                    autosar.mm.util.MinMaxHelper.getMinMaxValuesFromM3iType(m3iType,this.SlTypeInfo.slObj);
                    if isSupported
                        this.updateMinMaxValues(minVal,maxVal);
                    end
                end
            end
        end

        function setDescription(this)



            if~isa(this.M3iData,'Simulink.metamodel.arplatform.interface.ArgumentData')
                slDesc=autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc(this.M3iData.desc);
                if~isempty(slDesc)
                    this.updateDescription(slDesc);
                end
            end
        end
    end

    methods(Access=private,Static)
        function slTypeInfo=getSlTypeInfo(slTypeBuilder,m3iType)
            slTypeBuilder.errorOutForAnonStructType=false;
            slTypeInfo=slTypeBuilder.buildType(m3iType);
            slTypeBuilder.errorOutForAnonStructType=true;
        end
    end
end


