function update(this,event)




    switch event


    case 'attach'
        registerPropList(this,'NoDuplicate','All',[]);


        mdl=this.getModel;
        if~isempty(mdl)&&~any(strcmp(getConfigSets(mdl),'RTWinBackup'))
            newcs=copy(getActiveConfigSet(mdl));
            newcs.Name='RTWinBackup';
            attachConfigSet(mdl,newcs);
        end


    case{'pre-activate','activate'}

        SimulinkDesktopRealTime.SimulinkDesktopRealTimeCC.upgradeFromRTWin(this);

        set_param(getConfigSet(this),'SystemTargetFile','sldrt.tlc');


    case 'switch_target'


    case 'deselect_target'
    end
