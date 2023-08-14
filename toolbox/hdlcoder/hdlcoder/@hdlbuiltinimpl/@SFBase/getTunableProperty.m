function[TunableParamStrs,TunableParamTypes,TunableDataIds]=getTunableProperty(~,chartHandle)



    TunableParamStrs={};
    TunableParamTypes=[];
    TunableDataIds=[];
    chartID=sfprivate('block2chart',chartHandle);
    r=sfroot;
    chartUddH=r.idToHandle(chartID);
    chartParams=chartUddH.find('-isa','Stateflow.Data','Scope','Parameter');
    for ii=1:numel(chartParams)
        paramName=chartParams(ii).Name;
        TunableParamStr=hdlbuiltinimpl.EmlImplBase.getTunableParameter(chartHandle,paramName);
        if~isempty(TunableParamStr)
            if sfprivate('is_eml_chart_block',chartHandle)&&...
                ~chartParams(ii).Tunable
                error(message('hdlcoder:validate:TunableParamNotMarked',paramName));
            end
            TunableParamStrs{end+1}=TunableParamStr;%#ok<AGROW>

            sigType=chartParams(ii).CompiledType;
            isComplex=0;
            if strcmpi(chartParams(ii).ParsedInfo.Complexity,'on')
                isComplex=1;
            end
            portDims=1;
            arraySize=chartParams(ii).ParsedInfo.Array.Size;
            if~isempty(arraySize)
                portDims=arraySize;
            end

            if strcmpi(chartParams(ii).ParsedInfo.Type.Base,'structure')
                TunableParamType=getStructType(chartParams(ii).CompiledType,chartHandle);
                if isempty(TunableParamType)
                    error(message('hdlcoder:validate:SimulinkBusUsage',paramName,chartParams(ii).DataType));
                end
            else
                TunableParamType=getpirsignaltype(sigType,isComplex,portDims);
            end
            TunableParamTypes=[TunableParamTypes,TunableParamType];%#ok<AGROW>
            TunableDataIds=[TunableDataIds,chartParams(ii).Id];%#ok<AGROW>
        else
            if sfprivate('is_eml_chart_block',chartHandle)&&...
                chartParams(ii).Tunable

                error(message('hdlcoder:validate:SimulinkParamUsage',paramName,chartParams(ii).Path));
            end
        end
    end
end



function pirrecord=getStructType(baseTypeName,chartHandle)
    pirrecord=[];
    if ischar(baseTypeName)&&...
        any(arrayfun(@(z)(strcmp(z.name,baseTypeName)),evalin('base','whos')))
        obj=evalin('base',baseTypeName);
        if isa(obj,'Simulink.Bus')
            rtf=hdlcoder.tpc_rec_factory;
            rtf.setRecordName(baseTypeName);
            for ii=1:length(obj.Elements)
                elemt=obj.Elements(ii);
                name=elemt.Name;
                isComplex=strcmpi(elemt.Complexity,'complex');
                type=elemt.DataType;
                dims=elemt.Dimensions;
                if strncmpi(type,'Bus:',4)
                    signalType=getStructType(type(5:end),chartHandle);
                else
                    dtObj=slResolve(type,chartHandle);
                    if strcmpi(dtObj.DataTypeMode,'Double')
                        signalType=getpirsignaltype('double',isComplex,dims);
                    elseif strcmpi(dtObj.DataTypeMode,'Single')
                        signalType=getpirsignaltype('single',isComplex,dims);
                    else
                        [~,sltype]=hdlgettypesfromsizes(dtObj.WordLength,...
                        dtObj.FractionLength,strcmpi(dtObj.Signedness,'Signed'));
                        signalType=getpirsignaltype(sltype,isComplex,dims);
                    end
                end
                rtf.addMember(name,signalType);
            end
            pirrecord=hdlcoder.tp_record(rtf);
        end
    end
end

