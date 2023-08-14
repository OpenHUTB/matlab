function returnedValue=getUseAttributeSets(h,~)





    try
        if rptgen.use_java
            returnedValue=com.mathworks.toolbox.rptgen.xml.StylesheetEditor.getUseAttributeSets(h.JavaHandle);
        else
            returnedValue=mlreportgen.re.internal.ui.StylesheetEditor.getUseAttributeSets(h.JavaHandle);
        end

        if isempty(returnedValue)
            returnedValue={};
        else
            returnedValue=cellstr(char(returnedValue));
        end
    catch ME
        warning(ME.message);
        returnedValue={};
    end
