function s=getParamStruct(obj,p)





    name=p.Name;
    cs=obj.getCS;

    if~isempty(obj.tlcInfo)
        if obj.tlcInfo.isKey(name)

            s=p.getInfo(cs);
            try
                owner=cs.getPropOwner(name);
            catch



                if isa(cs,'Simulink.TargetCC')
                    tgt=cs;
                elseif isa(cs,'Simulink.RTWCC')
                    tgt=cs.getComponent('Target');
                elseif isa(cs,'Simulink.ConfigSet')
                    rtw=cs.getComponent('Code Generation');
                    tgt=rtw.getComponent('Target');
                else
                    tgt=[];
                end

                try
                    owner=tgt.getPropOwner(name);
                catch
                    owner=[];
                end
            end

            if isempty(owner)


                s.locked=strcmp(cs.readonly,'on');
            else
                s.locked=owner.isReadonlyProperty(name);
            end
            return;
        end
    end

    s=[];
    s.name=name;


    if~isa(p,'configset.internal.data.WidgetStaticData')
        value=obj.getParamValue(name);



        if isnumeric(value)&&strcmp(p.Type,'numeric')
            value=num2str(value);
        end

        valueList=obj.getWidgetValueList(name,p);
        s.status=obj.getParamWidgetStatus(name,p);
        try
            owner=cs.getPropOwner(name);
            s.locked=owner.isReadonlyProperty(name);
        catch
        end
        if isempty(p.WidgetList)
            if isempty(p.WidgetValuesFcn)

                [s.value,s.converted]=configset.internal.util.partialConversionToJSON(value);
            else
                s.value=valueList{1};
                s.converted=true;
            end
        else
            [s.value,s.converted]=configset.internal.util.partialConversionToJSON(value);
            n=length(p.WidgetList);
            s.widgets=cell(1,n);
            statusList=obj.getWidgetStatusList(name,p);
            for i=1:length(p.WidgetList)
                w=obj.getParamStruct(p.WidgetList{i});
                w.value=valueList{i};
                w.status=statusList{i};
                w.converted=true;
                s.widgets{i}=w;
            end
        end
    end

    if~isempty(p.UI)
        if~isempty(p.UI.f_prompt)
            str=p.getPrompt(cs);
            s.prompt=str;
            s.disp=str;
        end
        if~isempty(p.UI.f_tooltip)
            s.tooltip=p.getToolTip(cs);
        end
    end

    if~isempty(p.f_AvailableValues)
        if isa(p,'configset.internal.data.WidgetStaticData')...
            &&strcmp(p.WidgetType,'table')

            fn=str2func(p.f_AvailableValues);
            s.tableData=fn(cs,name);
        else
            s.options=p.getOptions(cs);
        end
    end


