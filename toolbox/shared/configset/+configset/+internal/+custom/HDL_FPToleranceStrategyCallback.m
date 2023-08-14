function updateDeps=HDL_FPToleranceStrategyCallback(cs,msg)




    updateDeps=true;
    strategy=msg.value;

    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end
    cli=hObj.getCLI;

    if ismember(strategy,{'DEFAULT','Relative'})
        cli.FPToleranceValue=1e-07;
    else
        cli.FPToleranceValue=0;
    end


