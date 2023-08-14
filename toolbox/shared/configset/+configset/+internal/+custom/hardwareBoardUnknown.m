function[out,dscr]=hardwareBoardUnknown(cs,~)





    dscr='';

    cs=cs.getConfigSet;
    val=cs.get_param('HardwareBoard');
    items=codertarget.utils.getTargetHardwareSelectionWidgetEntries(cs,true);
    vals=['None',{items.str}];

    if ismember(val,vals)
        out=3;
    else
        out=0;
    end



