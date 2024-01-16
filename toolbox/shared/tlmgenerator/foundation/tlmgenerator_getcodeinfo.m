function SystemInfo=tlmgenerator_getcodeinfo()

    try

        load codeInfo;

        SystemInfo.Name=codeInfo.Name;

        SystemInfo.InStruct.Name='';
        SystemInfo.InStruct.DataType='';
        SystemInfo.InStruct.NumPorts=0;

        SystemInfo.OutStruct.Name='';
        SystemInfo.OutStruct.DataType='';
        SystemInfo.OutStruct.NumPorts=0;

        SystemInfo.ParamStruct.Name='';
        SystemInfo.ParamStruct.DataType='';
        SystemInfo.ParamStruct.NumPorts=0;

        SystemInfo.RTMStruct.Name='';
        SystemInfo.RTMStruct.DataType='';
        SystemInfo.RTMStruct.NumPorts=0;

        SystemInfo.IsContinuous=0;

        for i=1:numel(codeInfo.InternalData)
            try
                if(isa(codeInfo.InternalData(i).Implementation,'RTW.PointerExpression'))
                    iH=codeInfo.InternalData(i).Implementation.TargetRegion;
                elseif(isa(codeInfo.InternalData(i).Implementation,'RTW.PointerVariable'))
                    iH=codeInfo.InternalData(i).Implementation.TargetVariable;
                else
                    iH=codeInfo.InternalData(i).Implementation;
                end
                gName=codeInfo.InternalData(i).GraphicalName;
                switch gName
                case 'ExternalInput'
                    SystemInfo.InStruct=l_getStructInfo(iH);
                case 'ExternalOutput'
                    SystemInfo.OutStruct=l_getStructInfo(iH);
                case 'Parameter'
                    SystemInfo.ParamStruct=l_getStructInfo(iH);
                case{'Real-time model','RTModel'}
                    SystemInfo.RTMStruct=l_getStructInfo(iH);
                otherwise

                end
            catch ME
                l_me=MException('','parsing %s %s',gName,ME.message);
                throw(l_me);
            end
        end

        SystemInfo.PortRate=0;
        for i=1:SystemInfo.InStruct.NumPorts
            SystemInfo.InStruct.Port(i).SamplePeriod=codeInfo.Inports(i).Timing.SamplePeriod;
            SystemInfo.InStruct.Port(i).SampleOffset=codeInfo.Inports(i).Timing.SampleOffset;
            if SystemInfo.PortRate==0
                SystemInfo.PortRate=SystemInfo.InStruct.Port(i).SamplePeriod;
            end
            if SystemInfo.InStruct.Port(i).SamplePeriod~=SystemInfo.PortRate

            end
            if SystemInfo.PortRate>SystemInfo.InStruct.Port(i).SamplePeriod
                SystemInfo.PortRate=SystemInfo.InStruct.Port(i).SamplePeriod;
            end
        end

        for i=1:SystemInfo.OutStruct.NumPorts
            SystemInfo.OutStruct.Port(i).SamplePeriod=codeInfo.Outports(i).Timing.SamplePeriod;
            SystemInfo.OutStruct.Port(i).SampleOffset=codeInfo.Outports(i).Timing.SampleOffset;
            if SystemInfo.PortRate==0
                SystemInfo.PortRate=SystemInfo.OutStruct.Port(i).SamplePeriod;
            end
            if SystemInfo.OutStruct.Port(i).SamplePeriod~=SystemInfo.PortRate

            end
            if SystemInfo.PortRate>SystemInfo.OutStruct.Port(i).SamplePeriod
                SystemInfo.PortRate=SystemInfo.OutStruct.Port(i).SamplePeriod;
            end
        end

        SystemInfo.BaseRate=SystemInfo.PortRate;
        for i=1:numel(codeInfo.TimingProperties)
            if strcmpi(codeInfo.TimingProperties(i).TimingMode,'PERIODIC')
                if SystemInfo.BaseRate>codeInfo.TimingProperties(i).SamplePeriod
                    SystemInfo.BaseRate=codeInfo.TimingProperties(i).SamplePeriod;
                end
            end
        end

        SystemInfo.StepRateRatio=1;
        if SystemInfo.PortRate~=SystemInfo.BaseRate
            SystemInfo.StepRateRatio=uint32(SystemInfo.PortRate/SystemInfo.BaseRate);
        end

        for i=1:numel(codeInfo.TimingProperties)
            if strcmpi(codeInfo.TimingProperties(i).TimingMode,'CONTINUOUS')
                SystemInfo.IsContinuous=1;
                break;
            end
        end
        SystemInfo.AllocateFcn=l_getFuncInfo(codeInfo.AllocationFunction);
        SystemInfo.InitializeFcn=l_getFuncInfo(codeInfo.InitializeFunctions);
        SystemInfo.OutputFcn=l_getFuncInfo(codeInfo.OutputFunctions);
        SystemInfo.UpdateFcn=l_getFuncInfo(codeInfo.UpdateFunctions);
        SystemInfo.TerminateFcn=l_getFuncInfo(codeInfo.TerminateFunctions);

        for i=1:SystemInfo.ParamStruct.NumPorts
            SystemInfo.SetParamFcn(i).Name=[codeInfo.Name,'_setparam_',SystemInfo.ParamStruct.Port(i).Name];
            SystemInfo.SetParamFcn(i).DPIName=['DPI_',codeInfo.Name,'_setparam_',SystemInfo.ParamStruct.Port(i).Name];
            SystemInfo.SetParamFcn(i).ReturnType='void';
            SystemInfo.SetParamFcn(i).ArgsType=SystemInfo.ParamStruct.Port(i).DataType;
        end

    catch ME
        l_me=MException('TLMGenerator:build','TLMG getcodeinfo: %s',ME.message);
        SystemInfo=struct([]);
        setappdata(0,'tlmgME',l_me.message);
        throw(l_me);
    end

