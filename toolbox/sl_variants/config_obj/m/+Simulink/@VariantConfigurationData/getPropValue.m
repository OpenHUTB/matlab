function propValue=getPropValue(~,propName)







    switch(propName)
    case 'DataType'
        propValue='Simulink.VariantConfigurationData';
    otherwise
        propValue='';
    end
end
