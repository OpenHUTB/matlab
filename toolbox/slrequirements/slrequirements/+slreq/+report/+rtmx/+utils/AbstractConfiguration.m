classdef AbstractConfiguration<handle

    properties
        Domain;
        DomainLabel;
        ConfigList;
        ArtifactID;
        QueryName;
    end

    methods
        function obj=AbstractConfiguration()

        end

        function out=createConfigBoolProp(~,propName,queryName,subTypeList)
            if nargin<4
                subTypeList={};
            end
            out.PropName=propName;
            out.PropLabel=propName;
            out.IsSub=false;
            out.ParentPropName='';
            out.PropValue=false;
            out.PropType='boolean';
            out.PropNum=0;
            out.QueryName=queryName;
            out.SubTypeList=subTypeList;
            if isempty(subTypeList)
                out.HasSub=false;
            else
                out.HasSub=true;
            end
        end

        function out=createConfigBoolSubProp(~,subPropName,propName,queryName)
            out.PropName=subPropName;
            out.ParentPropName=propName;
            out.PropValue=false;
            out.IsSub=true;
            out.PropType='boolean';
            out.PropNum=0;
            out.QueryName=['Sub',queryName];
            out.HasSub=false;
        end


        function out=createTypeConfig(this,configData)
            allTypes=configData.TypeList.keys;
            configType=cell(length(allTypes),1);
            for index=1:configData.TypeList.Count
                cType=allTypes{index};
                if isKey(configData.Type2SubTypeMap,cType)
                    allSubTypes=configData.Type2SubTypeMap(cType);
                    configSubType=cell(length(allSubTypes),1);
                    for sIndex=1:length(allSubTypes)
                        cSubType=allSubTypes{sIndex};
                        cSubTypeInfo=configData.SubTypeList(cSubType);
                        configSubType{sIndex}=this.createConfigBoolSubProp(cSubTypeInfo.Name,cType,'Type');
                        configSubType{sIndex}.PropNum=cSubTypeInfo.Count;
                        configSubType{sIndex}.PropLabel=cSubTypeInfo.Label;
                    end
                else
                    configSubType={};
                end

                cTypeInfo=configData.TypeList(cType);
                configType{index}=this.createConfigBoolProp(cTypeInfo.Name,'Type',configSubType);
                configType{index}.PropNum=cTypeInfo.Count;
                configType{index}.PropLabel=cTypeInfo.Label;
            end





            out=this.createConfig('Type',configType);
            out.ConfigLabel=getString(message('Slvnv:slreq:Type'));

        end

        function out=createKeywordConfig(this,configData,keywordName,keywordLabel)
            allKeywords=configData.KeywordList.keys;

            configKeyword=cell(length(allKeywords),1);
            for index=1:configData.KeywordList.Count
                cKeyword=allKeywords{index};
                cKeywordInfo=configData.KeywordList(cKeyword);
                configKeyword{index}=this.createConfigBoolProp(cKeywordInfo.Name,'Keywords');
                configKeyword{index}.PropNum=cKeywordInfo.Count;
                configKeyword{index}.PropLabel=cKeywordInfo.Name;
            end





            out=this.createConfig(keywordName,configKeyword);
            out.ConfigLabel=keywordLabel;

        end

        function out=createAttributeConfig(this,configData,attributeLabel)
            allAttributes=configData.AttributeList.keys;

            configAttribute=cell(length(allAttributes),1);
            for index=1:configData.AttributeList.Count
                cAttribute=allAttributes{index};
                cAttributeInfo=configData.AttributeList(cAttribute);
                configAttribute{index}=this.createConfigBoolProp(cAttributeInfo.Name,'Attributes');
                configAttribute{index}.PropNum=cAttributeInfo.Count;
                configAttribute{index}.PropLabel=cAttributeInfo.Name;
            end

            out=this.createConfig(attributeLabel,configAttribute);
            out.ConfigLabel=attributeLabel;

        end


        function out=createConfig(~,configName,propList)
            out.ConfigName=configName;
            out.ConfigLabel=configName;
            out.PropList=propList;
        end

        function out=createLinkConfig(this)


            linkConfig{1}=this.createConfigBoolProp('HasNoLink','Link');
            linkConfig{1}.PropLabel=getString(message('Slvnv:slreq_rtmx:FilterPanelLinkHasNoLink'));

            out=this.createConfig('Link',linkConfig);
            out.ConfigLabel=getString(message('Slvnv:slreq:Link'));
        end
    end
end

