function OpenCallbackParamsDialog(blk,paramName)











    isbd=~any(blk=='/');

    if isbd
        i_highlight_bd(blk,paramName)
    else
        i_highlight_block(blk,paramName)
    end
end

function i_highlight_bd(bdName,paramName)
    open_system(bdName);
    obj=get_param(bdName,'Object');
    d=loc_find_dialog(DAStudio.ToolRoot.getOpenDialogs(obj));
    if isempty(d)
        d=DAStudio.Dialog(obj);
    end
    assert(~isempty(d),'Dialog not found');
    try
        d.setActiveTab('Tabcont',1);




        d.setWidgetValue('CallbackFunctions',paramName);
        d.setWidgetValue('CallbackFunctions',[paramName,'*']);
        d.setFocus(paramName);
    catch e %#ok<NASGU>
        return;
    end
end

function i_highlight_block(blk,paramName)
    open_and_hilite_hyperlink(blk,'error');
    obj=get_param(blk,'Object');


    d=loc_find_dialog(DAStudio.ToolRoot.getOpenDialogs(obj));
    if isempty(d)
        open_system(blk,'property');
        d=loc_find_dialog(DAStudio.ToolRoot.getOpenDialogs(obj));
        assert(~isempty(d),'Dialog not found');
    end
    try
        d.setActiveTab('TabContainer',2);




        d.setWidgetValue('CallbackTree',paramName);
        d.setWidgetValue('CallbackTree',[paramName,'*']);
        d.setFocus(paramName);
    catch e %#ok<NASGU>
        return;
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