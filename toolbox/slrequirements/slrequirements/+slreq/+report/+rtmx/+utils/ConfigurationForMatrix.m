classdef ConfigurationForMatrix<slreq.report.rtmx.utils.AbstractConfiguration
    methods





















        function this=ConfigurationForMatrix(configData)


            this.Domain='Matrix';
            this.DomainLabel='Matrix';


            matrixConfig{1}=this.createConfigBoolProp('HasChangedLink','Link');


            config{1}=this.createConfig('Matrix',matrixConfig);
            this.ConfigList=config;
        end


    end
end
