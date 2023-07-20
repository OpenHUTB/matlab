function out=HDLInputOutputTypeValue(cs,param,direction,widgetVals)






    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end


    cli=hObj.getCLI;
    language=cli.TargetLanguage;

    if direction==0
        if strcmpi(language,'VHDL')
            out={cli.(param)};
        else
            out={'wire'};
        end
    elseif direction==1
        if strcmpi(language,'VHDL')
            out=widgetVals{1};
        else
            out=cli.(param);
        end

    end

