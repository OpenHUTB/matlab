function simrfV2_set_netpar_defaults(dialog)









    source=dialog.getSource;
    if strcmpi(get_param(source,'Paramtype'),'S-parameters')&&...
        strcmpi(get_param(source,'Sparam'),'[0 0;1 0]')
        if any(strcmpi(source.Sparam,...
            {'[0 0;1 0]','[.02 0;-.04 .02]','[50 0;100 50]'}))
            switch source.Paramtype
            case 'S-parameters'
                source.Sparam='[0 0;1 0]';
            case 'Y-parameters'
                source.Sparam='[.02 0;-.04 .02]';
            case 'Z-parameters'
                source.Sparam='[50 0;100 50]';
            end
        end
    end

end