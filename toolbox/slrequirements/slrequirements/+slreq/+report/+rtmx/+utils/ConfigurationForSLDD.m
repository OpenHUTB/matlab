classdef ConfigurationForSLDD<slreq.report.rtmx.utils.AbstractConfiguration




    methods



















        function this=ConfigurationForSLDD(configData)


            this.Domain='sldd';
            this.DomainLabel=getString(message('Slvnv:slreq_rtmx:DomainDataDictionary'));

            config{1}=this.createTypeConfig(configData);















            config{2}=this.createLinkConfig();

            this.ConfigList=config;
        end


    end
end
