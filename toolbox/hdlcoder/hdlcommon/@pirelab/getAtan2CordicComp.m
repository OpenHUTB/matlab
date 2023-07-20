function hNewC=getAtan2CordicComp(hN,hInSignals,hOutSignals,cordicInfo,~,usePipelines,customLatency,latencyStrategy,hC_Name)




    hCoreNet=pirelab.createNewNetwork(...
    'Network',hN,...
    'Name','atan2_cordic_nw',...
    'InportNames',{'y_in','x_in'},...
    'InportTypes',[hInSignals(1).Type,hInSignals(2).Type],...
    'InportRates',[hInSignals(1).SimulinkRate,hInSignals(2).SimulinkRate],...
    'OutportNames',{'angle'},...
    'OutportTypes',hOutSignals(1).Type);
    for itr=1:length(hOutSignals)
        hCoreNet(1).PirOutputSignals(itr).SimulinkRate=hInSignals(1).SimulinkRate;
    end

    hNewC=pirelab.instantiateNetwork(hN,hCoreNet,hInSignals,hOutSignals,...
    [hC_Name,'_inst']);




    if(nargin<5)
        usePipelines=true;
    end


    hInSigs=hCoreNet.PirInputSignals;
    hOutSigs=hCoreNet.PirOutputSignals;
    y_in=hInSigs(1);
    x_in=hInSigs(2);
    angle=hOutSigs(1);
    if(y_in.Type.isArrayType||y_in.Type.isMatrix)
        [dimLen,inputType]=pirelab.getVectorTypeInfo(y_in,true);
        vectorEnable=1;
    else
        inputType=y_in.Type.BaseType;
        vectorEnable=0;
    end
    angle.SimulinkRate=hInSignals(1).SimulinkRate;



    cordicInfo=initialize_parameters(cordicInfo,inputType);

    totalPipelinestages=cordicInfo.iterNum+3;
    pipelinestageArray=customPipelineStages(totalPipelinestages,customLatency,latencyStrategy);



    inputWL=inputType.WordLength;
    intermWL=inputWL+2;
    intermFL=inputType.FractionLength;
    if(vectorEnable==1)
        intermType=pirelab.createPirArrayType(pir_sfixpt_t(intermWL,intermFL),dimLen);
    else
        intermType=pir_sfixpt_t(intermWL,intermFL);
    end

    intermZWL=inputType.WordLength+2;
    intermZFL=inputType.WordLength-3;
    if(vectorEnable==1)
        intermZType=pirelab.createPirArrayType(pir_sfixpt_t(intermZWL,-intermZFL),dimLen);
    else
        intermZType=pir_sfixpt_t(intermZWL,-intermZFL);
    end

    outZWL=inputType.WordLength;
    outZFL=outZWL-3;
    if(vectorEnable==1)
        outZType=pirelab.createPirArrayType(pir_sfixpt_t(outZWL,-outZFL),dimLen);
    else
        outZType=pir_sfixpt_t(outZWL,-outZFL);
    end

    z_ex=pirelab.getTypeInfoAsFi(intermZType);
    intermZFimath=eml_al_cordic_fimath(z_ex);
    if(vectorEnable==1)
        ufix1Type=pirelab.createPirArrayType(pir_ufixpt_t(1,0),dimLen);
    else
        ufix1Type=pir_ufixpt_t(1,0);
    end
    x_in_ext=hCoreNet.addSignal(intermType,'x_in_ext');
    y_in_ext=hCoreNet.addSignal(intermType,'y_in_ext');
    pirelab.getDTCComp(hCoreNet,x_in,x_in_ext,'Floor','Wrap','RWV','Data Type Conversion');
    pirelab.getDTCComp(hCoreNet,y_in,y_in_ext,'Floor','Wrap','RWV','Data Type Conversion1');

    if(usePipelines)
        x_in_reg=hCoreNet.addSignal(intermType,'x_in_reg_out');
        pirelab.getIntDelayComp(hCoreNet,x_in_ext,x_in_reg,pipelinestageArray(1),'x_in_reg_out');
        y_in_reg=hCoreNet.addSignal(intermType,'y_in_reg_out');
        pirelab.getIntDelayComp(hCoreNet,y_in_ext,y_in_reg,pipelinestageArray(1),'y_in_reg_out');
    else
        x_in_reg=x_in_ext;
        y_in_reg=y_in_ext;
    end


    x_pre_quadcorr_out=hCoreNet.addSignal(intermType,'x_pre_quadcorr_out');
    y_pre_quadcorr_out=hCoreNet.addSignal(intermType,'y_pre_quadcorr_out');
    y_non_zero=hCoreNet.addSignal(ufix1Type,'y_non_zero');
    x_in_msb=hCoreNet.addSignal(ufix1Type,'x_in_msb');
    y_in_msb=hCoreNet.addSignal(ufix1Type,'y_in_msb');

    pirelab.getBitSliceComp(hCoreNet,x_in_reg,x_in_msb,intermWL-1,intermWL-1,'Bit Slice1');
    pirelab.getBitSliceComp(hCoreNet,y_in_reg,y_in_msb,intermWL-1,intermWL-1,'Bit Slice2');




















    x_in_reg_neg=hCoreNet.addSignal(intermType,'x_in_reg_neg');
    y_in_reg_neg=hCoreNet.addSignal(intermType,'y_in_reg_neg');

    pirelab.getUnaryMinusComp(hCoreNet,x_in_reg,x_in_reg_neg,'Wrap','x_in_reg_neg');
    pirelab.getUnaryMinusComp(hCoreNet,y_in_reg,y_in_reg_neg,'Wrap','y_in_reg_neg');
    pirelab.getSwitchComp(hCoreNet,[x_in_reg_neg,x_in_reg],x_pre_quadcorr_out,x_in_msb,'x_pre_quadcorr_out_switch','>',0,'Floor','Wrap');
    pirelab.getSwitchComp(hCoreNet,[y_in_reg_neg,y_in_reg],y_pre_quadcorr_out,y_in_msb,'y_pre_quadcorr_out_switch','>',0,'Floor','Wrap');
    x_quad_adjust=x_in_msb;
    y_quad_adjust=y_in_msb;

    comp_zero=hCoreNet.addSignal(ufix1Type,'comp_zero');
    pirelab.getCompareToValueComp(hCoreNet,y_in_reg,comp_zero,'>',double(0),'ComparetoZero');
    pirelab.getSwitchComp(hCoreNet,[y_in_msb,comp_zero],y_non_zero,y_in_msb,'y_non_zero_switch','>',0,'Floor','Wrap');


    if(usePipelines)
        x0_p=hCoreNet.addSignal(intermType,'x0_p');
        d1C=pirelab.getIntDelayComp(hCoreNet,x_pre_quadcorr_out,x0_p,pipelinestageArray(2),'x_pre_quadcorr_out_reg');

        if(pipelinestageArray(2))
            d1C.addComment('Pipeline registers');
        end
        y0_p=hCoreNet.addSignal(intermType,'y0_p');
        d1C=pirelab.getIntDelayComp(hCoreNet,y_pre_quadcorr_out,y0_p,pipelinestageArray(2),'y_pre_quadcorr_out_reg');

        if(pipelinestageArray(2))
            d1C.addComment('Pipeline registers');
        end
    else
        x0_p=x_pre_quadcorr_out;
        y0_p=y_pre_quadcorr_out;
    end
    pStageSum=sum(pipelinestageArray(2:end-1));
    if(usePipelines)
        x_quad_adjust_p=hCoreNet.addSignal(ufix1Type,'x_quad_adjust_p');
        y_quad_adjust_p=hCoreNet.addSignal(ufix1Type,'y_quad_adjust_p');
        y_non_zero_p=hCoreNet.addSignal(ufix1Type,'y_non_zero_p');
        pirelab.getIntDelayComp(hCoreNet,x_quad_adjust,x_quad_adjust_p,pStageSum,'x_quad_adjust_reg');
        pirelab.getIntDelayComp(hCoreNet,y_quad_adjust,y_quad_adjust_p,pStageSum,'y_quad_adjust_reg');
        pirelab.getIntDelayComp(hCoreNet,y_non_zero,y_non_zero_p,pStageSum,'y_non_zero_reg');
    else
        x_quad_adjust_p=x_quad_adjust;
        y_quad_adjust_p=y_quad_adjust;
        y_non_zero_p=y_non_zero;
    end



    z0=hCoreNet.addSignal(intermZType,'z0');
    z0.SimulinkRate=hInSignals(1).SimulinkRate;
    y_pre_quadcorr_out_msb=hCoreNet.addSignal(ufix1Type,'y0_p_msb');
    pirelab.getConstComp(hCoreNet,z0,fi(0,numerictype(z_ex),intermZFimath));
    pirelab.getBitSliceComp(hCoreNet,y0_p,y_pre_quadcorr_out_msb,intermWL-1,intermWL-1,'Bit Slice1');

    tInSignals=[x0_p,y0_p,z0,y_pre_quadcorr_out_msb];
    for stageNum=1:cordicInfo.iterNum


        x=hCoreNet.addSignal(intermType,sprintf('x%d',stageNum));
        y=hCoreNet.addSignal(intermType,sprintf('y%d',stageNum));
        z=hCoreNet.addSignal(intermZType,sprintf('z%d',stageNum));


        lutValues=cordicInfo.lutValue;
        lut_value=fi(lutValues(stageNum),numerictype(z_ex),intermZFimath);

















        rt_shift=stageNum-1;

        x_shift=hCoreNet.addSignal(intermType,sprintf('x_shift%d',stageNum));
        y_shift=hCoreNet.addSignal(intermType,sprintf('y_shift%d',stageNum));

        x_temp=hCoreNet.addSignal(intermType,sprintf('x_temp%d',stageNum));
        y_temp=hCoreNet.addSignal(intermType,sprintf('y_temp%d',stageNum));
        lut_value_temp=hCoreNet.addSignal(intermZType,sprintf('lut_value_temp%d',stageNum));
        x_temp_0=hCoreNet.addSignal(intermType,sprintf('x_temp_0_%d',stageNum));
        y_temp_0=hCoreNet.addSignal(intermType,sprintf('y_temp_0_%d',stageNum));
        lut_temp_0=hCoreNet.addSignal(intermZType,sprintf('y_temp_0_%d',stageNum));
        lut_value_s=hCoreNet.addSignal(intermZType,sprintf('lut_value_s%d',stageNum));
        lut_value_s.SimulinkRate=hInSignals(1).SimulinkRate;

        pirelab.getConstComp(hCoreNet,lut_value_s,lut_value,'lut_value','on',0,'','','');
        pirelab.getBitShiftComp(hCoreNet,tInSignals(1),x_shift,'sra',rt_shift,0,sprintf('Bit_shift_comp_x_%d',stageNum));
        pirelab.getBitShiftComp(hCoreNet,tInSignals(2),y_shift,'sra',rt_shift,0,sprintf('Bit_shift_comp_y_%d',stageNum));

        pirelab.getAddComp(hCoreNet,[tInSignals(1),y_shift],x_temp_0,'Floor','Wrap',sprintf('x_temp_0_%d',stageNum),intermType,'+-');
        pirelab.getAddComp(hCoreNet,[tInSignals(2),x_shift],y_temp_0,'Floor','Wrap',sprintf('y_temp_0_%d',stageNum),intermType,'++');
        pirelab.getAddComp(hCoreNet,[tInSignals(3),lut_value_s],lut_temp_0,'Floor','Wrap',sprintf('lut_temp_0_%d',stageNum),intermZType,'+-');

        pirelab.getAddComp(hCoreNet,[tInSignals(1),y_shift],x_temp,'Floor','Wrap',sprintf('x_temp_%d',stageNum),intermType,'++');
        pirelab.getAddComp(hCoreNet,[tInSignals(2),x_shift],y_temp,'Floor','Wrap',sprintf('y_temp_%d',stageNum),intermType,'+-');
        pirelab.getAddComp(hCoreNet,[tInSignals(3),lut_value_s],lut_value_temp,'Floor','Wrap',sprintf('lut_value_temp_%d',stageNum),intermZType,'++');
        pirelab.getSwitchComp(hCoreNet,[x_temp_0,x_temp],x,tInSignals(4),sprintf('x_rotated_%d',stageNum),'>',0,'Floor','Wrap');
        pirelab.getSwitchComp(hCoreNet,[y_temp_0,y_temp],y,tInSignals(4),sprintf('y_rotated_%d',stageNum),'>',0,'Floor','Wrap');
        pirelab.getSwitchComp(hCoreNet,[lut_temp_0,lut_value_temp],z,tInSignals(4),sprintf('lut_value_rotated_%d',stageNum),'>',0,'Floor','Wrap');

        if(usePipelines)

            x_p=hCoreNet.addSignal(intermType,sprintf('x%d_p',stageNum));
            y_p=hCoreNet.addSignal(intermType,sprintf('y%d_p',stageNum));

            d2C=pirelab.getIntDelayComp(hCoreNet,x,x_p,pipelinestageArray(2+stageNum),'x_reg');
            if(pipelinestageArray(2+stageNum))
                d2C.addComment('Pipeline registers');
            end
            pirelab.getIntDelayComp(hCoreNet,y,y_p,pipelinestageArray(2+stageNum),'y_reg');
        else
            x_p=x;
            y_p=y;
        end
        if(usePipelines)
            z_p=hCoreNet.addSignal(intermZType,sprintf('z%d_p',stageNum));
            pirelab.getIntDelayComp(hCoreNet,z,z_p,pipelinestageArray(2+stageNum),'z_reg');
        else
            z_p=z;
        end
        y_p_out_msb=hCoreNet.addSignal(ufix1Type,sprintf('y%d_p_msb',stageNum));
        pirelab.getBitSliceComp(hCoreNet,y_p,y_p_out_msb,intermWL-1,intermWL-1,'Bit Slice3');

        tInSignals=[x_p,y_p,z_p,y_p_out_msb];
    end


    zout=hCoreNet.addSignal(outZType,'z_out');
    pirelab.getDTCComp(hCoreNet,z_p,zout);
    zout_adjust=hCoreNet.addSignal(outZType,'z_out_adjust');
    tInSignals=[zout,x_quad_adjust_p,y_quad_adjust_p,y_non_zero_p];

































    if(vectorEnable==1)
        ufix3Type=pirelab.createPirArrayType(pir_ufixpt_t(3,0),dimLen);
    else
        ufix3Type=pir_ufixpt_t(3,0);
    end

    x_y_adjust=hCoreNet.addSignal(ufix3Type,'x_y_adjust');
    fiMath1=fimath('RoundingMethod','Nearest','OverflowAction','Saturate','ProductMode','FullPrecision','SumMode','FullPrecision');
    nt2=numerictype(1,outZWL,outZFL);
    onePi=hCoreNet.addSignal(outZType,'onePi');
    onePi.SimulinkRate=hInSignals(1).SimulinkRate;
    zero_of_Pi_type=hCoreNet.addSignal(outZType,'zero');
    zero_of_Pi_type.SimulinkRate=hInSignals(1).SimulinkRate;

    pirelab.getConstComp(hCoreNet,onePi,fi(pi,nt2,fiMath1),'onePi','on',0,'','','');
    pirelab.getConstComp(hCoreNet,zero_of_Pi_type,fi(0,nt2,fiMath1),'zero_of_Pi_type','on',0,'','','');

    z_temp1=hCoreNet.addSignal(outZType,'z_temp1');
    z_temp2=hCoreNet.addSignal(outZType,'z_temp2');
    z_temp3=hCoreNet.addSignal(outZType,'z_temp3');
    pirelab.getAddComp(hCoreNet,[zout,onePi],z_temp1,'Floor','Wrap','z_temp1',outZType,'+-');
    pirelab.getAddComp(hCoreNet,[onePi,zout],z_temp2,'Floor','Wrap','z_temp2',outZType,'+-');
    pirelab.getUnaryMinusComp(hCoreNet,zout,z_temp3,'Wrap','z_temp3');
    pirelab.getBitConcatComp(hCoreNet,[tInSignals(4),tInSignals(2),tInSignals(3)],x_y_adjust,'x_y_adjust_comp');
    portSel=[];
    dpForDefault='Last data port';
    numInputs=-1;
    nfpOptions.Latency=int8(0);
    nfpOptions.MantMul=int8(0);
    nfpOptions.Denormals=int8(0);
    diagForDefaultErr=true;
    codingStyle='case_stmt';

    dataSignals=[zero_of_Pi_type,zero_of_Pi_type,onePi,onePi,zout,z_temp3,z_temp2,z_temp1];
    pirelab.getMultiPortSwitchComp(hCoreNet,[x_y_adjust,dataSignals],zout_adjust,2,'Zero-based contiguous','Floor','Wrap','Z_Multiport_Switch',portSel,dpForDefault,numInputs,nfpOptions,diagForDefaultErr,codingStyle);

    if(usePipelines)
        d1C=pirelab.getIntDelayComp(hCoreNet,zout_adjust,angle,pipelinestageArray(end),'z_out_reg');
        if(pipelinestageArray(end))
            d1C.addComment('Pipeline register for output z');
        end
    else
        pirelab.getWireComp(hCoreNet,zout_adjust,angle);
    end

