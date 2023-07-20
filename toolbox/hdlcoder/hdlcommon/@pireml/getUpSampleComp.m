function usComp=getUpSampleComp(hN,hInSignal,hOutSignal,upSampleFactor,sampleOffset,initVal,compName,desc,slHandle)













    if nargin<9
        slHandle=-1;
    end

    if nargin<8
        desc='';
    end

    if nargin<7
        compName='us';
    end




    if nargin<6
        initVal=pirelab.getTypeInfoAsFi(hInSignal.Type);
    end

    if upSampleFactor==1
        usComp=pirelab.getWireComp(hN,hInSignal,hOutSignal);
    else

        if hOutSignal.SimulinkRate<=0
            hOutSignal.SimulinkRate=hInSignal.SimulinkRate/double(upSampleFactor);
        end


        hN.getClockBundle(hOutSignal,1,upSampleFactor,0);







        if upSampleFactor>2

            usComp=elabStandardUpsample(hN,hInSignal,hOutSignal,...
            upSampleFactor,sampleOffset,compName);

        else

            usComp=elabUpsampleArch3(hN,hInSignal,hOutSignal,...
            upSampleFactor,sampleOffset,compName);
        end
    end


    opComment=sprintf(' %s: Upsample by %d, Sample offset %d ',...
    compName,upSampleFactor,sampleOffset);
    usComp.addComment(opComment);
end


function usComp=elabStandardUpsample(hN,hInSignal,hOutSignal,...
    upSampleFactor,sampleOffset,compName)



    [usComp,muxout]=elabStandardMuxLogic(hN,hInSignal,hOutSignal,upSampleFactor,compName);


    bypassout=hN.addSignal(hInSignal.Type,sprintf('%s_bypassout',compName));
    bypassout.SimulinkRate=hOutSignal.SimulinkRate;

    [~,~,~]=hN.getClockBundle(hOutSignal,1,1,0);
    [~,hByPassEnb,~]=hN.getClockBundle(hOutSignal,1,1,1);
    bypassComp=pireml.getBypassRegisterComp(hN,muxout,bypassout,hByPassEnb,sprintf('%s_bypass',compName));
    bypassComp.addComment('Upsample bypass register');


    elabOptionalIntegerDelay(hN,hOutSignal,bypassout,sampleOffset,compName);

end



function usComp=elabUpsampleArch3(hN,hInSignal,hOutSignal,...
    upSampleFactor,sampleOffset,compName)



    [~,hcntEnb,~]=hN.getClockBundle(hOutSignal,1,1,0);


    if sampleOffset==1
        countInit=0;
    else
        countInit=1;
    end
    outputRate=hInSignal.SimulinkRate/upSampleFactor;
    ufix1Type=pir_ufixpt_t(1,0);
    muxsel=hN.addSignal(ufix1Type,sprintf('%s_muxsel',compName));
    countName=sprintf('%s_cnt',compName);
    usComp=pireml.getCounterFreeRunningComp(hN,muxsel,outputRate,countName,countInit,hcntEnb);


    constZero=hN.addSignal(hInSignal.Type,sprintf('%s_zero',compName));
    pireml.getConstComp(hN,constZero,0);


    pireml.getSwitchComp(hN,[muxsel,hInSignal,constZero],hOutSignal,...
    0,'floor','wrap',sprintf('%s_mux',compName));

end



function[usComp,muxout]=elabStandardMuxLogic(hN,hInSignal,hOutSignal,upSampleFactor,compName)


    [~,muxsel]=hN.getClockBundle(hOutSignal,1,upSampleFactor,1);


    constZero=hN.addSignal(hInSignal.Type,sprintf('%s_zero',compName));
    usComp=pireml.getConstComp(hN,constZero,0);


    muxout=hN.addSignal(hInSignal.Type,sprintf('%s_muxout',compName));
    pireml.getSwitchComp(hN,[muxsel,hInSignal,constZero],muxout,...
    0,'floor','wrap',sprintf('%s_mux',compName));

end


function elabOptionalIntegerDelay(hN,hOutSignal,delayIn,sampleOffset,compName)


    if sampleOffset>0
        [~,outenb,~]=hN.getClockBundle(hOutSignal,1,1,0);


        hN.setHasSLHWFriendlySemantics(true);
        outIntDelayComp=pireml.getIntDelayEnabledComp(hN,delayIn,hOutSignal,...
        sampleOffset,sprintf('%s_int_delay',compName),'','',outenb);
        outIntDelayComp.addComment('Upsample sample offset register');


    else
        pirelab.getWireComp(hN,delayIn,hOutSignal);
    end

end


