function[out,dscr]=hardwareboard_entries(cs,~)




    dscr='Values for HardwareBoard combo box, computed from set of registered targets.';

    cs=getConfigSet(cs);
    if isempty(cs)
        items.str=struct('str','None','disp','');
    else
        items=codertarget.utils.getTargetHardwareSelectionWidgetEntries(cs,true);
    end

    vals={items.str};

    val=cs.getProp('HardwareBoard');
    if isequal(val,'None')
        val=DAStudio.message('codertarget:build:DefaultHardwareBoardNameNone');
    end
    if~ismember(val,vals)
        items(end+1)=struct('str',val,'disp','');
    end

    out=items;
