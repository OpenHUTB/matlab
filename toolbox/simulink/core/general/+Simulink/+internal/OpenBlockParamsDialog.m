function OpenBlockParamsDialog(blk,paramName)













    try
        open_and_hilite_hyperlink(blk,'error');
        aMaskObj=Simulink.Mask.get(blk);
        if~isempty(aMaskObj)&&...
            any(strcmp(paramName,get_param(blk,'MaskNames')))
            open_system(blk,'Mask');
        else
            open_system(blk,'parameter');
        end

        o=get_param(blk,'object');
        s=o.getDialogSource;

        if~isa(s,'Simulink.SLDialogSource')
            return;
        end

        if~ismember(paramName,s.getDialogParams)
            return;
        end

        dialog=loc_find_dialog(DAStudio.ToolRoot.getOpenDialogs(s));

        if isempty(dialog)
            return;
        end

        schema=s.getDialogSchema('');

    catch
        return;
    end

    [tabNames,widget]=traverseSchema(schema.Items,paramName,false);

    switchTab(dialog,tabNames)

    if isempty(widget)
        highlightTag(dialog,paramName);
    else
        highlightWidget(dialog,widget)
    end

end


function highlightWidget(dialog,widget)
    if isfield(widget,'Items')
        for itemCount=1:numel(widget.Items)
            widItem=widget.Items{itemCount};
            highlightWidget(dialog,widItem)
        end
    elseif isfield(widget,'Tag')
        tagVal=widget.Tag;
        highlightTag(dialog,tagVal);
    end
end

function switchTab(dialog,tabNames)


    imd=DAStudio.imDialog.getIMWidgets(dialog);
    tbars=find(imd,'-isa','DAStudio.imTabBar');

    for tnCount=1:numel(tabNames)
        for tbarCount=1:numel(tbars)
            tbar=tbars(tbarCount);
            tabs=tbar.find('-isa','DAStudio.imTab');
            tabNamesAll=arrayfun(@(x)x.getName,tabs,'UniformOutput',false);
            logIndex=strcmp(tabNamesAll,tabNames{tnCount});
            tbar.setTab(find(logIndex)-1)
        end
    end

end


function highlightTag(dialog,tag)
    if dialog.isWidgetValid(tag)
        dialog.setFocus(tag);
        dialog.enableWidgetHighlight(tag,[0,0,255,255]);
    end
end

function[tabName,widget,pFound]=traverseSchema(items,paramName,isTab)
    pFound=false;
    tabName={};
    widget=[];
    for count=1:numel(items)

        tabNameNext=[];

        if isTab&&isfield(items{count},'Name')
            tabName={items{count}.Name};
        end

        if isfield(items{count},'ObjectProperty')&&...
            strcmpi(items{count}.ObjectProperty,paramName)
            widget=items{count};
            pFound=true;
            return;
        end

        if isfield(items{count},'Tag')&&...
            strcmpi(items{count}.Tag,paramName)
            widget=items{count};
            pFound=true;
            return;
        end

        if isfield(items{count},'WidgetId')&&...
            endsWith(items{count}.WidgetId,paramName,'IgnoreCase',true)
            widget=items{count};
            pFound=true;
            return;
        end

        if isfield(items{count},'Items')
            [tabNameNext,widget,pFound]=traverseSchema(items{count}.Items,paramName,false);
        end

        if isfield(items{count},'Tabs')
            [tabNameNext,widget,pFound]=traverseSchema(items{count}.Tabs,paramName,true);
        end

        if pFound
            if~isempty(tabNameNext)
                tabName{end+1}=tabNameNext{1};
            end
            return;
        else
            if~isempty(tabName)
                tabName{end}={};
            end

        end

    end

end


function d=loc_find_dialog(dlgs)
    d=[];
    if(length(dlgs)==1)
        if dlgs.isStandAlone
            d=dlgs;
        end
    else
        for i=1:length(dlgs)
            if dlgs{i}.isStandAlone
                d=dlgs{i};
                break;
            end
        end
    end
end

