function out=thermalNetworkTopology(in)
















    out=in;


    if~isempty(in.getValue('thermal_network_parameterization'))
        thermal_network_parameterization=in.getValue('thermal_network_parameterization');
        thermal_network_parameterization=strrep(thermal_network_parameterization,...
        'ee.enum.thermalNetworkTopology.cauer','ee.enum.thermalNetworkTopology.junctionCase');
        out=out.setValue('thermal_network_parameterization',thermal_network_parameterization);
    end

end