classdef SlBlockDDGInfo<slreportgen.webview.utils.DDGInfo



    properties(SetAccess=private)
        IsCacheable=true;
    end

    methods
        function h=SlBlockDDGInfo(src)
            h=h@slreportgen.webview.utils.DDGInfo(src);
            h.IsCacheable=h.IsCacheable&&~strcmp(src.Mask,'on');
            addOtherTabs(h,src);
        end

        function reset(h,src)
            assert(h.IsCacheable);
            n=numel(h.Params);
            h.Values=cell(1,n);
            for i=1:n
                try
                    h.Values{i}=src.(h.Params{i});
                catch
                    h.Values{i}='';
                end
            end
        end
    end

    methods(Access=protected)
        function parse(h,src)
            if~isa(src,'Simulink.Block')
                src=get_param(src,'Object');
            end

            init(h);
            pushSrc(h,src);

            wstate=warning('off','SimulinkHMI:errors:NonExistantBoundVariable');
            restoreWarning=onCleanup(@()warning(wstate));

            ds=getDialogSource(src);
            schema=getDialogSchema(ds,'');

            h.m_srcParams=getDialogParams(ds);
            h.m_nSrcParams=length(h.m_srcParams);
            h.parseItems(schema.Items);

            if isempty(h.Params)


                dlgParams=src.DialogParameters;
                if~isempty(dlgParams)
                    h.m_srcParams=fieldnames(dlgParams);
                    h.m_nSrcParams=length(h.m_srcParams);
                    parseUnsupported(h);
                end
            end

            popSrc(h);
        end

        function parseUnsupported(h)
            src=getRootSrc(h);
            pushSrc(h,src);

            for i=1:h.m_nSrcParams
                param=h.m_srcParams{i};
                if isValidProperty(src,param)
                    addParam(h,param);
                end
            end
            popSrc(h);
        end

        function parseLeafItem(h,item)
            if isfield(item,'ObjectProperty')
                addParam(h,item.ObjectProperty);


                rootSource=getRootSrc(h);
                itemSource=rootSource;
                if isfield(item,'Source')
                    itemSource=item.Source;
                end
                h.IsCacheable=h.IsCacheable&&(rootSource==itemSource);

            elseif isItemTagCorrespondsToObjParam(h,item)
                addParam(h,item.Tag);

            elseif isfield(item,'ObjectMethod')
                param=getBlockParam(h,item);
                if~isempty(param)
                    addParam(h,param);
                end
            end
        end

        function param=getBlockParam(h,item)
            param='';



            if isfield(item,'ArgDataTypes')...
                &&(length(item.ArgDataTypes)>=2)...
                &&strcmp(item.ArgDataTypes{2},'int32')

                paramIdx=item.MethodArgs{2}+1;
                if(paramIdx<=h.m_nSrcParams)
                    param=h.m_srcParams{paramIdx};
                end
            end
        end

        function tf=isItemTagCorrespondsToObjParam(h,item)

            tf=false;
            try
                if isfield(item,'Tag')
                    if isa(h.getSrc(),'Simulink.DABaseObject')
                        cls=metaclass(h.getSrc());
                    else
                        cls=classhandle(h.getSrc());
                    end
                    tf=~isempty(cls.findprop(item.Tag));
                end
            catch
            end
        end
    end

    methods(Access=private)
        function addOtherTabs(h,src)
            params=h.Params;
            dlgParams=get(src,'DialogParameters');
            if isa(dlgParams,'struct')
                dlgParams=fields(dlgParams);
                otherParams=setdiff(dlgParams,params);

                if~isempty(otherParams)
                    pushSrc(h,src);
                    if isempty(h.Tabs)
                        pushTab(h,h.PARAMETER_ATTRIBUTES);
                    else
                        pushTab(h,h.OTHER_TAB_LABEL);
                    end


                    n=numel(otherParams);
                    for i=1:n
                        addParam(h,otherParams{i});
                    end

                    popTab(h);
                    popSrc(h);
                end
            end
        end
    end

    properties(Access=private)
        m_srcParams;
        m_nSrcParams;
    end

end
