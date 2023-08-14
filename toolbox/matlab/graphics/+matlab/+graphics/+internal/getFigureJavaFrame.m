function javaFrame=getFigureJavaFrame(fig)




    if ishghandle(fig,'figure')
        try
            javaFrame=get(fig,'JavaFrame_I');
        catch
            javaFrame=[];
        end
    else
        javaFrame=[];
    end
end
