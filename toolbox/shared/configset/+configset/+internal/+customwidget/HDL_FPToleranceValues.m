function out=HDL_FPToleranceValues(cs,name,direction,widgetVals)



    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end
    cli=hObj.getCLI;
    strategy=cli.FPToleranceStrategy;

    if direction==0
        val=cli.(name);
        if ismember(strategy,{'DEFAULT','Relative'})
            out={num2str(val)};
        else
            out={cast(val,'int32')};
        end
    elseif direction==1
        if ismember(strategy,{'DEFAULT','Relative'})
            out=widgetVals{1};
        else
            out=cast(str2double(widgetVals{1}),'int32');
        end
    end

