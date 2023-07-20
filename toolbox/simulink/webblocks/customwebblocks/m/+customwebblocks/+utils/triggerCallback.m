function triggerCallback(~,code)
    try
        evalin('base',code);
    catch e

        Simulink.output.error(e);
    end
end