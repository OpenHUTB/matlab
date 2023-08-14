function[width,height]=getLabelSizeInPoints(updateState,textObj)




    try
        size=updateState.getStringBounds(textObj.String,textObj.Font,...
        textObj.Interpreter,textObj.FontSmoothing);
    catch err
        if strcmp(err.identifier,'MATLAB:hg:textutils:StringSyntaxError')
            size=updateState.getStringBounds(textObj.String,textObj.Font,...
            'none',textObj.FontSmoothing);
        else
            rethrow(err);
        end
    end
    width=size(1);
    height=size(2);
end