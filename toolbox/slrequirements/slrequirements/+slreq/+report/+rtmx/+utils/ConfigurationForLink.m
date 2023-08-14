classdef ConfigurationForLink<slreq.report.rtmx.utils.AbstractConfiguration


    properties
        ConfigInfo;
    end

    methods



















        function this=ConfigurationForLink(configData)


            this.Domain='Link';
            this.DomainLabel=getString(message('Slvnv:slreq:Links'));


































            allTypes=configData.TypeInfo.Type2SubTypeMap.keys;
            for index=1:configData.TypeInfo.Type2SubTypeMap.Count
                cType=allTypes{index};
                subTypeInfo=configData.TypeInfo.Type2SubTypeMap(cType);
                if length(subTypeInfo)==1&&strcmpi(subTypeInfo{1},[cType,'###Other#'])
                    configData.TypeInfo.Type2SubTypeMap.remove(cType);
                end
            end

            config{1}=this.createTypeConfig(configData.TypeInfo);

            configChangeName='Change';

            changeConfig{1}=this.createConfigBoolProp('WithChangeIssue',configChangeName);
            changeConfig{1}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelChangeWithChangeIssue'));










            config{2}=this.createConfig(configChangeName,changeConfig);
            config{2}.ConfigLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelChange'));



            this.ConfigList=config;
        end


    end
end
