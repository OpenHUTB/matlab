


function schema=reverseTransitionRF(cbinfo)
    if isvalid(cbinfo)
        schema=sl_toggle_schema;
        schema.state='Disabled';
        selection=cbinfo.selection;
        if selection.size==1&&loc_CanReverseTransition(selection.at(1))
            schema.state='Enabled';
        end
        schema.callback=@SFStudio.internal.reverseTransitionCB;
    end
end


function canReverse=loc_CanReverseTransition(element)
    canReverse=false;
    if~sf('Feature','ReverseTransition')
        return;
    end


    if(isa(element,'StateflowDI.Transition')...
        &&element.srcElement~=element.dstElement...
        &&~isempty(element.srcElement)&&~isempty(element.dstElement)...
        &&(~isa(element.dstElement,'StateflowDI.Junction')||~element.dstElement.isHistory)...
        &&~element.srcElement.isGrouped&&~element.dstElement.isGrouped...
        &&~isa(element.srcElement,'StateflowDI.Port')&&~isa(element.dstElement,'StateflowDI.Port'))
        canReverse=true;
    end


    if canReverse
        isSuperTransition=(element.srcSpace~=StateflowDI.ConnectionSpace.Simple)||(element.dstSpace~=StateflowDI.ConnectionSpace.Simple);
        if isSuperTransition
            canReverse=(element.superWireId>0&&sf('get',double(element.superWireId),'.dst.id')>0);
        end
    end
end