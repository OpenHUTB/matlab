function pvalue=getblkparam(~,block,param)







    if strcmpi(param,'roundingmode')
        pvalue=get(block,'RndMeth');
    elseif strcmpi(param,'overflowmode')
        pvalue=get(block,'DoSatur');
    else
        error(message('hdlcoder:validate:InvalidParam',param));
    end
