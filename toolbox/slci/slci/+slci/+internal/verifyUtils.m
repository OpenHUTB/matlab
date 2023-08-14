


function ret=verifyUtils(actualFile,baselineFile,mdl)


    try
        actualC=fileread(actualFile);
    catch
        ret=2;
        return;
    end

    try
        baselineC=fileread(baselineFile);
    catch
        ret=2;
        return
    end


    baselineC=updateFileDataReplacementTable(mdl,baselineC);


    baselineC=updateFileMaxMinIdentifier(mdl,baselineC);


    ret=slci.internal.locCmpC(actualC,baselineC,0);

end



function out=updateFileDataReplacementTable(mdl,baselineC);
    out=baselineC;

    replacedTypes=slci.internal.buildDataTypeReplacement(mdl);


    assert(isstruct(replacedTypes));

    for i=1:numel(replacedTypes)
        orig_t=replacedTypes(i).CodeGenType;
        rpl_t=replacedTypes(i).ReplTypeName;
        if~isempty(rpl_t)
            out=regexprep(out,orig_t,rpl_t);
        end
    end
end


function out=updateFileMaxMinIdentifier(mdl,in)

    out=in;

    paramId={'BooleanFalseId','BooleanTrueId',...
    'MaxIdInt64','MaxIdInt16','MaxIdInt32','MaxIdInt8',...
    'MaxIdUint64','MaxIdUint16','MaxIdUint32','MaxIdUint8',...
    'MinIdInt64','MinIdInt16','MinIdInt32','MinIdInt8',...
    };

    defaultValues={'false','true',...
    'MAX_int64_T','MAX_int16_T','MAX_int32_T','MAX_int8_T',...
    'MAX_uint64_T','MAX_uint16_T','MAX_uint32_T','MAX_uint8_T',...
    'MIN_int64_T','MIN_int16_T','MIN_int32_T','MIN_int8_T',...
    };
    assert(numel(paramId)==numel(defaultValues));
    for i=1:numel(paramId)
        value=get_param(mdl,paramId{i});
        d_value=defaultValues{i};
        if~strcmpi(value,d_value)
            out=regexprep(out,d_value,value);
        end
    end

end

