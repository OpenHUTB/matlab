function yesno=isComponentHarness(mdl,~)




    mdl=convertStringsToChars(mdl);

    if ischar(mdl)&&any(mdl==':')

        mdl=strtok(mdl,':');
    end


    try
        yesno=Simulink.harness.isHarnessBD(mdl);
    catch ex %#ok<NASGU>

        yesno=false;
    end
end

