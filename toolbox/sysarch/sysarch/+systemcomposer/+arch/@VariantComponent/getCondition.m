function expr=getCondition(this,choice)







    narginchk(2,2);
    if~this.isChoiceWithinVariant(choice)
        error('systemcomposer:API:SetGetConditionInvalidArg',message('SystemArchitecture:API:SetGetConditionInvalidArg').getString);
    end
    expr=get_param(choice.SimulinkHandle,'VariantControl');
end