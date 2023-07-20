function dtiComp=getDiscreteTimeIntegratorComp(hParentN,hInSignals,hOutSignals,...
    dtiInfo,nfpOptions)
















    if nargin<5
        nfpOptions.Latency=int8(0);
        nfpOptions.MantMul=int8(0);
        nfpOptions.Denormals=int8(0);
    end


    int_in=hInSignals(1);
    if~strcmpi(dtiInfo.externalReset,'none')
        reset_in=hInSignals(2);
    else
        reset_in=[];
    end

    int_out=hOutSignals(1);
    if length(hOutSignals)>1
        sat_out=hOutSignals(2);
        dtiInfo.showSatPort=true;
    else
        sat_out=[];
        dtiInfo.showSatPort=false;
    end


    hInType=int_in.Type;
    hOutType=int_out.Type;


    integratorMethod=dtiInfo.intMethod;

    edgeSens=strcmpi(dtiInfo.externalReset,'rising')||...
    strcmpi(dtiInfo.externalReset,'falling');
    if edgeSens


        hN=pirelab.createNewNetwork(...
        'Network',hParentN,...
        'Name',dtiInfo.compName,...
        'InportSignals',hInSignals,...
        'OutportSignals',hOutSignals);
        hN.setFlattenHierarchy('on');


        int_in=hN.PirInputSignals(1);
        if length(hInSignals)>1
            reset_in=hN.PirInputSignals(2);
        end
        hN.PirOutputSignals(1).SimulinkRate=int_out.SimulinkRate;
        int_out=hN.PirOutputSignals(1);
        if length(hOutSignals)>1
            hN.PirOutputSignals(2).SimulinkRate=sat_out.SimulinkRate;
            sat_out=hN.PirOutputSignals(2);
        end


        hS=hN.addSignal(hInType,[int_in.Name,'_dlyBalance']);
        pirelab.getIntDelayComp(hN,int_in,hS,1);
        int_in=hS;


        if strcmpi(dtiInfo.externalReset,'rising')
            reset_in=pirelab.createRisingEdgeTrigger(hN,reset_in);
        else
            reset_in=pirelab.createFallingEdgeTrigger(hN,reset_in);
        end
    else
        hN=hParentN;
    end




    hOutBaseType=hOutType.getLeafType;
    hInBaseType=hInType.getLeafType;

    if hOutBaseType.isFloatType
        tOutScaleType=hOutBaseType;
        tInScaleType=hInBaseType;
    else
        OutSigned=hOutBaseType.Signed;
        OutWordLength=hOutBaseType.WordLength;
        tOutScaleType=pir_fixpt_t(OutSigned,OutWordLength,0);

        InSigned=hInBaseType.Signed;
        InWordLength=hInBaseType.WordLength;
        tInScaleType=pir_fixpt_t(InSigned,InWordLength,0);
    end


    if hInType.isArrayType
        dimLenIn=hInType.getDimensions;
        hGainType=pirelab.getPirVectorType(tOutScaleType,dimLenIn);
        hInDTCType=pirelab.getPirVectorType(tInScaleType,dimLenIn);
        u_vec=int_in;
    else
        if hOutType.isArrayType
            dimLenOut=hOutType.getDimensions;
            hInSigs=repmat(int_in,dimLenOut,1);
            inVecType=pirelab.getPirVectorType(hInType,dimLenOut);
            u_vec=hN.addSignal(inVecType,sprintf('%s_u_vec',dtiInfo.compName));
            pirelab.getMuxComp(hN,hInSigs,u_vec);

            hGainType=pirelab.getPirVectorType(tOutScaleType,dimLenOut);
            hInDTCType=pirelab.getPirVectorType(tInScaleType,dimLenOut);
        else
            u_vec=int_in;

            hGainType=tOutScaleType;
            hInDTCType=tInScaleType;
        end
    end


    u_indtc=hN.addSignal(hInDTCType,sprintf('%s_indtc',dtiInfo.compName));
    pirelab.getDTCComp(hN,u_vec,u_indtc,dtiInfo.rndMode,dtiInfo.satMode,'SI',...
    'dtc','','-1',nfpOptions);










    if dtiInfo.isGainValueEqualToOne
        u_gain=u_vec;
    else
        u_gain=hN.addSignal(hGainType,sprintf('%s_u_gain',dtiInfo.compName));
        pirelab.getGainComp(hN,u_indtc,u_gain,dtiInfo.gainValue,1,0,...
        dtiInfo.rndMode,dtiInfo.satMode,'gain',int8(0),'',[],...
        false,nfpOptions);
    end


    if hOutType.isEqual(hGainType)
        u_dtc=u_gain;
    else
        u_dtc=hN.addSignal(hOutType,sprintf('%s_u_dtc',dtiInfo.compName));
        pirelab.getDTCComp(hN,u_gain,u_dtc,dtiInfo.rndMode,dtiInfo.satMode,...
        'SI','dtc','','-1',nfpOptions);
    end



    if strcmp(integratorMethod,'Integration: Forward Euler')||...
        strcmp(integratorMethod,'Accumulation: Forward Euler')




        u_add=hN.addSignal(hOutType,sprintf('%s_u_add',dtiInfo.compName));
        pirelab.getAddComp(hN,[int_out,u_dtc],u_add,dtiInfo.rndMode,...
        dtiInfo.satMode,'adder',hOutType,'++','',-1,nfpOptions);


        u_sat=hN.addSignal(hOutType,sprintf('%s_u_sat',dtiInfo.compName));
        addSaturationLogic(hN,u_add,u_sat,dtiInfo);


        x_reg=hN.addSignal(hOutType,sprintf('%s_x_reg',dtiInfo.compName));
        if strcmpi(dtiInfo.externalReset,'none')
            dtiComp=pirelab.getIntDelayComp(hN,u_sat,x_reg,1,...
            sprintf('%s_reg',dtiInfo.compName),dtiInfo.initC,edgeSens);
        else

            dtiComp=pirelab.getUnitDelayResettableComp(hN,u_sat,x_reg,...
            reset_in,sprintf('%s_reg',dtiInfo.compName),dtiInfo.initC);

            x_reg_out=hN.addSignal(hOutType,sprintf('%s_x_reg_out',dtiInfo.compName));




            init_val=hN.addSignal(hOutType,sprintf('%s_ic',dtiInfo.compName));
            init_val.SimulinkRate=int_in.SimulinkRate;
            pirelab.getConstComp(hN,init_val,...
            double(dtiInfo.initC),...
            sprintf('%s_x_ic',dtiInfo.compName));



            if edgeSens
                pirelab.getWireComp(hN,x_reg,x_reg_out);
            else
                pirelab.getSwitchComp(hN,[x_reg,init_val],x_reg_out,reset_in);
            end

            x_reg=x_reg_out;
        end


        if dtiInfo.showSatPort
            addSaturationLogic(hN,x_reg,[int_out,sat_out],dtiInfo);
        else
            pirelab.getWireComp(hN,x_reg,int_out);
        end

    elseif strcmp(integratorMethod,'Integration: Backward Euler')||...
        strcmp(integratorMethod,'Accumulation: Backward Euler')




        x_reg=hN.addSignal(hOutType,sprintf('%s_x_reg',dtiInfo.compName));
        u_add=hN.addSignal(hOutType,sprintf('%s_u_add',dtiInfo.compName));
        pirelab.getAddComp(hN,[x_reg,u_dtc],u_add,dtiInfo.rndMode,...
        dtiInfo.satMode,'adder',hOutType);


        init_val=hN.addSignal(hOutType,sprintf('%s_ic',dtiInfo.compName));
        init_val.SimulinkRate=int_in.SimulinkRate;
        pirelab.getConstComp(hN,init_val,double(dtiInfo.initC),...
        sprintf('%s_x_ic',dtiInfo.compName));

        y_outinit=addOutputInitialConditionLogic(hN,u_add,init_val,...
        reset_in,dtiInfo);


        addSaturationLogic(hN,y_outinit,[int_out,sat_out],dtiInfo);

        if strcmpi(dtiInfo.externalReset,'none')||...
            strcmpi(dtiInfo.initCMode,'Output')









            dtiComp=pirelab.getIntDelayComp(hN,int_out,x_reg,1,...
            sprintf('%s_reg',dtiInfo.compName),dtiInfo.initC,edgeSens);
        else



            x_reg_out=hN.addSignal(hOutType,sprintf('%s_x_reg_out',dtiInfo.compName));




            dtiComp=pirelab.getUnitDelayResettableComp(hN,int_out,x_reg_out,...
            reset_in,sprintf('%s_reg',dtiInfo.compName),dtiInfo.initC);


            if edgeSens
                pirelab.getWireComp(hN,x_reg_out,x_reg);
            else
                pirelab.getSwitchComp(hN,[x_reg_out,init_val],x_reg,reset_in);
            end
        end

    elseif strcmp(integratorMethod,'Integration: Trapezoidal')||...
        strcmp(integratorMethod,'Accumulation: Trapezoidal')





        x_reg=hN.addSignal(hOutType,sprintf('%s_x_reg',dtiInfo.compName));
        x_add=hN.addSignal(hOutType,sprintf('%s_x_add',dtiInfo.compName));
        pirelab.getAddComp(hN,[x_reg,u_dtc],x_add,dtiInfo.rndMode,dtiInfo.satMode);


        init_val=hN.addSignal(hOutType,sprintf('%s_ic',dtiInfo.compName));
        init_val.SimulinkRate=int_in.SimulinkRate;
        pirelab.getConstComp(hN,init_val,double(dtiInfo.initC),...
        sprintf('%s_x_ic',dtiInfo.compName));

        y_outinit=addOutputInitialConditionLogic(hN,x_add,init_val,...
        reset_in,dtiInfo);


        addSaturationLogic(hN,y_outinit,[int_out,sat_out],dtiInfo);


        y_add=hN.addSignal(hOutType,sprintf('%s_y_add',dtiInfo.compName));
        pirelab.getAddComp(hN,[int_out,u_dtc],y_add,dtiInfo.rndMode,...
        dtiInfo.satMode);


        y_sat=hN.addSignal(hOutType,sprintf('%s_y_sat',dtiInfo.compName));
        addSaturationLogic(hN,y_add,y_sat,dtiInfo);

        if strcmpi(dtiInfo.externalReset,'none')||...
            strcmpi(dtiInfo.initCMode,'Output')









            dtiComp=pirelab.getIntDelayComp(hN,y_sat,x_reg,1,...
            sprintf('%s_reg',dtiInfo.compName),dtiInfo.initC,edgeSens);
        else



            x_reg_out=hN.addSignal(hOutType,sprintf('%s_x_reg_out',dtiInfo.compName));




            dtiComp=pirelab.getUnitDelayResettableComp(hN,y_sat,x_reg_out,...
            reset_in,sprintf('%s_reg',dtiInfo.compName),dtiInfo.initC);


            if edgeSens
                pirelab.getWireComp(hN,x_reg_out,x_reg);
            else
                pirelab.getSwitchComp(hN,[x_reg_out,init_val],x_reg,reset_in);
            end
        end
    end

    if edgeSens
        dtiComp=pirelab.instantiateNetwork(hParentN,hN,hInSignals,...
        hOutSignals,hN.Name);
    end
