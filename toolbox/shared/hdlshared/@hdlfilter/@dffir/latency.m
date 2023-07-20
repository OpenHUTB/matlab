function[latency,initlatency,SLLatency]=latency(this)




    latency=0;
    if this.getHDLParameter('filter_registered_input')==1
        latency=latency+1;
    end

    if this.getHDLParameter('filter_registered_output')==1
        latency=latency+1;
    end





    latency=latency+this.getHDLParameter('filter_excess_latency');
    initlatency=this.getHDLParameter('foldingfactor')*latency;

    mip=this.getHDLParameter('multiplier_input_pipeline');
    mop=this.getHDLParameter('multiplier_output_pipeline');
    number_channel=this.getHDLParameter('filter_generate_multichannel');


    if strcmpi(this.implementation,'serial')||strcmpi(this.implementation,'serialcascade')
        if this.getHDLParameter('filter_registered_input')==1
            if this.getHDLParameter('filter_registered_output')==1

                latency=3;
                initlatency=(latency-1)*this.getHDLParameter('foldingfactor')+1+mip+mop;




                if~mod(mip+mop+1,this.getHDLParameter('foldingfactor'))
                    initlatency=initlatency+1;
                end
            else

                latency=3;
                initlatency=this.getHDLParameter('foldingfactor')+2+mip+mop;
            end
        else
            if this.getHDLParameter('filter_registered_output')==1

                latency=3;
                initlatency=(latency-1)*this.getHDLParameter('foldingfactor')+1+mip+mop;
            else

                latency=2;
                if mip+mop==this.getHDLParameter('foldingfactor')-1;
                    initlatency=(latency-1)*this.getHDLParameter('foldingfactor')+1+mip+mop+1;

                else
                    initlatency=(latency-1)*this.getHDLParameter('foldingfactor')+1+mip+mop;
                end

            end
        end
    else
        if strcmpi(this.implementation,'distributedarithmetic')

            radix=this.getHDLParameter('filter_daradix');
            baat=log2(radix);
            lpi=this.getHDLParameter('filter_dalutpartition');
            inputall=hdlgetallfromsltype(this.inputSLtype);
            inputsize=inputall.size;
            ffactor=this.getHDLParameter('foldingfactor');
            if strcmpi(this.getHDLParameter('filter_fir_final_adder'),'pipelined')||...
                this.getHDLParameter('filter_pipelined')
                nbaatPipeRegs=max((ceil(log2(baat))-1),0);
                nlutPipeRegs=max((ceil(log2(length(lpi)))),0);
                xcycles=nbaatPipeRegs+nlutPipeRegs;
            else
                xcycles=0;
            end
            if baat==inputsize
                latency=2+xcycles;

            else
                latency=2+ceil((2+xcycles)/ffactor);



            end
            initlatency=(latency-1)*ffactor+1;
        end
    end

    switch this.Implementation
    case{'serial','serialcascade'}
        SLLatency=latency-1;


        ff=this.getHDLParameter('foldingfactor');
        numcyles_wo_latchange=ff-2;
        multcycles=mop+mip;
        if multcycles>numcyles_wo_latchange

            remcylcles=multcycles-numcyles_wo_latchange;
            SLLatency=SLLatency+ceil(remcylcles/ff);
        end

    case 'parallel'
        preg=this.getHDLParameter('filter_pipelined');
        fl=this.getfilterlengths;
        SLLatency=0;

        if~(hdlgetparameter('requestedoptimslowering')||hdlgetparameter('forcedlowering'))
            if preg
                SLLatency=SLLatency+ceil(log2(fl.czero_len));
            end
            if mip>0
                SLLatency=SLLatency+this.getHDLParameter('multiplier_input_pipeline');
            end
            if mop>0
                SLLatency=SLLatency+this.getHDLParameter('multiplier_output_pipeline');
            end
        end
        if number_channel>1
            SLLatency=floor(SLLatency/number_channel)+1;
        end

    case 'distributedarithmetic'
        if baat==inputsize
            SLLatency=latency;


        else
            SLLatency=latency-1;
        end

    end


