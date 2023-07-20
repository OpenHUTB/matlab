classdef PropItem<handle



    properties
ParentPropName
PropName
PropLabel
        IsSub;
PropValue
PropType
PropNum
QueryName
SubTypeList
HasSub
Domain
Tooltip
TooltipPosition
ExcludedProp
    end

    methods
        function this=PropItem(propStruct)
            defaultParentPropName='';
            defaultPropLabel=false;
            defaultIsSub=false;
            defaultPropValue='';
            defaultPropType='boolean';
            defaultPropNum=0;
            defaultQueryName='';
            defaultTooltip='';
            defaultSubTypeList={};
            defaultExcludedProp={};
            defaultHasSub=false;
            defaultTooltipPosition='above';
            defaultDomain=containers.Map('keytype','char','valuetype','logical');


            p=inputParser;
            addParameter(p,'PropName','');
            addParameter(p,'PropLabel',defaultPropLabel);
            addParameter(p,'IsSub',defaultIsSub);
            addParameter(p,'PropValue',defaultPropValue);
            addParameter(p,'PropType',defaultPropType);
            addParameter(p,'PropNum',defaultPropNum);
            addParameter(p,'QueryName',defaultQueryName);
            addParameter(p,'SubTypeList',defaultSubTypeList);
            addParameter(p,'ParentPropName',defaultParentPropName);
            addParameter(p,'HasSub',defaultHasSub);
            addParameter(p,'Domain',defaultDomain);
            addParameter(p,'Tooltip',defaultTooltip);
            addParameter(p,'TooltipPosition',defaultTooltipPosition);
            addParameter(p,'ExcludedProp',defaultExcludedProp);


            parse(p,propStruct);


            this.PropName=p.Results.PropName;
            this.PropName=p.Results.PropName;
            this.ParentPropName=p.Results.ParentPropName;
            this.PropLabel=p.Results.PropLabel;
            this.IsSub=p.Results.IsSub;
            this.PropValue=p.Results.PropValue;
            this.PropType=p.Results.PropType;
            this.PropNum=p.Results.PropNum;
            this.QueryName=p.Results.QueryName;
            this.HasSub=p.Results.HasSub;
            this.Domain=p.Results.Domain;
            this.Tooltip=p.Results.Tooltip;
            this.TooltipPosition=p.Results.TooltipPosition;
            this.ExcludedProp=p.Results.ExcludedProp;

            this.addSubTypeList(p.Results.SubTypeList)

        end

        function addDomain(this,domainNames)
            for index=1:length(domainNames)
                this.Domain(domainNames{index})=true;
            end
        end

        function addSubTypeList(this,subTypeList)
            for index=1:length(subTypeList)
                cSubType=subTypeList{index};
                this.addSubType(cSubType);
            end
        end

        function addSubType(this,propStruct)
            if isa(propStruct,'slreq.report.rtmx.utils.PropItem')
                subTypeObj=propStruct;
            else
                subTypeObj=slreq.report.rtmx.utils.PropItem(propStruct);
            end

            subTypeObj.IsSub=true;
            subTypeObj.ParentPropName=this.PropName;
            this.HasSub=true;
            this.SubTypeList{end+1}=subTypeObj;
        end

        function out=export(this)
            out.PropName=this.PropName;
            out.ParentPropName=this.ParentPropName;
            out.PropLabel=this.PropLabel;
            out.IsSub=this.IsSub;
            out.PropValue=this.PropValue;
            out.PropType=this.PropType;
            out.PropNum=this.PropNum;
            out.QueryName=this.QueryName;
            out.HasSub=this.HasSub;
            out.Domain=this.Domain;
            out.Tooltip=this.Tooltip;
            out.TooltipPosition=this.TooltipPosition;
            out.ExcludedProp=this.ExcludedProp;
            out.SubTypeList=cell(1,length(this.SubTypeList));
            for index=1:length(this.SubTypeList)
                out.SubTypeList{index}=this.SubTypeList{index}.export();
            end
        end
    end
end

