function dcomp=elaborateTopLevel(~,hN,blockInfo)






    outsig=hN.PirOutputSignals(1);


    dataOutType=pirgetdatatypeinfo(outsig.Type);
    dataOutCplx=dataOutType.iscomplex;


    if and(dataOutType.isvector,dataOutType.iscomplex)
        outType=pir_sfixpt_t(dataOutType.wordsize,dataOutType.binarypoint);
        vecOutType=outsig(1).Type.BaseType;


    elseif(dataOutType.iscomplex)

        outType=pir_sfixpt_t(dataOutType.wordsize,dataOutType.binarypoint);
        vecOutType=outsig(1).Type;


    elseif(dataOutType.isvector)
        vecOutType=outsig(1).Type.BaseType;
        outType=pir_sfixpt_t(dataOutType.wordsize,dataOutType.binarypoint);
    else
        outType=outsig.Type;
        vecOutType=outType;
    end



    if(blockInfo.qwave)

        subTogRst=mod(blockInfo.tableState,2);
        negTogRst=blockInfo.tableState>1;


        booleanType=pir_ufixpt_t(1,0);
        for dim=1:blockInfo.copies
            submuxctrl_idx(dim)=hN.addSignal(booleanType,['subtract_mux_ctrl',num2str(dim)]);
            submuxctrl_idx(dim).SimulinkRate=blockInfo.SimulinkRate;

            submuxctrl_inv_idx(dim)=hN.addSignal(booleanType,['subtract_mux_ctrl_inv',num2str(dim)]);
            submuxctrl_inv_idx(dim).SimulinkRate=blockInfo.SimulinkRate;

            negmuxctrl_idx(dim)=hN.addSignal(booleanType,['negate_mux_ctrl',num2str(dim)]);
            negmuxctrl_idx(dim).SimulinkRate=blockInfo.SimulinkRate;


            negmuxctrl_inv_idx(dim)=hN.addSignal(booleanType,['negate_mux_ctrl_inv',num2str(dim)]);
            negmuxctrl_inv_idx(dim).SimulinkRate=blockInfo.SimulinkRate;
        end



        if(dataOutCplx)


            imag_submuxctrl_idx=submuxctrl_inv_idx;

            for dim=1:blockInfo.copies

                imag_negmuxctrl_idx(dim)=hN.addSignal(booleanType,['imag_negate_mux_ctrl',num2str(dim)]);
                imag_negmuxctrl_idx(dim).SimulinkRate=blockInfo.SimulinkRate;
            end


            subTogRst(2:2:end)=[];
            negTogRst(2:2:end)=[];

            realsig_suffix='_re';
            real_label='REAL ';
        else
            realsig_suffix='';
            real_label='';
        end
    end

    for dim=1:blockInfo.copies

        valuesSine=blockInfo.valuesSineTable{dim};
        vecOut(dim)=hN.addSignal(vecOutType,['vecOut',num2str(dim)]);
        vecOut(dim).SimulinkRate=blockInfo.SimulinkRate;

        if(blockInfo.qwave)

            maxCount=length(valuesSine)-2;
            bpWordLen=ceil(log2(length(valuesSine)+1));

            counterSize=ceil(log2(maxCount+1));

            cntsltype=pir_ufixpt_t(counterSize,0);
            cntidx(dim)=hN.addSignal(cntsltype,['address_cnt',num2str(dim)]);
            cntidx(dim).SimulinkRate=blockInfo.SimulinkRate;



            dcomp=pirelab.getCounterComp(hN,[],cntidx(dim),...
            'Count limited',...
            0,...
            1,...
            maxCount,...
            0,...
            0,...
            0,...
            0,...
            'Sine_Wave_addrcnt_temp_process1',...
0...
            );


            phase(dim)=hN.addSignal(booleanType,['phase',num2str(dim)]);
            phase(dim).SimulinkRate=blockInfo.SimulinkRate;


            optionOne(dim)=addSignal(hN,['optionOne',num2str(dim)],booleanType,blockInfo.SimulinkRate);
            pirelab.getConstComp(hN,optionOne(dim),1);


            optionZero(dim)=addSignal(hN,['optionZero',num2str(dim)],booleanType,blockInfo.SimulinkRate);
            pirelab.getConstComp(hN,optionZero(dim),0);

            if isequal(maxCount,1)
                pirelab.getSwitchComp(hN,...
                [optionOne(dim),optionZero(dim)],...
                phase(dim),...
                cntidx(dim),'Switch1',...
                '==',1,'Floor','Wrap');
            else


                outIfEqual(dim)=addSignal(hN,['outIfEqual',num2str(dim)],booleanType,blockInfo.SimulinkRate);

                maxCountLess2(dim)=addSignal(hN,['maxCountLess2',num2str(dim)],cntsltype,blockInfo.SimulinkRate);
                pirelab.getConstComp(hN,maxCountLess2(dim),maxCount);

                pirelab.getRelOpComp(hN,...
                [cntidx(dim),maxCountLess2(dim)],...
                outIfEqual(dim),...
                '==',0,'GreaterThan');

                pirelab.getSwitchComp(hN,...
                [optionOne(dim),optionZero(dim)],...
                phase(dim),...
                outIfEqual(dim),'Switch1',...
                '>',0,'Floor','Wrap');
            end



            pirelab.getLogicComp(hN,submuxctrl_idx(dim),submuxctrl_inv_idx(dim),'not');
            pirelab.getUnitDelayEnabledComp(hN,submuxctrl_inv_idx(dim),submuxctrl_idx(dim),phase(dim),'SineWave_Toggle1',subTogRst(dim),0);



            pirelab.getLogicComp(hN,negmuxctrl_idx(dim),negmuxctrl_inv_idx(dim),'not');

            enableSig(dim)=addSignal(hN,['enableSig',num2str(dim)],booleanType,blockInfo.SimulinkRate);
            pirelab.getLogicComp(hN,[phase(dim),submuxctrl_idx(dim)],enableSig(dim),'and',sprintf('Logical\nOperator'));

            pirelab.getUnitDelayEnabledComp(hN,negmuxctrl_inv_idx(dim),negmuxctrl_idx(dim),enableSig(dim),'SineWave_Toggle2',negTogRst(dim),0);



            addr_mv=maxCount+1;

            addr_mv_WL=ceil(log2(addr_mv+1));
            c_addrmv_sltype=pir_ufixpt_t(addr_mv_WL,0);
            C_addr_mv_idx(dim)=hN.addSignal(c_addrmv_sltype,['C_',blockInfo.blockName,'_addr_max_val',num2str(dim)]);
            C_addr_mv_idx(dim).SimulinkRate=blockInfo.SimulinkRate;

            pirelab.getConstComp(hN,C_addr_mv_idx(dim),addr_mv);
            subaddr_idx(dim)=hN.addSignal(c_addrmv_sltype,['LUT_length_minus_addr',num2str(dim)]);
            subaddr_idx(dim).SimulinkRate=blockInfo.SimulinkRate;



            dcomp=pirelab.getAddComp(hN,[C_addr_mv_idx(dim),cntidx(dim)],subaddr_idx(dim),'floor',false,'Sub',[],'+-');
            addr2lut_idx(dim)=hN.addSignal(c_addrmv_sltype,['LUT_addr_in',realsig_suffix,num2str(dim)]);
            addr2lut_idx(dim).SimulinkRate=blockInfo.SimulinkRate;


            if addr_mv_WL~=counterSize
                cntwider_idx(dim)=hN.addSignal(c_addrmv_sltype,['address_cnt_fullwidth',num2str(dim)]);
                cntwider_idx(dim).SimulinkRate=blockInfo.SimulinkRate;
                dcomp=pirelab.getDTCComp(hN,cntidx(dim),cntwider_idx(dim),'floor','Wrap');
                cntidx(dim)=cntwider_idx(dim);
            end

            pirelab.getSwitchComp(hN,...
            [subaddr_idx(dim),cntidx(dim)],...
            addr2lut_idx(dim),...
            submuxctrl_idx(dim),'Switch1',...
            '>',0,'Floor','Wrap');




            if(dataOutCplx)

                imagaddr2lut_idx(dim)=hN.addSignal(c_addrmv_sltype,['LUT_addr_in_im',num2str(dim)]);
                imagaddr2lut_idx(dim).SimulinkRate=blockInfo.SimulinkRate;

                pirelab.getSwitchComp(hN,...
                [subaddr_idx(dim),cntidx(dim)],...
                imagaddr2lut_idx(dim),...
                imag_submuxctrl_idx(dim),'Switch2',...
                '>',0,'Floor','Wrap');


            end

            lutout_idx(dim)=hN.addSignal(outType,['LUT_output',realsig_suffix,num2str(dim)]);
            lutout_idx(dim).SimulinkRate=blockInfo.SimulinkRate;


            real_outsig(dim)=hN.addSignal(outType,['real_outsig',num2str(dim)]);
            real_outsig(dim).SimulinkRate=blockInfo.SimulinkRate;
            img_outsig(dim)=hN.addSignal(outType,['img_outsig',num2str(dim)]);
            img_outsig(dim).SimulinkRate=blockInfo.SimulinkRate;




            [tabledata,idx,bpType,LUToutType,FLTypeInterp]=ComputeLUT(valuesSine,maxCount,bpWordLen,outType);
            dcomp=pirelab.getLookupNDComp(hN,addr2lut_idx(dim),...
            lutout_idx(dim),...
            (tabledata),...
            0,...
            bpType,...
            LUToutType,...
            FLTypeInterp,...
            0,...
            idx,...
            'Lookup Table',-1);...


            unaryminus_temp(dim)=hN.addSignal(outType,['unaryminus_temp',num2str(dim)]);
            unaryminus_temp(dim).SimulinkRate=blockInfo.SimulinkRate;

            pirelab.getUnaryMinusComp(hN,lutout_idx(dim),unaryminus_temp(dim));

            pirelab.getSwitchComp(hN,[lutout_idx(dim),unaryminus_temp(dim)],real_outsig(dim),negmuxctrl_idx(dim),...
            'select outputs','==',0);



            if(dataOutCplx)

                imaglutout_idx(dim)=hN.addSignal(outType,['LUT_output_im',num2str(dim)]);
                imaglutout_idx(dim).SimulinkRate=blockInfo.SimulinkRate;


                pirelab.getLookupNDComp(hN,imagaddr2lut_idx(dim),...
                imaglutout_idx(dim),...
                (tabledata),...
                0,...
                bpType,...
                LUToutType,...
                FLTypeInterp,...
                0,...
                idx,...
                'Lookup Table',-1);...



                pirelab.getLogicComp(hN,[negmuxctrl_inv_idx(dim),submuxctrl_idx(dim)],imag_negmuxctrl_idx(dim),'xor',sprintf('Logical\nOperator'));

                unaryminus_Imgtemp(dim)=hN.addSignal(outType,['unaryminus_Imgtemp',num2str(dim)]);
                unaryminus_Imgtemp(dim).SimulinkRate=blockInfo.SimulinkRate;

                pirelab.getUnaryMinusComp(hN,imaglutout_idx(dim),unaryminus_Imgtemp(dim));

                pirelab.getSwitchComp(hN,[imaglutout_idx(dim),unaryminus_Imgtemp(dim)],img_outsig(dim),imag_negmuxctrl_idx(dim),...
                'select outputs','==',0);

                pirelab.getRealImag2Complex(hN,[real_outsig(dim),img_outsig(dim)],vecOut(dim));
            else

                pirelab.getIntDelayComp(hN,real_outsig(dim),vecOut(dim),0,['LUToutRegister1',num2str(dim)],0);
            end



        else


            fullTableMaxCount=length(valuesSine);

            counterSize=ceil(log2(fullTableMaxCount));


            cntsltype=pir_ufixpt_t(counterSize,0);
            cntidx(dim)=hN.addSignal(cntsltype,['address_cnt',num2str(dim)]);
            cntidx(dim).SimulinkRate=blockInfo.SimulinkRate;


            dcomp=pirelab.getCounterComp(hN,[],cntidx(dim),...
            'Count limited',...
            0,...
            1,...
            fullTableMaxCount-1,...
            0,...
            0,...
            0,...
            0,...
            'Sine_Wave_addrcnt_temp_process1',...
0...
            );


            lut1out(dim)=hN.addSignal(outType,['lut1out',num2str(dim)]);
            lut1out(dim).SimulinkRate=blockInfo.SimulinkRate;
            [tabledata,idx,bpType,LUToutType,FLTypeInterp]=ComputeLUT(valuesSine,fullTableMaxCount-2,counterSize,outType);


            if(dataOutCplx)

                lut1out_real(dim)=hN.addSignal(outType,['lut1out_real',num2str(dim)]);
                lut1out_real(dim).SimulinkRate=blockInfo.SimulinkRate;

                lut1out_img(dim)=hN.addSignal(outType,['lut1out_img',num2str(dim)]);
                lut1out_img(dim).SimulinkRate=blockInfo.SimulinkRate;

                pirelab.getLookupNDComp(hN,cntidx(dim),...
                lut1out_real(dim),...
                real(tabledata),...
                0,...
                bpType,...
                LUToutType,...
                FLTypeInterp,...
                0,...
                idx,...
                'Lookup Table1',...
                -1);


                pirelab.getLookupNDComp(hN,cntidx(dim),...
                lut1out_img(dim),...
                imag(tabledata),...
                0,...
                bpType,...
                LUToutType,...
                FLTypeInterp,...
                0,...
                idx,...
                'Lookup Table2',...
                -1);
                pirelab.getRealImag2Complex(hN,[lut1out_real(dim),lut1out_img(dim)],vecOut(dim));
            else

                pirelab.getLookupNDComp(hN,cntidx(dim),...
                lut1out(dim),...
                tabledata,...
                0,...
                bpType,...
                LUToutType,...
                FLTypeInterp,...
                0,...
                idx,...
                'Lookup Table3',...
                -1);
                pirelab.getIntDelayComp(hN,lut1out(dim),vecOut(dim),0,'LUToutRegister',0);

            end




        end
    end

    pirelab.getMuxComp(hN,vecOut,outsig);


    function[tabledata,idx,bpType,LUToutType,FLTypeInterp]=ComputeLUT(valuesSine,tableCount,bpWordLen,outType)

        Fsat=fimath('RoundMode','Nearest',...
        'OverflowMode','Saturate',...
        'SumMode','KeepLSB',...
        'SumWordLength',outType.WordLength,...
        'SumFractionLength',-outType.FractionLength,...
        'CastBeforeSum',true);

        LUToutType=fi(0,1,outType.WordLength,-outType.FractionLength);


        FLTypeInterp=fi(0,0,32,31);






        bpType=fi(0,0,bpWordLen,0);





        idx={fi((0:tableCount+1),bpType.numerictype)};


        tabledata=fi(valuesSine,LUToutType.numerictype,Fsat);
    end


    function hS=addSignal(hN,sigName,pirTyp,simulinkRate)
        hS=hN.addSignal;
        hS.Name=sigName;
        hS.Type=pirTyp;
        hS.SimulinkHandle=0;
        hS.SimulinkRate=simulinkRate;
    end

end