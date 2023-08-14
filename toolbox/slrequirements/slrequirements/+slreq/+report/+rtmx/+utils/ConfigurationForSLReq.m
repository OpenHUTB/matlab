classdef ConfigurationForSLReq<slreq.report.rtmx.utils.AbstractConfiguration




    methods



















        function this=ConfigurationForSLReq(configData)


            this.Domain='slreq';
            this.DomainLabel=getString(message('Slvnv:slreq_rtmx:DomainRequirements'));

            configChangeName='Change';

            changeConfig{1}=this.createConfigBoolProp('WithChangeIssue',configChangeName);
            changeConfig{1}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelChangeWithChangeIssue'));

            config{3}=this.createConfig(configChangeName,changeConfig);
            config{3}.ConfigLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelChange'));
            allTypes=configData.Type2SubTypeMap.keys;
            for index=1:configData.Type2SubTypeMap.Count
                cType=allTypes{index};
                subTypeInfo=configData.Type2SubTypeMap(cType);
                if length(subTypeInfo)==1&&strcmpi(subTypeInfo{1},[cType,'###Other#'])
                    configData.Type2SubTypeMap.remove(cType);
                end
            end


            config{1}=this.createTypeConfig(configData);
            config{2}=this.createLinkConfig();

            if configData.KeywordList.Count~=0
                config{end+1}=this.createKeywordConfig(configData,'Keywords',getString(message('Slvnv:slreq:Keywords')));
            end

            if configData.CustomAttributeList.Count~=0

                prefix=[getString(message('Slvnv:slreq:CustomAttributes')),': '];
                for index=1:length(configData.CustomAttributesInfo)
                    cCustomAttribute=configData.CustomAttributesInfo(index);
                    if strcmpi(cCustomAttribute.Type,'checkbox')
                        config{end+1}=this.createCheckboxConfig(cCustomAttribute,[prefix,cCustomAttribute.Label]);
                    elseif strcmpi(cCustomAttribute.Type,'combobox')
                        config{end+1}=this.createComboboxConfig(cCustomAttribute,[prefix,cCustomAttribute.Label]);
                    end
                end
            end

            this.ConfigList=config;
        end

        function out=getSpeicificConfigList(this)
            out={'Change'};
        end

        function out=createCheckboxConfig(this,customAttribute,Label)
            queryName=['customattribute##',customAttribute.Name];
            configAttribute{1}=this.createConfigBoolProp('1',queryName);
            configAttribute{1}.PropLabel='True';
            configAttribute{2}=this.createConfigBoolProp('0',queryName);
            configAttribute{2}.PropLabel='False';
            out=this.createConfig(Label,configAttribute);
            out.ConfigName=queryName;
        end


        function out=createComboboxConfig(this,customAttribute,Label)
            queryName=['customattribute##',customAttribute.Name];
            configAttribute={};
            for index=1:length(customAttribute.Entries)
                cEntry=customAttribute.Entries{index};
                configAttribute{end+1}=this.createConfigBoolProp(cEntry,queryName);
            end

            out=this.createConfig(Label,configAttribute);
            out.ConfigName=queryName;
        end

    end
end
