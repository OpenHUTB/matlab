function tf=isequal(vcdo1,vcdo2)








    tf=false;

    vcd_class='Simulink.VariantConfigurationData';
    if(~isa(vcdo1,vcd_class)&&isa(vcdo2,vcd_class))...
        ||(isa(vcdo1,vcd_class)&&~isa(vcdo2,vcd_class))


        return;
    end

    if~isequal(vcdo1.Configurations,vcdo2.Configurations)

        return;
    end

    if~isequal(vcdo1.VariantConfigurations,vcdo2.VariantConfigurations)

        return;
    end

    if~isequal(vcdo1.PreferredConfiguration,vcdo2.PreferredConfiguration)

        return;
    end

    if~isequal(vcdo1.DefaultConfigurationName,vcdo2.DefaultConfigurationName)

        return;
    end

    if~isequal(vcdo1.Constraints,vcdo2.Constraints)

        return;
    end

    tf=true;
end