end


function structInfo=l_getStructInfo(rtwVarInfo)

    structInfo.Name=rtwVarInfo.Identifier;
    structInfo.pName=['p_',rtwVarInfo.Identifier];
    structInfo.DataType=rtwVarInfo.Type.Identifier;
    if rtwVarInfo.Type.isStructure
        structInfo.NumPorts=int32(numel(rtwVarInfo.Type.Elements));
        for i=1:structInfo.NumPorts
            structInfo.Port(i)=l_getPortInfo(rtwVarInfo.Type.Elements(i).Type);
            structInfo.Port(i).Name=rtwVarInfo.Type.Elements(i).Identifier;
            structInfo.Port(i).FlatName=[rtwVarInfo.Identifier,'_',rtwVarInfo.Type.Elements(i).Identifier];
            structInfo.Port(i).Mapped=int32(0);
        end
    end
end


function portInfo=l_getPortInfo(rtwVarInfo)

    if rtwVarInfo.isNumeric
        portInfo.DataType=rtwVarInfo.Identifier;
        portInfo.Dim=int32(1);
        portInfo.Signed=rtwVarInfo.Signedness;
        portInfo.ByteDim=int32(l_getTypeDim(portInfo.DataType)*portInfo.Dim);
        portInfo.BitWidth=int32(rtwVarInfo.WordLength);
    elseif rtwVarInfo.isComplex
        portInfo.DataType=rtwVarInfo.Identifier;
        portInfo.Dim=int32(1);
        portInfo.Signed=false;
        portInfo.ByteDim=int32(l_getTypeDim(portInfo.DataType)*portInfo.Dim);
        portInfo.BitWidth=int32(portInfo.ByteDim*8);
    elseif rtwVarInfo.isStructure
        portInfo.DataType=rtwVarInfo.Identifier;
        portInfo.Dim=int32(1);
        portInfo.Signed=false;
        portInfo.ByteDim=int32(0);
        portInfo.BitWidth=int32(0);
        for i=1:numel(rtwVarInfo.Elements)
            portInfoTemp=l_getPortInfo(rtwVarInfo.Elements(i).Type);
            portInfo.ByteDim=int32(portInfo.ByteDim+portInfoTemp.ByteDim);
        end
        portInfo.BitWidth=int32(portInfo.ByteDim*8);
    elseif rtwVarInfo.isMatrix
        portInfo=l_getPortInfo(rtwVarInfo.BaseType);
        portInfo.Dim=portInfo.Dim*int32(l_getScalarDim(rtwVarInfo.Dimensions));
        portInfo.ByteDim=int32(portInfo.ByteDim*portInfo.Dim);
        portInfo.BitWidth=int32(portInfo.ByteDim*8);
    else

    end
    portInfo.Name='';
    portInfo.FlatName='';
    portInfo.Mapped=0;
    portInfo.SamplePeriod=1;
    portInfo.SampleOffset=0;
end


function dim=l_getScalarDim(dimArray)

    dim=1;
    for i=1:length(dimArray)
        dim=dim*dimArray(i);
    end
end


function dim=l_getTypeDim(type)
    dim=1;
    switch(type)
    case{'cint128_T','cuint128_T','cint128m_T','cuint128m_T'}
        dim=32;
    case{'cint112_T','cuint112_T','cint112m_T','cuint112m_T'}
        dim=28;
    case{'cint96_T','cuint96_T','cint96m_T','cuint96m_T'}
        dim=24;
    case{'cint80_T','cuint80_T','cint80m_T','cuint80m_T'}
        dim=20;
    case{'int128_T','uint128_T','int128m_T','uint128m_T',...
        'cint64_T','cuint64_T','cint64m_T','cuint64m_T','creal64_T','creal_T'}
        dim=16;
    case{'int112_T','uint112_T','int112m_T','uint112m_T'}
        dim=14;
    case{'int96_T','uint96_T','int96m_T','uint96m_T',...
        'cint48_T','cuint48_T','cint48m_T','cuint48m_T'}
        dim=12;
    case{'int80_T','uint80_T','int80m_T','uint80m_T'}
        dim=10;
    case{'int64_T','uint64_T','int64m_T','uint64m_T','real64_T','real_T','time_T',...
        'cint32_T','cuint32_T','cint32m_T','cuint32m_T','creal32_T'}
        dim=8;
    case{'int48_T','uint48_T','int48m_T','uint48m_T'}
        dim=6;
    case{'int32_T','uint32_T','int32m_T','uint32m_T','real32_T',...
        'cint16_T','cuint16_T','cint16m_T','cuint16m_T'}
        dim=4;
    case{'int16_T','uint16_T','int16m_T','uint16m_T',...
        'cint8_T','cuint8_T'}
        dim=2;
    case{'int8_T','uint8_T','boolean_T','char_T','byte_T'}
        dim=1;
    case{'real16_T','creal16_T'}
        error(message('TLMGenerator:TLMTargetCC:TLMNotSupportHalfDataType'));
    end
end


function fcn=l_getFuncInfo(codeInfoFcn)
    if isempty(codeInfoFcn)
        fcn={};
        return;
    else
        fcn.Name=codeInfoFcn.Prototype.Name;

        if isempty(codeInfoFcn.ActualReturn)
            fcn.ReturnType='void';
        else
            fcn.ReturnType=codeInfoFcn.ActualReturn.Implementation.Type.BaseType.Identifier;
        end

        if isempty(codeInfoFcn.ActualArgs)
            fcn.ArgsType='void';
        else
            fcn.ArgsType=codeInfoFcn.ActualArgs.Implementation.Type.BaseType.Identifier;
        end

    end
end






