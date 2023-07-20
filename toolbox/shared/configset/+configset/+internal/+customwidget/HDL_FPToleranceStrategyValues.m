function out=HDL_FPToleranceStrategyValues(cs,name,direction,widgetVals)


    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end

    if direction==0
        cli=hObj.getCLI;
        val=cli.(name);
        if strcmpi(val,'DEFAULT')
            out={'Relative'};
        else
            out={val};
        end
    elseif direction==1
        out=widgetVals{1};
    end

