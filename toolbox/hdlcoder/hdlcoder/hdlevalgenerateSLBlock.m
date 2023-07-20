function hdlevalgenerateSLBlock(input,path)









    if~(isfield(input,'generateSLBlockFunction')&&...
        isfield(input,'generateSLBlockParams'))
        error(message('hdlcoder:makehdl:invalidblackboxdata'));
    end

    fcn=input.generateSLBlockFunction;
    params=input.generateSLBlockParams;


    if~isempty(fcn)
        feval(fcn,params{:},path);
    end



