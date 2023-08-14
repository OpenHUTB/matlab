function s=getInfo(p,varargin)






    if nargin==2&&~isempty(varargin{1})
        cs=varargin{1};
    else
        cs=[];
    end
    s=[];
    s.id=p.Name;
    s.tag=p.Tag;

    try
        value=cs.getProp(p.Name);
    catch
        value=p.DefaultValue;
    end
    [s.value,s.converted]=configset.util.mat2json(value);

    if~isempty(p.Type)
        s.type=p.Type;
    end

    if~isempty(p.UI)
        if isempty(p.UI.f_prompt)
            s.prompt_key=[p.UI.searchPrompt,''];
            s.name_key=[p.UI.prompt,''];
        else
            if~isempty(cs)
                s.prompt=p.getPrompt(cs);
            else
                s.f.disp=p.UI.f_prompt;
                s.f.prompt=p.UI.f_prompt;
            end
        end
        if isempty(p.UI.f_tooltip)
            s.tooltip_key=[p.UI.tooltip,''];
        else
            if~isempty(cs)
                fn=str2func(p.UI.f_tooltip);
                s.tooltip=fn(cs,s.name);
            else
                s.f.tooltip=p.UI.f_tooltip;
            end
        end
        if isfield(p.UI,'addColon')
            s.colon=p.UI.addColon;
        end
    end

    if~isempty(p.Description)
        s.prompt=p.Description;
        s.disp=p.Description;
    end
    if~isempty(p.ToolTip)
        s.tooltip=p.ToolTip;
    end

    if ismember(p.Type,{'enum','enum_edit'})
        if isempty(p.f_AvailableValues)
            opts=p.v_AvailableValues;
            n=length(opts);
            s.options=cell(1,n);
            for i=1:n
                opt=opts(i);
                a=[];
                a.value=opt.str;
                if isfield(opt,'key')
                    a.key=opt.key;
                end
                if isfield(opt,'disp')
                    a.label=opt.disp;
                end
                s.options{i}=a;
            end
        else
            s.options={};
            if~isempty(cs)
                try
                    s.options=p.getOptions(cs);
                catch
                end
            else
                s.fn.options=p.f_AvailableValues;
            end
        end
    end

    if strcmp(p.Type,'minmax')
        s.min=min(p.v_AvailableValues);
        s.max=max(p.v_AvailableValues);
    end

    if~isempty(p.Dependency)
        dp=p.Dependency;
        s.depinfo=dp.getInfo();
        cdl=dp.CustomDepList;
        if~isempty(cdl)
            for i=1:length(cdl)
                s.f.st{i}=func2str(cdl{i}.getStatusFcn);
            end
        end
    end
    s.DependencyOverride=p.DependencyOverride;

    if~isempty(p.FullParent)
        s.parent=p.FullParent;
    end

    if p.isInvertValue
        s.invert=true;
    end

    if~isempty(p.CSH)
        s.nocsh=true;
    end

    if p.Hidden
        s.hidden=true;
    end

    if~isempty(p.Feature)
        s.feature=p.Feature;
    end
    if~isempty(p.CallbackFunction)
        s.callback=p.CallbackFunction;
    end
    if~isempty(p.WidgetValuesFcn)
        s.fn.wv=p.WidgetValuesFcn;
    end


    wList=p.WidgetList;
    if~isempty(wList)
        n=length(wList);
        s.widgets=cell(1,n);
        for i=1:n
            w=wList{i}.getInfo(cs);
            s.widgets{i}=w;
        end
    end