end


function y_outinit=addOutputInitialConditionLogic(hN,hOriginalOut,...
    hInitialState,hResetIn,dtiInfo)









    if strcmpi(dtiInfo.initCMode,'Output')


        ufix1Type=pir_ufixpt_t(1,0);
        const_one=hN.addSignal(ufix1Type,...
        sprintf('%s_const_one',dtiInfo.compName));
        pirelab.getConstComp(hN,const_one,1);
        const_one.SimulinkRate=hOriginalOut.SimulinkRate;
        initc_sel=hN.addSignal(ufix1Type,...
        sprintf('%s_initc_sel',dtiInfo.compName));
        pirelab.getUnitDelayComp(hN,const_one,initc_sel,...
        sprintf('%s_initc_sel_reg',dtiInfo.compName));

        y_outinit=hN.addSignal(hOriginalOut.Type,...
        sprintf('%s_y_outinit',dtiInfo.compName));



        if~strcmpi(dtiInfo.externalReset,'none')





            hResetInReg=hN.addSignal(ufix1Type,...
            sprintf('%s_reset_reg',dtiInfo.compName));
            pirelab.getUnitDelayComp(hN,hResetIn,hResetInReg,...
            sprintf('%s_reset_reg',dtiInfo.compName),0);

            initc_sel_inv=hN.addSignal(ufix1Type,...
            sprintf('%s_initc_sel_reg_inv',dtiInfo.compName));
            pirelab.getLogicComp(hN,initc_sel,initc_sel_inv,...
            'not');


            initc_sel_inv_reset=hN.addSignal(ufix1Type,...
            sprintf('%s_initc_sel_reset',dtiInfo.compName));
            pirelab.getLogicComp(hN,[initc_sel_inv,hResetIn,hResetInReg],...
            initc_sel_inv_reset,'or');



            pirelab.getSwitchComp(hN,[hOriginalOut,hInitialState],y_outinit,...
            initc_sel_inv_reset);
        else


            pirelab.getSwitchComp(hN,[hInitialState,hOriginalOut],y_outinit,...
            initc_sel);
        end
    else
        y_outinit=hOriginalOut;
    end
end

function addSaturationLogic(hN,hInSignals,hOutSignals,dtiInfo)














    if dtiInfo.applySatLimit
        hInType=hInSignals(1).Type;
        u_limit_t=pirelab.getTypeInfoAsFi(hInType,'Nearest','Saturate',...
        dtiInfo.upperSatLimit,false);
        l_limit_t=pirelab.getTypeInfoAsFi(hInType,'Nearest','Saturate',...
        dtiInfo.lowerSatLimit,false);
        pirelab.getSaturateComp(hN,hInSignals,hOutSignals,...
        l_limit_t,u_limit_t,dtiInfo.rndMode,...
        sprintf('%s_saturate',dtiInfo.compName));
    else
        pirelab.getWireComp(hN,hInSignals,hOutSignals(1));
        if dtiInfo.showSatPort&&length(hOutSignals)>1
            sat_out=hOutSignals(2);
            hSatType=sat_out.Type;
            const_zero=hN.addSignal(hSatType,sprintf('%s_const_zero',...
            dtiInfo.compName));
            pirelab.getConstComp(hN,const_zero,0);
            const_zero.SimulinkRate=hInSignals(1).SimulinkRate;
            pirelab.getWireComp(hN,const_zero,sat_out);
        end
    end
end


