function baseDataT=getPirTypeForTBData(~,baseDataT)


    if isa(baseDataT,'hdlcoder.tp_sfixpt')||...
        isa(baseDataT,'hdlcoder.tp_ufixpt')||...
        isa(baseDataT,'hdlcoder.tp_signed')||...
        isa(baseDataT,'hdlcoder.tp_unsigned')
        baseDataT=pir_logic_t(baseDataT.WordLength);
    elseif isa(baseDataT,'hdlcoder.tp_boolean')
        baseDataT=pir_logic_t(1);
    end
end
