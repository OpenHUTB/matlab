function regexp_MAAB_InputParamCB(taskobj,tag,handle)%#ok<INUSD>
    if strcmp(tag,'InputParameters_1')
        if isa(taskobj,'ModelAdvisor.Task')
            inputParameters=taskobj.Check.InputParameters;
        elseif isa(taskobj,'ModelAdvisor.ConfigUI')
            inputParameters=taskobj.InputParameters;
        else
            return
        end
        switch inputParameters{1}.Value
        case{'MAB','JMAAB'}
            inputParameters{2}.Value=getDefaultRegularExpression(taskobj);
            inputParameters{2}.Enable=false;
        case 'Custom'
            inputParameters{2}.Enable=true;
        end
    end
end

function regexpStr=getDefaultRegularExpression(taskobj)
    switch taskobj.MAC
    case 'mathworks.maab.jc_0231'
        regexpStr=ModelAdvisor.Common.getDefaultRegularExpression_jc_0231;
    case 'mathworks.maab.jc_0211'
        regexpStr=ModelAdvisor.Common.getDefaultRegularExpression_jc_0211;
    case{'mathworks.maab.jc_0201','mathworks.maab.na_0030'}

        regexpStr=ModelAdvisor.Common.getDefaultRegularExpression_jc_0201;
    case{'mathworks.jmaab.jc_0222','mathworks.jmaab.jc_0232'}
        regexpStr=Advisor.Utils.Naming.getRegExp('JMAAB');
    otherwise
        regexpStr=Advisor.Utils.Naming.getRegExp('JMAAB');

    end
end
