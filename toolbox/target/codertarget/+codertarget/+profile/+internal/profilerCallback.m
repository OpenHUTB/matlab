function profilerCallback(hObj,hDlg,tag,~)




    values={...
    DAStudio.message('codertarget:ui:ProfilerConfigurationStream');...
    DAStudio.message('codertarget:ui:ProfilerConfigurationLegacy')...
    };
    cs=hObj.getConfigSet();
    transportName=codertarget.attributes.getExtModeData('Transport',cs);
    isXCP=strcmp(transportName,Simulink.ExtMode.Transports.XCPTCP.Transport);
    isKernelProfiler=codertarget.data.isParameterInitialized(cs,'Profiler.Instrumentation')&&...
    isequal(codertarget.data.getParameterValue(cs,'Profiler.Instrumentation'),0);
    if contains(tag,'Profiler_Enable')
        val=hDlg.getWidgetValue(tag);
        if val&&~isKernelProfiler
            set_param(cs,'CodeExecutionProfiling','on');
        elseif val&&isKernelProfiler
            if~isequal(get_param(cs,'CodeProfilingInstrumentation'),'off')
                set_param(cs,'CodeExecutionProfiling','on');
            else
                set_param(cs,'CodeExecutionProfiling','off');
            end
            codertarget.data.setParameterValue(cs,'Profiler.UseKernelProfiler',true);
        else
            set_param(cs,'CodeExecutionProfiling','off');
            if codertarget.data.isParameterInitialized(cs,'Profiler.UseKernelProfiler')
                codertarget.data.setParameterValue(cs,'Profiler.UseKernelProfiler',false);
            end
        end

        if~isXCP&&~isKernelProfiler
            codertarget.data.setParameterValue(cs,'TargetServices.Running',isequal(codertarget.data.getParameterValue(cs,'Profiler.Configuration'),0));
        end
    elseif contains(tag,'Profiler_Instrumentation')
        val=hDlg.getWidgetValue(tag);
        codertarget.data.setParameterValue(hObj,'Profiler.Instrumentation',val);
        if isequal(val,1)
            set_param(cs,'CodeExecutionProfiling','on');
            if codertarget.data.isParameterInitialized(cs,'Profiler.UseKernelProfiler')
                codertarget.data.setParameterValue(cs,'Profiler.UseKernelProfiler',false);
            end
            if~isXCP
                codertarget.data.setParameterValue(hObj,'TargetServices.Running',isequal(codertarget.data.getParameterValue(cs,'Profiler.Configuration'),0));
            end
        elseif isequal(val,0)
            if isequal(get_param(cs,'CodeProfilingInstrumentation'),'off')
                set_param(cs,'CodeExecutionProfiling','off');
            end
            codertarget.data.setParameterValue(cs,'Profiler.UseKernelProfiler',true);
        end
    elseif contains(tag,'Profiler_Configuration')
        if~isKernelProfiler
            assert(~isXCP,'Profiler Configuration option should not be visible for XCP transports');
            val=hDlg.getComboBoxText(tag);
            if~codertarget.data.isParameterInitialized(hObj,'TargetServices')
                codertarget.data.setParameterValue(hObj,'TargetServices',struct('Running',false));
            end
            if isequal(val,values{2})
                codertarget.data.setParameterValue(hObj,'TargetServices.Running',false);
            elseif isequal(val,values{1})
                codertarget.data.setParameterValue(hObj,'TargetServices.Running',true);
            end
        end
        codertarget.data.setParameterValue(hObj,'Profiler.Configuration',hDlg.getWidgetValue(tag));
    end

end


