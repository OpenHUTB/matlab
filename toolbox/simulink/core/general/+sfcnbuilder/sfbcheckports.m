function[ad,isValid,errorMessage,p,iP,oP]=sfbcheckports(ad)




    isValid=1;
    errorMessage='';
    cr=newline;

    [~,iP,oP,paramsList]=sfcnbuilder.sfunbuilderports('GetPortsInfo',ad.inputArgs,ad);

    NumberOfInputs=iP.Dimensions{1};
    ad.SfunWizardData.InputPortWidth=NumberOfInputs;
    NumberOfInputs=strrep(NumberOfInputs,']','');
    NumberOfInputs=strrep(NumberOfInputs,'[','');

    NumberOfOutputs=oP.Dimensions{1};
    ad.SfunWizardData.OutputPortWidth=NumberOfOutputs;
    NumberOfOutputs=strrep(NumberOfOutputs,']','');
    NumberOfOutputs=strrep(NumberOfOutputs,'[','');


    if isempty(paramsList.Name)||isempty(paramsList.Name{1})
        NumberOfParameters='0';
    else
        NumberOfParameters=num2str(length(paramsList.Name));
    end
    ad.SfunWizardData.NumberOfParameters=NumberOfParameters;

    [SampleTime,ad,isValid,errorMessage]=setSampleTime(ad);

    if~sfcnbuilder.isValidParams(NumberOfParameters)
        errorMessage=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidParameterSettings',NumberOfParameters);
        isValid=0;
    end

    if~strcmp(iP.Dimensions{1},'0')

        [isvalid,strmessage]=checkPortNames(iP,'input');
        if~isvalid
            errorMessage=horzcat(errorMessage,cr,strmessage);
            isValid=0;
        end

        [iP,isvalid,strmessage]=checkPortDims(iP,'input');
        if~isvalid
            errorMessage=horzcat(errorMessage,cr,strmessage);
            isValid=0;
        end

        [iP,isvalid,strmessage]=checkPortBuses(iP,'input',bdroot(ad.inputArgs));
        if~isvalid
            errorMessage=horzcat(errorMessage,cr,strmessage);
            isValid=0;
        end
    end

    if~strcmp(oP.Dimensions{1},'0')

        [isvalid,strmessage]=checkPortNames(oP,'output');
        if~isvalid
            errorMessage=horzcat(errorMessage,cr,strmessage);
            isValid=0;
        end

        [oP,isvalid,strmessage]=checkPortDims(oP,'output');
        if~isvalid
            errorMessage=horzcat(errorMessage,cr,strmessage);
            isValid=0;
        end

        [oP,isvalid,strmessage]=checkPortBuses(oP,'output',bdroot(ad.inputArgs));
        if~isvalid
            errorMessage=horzcat(errorMessage,cr,strmessage);
            isValid=0;
        end
    end

    if~strcmp(NumberOfParameters,'0')
        [isvalid,strmessage]=checkParamNames(paramsList,'parameter');
        if~isvalid
            errorMessage=horzcat(errorMessage,cr,strmessage);
            isValid=0;
        end
    end

    p.NumberOfInputs=NumberOfInputs;
    p.NumberOfOutputs=NumberOfOutputs;
    p.NumberOfParameters=NumberOfParameters;
    p.SampleTime=SampleTime;


    if(str2double(p.NumberOfInputs)==-1)
        p.NumberOfInputs='DYNAMICALLY_SIZED';
    end
    if(str2double(p.NumberOfOutputs)==-1)
        p.NumberOfOutputs='DYNAMICALLY_SIZED';
    end

    ad.SfunWizardData.InputPorts=iP;
    ad.SfunWizardData.OutputPorts=oP;
    ad.SfunWizardData.Parameters=paramsList;


end


