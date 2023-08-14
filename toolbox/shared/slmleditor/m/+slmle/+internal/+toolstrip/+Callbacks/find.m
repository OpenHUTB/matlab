function schema=find(fncname,cbinfo,eventData)




    fnc=str2func(fncname);

    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end

function schema=findTextTS(cbinfo)
    schema=sl_action_schema;
    schema.icon='search';
    schema.callback=@findTextCallback;
    schema.state='Enable';
    schema.autoDisableWhen='Never';

end

function schema=findText(cbinfo)
    schema=sl_action_schema;
    schema.callback=@findTextCallback;
    schema.state='Enable';
    schema.autoDisableWhen='Never';
end


function schema=findNext(cbinfo)
    schema=sl_action_schema;
    schema.state=GetTextSelectedStateForNP(cbinfo);
    schema.callback=@findNextCallback;
    schema.autoDisableWhen='Never';
end

function schema=findPrevious(cbinfo)
    schema=sl_action_schema;
    schema.state=GetTextSelectedStateForNP(cbinfo);
    schema.callback=@findPreviousCallback;
    schema.autoDisableWhen='Never';
end

function schema=findSelection(cbinfo)
    schema=sl_action_schema;
    schema.state=GetTextSelectedState(cbinfo);
    schema.callback=@findSelectionCallback;
    schema.autoDisableWhen='Never';
end


function result=GetTextSelectedState(cbinfo)
    if slmle.internal.isTextSelected(cbinfo)
        result='Enabled';
    else
        result='Disabled';
    end
end

function result=GetTextSelectedStateForNP(cbinfo)
    ed=getMLFB(cbinfo);

    if slmle.internal.isTextSelected(cbinfo)||ed.enableNextPreviousButton([])
        result='Enabled';
    else
        result='Disabled';
    end
end


function findTextCallback(cbinfo)

    ed=getMLFB(cbinfo);
    ed.publish('find_text',[]);


    SLM3I.SLCommonDomain.focusEditorCEF(ed.ed);
end

function findNextCallback(cbinfo)

    ed=getMLFB(cbinfo);
    ed.publish('find_next',[]);
end

function findPreviousCallback(cbinfo)

    ed=getMLFB(cbinfo);
    ed.publish('find_previous',[]);
end

function findSelectionCallback(cbinfo)

    ed=getMLFB(cbinfo);
    ed.publish('find_selection',[]);

    ed.enableNextPreviousButton(true);
end


function editor=getMLFB(info)
    mgr=slmle.internal.slmlemgr.getInstance;
    saEd=info.studio.App.getActiveEditor;
    editor=mgr.getMLFBEditorByStudioAdapter(saEd);
end

