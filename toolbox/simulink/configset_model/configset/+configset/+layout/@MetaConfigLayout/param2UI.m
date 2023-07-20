function UI=param2UI(obj,adp,names)






    namelist=names;
    if~iscell(names)
        namelist={names};
    end
    UI=cell(1,length(namelist));
    for i=1:length(namelist)
        n=namelist{i};
        u.Param=n;
        isUI=true;
        p=adp.getParamData(n);
        if isempty(p)
            u=[];
            UI{i}=u;
            continue;
        end
        u.Prompt=p.getPrompt(adp.Source);
        fullname=p.FullName;
        if obj.isUIParam(fullname,adp.Source,adp)
            status=adp.getParamStatus(p.Name,p);
            if p.Hidden||status==configset.internal.data.ParamStatus.UnAvailable
                isUI=false;




            elseif~loc_hasStandardWidget(adp,p)
                isUI=false;
            else
                if strcmp(p.Component,'Simulink.STFCustomTargetCC')
                    u.Path=loc_getSTFParamPath(adp,p);
                else
                    u.Path=obj.getParamDisplayPath(fullname,adp.Source);
                end
                widgets=adp.getWidgetDataList(p.Name,p);

                w=widgets{1};
                u.Type=configset.internal.util.getDDGWidgetType(w);
                u.Tag=w.getTag(adp.Source);
                u.Visible=status<configset.internal.data.ParamStatus.InAccessible;
            end
        else
            isUI=false;
        end

        if~isUI
            u.Prompt='';
            u.Path='';
            u.Visible=0;
            u.Type='NonUI';
            u.Tag='';
        end


        UI{i}=u;
    end
    if~iscell(names)
        UI=UI{1};
    end
end





function out=loc_hasStandardWidget(adp,pData)
    if isempty(pData.WidgetList)

        out=ismember(configset.internal.util.getDDGWidgetType(pData),...
        {'edit','editarea','checkbox','combobox','radiobutton'});
    else
        status=adp.getWidgetStatusList(pData.Name,pData);
        data=adp.getWidgetDataList(pData.Name,pData);
        out=~isempty(find(cellfun(@(s,d)(...
        ismember(configset.internal.util.getDDGWidgetType(d),...
        {'edit','editarea','checkbox','combobox','radiobutton'})&&...
        s<configset.internal.data.ParamStatus.UnAvailable),...
        status,data),1));
    end
end


function out=loc_getSTFParamPath(adp,param)
    info=adp.tlcCategory;
    for i=1:length(info)
        if isstruct(info{i})
            page=info{i}.prompt;
        else
            if strcmp(param.Name,info{i}.Name)
                break;
            end
        end
    end
    out=[message('RTW:configSet:configSetCodeGen').getString,'/',page];
end




