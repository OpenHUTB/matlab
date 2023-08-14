function renderMenus(this)





    this.ViewMenuListener=event.listener(this.Application,'ViewMenuOpening',@this.onViewMenuOpening);
    if~this.SimscapeMode
        this.ToolsMenuListener=event.listener(this.Application,'ToolsMenuOpening',@this.onToolsMenuOpening);
    end


    reduceUpdateValue=uiservices.logicalToOnOff(getPropertyValue(this,'ReduceUpdates'));
    this.Handles.ReduceUpdatesMenu=uimenu(this.Application.Handles.playbackMenu,...
    'Tag','uimgr.spctogglemenu_ReduceUpdates',...
    'Label',getString(message('dspshared:SpectrumAnalyzer:ReducePlotUpdates')),...
    'Checked',reduceUpdateValue,...
    'Callback',makeCallback(this,@toggleReduceUpdates),...
    'Accelerator','R');