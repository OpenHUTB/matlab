classdef lowerpir<handle





    methods(Static)

        hNewC=lowerAdd(hN,hC);
        hNewC=lowerMinus(hN,hC);
        hNewC=lowerMultiply(hN,hC);
        hNewC=lowerReciprocal(hN,hC);
        hNewC=lowerRecipSqrtNewton(hN,hC);
        hNewC=lowerSqrtNewton(hN,hC);
        hNewC=lowerDTCComp(hN,hC);
        hNewC=lowerUnitDelay(hN,hC);
        hNewC=lowerIntegerDelay(hN,hC);
        hNewC=lowerIntegerDelayEnabledResettable(hN,hC);
        hNewC=lowerRateTransition(hN,hC);
        hNewC=lowerDownSample(hN,hC);
        hNewC=lowerUpSample(hN,hC);
        hNewC=lowerSerializer(hN,hC);
        hNewC=lowerDeserializer(hN,hC);
        hNewC=lowerSerializer1D(hN,hC);
        hNewC=lowerDeserializer1D(hN,hC);
        hNewC=lowerDataUnbuffer(hN,hC);
        hNewC=lowerDataBuffer(hN,hC);
        hNewC=lowerGround(hN,hC);
        hNewC=lowerTappedDelay(hN,hC);
        hNewC=lowerConcatenate(hN,hC);
        hNewC=lowerMux(hN,hC);
        hNewC=lowerSwitch(hN,hC);
        hNewC=lowerMultiPortSwitch(hN,hC);
        hNewC=lowerSelector(hN,hC);
        hNewC=lowerMultiportSelector(hN,hC);
        hNewC=lowerVariableSelector(hN,hC);
        hNewC=lowerConstant(hN,hC);
        hNewC=lowerMConstant(hN,hC);
        hNewC=lowerLogic(hN,hC,mode);
        hNewC=lowerRelOp(hN,hC,mode);
        hNewC=lowerCompareToConstant(hN,hC);
        hNewC=lowerBitSlice(hN,hC);
        hNewC=lowerBitExtract(hN,hC);
        hNewC=lowerBitConcat(hN,hC);
        hNewC=lowerBitReduce(hN,hC);
        hNewC=lowerBitRotate(hN,hC);
        hNewC=lowerBitwiseOp(hN,hC);
        hNewC=lowerBitShift(hN,hC);
        hNewC=lowerBitShiftLib(hN,hC);
        hNewC=lowerBitSet(hN,hC);
        hNewC=lowerAbs(hN,hC);
        hNewC=lowerIncDecSI(hN,hC,mode);
        hNewC=lowerIncDecRWV(hN,hC,mode);
        hNewC=lowerDecToZero(hN,hC);
        hNewC=lowerAssignment(hN,hC);
        hNewC=lowerUnaryMinus(hN,hC);
        hNewC=lowerSignum(hN,hC);
        hNewC=lowerSaturation(hN,hC);
        hNewC=lowerSaturationDynamic(hN,hC);
        hNewC=lowerDeadZone(hN,hC);
        hNewC=lowerDeadZoneDynamic(hN,hC);
        hNewC=lowerReshape(hN,hC);
        hNewC=lowerBacklash(hN,hC);
        hNewC=lowerHitCross(hN,hC);
        hNewC=lowerRI2C(hN,hC);
        hNewC=lowerC2RI(hN,hC);
        hNewC=lowerGain(hN,hC);
        hNewC=lowerCounterLimited(hN,hC);
        hNewC=lowerCounterFreeRunning(hN,hC);
        hNewC=lowerHDLCounter(hN,hC);
        hNewC=lowerMinMax(hN,hC);
        hNewC=lowerHardwareDemux(hN,hC);
        hNewC=lowerFilter(hN,hC);
        hNewC=lowerMemory(hN,hC);
        hNewC=lowerLookup(hN,hC);
        hNewC=lowerDirectLookup(hN,hC);
        hNewC=lowerPreLookup(hN,hC);
        hNewC=lowerFrom(hN,hC);
        hNewC=lowerGoto(hN,hC);
        hNewC=lowerMegaFunction(hN,hC);
        hNewC=lowerDspba(hN,hC);
        hNewC=lowerXsg(hN,hC);
        hNewC=lowerXsgVivado(hN,hC);
        hNewC=lowerUnitDelayEnabledResettable(hN,hC);
        hNewC=lowerTappedDelayEnabledResettable(hN,hC);
        hNewC=lowerComplexConjugate(hN,hC);
        hNewC=lowerCordicRotationComp(hN,hC);
        hNewC=lowerCordicPreQuadCorrectionComp(hN,hC);
        hNewC=lowerCordicPostQuadCorrectionComp(hN,hC);
        hNewC=lowerTransposeComp(hN,hC);
        hNewC=lowerHermitianComp(hN,hC);
        hNewC=lowerAssertion(hN,hC);
        hNewC=lowerDynamicShiftComp(hN,hC);

        function copyConstrainedRetimingResults(hC,hNewC)
            hNewC.setConstrainedOutputPipeline(hC.getConstrainedOutputPipeline);
            hNewC.setConstrainedOutputPipelineStatus(hC.getConstrainedOutputPipelineStatus);
            hNewC.setConstrainedOutputPipelineDeficit(hC.getConstrainedOutputPipelineDeficit);
        end

        function postLowering(hN,hC,hNewC)
            if(hNewC~=hC)
                hNewC.copyComment(hC);
                hNewC.SimulinkHandle=hC.SimulinkHandle;
                hNewC.setGMHandle(hC.getGMHandle);
                hNewC.copyTags(hC);
                lowerpir.copyConstrainedRetimingResults(hC,hNewC);
                hN.removeComponent(hC);
            end
        end

        function checkSignalValidity(hPir)

            ntwks=hPir.Networks;


            for ii=1:length(ntwks)


                sigs=ntwks(ii).Signals;


                for jj=1:length(sigs)


                    if isprop(sigs(jj),'Type')
                        sigType=sigs(jj).Type;
                    else
                        sigType=sigs(jj);
                    end


                    sigType=sigType.getLeafType;




                    if(sigType.isWordType&&sigType.WordLength>128)

                        cd=sigs(jj).getConcreteDrivingComps;
                        cr=sigs(jj).getConcreteReceivingComps;





                        if~isempty(cd)
                            error(message('hdlcoder:makehdl:wordlengthOverflowOutputBlock',sigType.WordLength,[get_param(cd.OrigModelHandle,'Parent'),'/',get_param(cd.OrigModelHandle,'Name')]));



                        elseif~isempty(cr)
                            error(message('hdlcoder:makehdl:wordlengthOverflowInputBlock',sigType.WordLength,[get_param(cr.OrigModelHandle,'Parent'),'/',get_param(cr.OrigModelHandle,'Name')]));


                        else
                            error(message('hdlcoder:makehdl:wordlengthOverflow',sigType.WordLength));
                        end
                    end
                end
            end
        end


        function lowerPirNativeComp(hN,hC)
            className=hC.ClassName;
            hNewC=hC;
            doPostLowering=true;
            switch className
            case{...
                'not_comp',...
                'and_comp',...
                'or_comp',...
                'nand_comp',...
                'nor_comp',...
                'xor_comp',...
                'xnor_comp'}
                hNewC=lowerpir.lowerLogic(hN,hC,className);
            case 'logic_comp'
                hNewC=lowerpir.lowerLogic(hN,hC,sprintf('%s_comp',hC.getOpName));
            case{...
                'eq_comp',...
                'ne_comp',...
                'lt_comp',...
                'le_comp',...
                'gt_comp',...
                'ge_comp'}
                hNewC=lowerpir.lowerRelOp(hN,hC,className);
            case 'relop_comp'
                hNewC=lowerpir.lowerRelOp(hN,hC,hC.getOpName);
            case 'filter_comp'
                hNewC=lowerpir.lowerFilter(hN,hC);
                doPostLowering=false;
            case 'signum_comp'
                hNewC=lowerpir.lowerSignum(hN,hC);
            case 'saturation_comp'
                hNewC=lowerpir.lowerSaturation(hN,hC);
            case 'saturation_dynamic_comp'
                hNewC=lowerpir.lowerSaturationDynamic(hN,hC);
            case 'deadzone_comp'
                hNewC=lowerpir.lowerDeadZone(hN,hC);
            case 'deadzone_dynamic_comp'
                hNewC=lowerpir.lowerDeadZoneDynamic(hN,hC);
            case 'reshape_comp'
                hNewC=lowerpir.lowerReshape(hN,hC);
            case 'backlash_comp'
                hNewC=lowerpir.lowerBacklash(hN,hC);
            case 'hitcross_comp'
                hNewC=lowerpir.lowerHitCross(hN,hC);
            case 'from_comp'
                hNewC=lowerpir.lowerFrom(hN,hC);
            case 'goto_comp'
                hNewC=lowerpir.lowerGoto(hN,hC);
            case 'assignment_comp'
                hNewC=lowerpir.lowerAssignment(hN,hC);
            case 'uminus_comp'
                hNewC=lowerpir.lowerUnaryMinus(hN,hC);
            case 'lookuptable_comp'
                hNewC=lowerpir.lowerLookup(hN,hC);
            case 'prelookuptable_comp'
                hNewC=lowerpir.lowerPreLookup(hN,hC);
            case 'directlookuptable_comp'
                hNewC=lowerpir.lowerDirectLookup(hN,hC);
            case 'inc_si_comp'
                hNewC=lowerpir.lowerIncDecSI(hN,hC,1);
            case 'inc_rwv_comp'
                hNewC=lowerpir.lowerIncDecRWV(hN,hC,1);
            case 'dec_si_comp'
                hNewC=lowerpir.lowerIncDecSI(hN,hC,2);
            case 'dec_rwv_comp'
                hNewC=lowerpir.lowerIncDecRWV(hN,hC,2);
            case 'dec_zero_comp'
                hNewC=lowerpir.lowerDecToZero(hN,hC);
            case 'bitslice_comp'
                hNewC=lowerpir.lowerBitSlice(hN,hC);
            case 'bitextract_comp'
                hNewC=lowerpir.lowerBitExtract(hN,hC);
            case 'bitconcat_comp'
                hNewC=lowerpir.lowerBitConcat(hN,hC);
            case 'bitreduce_comp'
                hNewC=lowerpir.lowerBitReduce(hN,hC);
            case 'bitrotate_comp'
                hNewC=lowerpir.lowerBitRotate(hN,hC);
            case 'bitwiseop_comp'
                hNewC=lowerpir.lowerBitwiseOp(hN,hC);
            case 'bitshift_comp'
                hNewC=lowerpir.lowerBitShift(hN,hC);
            case 'bitshiftlib_comp'
                hNewC=lowerpir.lowerBitShiftLib(hN,hC);
            case 'bitset_comp'
                hNewC=lowerpir.lowerBitSet(hN,hC);
            case 'add_comp'
                hNewC=lowerpir.lowerAdd(hN,hC);
            case 'minus_comp'
                hNewC=lowerpir.lowerMinus(hN,hC);
            case 'mul_comp'
                hNewC=lowerpir.lowerMultiply(hN,hC);
            case 'recip_comp'
                hNewC=lowerpir.lowerReciprocal(hN,hC);
            case 'recip_sqrtnewton_comp'
                hNewC=lowerpir.lowerRecipSqrtNewton(hN,hC);
            case 'sqrtnewton_comp'
                hNewC=lowerpir.lowerSqrtNewton(hN,hC);
            case 'data_conv_comp'
                hNewC=lowerpir.lowerDTCComp(hN,hC);
            case 'unitdelay_comp'
                hNewC=lowerpir.lowerUnitDelay(hN,hC);
            case 'unitdelayenabledresettable_comp'
                hNewC=lowerpir.lowerUnitDelayEnabledResettable(hN,hC);
            case 'integerdelay_comp'
                hNewC=lowerpir.lowerIntegerDelay(hN,hC);
            case 'integerdelayenabledresettable_comp'
                hNewC=lowerpir.lowerIntegerDelayEnabledResettable(hN,hC);
            case 'tappeddelay_comp'
                hNewC=lowerpir.lowerTappedDelay(hN,hC);
            case 'tappeddelayenabledresettable_comp'
                hNewC=lowerpir.lowerTappedDelayEnabledResettable(hN,hC);
            case 'ratetransition_comp'
                hNewC=lowerpir.lowerRateTransition(hN,hC);
            case 'downsample_comp'
                hNewC=lowerpir.lowerDownSample(hN,hC);
            case 'upsample_comp'
                hNewC=lowerpir.lowerUpSample(hN,hC);
            case 'serializer_comp'
                hNewC=lowerpir.lowerSerializer(hN,hC);
            case 'deserializer_comp'
                hNewC=lowerpir.lowerDeserializer(hN,hC);
            case 'dataunbuffer_comp'
                hNewC=lowerpir.lowerDataUnbuffer(hN,hC);
            case 'databuffer_comp'
                hNewC=lowerpir.lowerDataBuffer(hN,hC);
            case 'ground_comp'
                hNewC=lowerpir.lowerGround(hN,hC);
            case 'mconstant_comp'



            case 'const_comp'
                hNewC=lowerpir.lowerConstant(hN,hC);
            case 'comparetoconst_comp'
                hNewC=lowerpir.lowerCompareToConstant(hN,hC);
            case 'abs_comp'
                hNewC=lowerpir.lowerAbs(hN,hC);
            case 'c2ri_comp'
                hNewC=lowerpir.lowerC2RI(hN,hC);
            case 'ri2c_comp'
                hNewC=lowerpir.lowerRI2C(hN,hC);
            case 'gain_comp'
                hNewC=lowerpir.lowerGain(hN,hC);
            case 'memory_comp'
                hNewC=lowerpir.lowerMemory(hN,hC);
            case 'mux_comp'

                hNewC=lowerpir.lowerMux(hN,hC);
            case 'hwdemux_comp'
                hNewC=lowerpir.lowerHardwareDemux(hN,hC);
            case 'counterlimited_comp'
                hNewC=lowerpir.lowerCounterLimited(hN,hC);
            case 'counterfreerunning_comp'
                hNewC=lowerpir.lowerCounterFreeRunning(hN,hC);
            case 'hdlcounter_comp'
                hNewC=lowerpir.lowerHDLCounter(hN,hC);
            case 'serializer1d_comp'
                hNewC=lowerpir.lowerSerializer1D(hN,hC);
            case 'deserializer1d_comp'
                hNewC=lowerpir.lowerDeserializer1D(hN,hC);
            case 'minmax_comp'
                hNewC=lowerpir.lowerMinMax(hN,hC);
            case 'switch_comp'
                hNewC=lowerpir.lowerSwitch(hN,hC);
            case 'multiportswitch_comp'
                hNewC=lowerpir.lowerMultiPortSwitch(hN,hC);
            case 'selector_comp'
                hNewC=lowerpir.lowerSelector(hN,hC);
            case 'multiportselector_comp'
                hNewC=lowerpir.lowerMultiportSelector(hN,hC);
            case 'variableselector_comp'
                hNewC=lowerpir.lowerVariableSelector(hN,hC);
            case 'megafunction_comp'
                hNewC=lowerpir.lowerMegaFunction(hN,hC);
            case 'dspba_comp'
                hNewC=lowerpir.lowerDspba(hN,hC);
            case 'xsg_comp'
                hNewC=lowerpir.lowerXsg(hN,hC);
            case 'xsg_vivado_comp'
                hNewC=lowerpir.lowerXsgVivado(hN,hC);
            case 'complex_conjugate_comp'
                hNewC=lowerpir.lowerComplexConjugate(hN,hC);
            case 'cordic_rotation_comp'
                hNewC=lowerpir.lowerCordicRotationComp(hN,hC);
            case 'cordic_prequadcorrection_comp'
                hNewC=lowerpir.lowerCordicPreQuadCorrectionComp(hN,hC);
            case 'cordic_postquadcorrection_comp'
                hNewC=lowerpir.lowerCordicPostQuadCorrectionComp(hN,hC);
            case 'transpose_comp'
                hNewC=lowerpir.lowerTransposeComp(hN,hC);
            case 'hermitian_comp'
                hNewC=lowerpir.lowerHermitianComp(hN,hC);
            case 'dynamic_shift_comp'
                hNewC=lowerpir.lowerDynamicShiftComp(hN,hC);
            end
            if doPostLowering
                lowerpir.postLowering(hN,hC,hNewC);
            end
        end

        function lowerNetwork(hN)
            vComps=hN.Components;
            for j=1:length(vComps)
                hC=vComps(j);
                if hC.isLowerable

                    try


                        lowerpir.lowerPirNativeComp(hN,hC);
                    catch me
                        if isa(hC,'hdlcoder.component')
                            errMsg=message('hdlcoder:engine:ErrorWhileWorkingOn',lowerpir.getCompName(hC));
                            fprintf(errMsg.getString());
                            mEx=me.addCause(MException(errMsg));
                            throw(mEx);
                        end
                        rethrow(me);
                    end

                end
            end
        end

        function doIt(hPir)
            debugLevel=hdlgetparameter('debug');
            if debugLevel>=2
                cDir=hdlGetCodegendir;
                hPir.dumpDot(fullfile(cDir,'pre_lowerpir2eml.dot'));
            end


            for ii=1:length(hPir.Networks)
                if(hPir.Networks(ii).NumberOfPirGenericPorts()>0)
                    hPir.extractGenericParameter;
                    break;
                end
            end




            if~hPir.getParamValue('axiInterface512BitDataPortFeatureControl')
                lowerpir.checkSignalValidity(hPir);
            end

            vNetworks=hPir.Networks;
            for i=1:length(vNetworks)
                hN=vNetworks(i);
                lowerpir.lowerNetwork(hN);
            end

            if hdlgetparameter('minimizeintermediatesignals')
                hPir.foldConstants;
            end

            for i=1:length(vNetworks)
                hN=vNetworks(i);
                lowerpir.lowerConstsOnly(hN);
            end

            if debugLevel>=2
                hPir.dumpDot(fullfile(cDir,'post_lowerpir2eml.dot'));
            end
        end

        function lowerConstsOnly(hN)
            vComps=hN.Components;
            for j=1:length(vComps)
                hC=vComps(j);
                if strcmp(hC.ClassName,'mconstant_comp')
                    try
                        hNewC=lowerpir.lowerMConstant(hN,hC);
                        lowerpir.postLowering(hN,hC,hNewC);
                    catch me

                        fprintf(message('hdlcoder:engine:ErrorLoweringConstantComp').getString());
                        mEx=me.addCause(MException(message('hdlcoder:engine:ErrorLoweringConstantComp')));
                        throw(mEx);
                    end

                end
            end
        end

        function name=getCompName(hC)
            if~hC.Synthetic
                name=getfullname(hC.SimulinkHandle);
            else
                if~isempty(hC.Name)
                    name=[hC.Owner.Name,'/',hC.Name];
                else
                    name=[hC.Owner.Name,'/',hC.RefNum];
                end
            end
        end
    end
end









