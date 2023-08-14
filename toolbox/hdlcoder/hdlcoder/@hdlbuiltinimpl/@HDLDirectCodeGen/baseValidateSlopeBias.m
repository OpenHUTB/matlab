function v=baseValidateSlopeBias(this,hC)



















    v=hdlvalidatestruct;
    bfp=hC.SimulinkHandle;

    params_to_check=this.slopeBiasParametersToCheck;

    found_slope_bias=false;

    for ii=1:numel(params_to_check)
        param_str=get_param(bfp,params_to_check{ii});
        if strcmpi(param_str,'Slope and bias scaling')
            found_slope_bias=true;
            break;
        end
    end

    if found_slope_bias
        v=hdlvalidatestruct(1,...
        message('hdlcoder:validate:unsupportedslopebias'));
    end
