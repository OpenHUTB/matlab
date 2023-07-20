classdef ConfigurationForHighlighting<slreq.report.rtmx.utils.AbstractConfiguration




    methods





















        function this=ConfigurationForHighlighting(configData)


            this.Domain='Highlight';
            this.DomainLabel='Highlight';

            highlightConfig{3}=this.createConfigBoolProp('FailedTest','TestStatus');
            highlightConfig{2}=this.createConfigBoolProp('HasChangedLink','Link');
            highlightConfig{1}=this.createConfigBoolProp('HasNoLink','Link');
            highlightConfig{1}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelLinkHasNoLink'));
            highlightConfig{2}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelChangeWithChangeIssue'));

            config{1}=this.createConfig('Highlight',highlightConfig);


            this.ConfigList=config;
        end


    end
end
