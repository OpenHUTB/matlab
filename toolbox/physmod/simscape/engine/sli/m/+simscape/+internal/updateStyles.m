function updateStyles(name)






    if nargin==0
        name='MathWorks';
    end

    builtin('_simscape_apply_stylesheet',name);
    value=simscape.internal.getStylePreference();





    builtin('_simscape_line_styles',true);


    if strcmpi(value,'on')
        builtin('_simscape_line_styles',true);
    else
        builtin('_simscape_line_styles',false);
    end


    simscape.internal.stylerInitialized(true);

end






