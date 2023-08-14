function flag=isCompoundCtrlVarType(value)










    if ischar(value)||isStringScalar(value)

        ctrlVarValue=str2num(value);%#ok<ST2NM>
        if isempty(ctrlVarValue)
            flag=true;
            return;
        end
    else
        ctrlVarValue=value;
    end

    if isempty(ctrlVarValue)||numel(ctrlVarValue)>1
        flag=true;
    elseif isnumeric(ctrlVarValue)||isa(ctrlVarValue,'logical')||...
        isenum(ctrlVarValue)||isnumeric(ctrlVarValue)
        flag=false;
    elseif isa(ctrlVarValue,'Simulink.Parameter')||...
        isa(ctrlVarValue,'Simulink.VariantControl')
        flag=false;
    else
        flag=true;
    end
end