end



function cordicInfo=initialize_parameters(cordicInfo,inputType)

    if~isfield(cordicInfo,'iterNum')
        cordicInfo.iterNum=inputType.WordLength-1;
    end

    if~isfield(cordicInfo,'networkName')
        cordicInfo.networkName='atan2_cordic';
    end

    if inputType.isFloatType||~inputType.Signed
        error(message('hdlcommon:hdlcommon:InputTypeMustBeSigned'));
    end
end


function cordicFimath=eml_al_cordic_fimath(y_in)

    if isfloat(y_in)


        eml_assert(0);
    else
        y_inType=numerictype(y_in);



        cordicFimath=fimath(...
        'ProductMode','FullPrecision',...
        'ProductWordLength',y_inType.WordLength,...
        'ProductFractionLength',y_inType.FractionLength,...
        'SumMode','FullPrecision',...
        'SumWordLength',y_inType.WordLength,...
        'SumFractionLength',y_inType.FractionLength,...
        'RoundMode','floor',...
        'OverflowMode','wrap');
    end
end

function pipelinestageArray=customPipelineStages(totalPipelineStages,latency,latencyStrategy)

    pipelinestageArray=zeros(1,totalPipelineStages);
    if(strcmpi(latencyStrategy,'MAX'))
        pipelinestageArray=ones(1,totalPipelineStages);
    elseif(strcmpi(latencyStrategy,'CUSTOM'))


        if(latency~=0)



            if(latency==1)
                pipelinestageArray(end-(end-3))=1;
            elseif(latency==2)
                if(totalPipelineStages~=6)


                    pipelinestageArray(3)=1;
                    pipelinestageArray(end-3)=1;

                else

                    pipelinestageArray(2)=1;
                    pipelinestageArray(end-3)=1;
                end

            else


                k=ceil(totalPipelineStages/latency);

                j=1;
                temp=1;

                for i=1:latency
                    if(latency>1)
                        if(i==latency)

                            pipelinestageArray(end)=1;
                        else
                            pipelinestageArray(j)=1;


                            if(j<totalPipelineStages-k)
                                j=j+k;
                            else

                                j=temp+1;

                                temp=temp+1;
                            end
                        end

                    else
                        pipelinestageArray(j)=1;
                    end

                end
            end
        end
    end
end






