function v=validateBlock(this,hC)




    v=hdlvalidatestruct;


    if isa(hC.PirInputSignals.Type.getLeafType,'hdlcoder.tp_double')||...
        isa(hC.PirOutputSignals.Type.getLeafType,'hdlcoder.tp_double')

        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:pskDemodulator:validateBlock:doubletype'));
    end


    if~this.isHardDecision(hC)
        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:pskDemodulator:validateBlock:harddecision'));
    end


    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        if isa(sysObjHandle,'comm.PSKDemodulator')
            M=sysObjHandle.ModulationOrder;
            if~any(M==[2,4,8])
                v=error_M_not248(v);
            end
        end
    else
        bfp=hC.SimulinkHandle;
        if strcmpi(this.Blocks{1},'commdigbbndpm3/M-PSK Demodulator Baseband')
            M=this.hdlslResolve('M',bfp);
            if~any(M==[2,4,8])
                v=error_M_not248(v);
            end
        end
    end



    RequiredArrayLen=1;
    msg=dsphdlshared.validation.getMultiSymbolValidationMessage(hC.PirInputSignals(1),...
    RequiredArrayLen);

    v(end+1)=baseValidateVectorPortLength(this,hC.PirInputSignals(1),...
    RequiredArrayLen,msg);

end

function v=error_M_not248(v)
    v(end+1)=hdlvalidatestruct(1,...
    message('comm:hdl:pskDemodulator:validateBlock:M248'));
end
