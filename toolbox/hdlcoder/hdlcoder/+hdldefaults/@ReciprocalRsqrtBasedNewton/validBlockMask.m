function v=validBlockMask(~,slbh)





    v=true;
    if slbh<0
        return;
    end

    type=hdlgetblocklibpath(slbh);
    isMath=~isempty(strfind(type,'Math'));
    isProduct=~isempty(strfind(type,'Product'));

    if(isMath)
        functionName=get_param(slbh,'Function');
    elseif(isProduct)
        inputsigns=get_param(slbh,'Inputs');
        inputsigns=strrep(inputsigns,'|','');

        functionName='Product';
        if~isempty(strfind(inputsigns,'/'))
            if strcmpi(inputsigns,'/')
                functionName='Reciprocal';
            end
        end
    end

    if(~strcmpi(functionName,'Reciprocal'))
        v=false;
        return;
    end

    isMathRecipNR=isMath&&strcmpi(functionName,'Reciprocal')&&strcmpi(get_param(slbh,'AlgorithmMethod'),'Newton-Raphson');
    if isMathRecipNR
        v=false;
    end
