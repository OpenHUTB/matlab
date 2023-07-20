function action(obj,msg)




    try

        objectId=msg.objectId;
        action=msg.action;
        uid=msg.uid;
        data=msg.data;
        eid=msg.eid;

        m=slmle.internal.slmlemgr.getInstance;

        switch action
        case 'ready'

            obj.refresh(uid);
            obj.ready=true;

        case 'save'









            SLM3I.SLCommonDomain.focusEditorCEF(obj.ed);


        case 'escape'

            ed=obj.ed;
            ed.gotoParent;

        case 'update'
            obj.update(data,objectId,uid);

        case 'updateTextProperty'
            obj.updateTextProperty(data,eid)

        case 'm2c'

            line=msg.data.pos.line;
            type=msg.data.type;
            obj.navigateToCode(line,type);

        case 'cursor'


            pos=data.pos;
            obj.fCursor=[pos.line,pos.column];
            obj.fIndex=data.index;

            obj.hasSelection=data.hasSelection;
            if obj.hasSelection
                obj.fSelection=data.Selection';
            else


                obj.fSelection=[obj.fCursor,obj.fCursor];
            end

            obj.SelectedText=data.SelectedText;


            if data.inHighlight
                return;
            end

            msg.blockPath=obj.h.Path;
            msg.blockName=obj.h.Name;

            pkg=[];
            pkg.studio=obj.studio;
            pkg.msg=msg;
            eventData=slmle.internal.MLFBEventData(pkg);
            m.notify('EVENT',eventData);
        case 'fnc_list'
            obj.functionList=data;
        case 'evalM'
            obj.evalM(data);
        case 'set_scope'
            sfprivate('eml_man','set_data_scope',objectId,data.varname,data.newScope);
        case 'dsMenuStatus'
            obj.dsMenuStatus=data;
        case 'debuggingContextMenu'
            obj.executeDebugContextMenuAction(data.action);
        case 'highlight'
            obj.highlightedRanges=data;
        case 'refreshAllBreakPoints'
            obj.deleteAllBPsForBlock(objectId);
            m=slmle.internal.slmlemgr.getInstance;
            m.publish(objectId,'refresh_breakpoints');
        end
    catch ME

    end


