function CORDICnet=elabCORDICIteration(this,topNet,sigInfo,dataRate,blockInfo)





    hTm=sigInfo.absdatatype;

    shiftT=sigInfo.shiftT;
    booleanType=pir_boolean_t();
    outMode=blockInfo.outMode;



    if outMode(1)
        inportnames={'xin','yin','idx'};
        inporttypes=[hTm,hTm,shiftT];
        inportrates=[dataRate,dataRate,dataRate];
        outportnames={'xout','yout'};
        outporttypes=[hTm,hTm];
    else
        lutT=sigInfo.lutT;
        zType=sigInfo.zType;
        inportnames={'xin','yin','zin','lut_value','idx'};
        inportrates=[dataRate,dataRate,dataRate,dataRate,dataRate];
        inporttypes=[hTm,hTm,zType,lutT,shiftT];
        outportnames={'xout','yout','zout'};
        outporttypes=[hTm,hTm,zType];
    end

    CORDICnet=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','CordicKernelMag',...
    'InportNames',inportnames,...
    'InportTypes',inporttypes,...
    'InportRates',inportrates,...
    'OutportNames',outportnames,...
    'OutportTypes',outporttypes...
    );






    CordicIterationInput=CORDICnet.PirInputSignals;
    CordicIterationOutput=CORDICnet.PirOutputSignals;
    x0=CordicIterationInput(1);
    y0=CordicIterationInput(2);
    if outMode(1)
        idx=CordicIterationInput(3);
    else
        z0=CordicIterationInput(3);
        lut_in=CordicIterationInput(4);
        idx=CordicIterationInput(5);
    end

    x1=CORDICnet.addSignal2('Type',hTm,'Name','xShifted');
    y1=CORDICnet.addSignal2('Type',hTm,'Name','yShifted');

    x1.SimulinkRate=CordicIterationInput(1).SimulinkRate;
    y1.SimulinkRate=CordicIterationInput(2).SimulinkRate;

    ylesszero=CORDICnet.addSignal2('Type',booleanType,'Name','yLessThanZero');
    ylesszero.SimulinkRate=CordicIterationInput(2).SimulinkRate;






    pirelab.getCompareToValueComp(CORDICnet,y0,ylesszero,'<',0);

    pirelab.getDynamicBitShiftComp(CORDICnet,...
    [x0,idx],...
    x1,...
    'right','dynamic_shift');
    pirelab.getDynamicBitShiftComp(CORDICnet,...
    [y0,idx],...
    y1,...
    'right','dynamic_shift');

    xout1=CORDICnet.addSignal2('Type',hTm,'Name','xout1');
    xout2=CORDICnet.addSignal2('Type',hTm,'Name','xout2');
    yout1=CORDICnet.addSignal2('Type',hTm,'Name','yout1');
    yout2=CORDICnet.addSignal2('Type',hTm,'Name','yout2');



    pirelab.getAddComp(CORDICnet,[x0,y1],xout1,'Floor','Wrap','XSubtractor',hTm,'+-');
    pirelab.getAddComp(CORDICnet,[y0,x1],yout1,'Floor','Wrap','YAdder');

    pirelab.getAddComp(CORDICnet,[x0,y1],xout2,'Floor','Wrap','XAdder');

    pirelab.getAddComp(CORDICnet,[y0,x1],yout2,'Floor','Wrap','YSub',hTm,'+-');

    pirelab.getSwitchComp(CORDICnet,[xout1,xout2],CordicIterationOutput(1),ylesszero,'MuxX','~=',0);
    pirelab.getSwitchComp(CORDICnet,[yout1,yout2],CordicIterationOutput(2),ylesszero,'MuxY','~=',0);

    if~outMode(1)
        zout1=CORDICnet.addSignal2('Type',zType,'Name','zout1');
        zout2=CORDICnet.addSignal2('Type',zType,'Name','zout2');

        pirelab.getAddComp(CORDICnet,[z0,lut_in],zout1,'Floor','Wrap','ZSub',zType,'+-');
        pirelab.getAddComp(CORDICnet,[z0,lut_in],zout2,'Floor','Wrap','ZAdder');
        pirelab.getSwitchComp(CORDICnet,[zout1,zout2],CordicIterationOutput(3),ylesszero,'MuxZ','~=',0);
    end
end
