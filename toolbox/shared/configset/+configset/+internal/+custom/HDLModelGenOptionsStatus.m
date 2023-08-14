function status=HDLModelGenOptionsStatus(cs,optionVal)





    status=true;
    hdlcc=cs.getComponent('HDL Coder');
    cli=hdlcc.getCLI;

    if strcmp(optionVal.name,'AutoPlace')
        if~optionVal.value
            cli.AutoRoute='off';
        end
    elseif strcmp(optionVal.name,'AutoRoute')
        if strcmp(cli.AutoPlace,'off')
            cli.AutoRoute='off';
        end
    end

    if strcmp(optionVal.name,'GenerateModel')
        if~optionVal.value
            cli.GenerateValidationModel='off';
        end
    end
