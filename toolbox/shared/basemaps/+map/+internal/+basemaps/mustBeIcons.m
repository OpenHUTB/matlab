function mustBeIcons(icons)









    if~matches(icons,"auto","IgnoreCase",true)
        for k=1:length(icons)
            icon=convertStringsToChars(icons(k));


            [~,iconType]=matlab.ui.internal.IconUtils.validateIcon(icon);



            if strcmp(iconType,'preset')

                throwAsCaller(MException(message('MATLAB:ui:components:invalidIconFile')));
            end
        end
    end
end