function[isvalid,strmessage]=checkPortNames(portStruct,portIOString)
    isvalid=1;
    strmessage='';
    for k=1:length(portStruct.Name)
        try
            if(~iscvar(portStruct.Name{k})||isempty(portStruct.Name{k}))
                strmessage=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidPortName',portIOString,portStruct.Name{k});
                isvalid=0;
                return
            end
        catch
            isvalid=0;
            strmessage=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidPortName1',portIOString,k);
            return
        end
    end
end

function[isvalid,strmessage]=checkParamNames(portStruct,portIOString)
    isvalid=1;
    strmessage='';
    for k=1:length(portStruct.Name)
        try
            if~iscvar(portStruct.Name{k})
                strmessage=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidParamName',portIOString,portStruct.Name{k});
                isvalid=0;
                return
            end
        catch
            isvalid=0;
            strmessage=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidPortName1',portIOString,k);
            return
        end
    end
end

function[portStruct,isvalid,strmessage]=checkPortBuses(portStruct,portIOString,model)
    isvalid=1;
    strmessage='';
    for k=1:length(portStruct.Name)
        try
            if(strcmp(portStruct.Bus{k},'on'))
                if(~iscvar(portStruct.Busname{k})||isempty(portStruct.Busname{k}))
                    strmessage=sprintf('\n ERROR: Invalid %s Bus name: %s',portIOString,portStruct.Busname{k});
                    isvalid=0;
                    return
                end

                isSlObjDefined=existsInGlobalScope(model,portStruct.Busname{k});

                if isSlObjDefined~=1
                    strmessage=sprintf('\n ERROR: Bus object for %s port %s %s does not exist in workspace',portIOString,num2str(k),portStruct.Busname{k});
                    isvalid=0;
                    return
                else
                    slObj=evalinGlobalScope(model,portStruct.Busname{k});
                    if isa(slObj,'Simulink.Bus')
                        for i=1:length(slObj.Elements)

                            [isvalid,strmessage]=checkForNestedArrayOfBuses(slObj.Elements(i).DataType,prod(slObj.Elements(i).Dimensions),portIOString,k,portStruct.Busname{k},1,'',model);
                            if(~isvalid)
                                return;
                            end

                            [isvalid,strmessage]=checkForUnsupportedDataTypes(slObj.Elements(i).DataType,slObj.Elements(i).Name,portStruct.Busname{k},portIOString,k,1,'',model);
                            if(~isvalid)
                                return;
                            end

                            EnumDTStr='Enum:';
                            indices=findstr(slObj.Elements(i).DataType,EnumDTStr);
                            if(~isempty(indices)&&indices(1)==1)
                                if isempty(strtrim(slObj.HeaderFile))
                                    strmessage=sprintf('\n ERROR: For enumerated data types a header file must be specified for the Bus object %s for %s port %s',portStruct.Busname{k},portIOString,num2str(k));
                                    isvalid=0;
                                    return
                                end
                            end
                        end
                    end
                end
            end
        catch
            isvalid=0;
            strmessage=sprintf('\n ERROR: Invalid bus name specified for %s port: %d',portIOString,k);
            return
        end
    end
end

function[isValidBus]=validateBusName(dtString,model)
    isValidBus=1;

    busDTStr='Bus:';
    dtString=strtrim(strrep(dtString,busDTStr,''));
    isSlObjDefined=existsInGlobalScope(model,dtString);
    slObj=[];
    if isSlObjDefined==1
        slObj=evalinGlobalScope(model,dtString);
    end
    if~(isSlObjDefined&&isa(slObj,'Simulink.Bus'))
        isValidBus=0;
    end
end

