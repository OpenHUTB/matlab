function executor=getActionExecutor(action)





    switch action
    case 'addDataPoint'
        executor=@Simulink.stawebscope.servermanager.addDataPoint;
    case 'removeDataPoint'
        executor=@Simulink.stawebscope.servermanager.removeDataPoint;
    case 'editDataPoint'
        executor=@Simulink.stawebscope.servermanager.editDataPoint;
    case 'clearData'
        executor=@Simulink.stawebscope.servermanager.clearData;
    case 'doCastData'
        executor=@Simulink.stawebscope.servermanager.doCastData;
    case 'offsetData'
        executor=@Simulink.stawebscope.servermanager.offsetData;
    case 'setData'
        executor=@Simulink.stawebscope.servermanager.setData;
    otherwise
        error('No executor found');
    end

end
