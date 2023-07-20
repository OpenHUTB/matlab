function rtComp=getRateTransitionComp(hN,hInSignals,hOutSignals,...
    outputRate,initVal,extraDelayAvl,compName,integrity,deterministic)






















    if nargin<7
        compName='rate_transition';
    end

    if nargin<6||isempty(extraDelayAvl)
        extraDelayAvl=false;
    end

    if nargin<5||isempty(initVal)
        initVal=pirelab.getTypeInfoAsFi(hInSignals.Type);
    end


    inputRate=hInSignals.SimulinkRate;
    anyZero=any([inputRate,outputRate]==0);
    anyInf=any([inputRate,outputRate]==Inf);
    if anyZero||anyInf
        error(message('hdlcommon:hdlcommon:InvalidRates'));
    end

    if inputRate==outputRate

        rtComp=pirelab.getWireComp(hN,hInSignals,hOutSignals,compName);

    elseif inputRate>outputRate




        need_dvalid=length(hOutSignals)>1;
        if need_dvalid
            [~,hDvalid]=hN.getClockBundle(hOutSignals,1,int32(outputRate/inputRate),1);
            pirelab.getWireComp(hN,hDvalid,hOutSignals(2));
        end

        if~integrity&&~deterministic

            rtComp=pirelab.getWireComp(hN,hInSignals,hOutSignals(1),compName);
        else


            [clock,hEnb,reset]=hN.getClockBundle(hInSignals,1,1,0);
            rtComp=pireml.getUnitDelayComp(hN,hInSignals,hOutSignals(1),compName,initVal);
            rtComp.connectClockBundle(clock,hEnb,reset);
        end
    else


        downFactor=int32(outputRate/inputRate);
        [~,hByPassEnb]=hN.getClockBundle(hInSignals,1,downFactor,1);

        [clock,~,reset]=hN.getClockBundle(hInSignals,1,1,0);

        if~integrity&&~deterministic




            rtComp=pirelab.getWireComp(hN,hInSignals,hOutSignals(1),compName);
        elseif~extraDelayAvl


            rtComp=pireml.getBypassRegisterComp(hN,hInSignals,hOutSignals,hByPassEnb,sprintf('%s_bypass',compName),initVal);
        else
            rtComp=pireml.getUnitDelayComp(hN,hInSignals,hOutSignals,sprintf('%s_output',compName),initVal);

            rtComp.connectClockBundle(clock,hByPassEnb,reset);
        end

    end


    hOutSignals.SimulinkRate=outputRate;