function[isvalid,strmessage]=checkForNestedArrayOfBuses(dtString,dtWidth,portIOString,portNumber,portBusName,isvalid,strmessage,model)

    busDTStr='Bus:';
    dtString=strrep(dtString,' ','');
    indicesBus=strfind(dtString,busDTStr);
    if(~isempty(indicesBus)&&indicesBus(1)==1)
        isvalid=validateBusName(dtString,model);
        if~(isvalid)
            strmessage=sprintf('\n ERROR: Invalid bus name %s specified for %s port: %d. Nested bus object %s does not exist in workspace.',portBusName,portIOString,portNumber,dtString);
            return;
        elseif~slfeature('slBusArraySFBuilder')
            if(dtWidth~=1)
                isvalid=0;
                strmessage=sprintf('\n ERROR: Invalid bus name %s specified for %s port: %d. Nested bus object %s is specified for an element with non-scalar dimensions. S-function Builder does not support nested arrays of buses.',portBusName,portIOString,portNumber,dtString);
                return;
            else
                dtString=strtrim(strrep(dtString,busDTStr,''));
                slObj=evalinGlobalScope(model,dtString);
                for k=1:length(slObj.Elements)
                    [isvalid,strmessage]=checkForNestedArrayOfBuses(slObj.Elements(k).DataType,prod(slObj.Elements(k).Dimensions),portIOString,portNumber,portBusName,isvalid,strmessage,model);
                    if(~isvalid)
                        return;
                    end
                end
            end
        end
    end
end

function[isvalid,strmessage]=checkForUnsupportedDataTypes(dtString,busElName,portBusName,portIOString,portNumber,isvalid,strmessage,model)
    builtinDataTypeNames=slprivate('sfbGetBuiltinDataTypeNames');

    if~ismember(dtString,builtinDataTypeNames)&&~findFixdt(dtString)&&~isMultiWord(dtString)


        EnumDTStr='Enum:';
        indices=strfind(dtString,EnumDTStr);
        if(~isempty(indices)&&indices(1)==1)
            return;
        end


        isValidBus=validateBusName(dtString,model);
        BusDTStr='Bus:';
        if(isValidBus)
            dtString=strtrim(strrep(dtString,BusDTStr,''));
            slObj=evalinGlobalScope(model,dtString);
            for k=1:length(slObj.Elements)
                [isvalid,strmessage]=checkForUnsupportedDataTypes(slObj.Elements(k).DataType,slObj.Elements(k).Name,portBusName,portIOString,portNumber,isvalid,strmessage,model);
                if(~isvalid)
                    return;
                end
            end
        else
            isvalid=0;
            strmessage=sprintf('\n ERROR: Invalid bus %s specified for %s port: %d. The element ''%s'' specifies data type %s, which is unsupported. S-Function Builder supports bus elements of the following data types: %s, single word fxdt, enumerated, bus.',portBusName,portIOString,portNumber,busElName,dtString,strjoin(builtinDataTypeNames,', '));
        end
    else


        if isMultiWord(dtString)
            isvalid=0;
            strmessage=sprintf('\n ERROR: Invalid bus %s specified for %s port: %d. The element ''%s'' specifies data type multiword %s, which is unsupported. S-Function Builder supports bus elements of the following data types: %s, single word fxdt, enumerated, bus.',portBusName,portIOString,portNumber,busElName,dtString,strjoin(builtinDataTypeNames,', '));
        end
    end
end



function res=findFixdt(dtype)

    isBus=false;
    isEnum=false;

    busDTStr='Bus:';
    dtype=strrep(dtype,' ','');
    indicesBus=findstr(dtype,busDTStr);
    if(~isempty(indicesBus)&&indicesBus(1)==1)
        isBus=true;
    end

    EnumDTStr='Enum:';
    indices=findstr(dtype,EnumDTStr);
    if(~isempty(indices))&&(indices(1)==1)
        isEnum=true;
    end

    res=false;
    if~isEnum&&~isBus
        idx=findstr(dtype,'fixdt');

        if~isempty(idx)
            res=true;
        end
    else
        res=false;
    end
end



function res=isMultiWord(dtype)
    res=false;
    if findFixdt(dtype)
        argCell=regexp(dtype(length('fixdt')+2:end-1),',','split');
        if str2double(argCell{2})>64
            res=true;
        end
    end
end


