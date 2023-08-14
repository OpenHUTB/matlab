classdef ConfigListObj<handle
    properties
        Domain;
        DomainLabel;
        QueryName;
        ConfigList;
        ArtifactID;
        ConfigNameToConfigObj;
    end

    methods
        function this=ConfigListObj(configList)
            this.QueryName=configList.QueryName;

            this.Domain=containers.Map('keytype','char','valuetype','char');
            this.ConfigNameToConfigObj=containers.Map('keytype','char','valuetype','any');
            this.ArtifactID=containers.Map(configList.ArtifactID,true(1,length(configList.ArtifactID)));
            this.Domain(configList.Domain)=configList.DomainLabel;

            this.ConfigList={};
            this.addConfigList(configList.ConfigList);
        end

        function addConfigList(this,configList)
            for index=1:length(configList)





                cConfig=configList{index};
                this.addConfig(cConfig);

            end
        end

        function addDomain(this,domain,domainLabel)
            if nargin<3
                domainLabel=domain;
            end
            this.Domain(domain)=domainLabel;
        end

        function addArtifact(this,artifactID)
            this.ArtifactID(artifactID)=true;
        end

        function addConfig(this,config)
            if isa(config,'slreq.report.rtmx.utils.ConfigItem')
                configObj=config;
            else
                configObj=slreq.report.rtmx.utils.ConfigItem(config);
            end

            this.ConfigNameToConfigObj(configObj.ConfigName)=configObj;
        end

        function out=export(this)
            out.DomainName=this.Domain.keys;
            out.DomainLabel=this.Domain.values;
            out.ArtifactID=this.ArtifactID.keys;
            out.ConfigList=this.exportConfigList();
        end

        function demoteTypeConfig(this)
            domain=this.Domain.keys;
            domainLabel=this.Domain.values;
            propObj=this.createTypeProp(domain{1},domainLabel{1});

            configObj=this.ConfigNameToConfigObj('Type');
            propListToBeDemoted=configObj.PropNameMap.values;
            propObj.addSubTypeList(propListToBeDemoted);
            configObj.PropNameMap=containers.Map('keytype','char','valuetype','any');
            configObj.addProp(propObj);
            this.ConfigNameToConfigObj('Type')=configObj;
        end

        function mergetConfigList(this,configList)
            this.Domain(configList.Domain)=configList.DomainLabel;
            for index=1:length(configList.ArtifactID)
                this.ArtifactID(configList.ArtifactID{index})=true;
            end

            for index=1:length(configList.ConfigList)
                cConfig=configList.ConfigList{index};
                if isstruct(cConfig)
                    cConfig=slreq.report.rtmx.utils.ConfigItem(cConfig);
                end
                this.addExtraConfig(cConfig,configList.Domain,configList.DomainLabel)
            end
        end

        function addExtraConfig(this,config,domain,domainLabel)
            if isKey(this.ConfigNameToConfigObj,config.ConfigName)

                configObj=this.ConfigNameToConfigObj(config.ConfigName);
                if strcmpi(config.ConfigName,'Type')
                    propObj=this.createTypeProp(domain,domainLabel);
                    allSubProps=config.PropNameMap.values;
                    propObj.addSubTypeList(allSubProps);
                    config.PropNameMap=containers.Map('keytype','char','valuetype','any');
                    config.addProp(propObj);
                end

                newPropList=config.PropNameMap.values;
                for index=1:length(newPropList)
                    configObj.addExtraProp(newPropList{index},domain);
                end
            else
                configObj=config;
            end

            this.ConfigNameToConfigObj(configObj.ConfigName)=configObj;
        end

        function out=createTypeProp(this,domain,domainLabel)
            prop.PropName=domain;
            prop.PropLabel=domainLabel;
            prop.IsSub=false;
            prop.PropValue=false;
            prop.PropType='boolean';
            prop.PropNum=0;
            prop.QueryName='Domain';
            prop.SubTypeList={};
            prop.ParentPropName='';
            prop.HasSub=true;
            prop.Domain=containers.Map(domain,true);
            prop.Tooltip='';
            prop.TooltipPosition='above';
            prop.ExcludedProp={};
            out=slreq.report.rtmx.utils.PropItem(prop);
        end

        function out=exportConfigList(this)
            configList=values(this.ConfigNameToConfigObj);
            out=cell(1,length(configList));
            for index=1:length(configList)
                cConfig=configList{index};
                out{index}=cConfig.export();
            end
        end
    end
end