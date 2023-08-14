classdef ConfigurationForSLModel<slreq.report.rtmx.utils.AbstractConfiguration




    methods



















        function this=ConfigurationForSLModel(configData)


            this.Domain='simulink';
            this.DomainLabel=getString(message('Slvnv:slreq_rtmx:DomainModels'));
















            config{1}=this.createTypeConfig(configData);


            config{2}=this.createLinkConfig(configData);










            this.ConfigList=config;
        end

        function out=createLinkConfig(this,configData)
            linkConfig{1}=this.createConfigBoolProp('HasNoLink','Link');
            linkConfig{1}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelLinkHasNoLink'));
            linkConfig{1}.Tooltip=getString(message('Slvnv:slreq_rtmx:FilterPanelLinkHasNoLinkTooltip'));
            linkConfig{1}.TooltipPosition='after';

            [~,modelName]=fileparts(configData.ArtifactID);
            if~Simulink.internal.isArchitectureModel(modelName)
                linkConfig{1}.ExcludedProp={'Link','HasNoExpectedLink'};
                linkConfig{2}=this.createConfigBoolProp('HasNoExpectedLink','Link');
                linkConfig{2}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelLinkMissingExpectLink'));
                hislPage=strcat(docroot,'/simulink/mdl_gd/hi/requirements.html');
                if ispc


                    hislPage=strrep(hislPage,'\','\\');
                end
                onclickString=['onclick="require([''slreqrtmx/js/controllers/DataUtils''], function (dataUtils) {dataUtils.openHelpPage(''',hislPage,''');});"'];
                linkConfig{2}.Tooltip=getString(message('Slvnv:slreq_rtmx:FilterPanelLinkMissingExpectLinkTooltip',['<a href="#" ',onclickString,'>HISL 0070</a>']));
                linkConfig{2}.TooltipPosition='after';
                linkConfig{2}.QueryName='ExpectedMissingLinks';
                linkConfig{2}.ExcludedProp={'Link','HasNoLink'};
            end
            out=this.createConfig('Link',linkConfig);
            out.ConfigLabel=getString(message('Slvnv:slreq:Link'));
        end
        function out=createSubsystemConfig(this)
            ssConfig{1}=this.createConfigBoolProp('No','SubsysNoLinkedContent');
            ssConfig{1}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelBlocksUnderLinkedSubsystem'));
            onclickString='onclick="require([''slreqrtmx/js/controllers/DataUtils''], function (dataUtils) {dataUtils.openHelpPage(helpview(strcat(docroot, ''/simulink/mdl_gd/hi/requirements.html'')););});"';
            ssConfig{1}.Tooltip=[getString(message('Slvnv:slreq_rtmx:FilterPanelBlocksUnderLinkedSubsystem')),['<a href="#" ',onclickString,'>test click</a>']];
            ssConfig{1}.TooltipPosition='after';
            out=this.createConfig('SubsysNoLinkedContent',ssConfig);
            out.ConfigLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelUnlinked'));
        end
    end
end
