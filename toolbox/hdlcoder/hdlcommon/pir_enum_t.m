function enumType=pir_enum_t(typeName,enumStrings,enumValues,defaultOrdinal)













    narginchk(4,4);
    pir_udd;


    numVals=numel(enumValues);
    etf=hdlcoder.tpc_enum_factory(typeName,defaultOrdinal);
    for ii=1:numVals
        etf.addEnum(enumStrings{ii},enumValues(ii));
    end
    enumType=hdlcoder.tp_enum(etf);
end
