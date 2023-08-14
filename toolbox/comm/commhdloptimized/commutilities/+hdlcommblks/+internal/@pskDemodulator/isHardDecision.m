function tf=isHardDecision(this,hC)










    if isa(hC,'hdlcoder.sysobj_comp')
        sysObjHandle=hC.getSysObjImpl;
        if isa(sysObjHandle,'comm.BPSKDemodulator')
            tf=strcmpi(sysObjHandle.DecisionMethod,'Hard decision');
        else
            if~sysObjHandle.BitOutput
                tf=true;
            else
                tf=strcmpi(sysObjHandle.DecisionMethod,'Hard decision');
            end
        end
    else
        bfp=hC.SimulinkHandle;

        switch(this.Blocks{1})

        case 'commdigbbndpm3/BPSK Demodulator Baseband'

            tf=strcmpi(get_param(bfp,'DecType'),'Hard decision');

        otherwise




            if strcmpi(get_param(bfp,'OutType'),'Integer')
                tf=true;
            else
                if strcmpi(get_param(bfp,'DecType'),'Hard decision')
                    tf=true;
                else
                    tf=false;
                end
            end


        end
    end




end
