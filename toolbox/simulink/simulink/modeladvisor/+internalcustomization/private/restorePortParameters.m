
function restorePortParameters(ph,prmNames,prmVals)
    for j=1:length(prmNames)
        try
            set_param(ph,prmNames{j},prmVals{j});
        catch e
            warning(e.message);
        end
    end
end