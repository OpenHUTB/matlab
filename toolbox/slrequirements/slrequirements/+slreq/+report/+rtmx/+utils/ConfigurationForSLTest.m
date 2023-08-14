classdef ConfigurationForSLTest<slreq.report.rtmx.utils.AbstractConfiguration




    methods















        function this=ConfigurationForSLTest(configData)


            this.Domain='sltest';
            this.DomainLabel=getString(message('Slvnv:slreq_rtmx:DomainSimulinkTest'));

            config{1}=this.createTypeConfig(configData);
            config{2}=this.createLinkConfig();

            if configData.KeywordList.Count
                config{3}=this.createKeywordConfig(configData,'Tags',getString(message('Slvnv:slreq_rtmx:FilterSLTestTags')));
            end
            this.ConfigList=config;
        end


    end
end
