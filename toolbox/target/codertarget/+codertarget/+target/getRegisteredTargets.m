function targets=getRegisteredTargets(varargin)




    if nargin>0&&isequal(varargin{1},'matlab')
        RTW.TargetRegistry.getInstance('coder');
        reg=codertarget.TargetRegistry.manageInstance('get','CoderTargetBoard');
        targets=reg.Targets;
    else
        if codertarget.TargetBoardRegistry.isSimulinkInstalled&&~codertarget.TargetBoardRegistry.getSlTargetsLoadedState
            sl_refresh_customizations;
        end
        reg=codertarget.TargetRegistry.manageInstance('get','CoderTarget');
        regSL=codertarget.TargetRegistry.manageInstance('get','CoderTargetSL');
        targets=[reg.Targets,regSL.Targets];
    end
end