function result=isSupportedClass(className,name,path)



    import com.mathworks.toolbox.coder.plugin.inputtypes.ExampleConversionResult;

    msg='';
    try
        idp=emlcoder.EnumInputDataProperty(name);
        idp.class=className;
        if~idp.EnumType
            error(message('Coder:configSet:ExampleClassNotSupported',className,path));
        end
    catch ME
        msg=ME.message;
    end

    result=ExampleConversionResult(msg);

end
