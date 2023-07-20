function dsComp=getDownSampleComp(hN,hInSignal,hOutSignal,downSampleFactor,...
    sampleOffset,initVal,ph0_extraDelayAvl,compName,desc,slHandle)
















    if nargin<10
        slHandle=-1;
    end

    if nargin<9
        desc='';
    end

    if nargin<8
        compName='downsample';
    end

    if nargin<7||isempty(ph0_extraDelayAvl)
        ph0_extraDelayAvl=false;
    end

    if nargin<6
        initVal=pirelab.getTypeInfoAsFi(hInSignal.Type);
    end

    if downSampleFactor==1
        dsComp=pirelab.getWireComp(hN,hInSignal,hOutSignal);
    else
        dsComp=elabStandardDownsample(hN,hInSignal,hOutSignal,...
        downSampleFactor,sampleOffset,compName,initVal,...
        ph0_extraDelayAvl);
    end

    dsComp.SimulinkHandle=slHandle;
    dsComp.addComment(desc);

end


function dsComp=elabStandardDownsample(hN,hInSignal,hOutSignal,...
    downSampleFactor,sampleOffset,compName,initVal,phase0_noBypassNeeded)

    if hOutSignal.SimulinkRate<=0
        hOutSignal.SimulinkRate=hInSignal.SimulinkRate*double(downSampleFactor);
    end


    [hBaseClock,~,hBaseReset]=hN.getClockBundle(hInSignal,1,1,0);


    [~,hByPassEnb]=hN.getClockBundle(hInSignal,...
    1,downSampleFactor,mod(sampleOffset+1,downSampleFactor));

    if sampleOffset>0
        if hdlgetparameter('clockinputs')<=1

            if(sampleOffset~=(downSampleFactor-1))



                dsRegSignal=hN.addSignal(hInSignal.Type,sprintf('%s_ds_out',compName));
                dsComp=pireml.getUnitDelayComp(hN,hInSignal,dsRegSignal,sprintf('%s_ds',compName),initVal);
                dsComp.setClockEnable(hByPassEnb);
                dsComp.addComment('Downsample register');


                [~,hOutputEnb]=hN.getClockBundle(hOutSignal,1,1,0);
                outRegComp=pireml.getUnitDelayComp(hN,dsRegSignal,hOutSignal,sprintf('%s_output',compName),initVal);
                outRegComp.setClockEnable(hOutputEnb);
                outRegComp.addComment('Downsample output register');
            else
                [~,hOutputEnb]=hN.getClockBundle(hOutSignal,1,1,0);
                outRegComp=pireml.getUnitDelayComp(hN,hInSignal,hOutSignal,sprintf('%s_output',compName),initVal);
                outRegComp.setClockEnable(hOutputEnb);
                outRegComp.addComment('Downsample output register');
                dsComp=outRegComp;
            end
        else
            bypassRegSignal=hN.addSignal(hInSignal.Type,sprintf('%s_bypass_out',compName));
            dsComp=pireml.getBypassRegisterComp(hN,hInSignal,bypassRegSignal,hByPassEnb,sprintf('%s_bypass',compName));


            [~,hOutputEnb]=hN.getClockBundle(hOutSignal,1,1,0);
            outRegComp=pireml.getUnitDelayComp(hN,bypassRegSignal,hOutSignal,sprintf('%s_output',compName),initVal);
            outRegComp.setClockEnable(hOutputEnb);
            outRegComp.addComment('Downsample output register');
        end

    elseif~phase0_noBypassNeeded

        dsComp=pireml.getBypassRegisterComp(hN,hInSignal,hOutSignal,hByPassEnb,sprintf('%s_bypass',compName));
        dsComp.addComment(sprintf(' %s: Downsample by %d, Sample offset %d \nDownsample bypass register',...
        compName,downSampleFactor,sampleOffset));

    else
        dsComp=pireml.getUnitDelayComp(hN,hInSignal,hOutSignal,sprintf('%s_output',compName),initVal);
        dsComp.connectClockBundle(hBaseClock,hByPassEnb,hBaseReset);
        dsComp.addComment(sprintf('Downsample by %d register (Sample offset %d)',downSampleFactor,sampleOffset));
    end

end


