function values=ctGetInitialValues(javaContexts)
    values=cell(length(javaContexts),1);
    nullValue=com.mathworks.toolbox.coder.target.JavaCallbackContext.MATLAB_NULL;
    configSet=[];

    for i=1:length(javaContexts)
        javaContext=javaContexts(i);

        try
            [value,~,~,configSet]=ctFireCallback(javaContext,configSet);
        catch
            value=nullValue;
        end

        values{i}=value;
    end
end