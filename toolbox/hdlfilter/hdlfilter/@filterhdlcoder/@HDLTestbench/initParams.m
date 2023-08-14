function initParams(this)





    this.initParamsCommon;

    if hdlgetparameter('bit_true_to_filter')==0||...
        strcmpi(hdlgetparameter('filter_fir_final_adder'),'tree')||...
        strcmpi(hdlgetparameter('filter_fir_final_adder'),'pipelined')||...
        (strcmpi(hdlgetparameter('filter_fir_final_adder'),'linear')&&hdlgetparameter('filter_pipelined'))||...
        strcmpi(this.HDLFilterComp.Implementation,'serial')||strcmpi(this.HDLFilterComp.Implementation,'serialcascade')
        warning(message('hdlfilter:filterhdlcoder:HDLTestbench:initParams:inexactresults'));

        if isempty(hdlgetparameter('error_margin'))
            comparethreshold=15;
            warning(message('hdlfilter:filterhdlcoder:HDLTestbench:initParams:defaulterrormargin'));
        else
            if hdlgetparameter('error_margin')<=0
                comparethreshold=0;
            else
                comparethreshold=floor(2.^hdlgetparameter('error_margin')-1);
            end
        end
    else
        comparethreshold='0';
    end


    this.fixedPointErrorMargin=num2str(comparethreshold);
    this.doubleErrorMargin='1.0e-9';

