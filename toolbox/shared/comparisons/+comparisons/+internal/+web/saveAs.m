function saveAs(filename,contents)



    try
        import com.google.common.base.Charsets;
        import com.google.common.io.Files;
        import java.io.File;
        import java.lang.String;

        Files.write(String(contents),File(filename),Charsets.UTF_8);
    catch exception
        import com.mathworks.comparisons.exception.SwingExceptionHandler;

        if isa(exception,'matlab.exception.JavaException')
            SwingExceptionHandler.handle(exception.ExceptionObject);
        else
            disp(exception.getReport());
        end
    end
end