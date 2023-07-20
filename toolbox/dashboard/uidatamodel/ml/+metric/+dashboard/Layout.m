classdef Layout<metric.dashboard.widgets.WidgetContainer

    properties(Access=?metric.dashboard.ConfigurationBase)
MF0Layout
    end

    properties(Dependent)
Id
Name
ShortName
DashboardCategory
Description
SupportedBy
RequiredParameters
TopLevel
BreakPoints
ArtifactView
ReportClass
    end

    properties(SetAccess=private)
DashboardHeader
    end

    properties(Access=protected)
Configuration
    end

    methods

        function obj=Layout(mf0Layout,config)
            obj.MF0Layout=mf0Layout;
            obj.Configuration=config;
        end


        function dbHdr=get.DashboardHeader(this)
            if isempty(this.MF0Layout.Header)
                this.MF0Layout.Header=dashboard.ui.DashboardHeader(mf.zero.getModel(this.MF0Layout));
            end
            dbHdr=metric.dashboard.DashboardHeader(this.MF0Layout.Header);
        end


        function id=get.Id(this)
            id=this.MF0Layout.Id;
        end


        function name=get.Name(this)
            name=this.MF0Layout.Name;
        end

        function set.Name(this,name)
            metric.dashboard.Verify.ScalarCharOrString(name);
            this.MF0Layout.Name=name;
        end


        function name=get.ShortName(this)
            name=this.MF0Layout.ShortName;
        end

        function set.ShortName(this,shortname)
            metric.dashboard.Verify.ScalarCharOrString(shortname);
            this.MF0Layout.ShortName=shortname;
        end


        function name=get.DashboardCategory(this)
            name=this.MF0Layout.DashboardCategory;
        end

        function set.DashboardCategory(this,cat)
            metric.dashboard.Verify.ScalarCharOrString(cat);
            this.MF0Layout.DashboardCategory=cat;
        end


        function name=get.Description(this)
            name=this.MF0Layout.Description;
        end

        function set.Description(this,des)
            metric.dashboard.Verify.ScalarCharOrString(des);
            this.MF0Layout.Description=des;
        end


        function name=get.SupportedBy(this)
            name=this.MF0Layout.SupportedBy.toArray();
        end

        function set.SupportedBy(this,sb)
            this.MF0Layout.SupportedBy.clear();
            for i=1:numel(sb)
                this.MF0Layout.SupportedBy.add(char(sb(i)));
            end
        end


        function name=get.RequiredParameters(this)
            name=this.MF0Layout.RequiredParameters.toArray();
        end

        function set.RequiredParameters(this,rp)
            this.MF0Layout.RequiredParameters.clear();
            for i=1:numel(rp)
                this.MF0Layout.RequiredParameters.add(rp(i));
            end
        end


        function name=get.TopLevel(this)
            name=this.MF0Layout.TopLevel;
        end

        function set.TopLevel(this,tl)
            metric.dashboard.Verify.LogicalOrDoubleOneZero(tl);
            this.MF0Layout.TopLevel=tl;
        end


        function name=get.ArtifactView(this)
            name=this.MF0Layout.ArtifactView;
        end

        function set.ArtifactView(this,av)
            metric.dashboard.Verify.ScalarCharOrString(av);
            this.MF0Layout.ArtifactView=av;
        end


        function rc=get.ReportClass(this)
            rc=this.MF0Layout.ReportClass;
        end

        function set.ReportClass(this,rc)
            metric.dashboard.Verify.ScalarCharOrString(rc);
            this.MF0Layout.ReportClass=rc;
        end


        function bps=get.BreakPoints(this)
            bps=this.MF0Layout.BreakPoints.toArray();
        end

        function set.BreakPoints(this,bps)
            if isempty(bps)||numel(bps)~=3...
                ||any(diff(bps)>=0)...
                ||any(~isfinite(bps))||(any(bps<=0))...
                ||(any(floor(bps)~=bps))
                error(message('dashboard:uidatamodel:InvalidBreakPointArray'));
            end
            this.MF0Layout.BreakPoints.clear();
            for i=1:numel(bps)
                this.MF0Layout.BreakPoints.add(uint32(bps(i)));
            end
        end



        function verify(this)
            hasOneWidget=false;
            tocheck=this.Widgets();
            while~isempty(tocheck)
                tocheck(1).verify();
                if~strcmp(tocheck(1).Type,'Group')&&...
                    ~strcmp(tocheck(1).Type,'Container')&&...
                    ~strcmp(tocheck(1).Type,'Bundle')
                    hasOneWidget=true;
                    tocheck=tocheck(2:end);
                else
                    if numel(tocheck)==1
                        tocheck=tocheck(1).Widgets;
                    else
                        tocheck=[tocheck(2:end),tocheck(1).Widgets];
                    end
                end
            end

            if~hasOneWidget
                error(message('dashboard:uidatamodel:NoWidget',this.Name));
            end
        end


        function cfg=getConfiguration(this)
            cfg=this.Configuration;
        end

    end

    methods(Hidden)

        function res=getWidgetsByMetricIds(this,ids)
            widgets=this.getAllWidgets();
            res=[];
            for i=1:numel(widgets)
                if isprop(widgets(i),'MetricIDs')&&isempty(setdiff(ids,widgets(i).MetricIDs))
                    res=[res,widgets(i)];%#ok<AGROW>
                end
            end

        end

        function res=getAllWidgets(this)
            res=localGetAllWidgets([this.Widgets]);
        end

        function res=getAllMetricIds(this,widgets)
            res=[];
            for i=1:numel(widgets)
                widget=widgets(i);
                if(isprop(widget,'MetricIDs'))
                    res=[res,widget.MetricIDs];%#ok<AGROW>
                end
                if(isprop(widget,'Widgets')&&numel(widget.Widgets)>0)
                    res=[res,this.getAllMetricIds(widget.Widgets)];%#ok<AGROW>
                end
            end
        end

        function res=getWidgetsByType(this,widgets,type)
            res=[];
            for i=1:numel(widgets)
                widget=widgets(i);
                if strcmp(widget.Type,type)
                    res=[res,widget];%#ok<AGROW>
                end
                if(isprop(widget,'Widgets')&&numel(widget.Widgets)>0)
                    res=[res,this.getWidgetsByType(widget.Widgets,type)];%#ok<AGROW>
                end
            end
        end

        function res=getWidgetByUUID(this,uuid)
            widgets=this.getAllWidgets();
            for i=1:numel(widgets)
                if strcmp(widgets(i).getUUID(),uuid)
                    res=widgets(i);
                    return;
                end
            end
            res=[];
        end

        function res=getParentForWidget(this,widgetOrUUID)
            uuid=widgetOrUUID;
            if ismethod(widgetOrUUID,'getUUID')
                uuid=widgetOrUUID.getUUID();
            end
            widgets=this.getAllWidgets();
            for i=1:numel(widgets)
                if(isprop(widgets(i),'Widgets')&&numel(widgets(i).Widgets)>0)
                    for j=1:numel(widgets(i).Widgets)
                        if strcmp(widgets(i).Widgets(j).getUUID(),uuid)
                            res=widgets(i).Widgets(j);
                            return;
                        end
                    end
                end
            end
            res=[];
        end
    end

    methods(Access=protected)
        function mf0Obj=getMF0Object(this)
            mf0Obj=this.MF0Layout;
        end
    end

    methods(Static,Hidden)
        function this=create(MF0Model,id)
            this=dashboard.ui.Layout(MF0Model);
            this.Id=id;
            this.BreakPoints.add(uint32(1460));
            this.BreakPoints.add(uint32(950));
            this.BreakPoints.add(uint32(800));
        end
    end

end

function res=localGetWidgetsByMetricIds(widgets,ids)
    res=[];
    for i=1:numel(widgets)
        widget=widgets(i);
        if~strcmp(widget.Type,'Group')&&...
            ~strcmp(widget.Type,'Container')&&...
            ~strcmp(widget.Type,'Bundle')
            if any(contains(widget.MetricIDs,ids))
                res=[res,widget];%#ok<AGROW>
            end
        else
            res=[res,localGetWidgetsByMetricIds([widget.Widgets],ids)];%#ok<AGROW>
        end
    end
end

function res=localGetAllWidgets(widgets)
    res=[];
    for i=1:numel(widgets)
        widget=widgets(i);
        res=[res,widget];%#ok<AGROW>
        if isprop(widget,'Widgets')&&numel(widget.Widgets)>0
            res=[res,localGetAllWidgets([widget.Widgets])];%#ok<AGROW>
        end
    end
end
