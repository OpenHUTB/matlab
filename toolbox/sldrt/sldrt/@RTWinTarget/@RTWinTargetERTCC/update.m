function update(this,event)




    switch event


    case 'attach'
        registerPropList(this,'NoDuplicate','All',[]);


        mdl=this.getModel;
        if~isempty(mdl)&&~any(strcmp(getConfigSets(mdl),'RTWinERTBackup'))
            newcs=copy(getActiveConfigSet(mdl));
            newcs.Name='RTWinERTBackup';
            attachConfigSet(mdl,newcs);
        end


    case{'pre-activate','activate'}

        SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC.upgradeFromRTWin(this);

        set_param(getConfigSet(this),'SystemTargetFile','sldrtert.tlc');


    case 'switch_target'


    case 'deselect_target'
    end
