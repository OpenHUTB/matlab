function out=getDisplayIcon(obj)




    cs=obj.Source.Source;
    isActive=~isempty(cs.getModel)&&cs.isActive;
    if isa(cs,'Simulink.ConfigSetRef')
        if isActive
            icon='ActiveConfigurationReference.png';
        else
            icon='ConfigurationReference.png';
        end
    else
        if isActive
            icon='ActiveConfiguration_24.png';
        else
            icon='Configuration_24.png';
        end
    end
    out=['toolbox/shared/dastudio/resources/',icon];
