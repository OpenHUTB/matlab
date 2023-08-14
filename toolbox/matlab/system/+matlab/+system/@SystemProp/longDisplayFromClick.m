function longDisplayFromClick(obj,variableName,className)



    fprintf('\n');

    if~strcmp(class(obj),className)
        disp(getString(message('MATLAB:system:FooterLinkFailureClassMismatch',variableName,className)));
    else
        try
            longDisplay(obj);
        catch
            disp(getString(message('MATLAB:system:FooterLinkFailure',variableName)));
        end
    end
end
