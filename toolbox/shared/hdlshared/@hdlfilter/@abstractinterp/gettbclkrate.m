function[inprate,outprate]=gettbclkrate(this)






    radix=this.getHDLParameter('filter_daradix');
    baat=log2(radix);

    phases=this.interpolationfactor;
    inpall=hdlgetallfromsltype(this.inputsltype);
    inputsize=inpall.size;
    if~(strcmp(this.implementation,'distributedarithmetic')&&baat~=inputsize)

        inprate=this.InterpolationFactor*this.getHDLParameter('foldingfactor');
        outprate=this.getHDLParameter('foldingfactor')/inprate;
    else
        final_adder_style=this.getHDLParameter('filter_fir_final_adder');
        if this.getHDLParameter('filter_pipelined')
            final_adder_style='pipelined';
        end
        if strcmpi(final_adder_style,'pipelined')
            ffactor=inputsize/baat+ceil(log2(baat))-1;
        else
            ffactor=inputsize/baat;
        end
        if phases==ffactor
            inprate=ffactor;
        else
            if phases>ffactor




                inprate=phases;
            else

                inprate=phases*ceil(ffactor/phases);

            end
        end
        outprate=1/this.InterpolationFactor;
    end

