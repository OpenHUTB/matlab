function storedValue=setUseAttributeSets(h,proposedValue)




    try
        if rptgen.use_java
            com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setUseAttributeSets(h.JavaHandle,proposedValue);
        else
            mlreportgen.re.internal.ui.StylesheetEditor.setUseAttributeSets(h.JavaHandle,proposedValue);
        end
    catch ME
        warning(ME.message);
    end

    storedValue={};
