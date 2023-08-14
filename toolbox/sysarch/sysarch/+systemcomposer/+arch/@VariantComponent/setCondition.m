function setCondition(this,choice,expr)









    narginchk(3,3);
    if~this.isChoiceWithinVariant(choice)
        error('systemcomposer:API:SetGetConditionInvalidArg',message('SystemArchitecture:API:SetGetConditionInvalidArg').getString);
    end
    set_param(choice.SimulinkHandle,'VariantControl',expr);
end