function[portStruct,isvalid,strmessage]=checkPortDims(portStruct,portIOString)
    isvalid=1;
    strmessage='';
    for k=1:length(portStruct.Name)

        Dims=portStruct.Dimensions{k};
        if(Dims(1)=='[')
            Dims=strrep(Dims,'[','');
        end
        if(Dims(end)==']')
            Dims=strrep(Dims,']','');
        end


        Dims=strrep(Dims,'DYNAMICALLY_SIZED','-1');
        if k==1
            if~loc_isdigit(Dims)
                strmessage=sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s',portIOString,portStruct.Name{k},Dims);
                isvalid=0;
                return
            end
        else
            if~loc_isdigit(Dims,1)
                strmessage=sprintf('\n ERROR: Invalid setting for the %s port dimensions ''%s'' : %s',portIOString,portStruct.Name{k},Dims);
                isvalid=0;
                return
            end
        end
        portStruct.Dimensions{k}=['[',Dims,']'];
    end
end

function out=loc_isdigit(in,validateMinusOne)
    if nargin==1
        validateMinusOne='';
    end
    if isempty(in)
        out=0;
        return
    else
        if findstr(in,'.')
            out=0;
        else
            idx=findstr(in,'-');
            out=1;
            if(isempty(str2num(in))||any(str2num(in)==Inf))
                out=0;
                return
            end
            if(numel(str2num(in))>2&&any(str2num(in)==-1))

                out=0;
                return
            end
            if~isempty(idx)&&~isempty(validateMinusOne)
                out=0;
                return
            end
            for i=1:numel(idx)
                if idx(i)<numel(in)



                    if isspace(in(idx(i)+1))||~isequal(abs(in(idx(i)+1)),abs('1'))
                        out=0;
                    end
                end
            end
        end
    end
end

function[SampleTime,ad,isValid,errorMessage]=setSampleTime(ad)

    isValid=1;
    errorMessage='';

    SampleTime=ad.SfunWizardData.SampleTime;

    if~isfield(ad.SfunWizardData,'SampleMode')
        return
    else
        switch ad.SfunWizardData.SampleMode
        case 'Inherited'
            SampleTime='INHERITED_SAMPLE_TIME';
            ad.SfunWizardData.SampleTime=SampleTime;
            return
        case 'Continuous'
            SampleTime='0';
            ad.SfunWizardData.SampleTime=SampleTime;
            return
        case 'Discrete'
            if(isempty(SampleTime))
                isValid=0;
                errorMessage=DAStudio.message('Simulink:blocks:SFunctionBuilderInvalidSampleTime');
                return
            end
        otherwise
            return
        end
    end

    ad.SfunWizardData.SampleTime=SampleTime;

    SampleTime=strrep(SampleTime,']','');
    SampleTime=strrep(SampleTime,'[','');
    warnMsg=sprintf(['Warning: You have specified an invalid sample time.\n\tSetting'...
    ,' the S-function sample time to be inherited']);
    warnMsg1=sprintf(['Warning: Sample Time was not specified.\n\tSetting'...
    ,' the S-function sample time to be inherited']);

    try
        if(str2double(SampleTime)>=0)
            return
        elseif(findstr(SampleTime,'UserDefined'))
            SampleTime='INHERITED_SAMPLE_TIME';
            disp(warnMsg1);
            return
        elseif isempty(str2double(SampleTime))

            if(strcmp(SampleTime,'Inherited'))
                SampleTime='INHERITED_SAMPLE_TIME';
            end
            if(strcmp(SampleTime,'Continuous'))
                SampleTime='0';
            end
            return
        elseif~(isempty(str2double(SampleTime)))
            if(str2double(SampleTime)==-1)
                SampleTime='INHERITED_SAMPLE_TIME';
            elseif(str2double(SampleTime)<-1)
                disp(warnMsg);
                SampleTime='INHERITED_SAMPLE_TIME';
            end
        end
    catch
        disp(warnMsg);
        SampleTime='INHERITED_SAMPLE_TIME';
    end
end



