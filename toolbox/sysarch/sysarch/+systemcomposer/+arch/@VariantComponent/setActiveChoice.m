function setActiveChoice(this,choice)








    narginchk(2,2);
    if this.isChoiceWithinVariant(choice)
        label=get_param(choice.SimulinkHandle,'VariantControl');
    elseif ischar(choice)||isstring(choice)
        if(strcmpi(get_param(this.SimulinkHandle,'VariantControlMode'),'expression'))
            error('systemcomposer:API:SetChoiceInvalidMode',message('SystemArchitecture:API:SetChoiceInvalidMode').getString);
        end
        label=choice;
    else
        error('systemcomposer:API:SetChoiceInvalidInput',message('SystemArchitecture:API:SetChoiceInvalidInput').getString);
    end
    set_param(this.SimulinkHandle,'LabelModeActiveChoice',label);
end
