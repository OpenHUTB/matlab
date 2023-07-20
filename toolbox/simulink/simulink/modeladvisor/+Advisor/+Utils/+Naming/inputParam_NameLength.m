function inputParam_NameLength(taskobj,tag,handle)%#ok<INUSD>







    if strcmp(tag,'InputParameters_3')
        if isa(taskobj,'ModelAdvisor.Task')
            inputParameters=taskobj.Check.InputParameters;
        elseif isa(taskobj,'ModelAdvisor.ConfigUI')
            inputParameters=taskobj.InputParameters;
        else
            return
        end

        switch inputParameters{3}.Value
        case 'JMAAB'

            [inputParameters{4}.Value,inputParameters{5}.Value]=...
            Advisor.Utils.Naming.getNameLength('JMAAB');
            inputParameters{4}.Enable=false;
            inputParameters{5}.Enable=false;
        case 'Custom'
            inputParameters{4}.Enable=true;
            inputParameters{5}.Enable=true;
        otherwise

        end

    end
end
