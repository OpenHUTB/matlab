function refreshConfig()








    xtester_emulate_ctrl_c('slRefreshToolstripConfig');

    if feature('HasDisplay')

        feature('ScopedAccelEnablement','off');







        if DAStudio.wasBuiltWithAssertsOn()

            if~isempty(Simulink.loadsave.resolveFile('SFStudio/ChartMenu'))
                wasStateflowAlreadyLoaded=DAStudio.isModuleLoaded('stateflow');
                simulink.toolstrip.internal.loadConfig('validate');
                if~wasStateflowAlreadyLoaded&&DAStudio.isModuleLoaded('stateflow')
                    error(message('dastudio:studio:StateflowShouldNotBeLoaded'));
                end
            else
                simulink.toolstrip.internal.loadConfig('validate');
            end
        else
            simulink.toolstrip.internal.loadConfig('normal');
        end
    end
end
