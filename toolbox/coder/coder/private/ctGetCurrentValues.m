function values=ctGetCurrentValues(javaContexts)
    values=cell(length(javaContexts),1);
    nullValue=com.mathworks.toolbox.coder.target.JavaCallbackContext.MATLAB_NULL;

    for i=1:length(javaContexts)
        javaContext=javaContexts(i);

        try
            [value,~]=ctFireCallback(javaContext);
        catch
            value=nullValue;
        end

        values{i}=value;
    end
end