classdef DDGInfo<handle


    properties(Constant,Access=protected)
        PARAMETER_ATTRIBUTES=getString(message('slreportgen_webview:modelinspector:ParameterAttributes'));
        OTHER_TAB_LABEL=['-',getString(message('slreportgen_webview:exporter:inspectorOtherTabLabel'))];
    end

    properties(SetAccess=protected)
        Params;
        Values;
        Tabs;
        TabsParamStartIndex;
    end

    methods
        function h=DDGInfo(src)
            h.parse(src);
        end
    end

    methods(Access=protected)
        function init(h)
            h.m_srcStack={};
            h.m_tabStack={};
            h.Params={};
            h.Values={};
            h.Tabs={};
            h.TabsParamStartIndex=[];
        end

        function parse(h,src)
            schema=src.getDialogSchema('');
            h.init();
            h.pushSrc(src);
            h.parseItems(schema.Items);
            h.popSrc();
        end

        function parseItems(h,items)
            n=length(items);
            for i=1:n
                item=items{i};

                toPopSrc=h.pushItemSrc(item);
                toPopTab=h.pushItemTab(item);

                if isfield(item,'Type')&&strcmp(item.Type,'tab')
                    tabs=item.Tabs;
                    nTabs=length(tabs);
                    for j=1:nTabs

                        tabs{j}.Type='tabitem';
                    end
                    h.parseItems(tabs);

                elseif isfield(item,'Items')
                    h.parseItems(item.Items);

                elseif h.isItemParamTrue(item,'Visible')
                    h.parseLeafItem(item);
                end

                if toPopTab
                    h.popTab();
                end
                if toPopSrc
                    h.popSrc();
                end
            end
        end

        function parseLeafItem(h,item)
            if isfield(item,'ObjectProperty')
                h.addParam(item.ObjectProperty);
            end
        end

        function addParam(h,param)
            src=h.getSrc();

            try
                val=src.(param);
            catch
                val='';
            end

            h.Params{end+1}=param;
            h.Values{end+1}=val;

            tab=h.getTabName();
            if~isempty(tab)...
                &&(isempty(h.Tabs)||~strcmp(tab,h.Tabs{end}))
                h.Tabs{end+1}=tab;
                h.TabsParamStartIndex(end+1)=numel(h.Params);
            end
        end

        function src=getRootSrc(h)
            src=h.m_srcStack{1};
        end

        function src=getSrc(h)
            src=h.m_srcStack{end};
        end

        function pushSrc(h,src)
            if isempty(h.m_srcStack)
                h.m_srcStack={src};
            else
                h.m_srcStack{end+1}=src;
            end
        end

        function popSrc(h)
            h.m_srcStack=h.m_srcStack(1:end-1);
        end

        function toPop=pushItemSrc(h,item)
            toPop=false;
            if isfield(item,'Source')
                pushSrc(h,item.Source);
                toPop=true;
            end
        end

        function tab=getTabName(h)
            if~isempty(h.m_tabStack)
                tab=h.m_tabStack{end};
            else
                tab=h.PARAMETER_ATTRIBUTES;
            end
        end

        function toPop=pushItemTab(h,item)
            toPop=false;
            if isfield(item,'Type')&&strcmp(item.Type,'tabitem')
                pushTab(h,item.Name);
                toPop=true;
            end
        end

        function pushTab(h,tabName)
            h.m_tabStack{end+1}=tabName;
        end

        function popTab(h)
            h.m_tabStack=h.m_tabStack(1:end-1);
        end
    end

    properties(Access=private)
        m_srcStack;
        m_tabStack;
    end

    methods(Static,Access=protected)
        function tf=isItemParamTrue(item,param)
            tf=~isfield(item,param)||item.(param);
        end
    end
end