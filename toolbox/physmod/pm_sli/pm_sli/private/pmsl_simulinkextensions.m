function ext=pmsl_simulinkextensions




    persistent pExtensions;

    if isempty(pExtensions)
        pExtensions={'mdl','slx'};
    end

    ext=pExtensions;

end
