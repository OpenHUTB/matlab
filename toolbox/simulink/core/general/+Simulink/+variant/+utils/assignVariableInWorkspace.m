function assignVariableInWorkspace(controlVariable)















    Simulink.variant.utils.assert(isstruct(controlVariable));

    if~isempty(controlVariable.Source)&&~strcmp(controlVariable.Source,'base')





        ddConn=Simulink.data.dictionary.open(controlVariable.Source);
        wks=ddConn.getSection('Design Data');
    else
        wks='base';
    end

    assignin(wks,controlVariable.Name,controlVariable.Value);

end


