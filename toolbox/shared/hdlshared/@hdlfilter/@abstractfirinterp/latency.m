function[latency,initlatency,SLLatency]=latency(this)




    factor=this.InterpolationFactor;

    mip=this.getHDLParameter('multiplier_input_pipeline');
    mop=this.getHDLParameter('multiplier_output_pipeline');
    latency=0;
    if this.getHDLParameter('filter_registered_input')==1
        latency=latency+factor;
    end

    if this.getHDLParameter('filter_registered_output')==1
        latency=latency+1;
    end
    latency=latency+mip+mop;
    latency=latency+this.getHDLParameter('filter_excess_latency');
    initlatency=latency;
    latency=1;
    SLLatency=0;
    if strcmpi(this.implementation,'serial')
        initlatency=this.getHDLParameter('filter_excess_latency');
        if this.getHDLParameter('foldingfactor')==1
            initlatency=initlatency+this.getHDLParameter('foldingfactor');
        else
            initlatency=initlatency+this.getHDLParameter('foldingfactor')+1;
        end

        if this.getHDLParameter('filter_registered_input')
            initlatency=initlatency+1;
            if this.getHDLParameter('filter_registered_output')

                initlatency=initlatency+1;
            else

            end
        else
            if this.getHDLParameter('filter_registered_output')

                initlatency=initlatency+1;
            else

            end
        end
        latency=1;
        initlatency=initlatency+mip+mop;
        SLLatency=ceil((1+initlatency)/this.getHDLParameter('foldingfactor'))-1;



    end
    if strcmp(this.Implementation,'distributedarithmetic')
        radix=this.getHDLParameter('filter_daradix');
        baat=log2(radix);
        inpall=hdlgetallfromsltype(this.inputsltype);
        inputsize=inpall.size;

        [inprate,oprate]=this.gettbclkrate;%#ok
        latency=inprate;
        latency=latency+1;
        if this.getFoldingFactor==1&&inputsize~=baat
            latency=latency+1;
        end





        initlatency=latency;
        latency=1;
        SLLatency=ceil((1+initlatency)/this.getHDLParameter('foldingfactor'))-1;
    end

    preg=this.getHDLParameter('filter_pipelined');
    if strcmp(this.Implementation,'parallel')
        if preg
            SLLatency=0;
            fl=this.getfilterlengths;
            SLLatency=SLLatency+ceil(log2(fl.polyfirlen))-1;
        end
        SLLatency=SLLatency+mip+mop;
    end

