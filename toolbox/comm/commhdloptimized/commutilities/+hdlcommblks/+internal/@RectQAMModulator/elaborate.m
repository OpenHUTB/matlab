function hNewC=elaborate(this,hN,hC)





    hTopNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC...
    );


    e=dsphdlshared.Elaborator('CurrentNetwork',hTopNet,...
    'PIROriginalComponent',hC,...
    'AutoCopyComments',false);

    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        prm=this.buildSysObjParams(hC,hN,sysObjHandle);
    else
        prm=this.buildBlockParams(hC,hN);
    end

    prm.hN=hTopNet;
    prm.hC=[];
    prm.InputSignals=hTopNet.PirInputSignals;
    prm.OutputSignals=hTopNet.PirOutputSignals;




    addrWL=log2(prm.M);


    addrType=prm.hN.getType('FixedPoint',...
    'Signed',0,...
    'WordLength',addrWL,...
    'FractionLength',0);






    if prm.IntegerInput
        lutAddr=prm.hN.addSignal2('Type',addrType,'Name','constellationLUTaddress');

        if addrWL<prm.InputSignals.Type.Wordlength
            e.Slicer('Inputs',prm.InputSignals,'Outputs',lutAddr,...
            'MSB',addrWL-1,'LSB',0);
        else
            e.DataTypeConverter('Inputs',prm.InputSignals,'Outputs',lutAddr,...
            'RoundingMethod','Floor','OverflowAction','Wrap');
        end

    else
        if(prm.M~=2)
            lutAddr=prm.hN.addSignal2('Type',addrType,'Name','constellationLUTaddress');


            e.BitConcat('Inputs',prm.InputSignals,'Outputs',lutAddr);
        else
            lutAddr=prm.InputSignals;
        end
    end

    e.LUT('Inputs',lutAddr,...
    'Outputs',prm.OutputSignals,...
    'TableData',complex(prm.TableDataReal,prm.TableDataImag)...
    );


    hNewC=pirelab.instantiateNetwork(hN,hTopNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);


    if~isa(hC,'hdlcoder.sysobj_comp')
        hTopNet.flattenAfterModelgen;
    end

end
