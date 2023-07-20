classdef ParamPortInfo<dpig.internal.PortInfo
    properties(Access=private)
ParamType
ParamGraphicalName
InstanceSpecificParameter
InstanceSpecificParameterGroupElementName
    end

    properties(GetAccess=public,SetAccess=private)
ParamValue
ParamRange
    end

    properties
objhandlecast
    end


    methods
        function obj=ParamPortInfo(modelCodeInfo,paramCodeInfo)
            if nargin==0
                error('not enough arguments for dpig.internal.ParamPortInfo');
            end
            StructFieldInfo=struct('TopStructFlatName',{},...
            'TopStructName',{},...
            'TopStructDim',[],...
            'ElementAccessIndexNumber',[],...
            'ElementAccessIndexVariable',{},...
            'TopStructIndexing',{},...
            'ElementAccess',{},...
            'TopStructType',{});

            StructFieldInfo(1).TopStructFlatName={};
            StructFieldInfo(1).TopStructName={};
            StructFieldInfo(1).TopStructDim=[];
            StructFieldInfo(1).ElementAccessIndexNumber=[];
            StructFieldInfo(1).ElementAccessIndexVariable={};
            StructFieldInfo(1).TopStructIndexing={};
            StructFieldInfo(1).ElementAccess={};
            StructFieldInfo(1).TopStructType={};
            TempMapFlattenedDim=containers.Map;
            TempMapFlattenedDim('FlattenedDimensions')=[];

            ParamType=l_getParamType(paramCodeInfo);
            if strcmpi(ParamType,'ExternParam')
                RTWVarIdentifier=paramCodeInfo.Implementation.Identifier;
            else
                RTWVarIdentifier=paramCodeInfo.Implementation.ElementIdentifier;
            end

            obj@dpig.internal.PortInfo(paramCodeInfo.Implementation.Type.BaseType,...
            ParamType,...
            RTWVarIdentifier,...
            StructFieldInfo,...
            int32(l_getScalarDim(paramCodeInfo.Type.Dimensions)),...
            TempMapFlattenedDim,...
            '',...
            false);

            obj.ParamGraphicalName=paramCodeInfo.GraphicalName;
            [obj.InstanceSpecificParameter,obj.ParamValue,obj.ParamRange]=l_IsInstanceSpecificParam(obj.ParamGraphicalName,bdroot);
            if(obj.InstanceSpecificParameter)
                obj.InstanceSpecificParameterGroupElementName=l_InstanceSpecificParamGroupElementName(obj.ParamGraphicalName,modelCodeInfo);
            end
            obj.ParamType=ParamType;


            if hdlverifierfeature('IS_CODEGEN_FOR_UVM')&&paramCodeInfo.Type.isMatrix
                n_check_param_type4uvm(paramCodeInfo.Type.BaseType);
            elseif hdlverifierfeature('IS_CODEGEN_FOR_UVM')&&paramCodeInfo.Type.isNumeric
                n_check_param_type4uvm(paramCodeInfo.Type);
            end
            function n_check_param_type4uvm(TempcodeInfo)


                assert(~isa(TempcodeInfo,'coder.types.Struct'),message('HDLLink:DPIG:StructTunableParamsNotSupported'));
                assert(~isa(TempcodeInfo,'coder.types.Complex'),message('HDLLink:DPIG:ComplexTunableParamsNotSupported'));
                assert(~isa(TempcodeInfo,'coder.types.Enum'),message('HDLLink:DPIG:EnumTunableParamsNotSupported'));
            end
        end



        function IsInsP=IsInstanceSpecific(obj)
            IsInsP=obj.InstanceSpecificParameter;
        end

        function str=getParamInitializationConst(obj)
            if obj.IsPortAnArray

                str_arr='';
                for idx=1:numel(obj.ParamValue)
                    str_arr=sprintf('%s%s,',str_arr,num2str(obj.ParamValue(idx)));
                end
                str=sprintf('{%s}',str_arr(1:end-1));
            else

                str=num2str(obj.ParamValue);
            end
        end

        function str=getParamPtrFromRTW(ParamInfo,rtmVarName,objhandlecast)
            if strcmpi(ParamInfo.ParamType,'ExternParam')
                rval_str=sprintf('%s',ParamInfo.Name);
            elseif ParamInfo.InstanceSpecificParameter
                rval_str=sprintf('%s->%s->%s',objhandlecast,ParamInfo.InstanceSpecificParameterGroupElementName,ParamInfo.Name);
            else
                rval_str=sprintf('%s->defaultParam->%s',objhandlecast,ParamInfo.Name);
            end

            if ParamInfo.IsPortPassedByValueFromInterface
                str=[ParamInfo.DataType,'* ',rtmVarName,'_param_',ParamInfo.Name,'_Ptr = &(',rval_str,');'];
            else
                str=[ParamInfo.DataType,'* ',rtmVarName,'_param_',ParamInfo.Name,'_Ptr = ',rval_str,';'];
            end
        end

        function str=getParamStType(ParamInfo)
            if strcmpi(ParamInfo.ParamType,'ExternParam')
                str=ParamInfo.Name;
            elseif ParamInfo.InstanceSpecificParameter
                str=ParamInfo.InstanceSpecificParameterGroupElementName;
            else

                str='defaultParam';
            end
        end

    end

    methods(Access=protected)

        function str=getRTWHandlesToCopy(ParamInfo,rtmVarName,~)
            str=getRTWHandlesToCopy@dpig.internal.PortInfo(ParamInfo,rtmVarName,'param');
        end
    end

