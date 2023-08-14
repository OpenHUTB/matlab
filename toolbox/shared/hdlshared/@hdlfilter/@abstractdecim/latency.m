function[latency,initlatency,SLLatency]=latency(this)
















    phases=this.decimationfactor;
    latency=phases;
    mip=this.getHDLParameter('multiplier_input_pipeline');
    mop=this.getHDLParameter('multiplier_output_pipeline');
    initlatency=0;
    if this.getHDLParameter('filter_registered_input')==1
        initlatency=initlatency+1;
    end

    if this.getHDLParameter('filter_registered_output')==1
        initlatency=initlatency+1;
    end


    polycoeffs=this.polyphaseCoefficients;
    num_multipliers=length(polycoeffs(find(polycoeffs~=0)));
    additional_latency=0;
    if this.getHDLParameter('filter_pipelined')
        additional_latency=(ceil(log2(num_multipliers))+1)*this.decimationfactor;
    else
        if strcmpi(this.getHDLParameter('filter_fir_final_adder'),'pipelined')
            additional_latency=(ceil(log2(num_multipliers)))*this.decimationfactor;
        end
    end
    initlatency=initlatency+additional_latency;

    pipe=this.isPipelineSupported;

    if pipe.multinput
        initlatency=initlatency+this.getHDLParameter('multiplier_input_pipeline');
    end

    if pipe.multoutput
        initlatency=initlatency+this.getHDLParameter('multiplier_output_pipeline');
    end

    if strcmpi(this.implementation,'serial')
        pp_firlen=size(polycoeffs,2);
        latency=phases;
        if this.getHDLParameter('filter_registered_input')==1
            if this.getHDLParameter('filter_registered_output')==1

                initlatency=pp_firlen+4;
            else

                initlatency=pp_firlen+3;
            end
        else
            if this.getHDLParameter('filter_registered_output')==1

                initlatency=pp_firlen+3;
            else

                if mip+mop==this.getHDLParameter('foldingfactor')-1;
                    initlatency=pp_firlen+2;
                else
                    initlatency=pp_firlen+2;
                end
            end
        end
    else
        if strcmpi(this.implementation,'distributedarithmetic')

            radix=this.getHDLParameter('filter_daradix');
            baat=log2(radix);




            inputsize=hdlgetsizesfromtype(this.Inputsltype);
            ffactor=inputsize/baat;
            if phases==ffactor
                latency=phases;
                initlatency=phases+3;
            else
                if phases>ffactor
                    latency=phases;
                    initlatency=phases+3;
                else


                    latency=ceil(ffactor/phases)*phases;
                    initlatency=latency*2;
                end
            end
        end
    end

    preg=this.getHDLParameter('filter_pipelined');

    switch this.Implementation
    case{'serial','serialcascade'}
        SLLatency=0;
        if isa(this,'hdlfilter.firdecim')
            ff=this.getHDLParameter('foldingfactor');
            numcyles_wo_latchange=ff*phases-(ff+2+1);
            multcycles=mop+mip;
            if multcycles>numcyles_wo_latchange

                remainingcylcles=multcycles-numcyles_wo_latchange;
                SLLatency=SLLatency+ceil(remainingcylcles/(ff*phases));
            end
        end



    case 'parallel'
        SLLatency=0;

        if isa(this,'hdlfilter.firdecim')
            if preg
                non_zero_coeffs=length(find(this.polyphaseCoefficients(:)));
                SLLatency=SLLatency+ceil(log2(non_zero_coeffs));

            end
            if mip>0
                SLLatency=SLLatency+this.getHDLParameter('multiplier_input_pipeline');
            end
            if mop>0
                SLLatency=SLLatency+this.getHDLParameter('multiplier_output_pipeline');
            end

        else
            numcyles_wo_latchange=phases-1;
            multcycles=mop+mip;
            if multcycles>numcyles_wo_latchange

                remainingcylcles=multcycles-numcyles_wo_latchange;
                SLLatency=SLLatency+ceil(remainingcylcles/phases);
            end
        end
    case 'distributedarithmetic'
        if inputsize==baat
            if phases>2
                SLLatency=0;
            else
                SLLatency=1;


            end
        else

            ffactor=inputsize/baat;
            if phases>=ffactor
                count_to=phases;
            else

                count_to=phases*ceil(ffactor/phases);
            end
            SLLatency=1;

            if count_to<4
                SLLatency=SLLatency+1;



            end
        end
        preg=this.getHDLParameter('filter_pipelined');
        if preg


            SLLatency=SLLatency+ceil(log2(phases))-1;
        end
    end





