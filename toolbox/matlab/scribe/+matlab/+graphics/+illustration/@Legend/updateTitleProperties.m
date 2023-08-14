function updateTitleProperties(hObj)




    t=hObj.Title_I;
    if~isempty(t)&&isvalid(t)
        if strcmp(t.ColorMode,'auto')
            t.Color_I=hObj.TextColor_I;
        end
        if strcmp(t.FontNameMode,'auto')
            t.FontName_I=hObj.FontName_I;
        end
        if strcmp(t.FontAngleMode,'auto')
            t.FontAngle_I=hObj.FontAngle_I;
        end
        if strcmp(t.FontSizeMode,'auto')
            t.FontSize_I=hObj.FontSize_I;
        end
        if strcmp(t.FontWeightMode,'auto')
            t.FontWeight_I='bold';
        end
        if strcmp(t.InterpreterMode,'auto')
            t.Interpreter_I=hObj.Interpreter_I;
        end
    end
