







function apiInfo=getApiInfo(dataSpec,apiKind)


    narginchk(2,2);
    validateattributes(dataSpec,{'legacycode.lct.spec.Data'},{'scalar','nonempty'},1);

    if nargin<2
        apiKind='sfun';
    else
        apiKind=validatestring(apiKind,{'sfun','cgir','tlc'},2);
    end


    apiInfo=struct(...
    'TypeId','',...
    'TypeName','',...
    'CplxTypeName','',...
    'Val','',...
    'ValLiteral','',...
    'Ptr','',...
    'Width','',...
    'Dims',@(x)sprintf('%d',x-1),...
    'IsCplx','',...
    'WBus','',...
    'WAND','',...
    'WBusName','',...
    'WANDName','',...
    'CVarWBusName','',...
    'CVarWANDName','',...
    'RVal','_val',...
    'RPtr','_ptr'...
    );


    apiInfo.WBusName=sprintf('%sBUS',dataSpec.Identifier);
    apiInfo.WANDName=sprintf('%sAND',dataSpec.Identifier);

    apiInfo.CVarWBusName=sprintf('__%sBUS',dataSpec.Identifier);
    apiInfo.CVarWANDName=sprintf('__%sAND',dataSpec.Identifier);


    idx=dataSpec.Id-1;

    if dataSpec.isInput()
        switch apiKind
        case 'sfun'
            if dataSpec.IsDynamicArray
                apiInfo.Ptr=sprintf('ssGetInputPortDynamicArrayContainedData(S, %d)',idx);
                apiInfo.Width=sprintf('ssGetCurrentInputPortWidth(S, %d)',idx);
                apiInfo.Dims=@(x)sprintf('ssGetCurrentInputPortDimensions(S, %d, %s)',idx,getDimStr(x));
            else
                apiInfo.Ptr=sprintf('ssGetInputPortSignal(S, %d)',idx);
                apiInfo.Width=sprintf('ssGetInputPortWidth(S, %d)',idx);
                apiInfo.Dims=@(x)sprintf('ssGetInputPortDimensions(S, %d)[%s]',idx,getDimStr(x));
            end
            apiInfo.NumDims=sprintf('ssGetInputPortNumDimensions(S, %d)',idx);
            apiInfo.WBus=sprintf('ssGetPWorkValue(S, %d)',dataSpec.BusInfo.PWorkIdx-1);
            apiInfo.WAND=sprintf('ssGetDWork(S, %d)',dataSpec.CArrayND.DWorkIdx-1);
        case 'cgir'
            apiInfo.TypeId=sprintf('ssGetInputPortDataType(getSimStruct(), %d)',idx);
            apiInfo.Width=sprintf('ssGetInputPortWidth(getSimStruct(), %d)',idx);
            apiInfo.Dims=@(x)sprintf('ssGetInputPortDimensionSize(getSimStruct(), %d, %s)',idx,getDimStr(x));
        case 'tlc'
            if dataSpec.IsDynamicArray

                apiInfo.Width=sprintf('%%<LibBlockInputSignal(%d, "", "", 0)>.numel()',idx);
                apiInfo.Dims=sprintf('%%<LibBlockInputSignal(%d, "", "", 0)>.size()',idx);
            else
                apiInfo.Width=sprintf('LibBlockInputSignalWidth(%d)',idx);
                apiInfo.Dims=sprintf('LibBlockInputSignalDimensions(%d)',idx);
            end
            apiInfo.TypeId=sprintf('LibBlockInputSignalDataTypeId(%d)',idx);
            apiInfo.TypeName=sprintf('LibGetDataTypeNameFromId(LibBlockInputSignalDataTypeId(%d))',idx);
            apiInfo.CplxTypeName=sprintf('LibGetDataTypeComplexNameFromId(LibBlockInputSignalDataTypeId(%d))',idx);
            apiInfo.Val=sprintf('LibBlockInputSignal(%d, "", "", 0)',idx);
            apiInfo.Ptr=sprintf('LibBlockInputSignalAddr(%d, "", "", 0)',idx);
            apiInfo.IsCplx=sprintf('LibBlockInputSignalIsComplex(%d)',idx);
            apiInfo.WBus=sprintf('LibBlockPWork("", "", "", %d)',dataSpec.BusInfo.PWorkIdx-1);
            apiInfo.WAND=sprintf('LibBlockDWorkAddr(%s, "", "", 0)',apiInfo.WANDName);
        end

    elseif dataSpec.isOutput()
        switch apiKind
        case 'sfun'
            if dataSpec.IsDynamicArray
                apiInfo.Ptr=sprintf('ssGetOutputPortDynamicArrayContainedData(S, %d)',idx);
                apiInfo.Width=sprintf('ssGetCurrentOutputPortWidth(S, %d)',idx);
                apiInfo.Dims=@(x)sprintf('ssGetCurrentOutputPortDimensions(S, %d, %s)',idx,getDimStr(x));
            else
                apiInfo.Ptr=sprintf('ssGetOutputPortSignal(S, %d)',idx);
                apiInfo.Width=sprintf('ssGetOutputPortWidth(S, %d)',idx);
                apiInfo.Dims=@(x)sprintf('ssGetOutputPortDimensions(S, %d)[%s]',idx,getDimStr(x));
            end
            apiInfo.NumDims=sprintf('ssGetOutputPortNumDimensions(S, %d)',idx);
            apiInfo.WBus=sprintf('ssGetPWorkValue(S, %d)',dataSpec.BusInfo.PWorkIdx-1);
            apiInfo.WAND=sprintf('ssGetDWork(S, %d)',dataSpec.CArrayND.DWorkIdx-1);
        case 'cgir'
            apiInfo.TypeId=sprintf('ssGetOutputPortDataType(getSimStruct(), %d)',idx);
            apiInfo.Width=sprintf('ssGetOutputPortWidth(getSimStruct(), %d)',idx);
        case 'tlc'
            apiInfo.TypeId=sprintf('LibBlockOutputSignalDataTypeId(%d)',idx);
            apiInfo.TypeName=sprintf('LibGetDataTypeNameFromId(LibBlockOutputSignalDataTypeId(%d))',idx);
            apiInfo.CplxTypeName=sprintf('LibGetDataTypeComplexNameFromId(LibBlockOutputSignalDataTypeId(%d))',idx);
            apiInfo.Val=sprintf('LibBlockOutputSignal(%d, "", "", 0)',idx);
            apiInfo.Ptr=sprintf('LibBlockOutputSignalAddr(%d, "", "", 0)',idx);
            if dataSpec.IsDynamicArray

                apiInfo.Width=sprintf('%%<LibBlockOutputSignal(%d, "", "", 0)>.numel()',idx);
                apiInfo.Dims=sprintf('%%<LibBlockOutputSignal(%d, "", "", 0)>.size()',idx);
            else
                apiInfo.Width=sprintf('LibBlockOutputSignalWidth(%d)',idx);
                apiInfo.Dims=sprintf('LibBlockOutputSignalDimensions(%d)',idx);
            end
            apiInfo.IsCplx=sprintf('LibBlockOutputSignalIsComplex(%d)',idx);
            apiInfo.WBus=sprintf('LibBlockPWork("", "", "", %d)',dataSpec.BusInfo.PWorkIdx-1);
            apiInfo.WAND=sprintf('LibBlockDWorkAddr(%s, "", "", 0)',apiInfo.WANDName);
        end

    elseif dataSpec.isParameter()
        switch apiKind
        case 'sfun'
            apiInfo.Ptr=sprintf('ssGetRunTimeParamInfo(S, %d)->data',idx);
            apiInfo.Val=sprintf('mxGetScalar(ssGetSFcnParam(S, %d))',idx);
            apiInfo.Width=sprintf('(int_T)mxGetNumberOfElements(ssGetSFcnParam(S, %d))',idx);
            apiInfo.Dims=@(x)sprintf('(int_T)mxGetDimensions(ssGetSFcnParam(S, %d))[%s]',idx,getDimStr(x));
            apiInfo.NumDims=sprintf('(int_T)mxGetNumberOfDimensions(ssGetSFcnParam(S, %d))',idx);
            apiInfo.WBus=sprintf('ssGetPWorkValue(S, %d)',dataSpec.BusInfo.PWorkIdx-1);
            apiInfo.WAND=sprintf('ssGetDWork(S, %d)',dataSpec.CArrayND.DWorkIdx-1);
        case 'cgir'
            apiInfo.TypeId=sprintf('(ssGetRunTimeParamInfo(getSimStruct(), %d))->dataTypeId',idx);
            apiInfo.Val=sprintf('mxGetScalar(ssGetSFcnParam(getSimStruct(), %d))',idx);
            apiInfo.Width=sprintf('(int_T)mxGetNumberOfElements(ssGetSFcnParam(getSimStruct(), %d))',idx);
            apiInfo.Dims=@(x)sprintf('(int_T)mxGetDimensions(ssGetSFcnParam(getSimStruct(), %d))[%s]',idx,getDimStr(x));
        case 'tlc'
            apiInfo.TypeId=sprintf('LibBlockParameterDataTypeId(%s)',dataSpec.Identifier);
            apiInfo.TypeName=sprintf('LibGetDataTypeNameFromId(LibBlockParameterDataTypeId(%s))',dataSpec.Identifier);
            apiInfo.CplxTypeName=sprintf('LibGetDataTypeComplexNameFromId(LibBlockParameterDataTypeId(%s))',dataSpec.Identifier);
            apiInfo.Val=sprintf('LibBlockParameter(%s, "", "", 0)',dataSpec.Identifier);
            apiInfo.ValLiteral=sprintf('LibBlockParameterValue(%s, 0)',dataSpec.Identifier);
            apiInfo.Ptr=sprintf('LibBlockParameterBaseAddr(%s)',dataSpec.Identifier);
            apiInfo.Width=sprintf('LibBlockParameterWidth(%s)',dataSpec.Identifier);
            apiInfo.Dims=sprintf('LibBlockParameterDimensions(%s)',dataSpec.Identifier);
            apiInfo.IsCplx=sprintf('LibBlockParameterIsComplex(%s)',dataSpec.Identifier);
            apiInfo.WBus=sprintf('LibBlockPWork("", "", "", %d)',dataSpec.BusInfo.PWorkIdx-1);
            apiInfo.WAND=sprintf('LibBlockDWorkAddr(%s, "", "", 0)',apiInfo.WANDName);
        end

    elseif dataSpec.isDWork()
        switch apiKind
        case 'sfun'
            if~strcmpi(dataSpec.DataTypeName,'void')
                idx=dataSpec.dwIdx-1;
                apiInfo.Ptr=sprintf('ssGetDWork(S, %d)',idx);
                apiInfo.Width=sprintf('ssGetDWorkWidth(S, %d)',idx);
                apiInfo.WBus=sprintf('ssGetPWorkValue(S, %d)',dataSpec.BusInfo.PWorkIdx-1);
            else
                idx=dataSpec.pwIdx-1;
                apiInfo.Ptr=sprintf('ssGetPWorkValue(S, %d)',idx);
                apiInfo.Width=sprintf('1');
            end
            apiInfo.Dims='';
            apiInfo.wND='';
        case 'cgir'
            if~strcmpi(dataSpec.DataTypeName,'void')
                idx=dataSpec.dwIdx-1;
                apiInfo.TypeId=sprintf('ssGetDWorkDataType(getSimStruct(), %d)',idx);
                apiInfo.Width=sprintf('ssGetDWorkWidth(getSimStruct(), %d)',idx);
            else
                apiInfo.TypeId='SS_DOUBLE';
                apiInfo.Width='1';
            end
        case 'tlc'
            if~strcmpi(dataSpec.DataTypeName,'void')
                apiInfo.TypeId=sprintf('LibBlockDWorkDataTypeId(%s)',dataSpec.Identifier);
                apiInfo.TypeName=sprintf('LibGetDataTypeNameFromId(LibBlockDWorkDataTypeId(%s))',dataSpec.Identifier);
                apiInfo.CplxTypeName=sprintf('LibGetDataTypeComplexNameFromId(LibBlockDWorkDataTypeId(%s))',dataSpec.Identifier);
                apiInfo.Val=sprintf('LibBlockDWork(%s, "", "", 0)',dataSpec.Identifier);
                apiInfo.Ptr=sprintf('LibBlockDWorkAddr(%s, "", "", 0)',dataSpec.Identifier);
                apiInfo.Width=sprintf('LibBlockDWorkWidth(%s)',dataSpec.Identifier);
                apiInfo.IsCplx=sprintf('LibBlockDWorkIsComplex(%s)',dataSpec.Identifier);
                apiInfo.WBus=sprintf('LibBlockPWork("", "", "", %d)',dataSpec.BusInfo.PWorkIdx-1);
            else
                idx=dataSpec.pwIdx-1;
                apiInfo.TypeName=sprintf('"void"');
                apiInfo.Val=sprintf('LibBlockPWork("", "", "", %d)',idx);
                apiInfo.Ptr=sprintf('"&"+LibBlockPWork("", "", "", %d)',idx);
                apiInfo.Width=sprintf('"1"');
            end
        end
    else

    end

    function str=getDimStr(dimVal)



        if isnumeric(dimVal)
            str=sprintf('%d',dimVal);
        elseif ischar(dimVal)||(isstring(dimVal)&&isscalar(dimVal))
            str=char(dimVal);
        else
            str='0';
        end
    end
end



