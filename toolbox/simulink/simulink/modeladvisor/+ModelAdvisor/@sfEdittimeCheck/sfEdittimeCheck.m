classdef(CaseInsensitiveProperties=true)sfEdittimeCheck<slcheck.Check




    methods
        function CheckObj=sfEdittimeCheck(config)

            mlock;

            config=ModelAdvisor.sfEdittimeCheck.configurationAdapter(config);
            CheckObj=CheckObj@slcheck.Check(config.checkID,config.SubCheckCfg,config.checkGroup);
            CheckObj.SupportsEditTime=true;
            CheckObj.SupportsCppCodeReuse=true;
            CheckObj.relevantEntities=@slcheck.SFEditTimeCheck.getRelevantBlocks;
            CheckObj.setDefaultInputParams();
            CheckObj.LicenseString=config.license;
        end
    end
    methods(Static)

        function config=configurationAdapter(config)

            if isfield(config,'SubCheckCfg')
                return;
            end

            config.SubCheckCfg.Type='Normal';
            config.SubCheckCfg(1).subcheck.ID='slcheck.SFEditTimeCheck';

            if~isfield(config,'SFETMsgCataloguePrefix')||...
                isempty(config.SFETMsgCataloguePrefix)
                DAStudio.warning('ModelAdvisor:engine:SFEditTimePrefix');
            end

            config.SubCheckCfg.subcheck.InitParams.SFETMsgCataloguePrefix=config.SFETMsgCataloguePrefix;

            if isfield(config,'MAMsgCataloguePrefix')
                config.SubCheckCfg.subcheck.InitParams.MAMsgCataloguePrefix=config.MAMsgCataloguePrefix;
            else
                config.SubCheckCfg.subcheck.InitParams.MAMsgCataloguePrefix=config.SFETMsgCataloguePrefix;
            end

        end

    end
end
