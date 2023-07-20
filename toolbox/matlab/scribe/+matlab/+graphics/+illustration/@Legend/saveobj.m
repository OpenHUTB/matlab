function hObj=saveobj(hObj)







    t=hObj.Title_I;
    if~isempty(t)
        if isvalid(t)


            if isempty(t.String)&&...
                strcmp(t.ColorMode,'auto')&&...
                strcmp(t.FontNameMode,'auto')&&...
                strcmp(t.FontAngleMode,'auto')&&...
                strcmp(t.FontSizeMode,'auto')&&...
                strcmp(t.FontWeightMode,'auto')&&...
                strcmp(t.InterpreterMode,'auto')


                t.Parent=matlab.graphics.primitive.world.Group.empty();


                hObj.Title_I=matlab.graphics.illustration.legend.Text.empty();
            end
        else


            hObj.Title_I=matlab.graphics.illustration.legend.Text.empty();
        end
    end

end