end

function[InstanceSpecificParameter,ParamValue,ParamRange]=l_IsInstanceSpecificParam(ParamName,ModelName)
    ParamValue=[];%#ok<NASGU>
    slObj=get_param(ModelName,'UDDObject');
    dict=slObj.DictionarySystem;
    dictP=dict.Parameter;
    param=dictP.getByKey(ParamName);
    if isempty(param)
        InstanceSpecificParameter=false;

        if Simulink.data.existsInGlobal(ModelName,ParamName)

            tSLprm=Simulink.data.evalinGlobal(ModelName,ParamName);
            if isnumeric(tSLprm)||islogical(tSLprm)
                ParamValue=tSLprm;
                ParamRange=struct('Min',[],'Max',[]);
            else
                ParamValue=l_getValueWithCorrectDT(tSLprm.Value,tSLprm.DataType);
                ParamRange=struct('Min',l_getValueWithCorrectDT(tSLprm.Min,tSLprm.DataType),...
                'Max',l_getValueWithCorrectDT(tSLprm.Max,tSLprm.DataType));
            end
        else
            error(['Parameter ',ParamName,' not found in model']);
        end
    else
        InstanceSpecificParameter=~strcmp(param.StorageClass,'Auto')&&param.Argument;
        ParamValue=l_getValueWithCorrectDT(param.Value,param.DataType);
        ParamRange=struct('Min',l_getValueWithCorrectDT(param.Minimum,param.DataType),...
        'Max',l_getValueWithCorrectDT(param.Maximum,param.DataType));
    end

end

function val=l_getValueWithCorrectDT(value,dt)
    if any(strcmp(dt,{'single','double','int8','int16','int32','int64','uint8','uint16','uint32','uint64','logical'}))
        val=cast(value,dt);
    elseif strcmp(dt,'boolean')
        val=cast(value,'logical');
    elseif~isempty(regexp(dt,'fixdt\s*\(.*\)','once'))
        val=fi(value,eval(dt));
    else


        val=value;
    end
end

function InstanceSpecificParameterGroupElementName=l_InstanceSpecificParamGroupElementName(paramName,modelCodeInfo)
    paramInfo=modelCodeInfo.Parameters;
    for i=1:length(paramInfo)
        paramData=paramInfo(i);
        if strcmp(paramData.GraphicalName,paramName)
            identifier=paramData.Implementation.BaseRegion.Identifier;
            internalInfo=modelCodeInfo.InternalData;
            for j=1:length(internalInfo)
                internalData=internalInfo(j);
                if isa(internalData.Implementation,'RTW.PointerExpression')&&...
                    strcmp(internalData.Implementation.TargetRegion.Identifier,identifier)
                    InstanceSpecificParameterGroupElementName=...
                    internalData.Implementation.ElementIdentifier;
                    break;
                end
            end
        end
    end
end

function var=l_getParamType(paramCodeInfo)
    if isa(paramCodeInfo.Implementation,'RTW.Variable')&&...
        isprop(paramCodeInfo.Implementation,'StorageSpecifier')&&...
        strcmpi(paramCodeInfo.Implementation.StorageSpecifier,'extern')
        var='ExternParam';
    else
        var='RTWStructParam';
    end

end

function dim=l_getScalarDim(dimArray)
    dim=prod(reshape(dimArray,numel(dimArray),1));
end
