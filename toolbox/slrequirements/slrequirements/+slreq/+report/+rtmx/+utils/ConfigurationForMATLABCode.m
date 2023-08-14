classdef ConfigurationForMATLABCode<slreq.report.rtmx.utils.AbstractConfiguration




    methods



















        function this=ConfigurationForMATLABCode(configData)
            this.Domain='matlabcode';
            this.DomainLabel=getString(message('Slvnv:slreq_rtmx:DomainMATLABCode'));
            config{1}=this.createTypeConfig(configData);


            config{2}=this.createLinkConfig();

            if configData.AttributeList.Count
                config{3}=this.createAttributeConfig(configData,'Attributes');
            end

            this.ConfigList=config;
        end


    end
end
