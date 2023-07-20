function gw=generateBlockChoicesPopupList(cbinfo)




    blkHandle=simscape.internal.sl_toolstrip.getSelectedBlock(cbinfo);
    if(~isempty(blkHandle))
        gw=dig.GeneratedWidget(cbinfo.EventData.namespace,cbinfo.EventData.type);

        if(~simscape.engine.sli.internal.issimscapeblock(blkHandle))
            return
        end

        if(isempty(get_param(blkHandle,'SourceFile')))
            return
        end

        currentSrcFile=get_param(blkHandle,'SourceFile');
        [c,d]=simscape.internal.variantsAndNames(blkHandle);
        for idx=1:numel(d)
            itemId=['item',int2str(idx)];
            actionId=[itemId,'Action'];
            item=gw.Widget.addChild('ListItemWithRadioButton',itemId);
            item.ActionId=['blockChoicesPopupList:',actionId];
            action=gw.createAction(actionId);
            action.text=d{idx};
            action.enabled=true;
            action.buttonGroupName='blockChoicesPopupRadioGroup';
            action.closePopupOnClick=false;
            action.eventDataType=dig.model.EventDataType.Boolean;
            if(strcmp(currentSrcFile,c{idx}))
                action.selected=true;
            else
                action.selected=false;
            end
            fcn=@(cbinfo)simscape.internal.sl_toolstrip.setBlockChoice(c{idx},blkHandle);
            action.setCallbackFromArray(fcn,dig.model.FunctionType.Action);
        end
    end

end