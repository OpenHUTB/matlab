function result=example2xml(ex,name,~)



    import com.mathworks.toolbox.coder.plugin.inputtypes.ExampleConversionResult;

    message='';
    xml='';
    try
        val=evalin('base',ex);
        xITC=type2xml(coder.typeof(val),true,name);
        xml=xmlwrite(xITC);
    catch ME
        if isempty(ME.cause)
            message=ME.message;
        else

            ME=coderprivate.makeCause(ME);
            message=ME.getReport();
        end
    end

    result=ExampleConversionResult(message,xml);

end