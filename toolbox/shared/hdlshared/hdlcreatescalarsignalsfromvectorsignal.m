function scalarSignals=hdlcreatescalarsignalsfromvectorsignal(hN,vecSignal)









    narginchk(2,2);

    scalarSignals=vecSignal;
    if hdlissignalvector(vecSignal)
        hT=vecSignal.Type.BaseType;
        vecSize=hdlsignalvector(vecSignal);
        for ii=1:vecSize
            scalarSignals(ii)=hN.addSignal2('Type',hT,'Name',[vecSignal.Name,'_',num2str(ii-1)]);
        end
    end

end

