function[re,im]=trivialDerotate(this,prm,e)







    binedges=[-1,1,3,5,7]*(pi/4);
    phaseBins=histc(prm.Phase,binedges);
    phaseBins(end)=[];


    isig=prm.InputSignals;
    iType=isig.Type;
    inBT=iType.BaseType;

    retmp=prm.hN.addSignal2('Name','inphase','Type',inBT);
    imtmp=prm.hN.addSignal2('Name','quadrature','Type',inBT);


    e.ComplexToRealImag('Inputs',isig,'Outputs',[retmp,imtmp]);


    if phaseBins(1)

        re=retmp;
        im=imtmp;

    elseif phaseBins(2)

        re=imtmp;
        im=invSignal(retmp,prm.hN,e);

    elseif phaseBins(3)

        re=invSignal(retmp,prm.hN,e);
        im=invSignal(imtmp,prm.hN,e);

    else

        re=invSignal(imtmp,prm.hN,e);
        im=retmp;

    end


    function xinv=invSignal(x,hN,e)


        xType=x.Type;
        xinv=hN.addSignal2('Name',[x.Name,'_inv'],'Type',xType);

        e.UnaryMinus('Inputs',x,'Outputs',xinv,...
        'RoundingMethod','Nearest',...
        'OverflowAction','Saturate');











