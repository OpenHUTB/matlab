function outValue=evalinWorkspaceAndSimulink(model,expressionIn)




    try
        [~,outValue]=evalin('base',"evalc('"+expressionIn+"')");
        if isa(outValue,'Simulink.Parameter')
            outValue=outValue.Value;
        end

    catch
        try
            outValue=slwebwidgets.tableeditor.evalinSimulink(model,expressionIn);
        catch
            outValue=[];
        end
    end
