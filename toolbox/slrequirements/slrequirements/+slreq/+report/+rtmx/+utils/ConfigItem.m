classdef ConfigItem<handle



    properties
PropList
PropNameMap
ConfigName
ConfigLabel
ConfigDomain
        CurrentDomain;
    end

    methods
        function this=ConfigItem(configStruct)



            defaultPropList={};
            defaultConfigName=false;
            defaultConfigLabel=false;
            defaultConfigDomain={};


            p=inputParser;
            addParameter(p,'ConfigName',defaultConfigName);
            addParameter(p,'ConfigLabel',defaultConfigLabel);
            addParameter(p,'ConfigDomain',defaultConfigDomain);
            addParameter(p,'PropList',defaultPropList);

            parse(p,configStruct);

            this.ConfigName=p.Results.ConfigName;
            this.ConfigLabel=p.Results.ConfigLabel;
            this.PropNameMap=containers.Map('keytype','char','valuetype','any');
            if isempty(p.Results.ConfigDomain)
                this.ConfigDomain=containers.Map;
            else
                this.ConfigDomain=containers.Map(p.Results.ConfigDomain,true(1,length(p.Results.ConfigDomain)));
            end

            this.CurrentDomain=this.ConfigDomain.keys;

            this.addPropList(p.Results.PropList);

        end

        function addPropList(this,propList)
            for index=1:length(propList)
                cProp=propList{index};
                if isa(cProp,'slreq.report.rtmx.utils.PropItem')
                    cPropObj=cProp;
                else
                    cPropObj=slreq.report.rtmx.utils.PropItem(cProp);
                end

                this.addProp(cPropObj);
            end
        end

        function addExtraProp(this,propInfo,domain)
            this.ConfigDomain(domain)=true;

            if isKey(this.PropNameMap,propInfo.PropName)
                propInfo=this.PropNameMap(propInfo.PropName);
            end

            propInfo.addDomain({domain});

            this.PropNameMap(propInfo.PropName)=propInfo;
        end

        function addProp(this,propInfo)


            if isKey(this.PropNameMap,propInfo.PropName)
                propInfo=this.PropNameMap(propInfo.PropName);
            end

            propInfo.addDomain(this.CurrentDomain)

            this.PropNameMap(propInfo.PropName)=propInfo;
        end

        function addDomain(this,domain)
            this.CurrentDomain={domain};
            this.ConfigDomain(domain)=true;
        end

        function out=export(this)
            out.ConfigName=this.ConfigName;
            out.ConfigLabel=this.ConfigLabel;
            out.ConfigDomain=this.ConfigDomain.keys;
            out.PropList=exportPropList(this,values(this.PropNameMap));
        end

        function out=exportPropList(~,propList)
            out=cell(1,length(propList));
            for index=1:length(propList)
                cProp=propList{index};
                out{index}=cProp.export();
            end

        end


    end
end

