function makeOutput(this,prm,e,LUTidx)




    osig=prm.OutputSignals;


    if~isempty(prm.mapping)
        idxdt=prm.hN.getType('FixedPoint',...
        'Signed',0,...
        'WordLength',log2((prm.M)),...
        'FractionLength',0);

        LUTout=prm.hN.addSignal2('Name','QAMdemodDecoded','Type',idxdt);
        data=fi(prm.mapping,0,ceil(log2(double(max(prm.mapping)))),0);
        e.LUT('Inputs',LUTidx,'Outputs',LUTout,'TableData',data);

    else
        LUTout=LUTidx;
    end


    if isa(osig.Type,'hdlcoder.tp_array')
        e.commsIntegerToBitVector(LUTout,osig);
    else
        e.DataTypeConverter('Inputs',LUTout,'Outputs',osig,...
        'RoundingMethod','Floor',...
        'OverflowAction','Wrap');
    end
