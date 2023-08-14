function[nfpNetwork,customLatency]=addNfpNetwork(hN,hC,compName,isSingle,compositeNFPOptions)


    sigT=[];
    slRate=hC.PirInputSignals(1).SimulinkRate;
    if isempty(compositeNFPOptions)
        if hC.NumberOfPirInputPorts>0
            sigT=hC.PirInputSignals(1).Type.getLeafType;
        end

        if~isempty(sigT)&&~(sigT.isFloatType)&&...
            (hC.NumberOfPirOutputPorts>0)
            sigT=hC.PirOutputSignals(1).Type.getLeafType;
        end
    end
    if(~isempty(sigT))
        isHalf=sigT.isHalfType;
    else
        isHalf=false;
    end


    partMultOpt=false;
    if(transformnfp.mantissaMultiplyStrategy==2)&&...
        (transformnfp.partAddShiftMultiplierSize~=3)
        partMultOpt=true;
    end

    customLatency=-1;

    switch compName


    case 'nfp_abs_comp'
        nfpNetwork=transformnfp.addNfpAbsComp(hN,slRate,isSingle);
    case{'nfp_add_comp','nfp_add2_comp','nfp_sub_comp'}
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'AddSub',sigT);
        if strcmpi(compName,'nfp_sub_comp')
            nfpNetwork=transformnfp.addNfpSubComp(hN,latency,slRate,isSingle,isHalf);
        else
            nfpNetwork=transformnfp.addNfpAddComp(hN,latency,slRate,isSingle,isHalf);
        end
    case 'nfp_div_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Div',sigT);
        nfpNetwork=transformnfp.addNfpDivComp(hN,latency,slRate,isSingle,isHalf);
    case 'nfp_mul_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Mul',sigT);
        nfpNetwork=transformnfp.addNfpMulComp(hN,latency,slRate,isSingle,isHalf);
    case 'nfp_relop_comp'
        if~isempty(compositeNFPOptions)
            opName=compositeNFPOptions.opName;
        else
            opName=hC.getOpName;
        end
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Relop',sigT);
        nfpNetwork=transformnfp.addNfpRelopComp(hN,opName,latency,slRate,isSingle,isHalf);
    case 'nfp_rsqrt_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Rsqrt',sigT);
        nfpNetwork=transformnfp.addNfpRSqrtComp(hN,latency,slRate,isSingle);
    case 'nfp_round_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Rounding',sigT);
        nfpNetwork=transformnfp.addNfpRoundComp(hN,latency,slRate,isSingle);
    case 'nfp_floor_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Rounding',sigT);
        nfpNetwork=transformnfp.addNfpFloorComp(hN,latency,slRate,isSingle);
    case 'nfp_ceil_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Rounding',sigT);
        nfpNetwork=transformnfp.addNfpCeilComp(hN,latency,slRate,isSingle);
    case 'nfp_fix_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Fix',sigT);
        nfpNetwork=transformnfp.addNfpFixComp(hN,latency,slRate,isSingle);
    case 'nfp_sqrt_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Sqrt',sigT);
        nfpNetwork=transformnfp.addNfpSqrtComp(hN,latency,slRate,isSingle,isHalf);
    case 'nfp_exp_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'EXP',sigT);
        nfpNetwork=transformnfp.addNfpExpComp(hN,latency,slRate,isSingle,isHalf);
    case 'nfp_pow_comp'
        nfpNetwork=transformnfp.addNfpPowComp(hN,slRate,isSingle);
    case 'nfp_pow2_comp'
        nfpNetwork=transformnfp.addNfpPow2Comp(hN,slRate,isSingle);
    case 'nfp_pow10_comp'
        nfpNetwork=transformnfp.addNfpPow10Comp(hN,slRate,isSingle);
    case 'nfp_log_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Log',sigT);
        nfpNetwork=transformnfp.addNfpLogComp(hN,latency,slRate,isSingle,isHalf);
    case 'nfp_log2_comp'
        nfpNetwork=transformnfp.addNfpLog2Comp(hN,slRate,isSingle);
    case 'nfp_log10_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Log10',sigT);
        nfpNetwork=transformnfp.addNfpLog10Comp(hN,latency,slRate,isSingle,isHalf);
    case 'nfp_minmax_comp'
        nfpNetwork=transformnfp.addNfpMinMaxComp(hN,slRate,isSingle);
    case 'nfp_recip_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Recip',sigT);
        nfpNetwork=transformnfp.addNfpRecipComp(hN,latency,slRate,isSingle,isHalf);
    case 'nfp_hdlrecip_comp'
        nfpNetwork=transformnfp.addNfpHDLRecipComp(hN,slRate,hC.getIterNum,isSingle);
    case 'nfp_signum_comp'
        nfpNetwork=transformnfp.addNfpSignumComp(hN,slRate,isSingle);
    case 'nfp_sincos_comp'
        nfpNetwork=transformnfp.addNfpSinCosComp(hN,slRate,hC.getNFPArgReduction(),partMultOpt,isSingle);
    case 'nfp_atan2_comp'
        nfpNetwork=transformnfp.addNfpATan2Comp(hN,slRate,isSingle);
    case 'nfp_atan_comp'
        nfpNetwork=transformnfp.addNfpATanComp(hN,slRate,isSingle);
    case 'nfp_asin_comp'
        nfpNetwork=transformnfp.addNfpASinComp(hN,slRate,isSingle);
    case 'nfp_acos_comp'
        nfpNetwork=transformnfp.addNfpACosComp(hN,slRate,isSingle);
    case 'nfp_sin_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Sin',sigT);
        nfpNetwork=transformnfp.addNfpSinComp(hN,latency,slRate,hC.getNFPArgReduction(),partMultOpt,isSingle,isHalf);
    case 'nfp_cos_comp'
        [latency,customLatency]=transformnfp.getLatencyFromNfpComp(hC,'Cos',sigT);
        nfpNetwork=transformnfp.addNfpCosComp(hN,latency,slRate,hC.getNFPArgReduction(),partMultOpt,isSingle,isHalf);
    case 'nfp_tan_comp'
        nfpNetwork=transformnfp.addNfpTanComp(hN,slRate,hC.getNFPArgReduction(),isSingle);
    case 'nfp_sinh_comp'
        nfpNetwork=transformnfp.addNfpSinhComp(hN,slRate,isSingle);
    case 'nfp_cosh_comp'
        nfpNetwork=transformnfp.addNfpCoshComp(hN,slRate,isSingle);
    case 'nfp_tanh_comp'
        nfpNetwork=transformnfp.addNfpTanhComp(hN,slRate,isSingle);
    case 'nfp_asinh_comp'
        nfpNetwork=transformnfp.addNfpAsinhComp(hN,hC,slRate,isSingle);
    case 'nfp_acosh_comp'
        nfpNetwork=transformnfp.addNfpAcoshComp(hN,hC,slRate,isSingle);
    case 'nfp_atanh_comp'
        nfpNetwork=transformnfp.addNfpAtanhComp(hN,hC,slRate,isSingle);
    case 'nfp_trig_comp'
        nfpNetwork=transformnfp.addNfpTrigComp(hN,slRate,isSingle);
    case 'nfp_uminus_comp'
        nfpNetwork=transformnfp.addNfpUminusComp(hN,slRate,isSingle,isHalf);
    case 'nfp_rem_comp'
        nfpNetwork=transformnfp.addNfpRemComp(hN,slRate,isSingle);
    case 'nfp_mod_comp'
        nfpNetwork=transformnfp.addNfpModComp(hN,slRate,isSingle);
    case 'nfp_fma_comp'
        nfpNetwork=transformnfp.addNfpFMAComp(hN,slRate,isSingle);
    case 'nfp_hypot_comp'
        nfpNetwork=transformnfp.addNfpHypotComp(hN,slRate,isSingle);
    otherwise
        assert(true);
    end
    nfpNetwork.setNfpNetwork(true);
end


