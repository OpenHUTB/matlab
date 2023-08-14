function[info,e]=getProfilerWidgets(hObj)





    info.ParameterGroups={};
    info.Parameters={};
    e=[];
    grpname=DAStudio.message('codertarget:ui:ProfilerGroupName');
    if~codertarget.data.isParameterInitialized(hObj,'TargetServices')
        codertarget.data.setParameterValue(hObj,'TargetServices',struct('Running',false));
    end
    attr=codertarget.attributes.getTargetHardwareAttributes(hObj);
    if isempty(attr)||isempty(attr.Profiler)
        return;
    end
    try
        hardware=codertarget.targethardware.getHardwareConfiguration(hObj);
        if isempty(hardware)
            return
        end
        targetInfo=codertarget.attributes.getTargetHardwareAttributes(hObj);
        if~isempty(targetInfo)&&~isempty(targetInfo.ExternalModeInfo)&&targetInfo.EnableOneClick
            info.ParameterGroups={grpname};
            ii=1;
            p(ii)=codertarget.parameter.ParameterInfo.getDefaultParameter();
            p(ii).Name=DAStudio.message('RTW:configSet:ERTDialogSilPilExecProfiling');
            p(ii).Storage='Profiler.Enable';
            p(ii).Tag='Profiler_Enable';
            p(ii).Type='checkbox';
            p(ii).Value=codertarget.profile.internal.isProfilingEnabled(hObj);
            p(ii).Callback='codertarget.profile.internal.profilerCallback';
            p(ii).Visible=true;
            p(ii).RowSpan=eval(p(ii).RowSpan);
            p(ii).ColSpan=eval(p(ii).ColSpan);
            p(ii).DialogRefresh=true;
            p(ii).DoNotStore=true;
            info.Parameters{1}{ii}=p(ii);

            if any(contains(hardware.RTOSInfoFiles,'linux'))
                ii=ii+1;
                p(ii)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                values={...
                DAStudio.message('codertarget:ui:ProfilingKernelMode');...
                DAStudio.message('codertarget:ui:ProfilingCodeInstrMode')...
                };
                p(ii).Entries=values;
                p(ii).Name=DAStudio.message('codertarget:ui:ProfilerInstrumentation');
                p(ii).SaveValueAsString=false;
                p(ii).Storage='Profiler.Instrumentation';
                p(ii).Type='combobox';
                p(ii).Tag='Profiler_Instrumentation';
                p(ii).Callback='codertarget.profile.internal.profilerCallback';
                p(ii).Visible='codertarget.profile.internal.showKernelProfilingOptions(hObj)';
                if codertarget.data.isParameterInitialized(hObj,'Profiler.Instrumentation')
                    p(ii).Value=codertarget.data.getParameterValue(hObj,'Profiler.Instrumentation');
                else
                    if isequal(get_param(hObj,'CodeExecutionProfiling'),'on')
                        p(ii).Value=1;
                    else
                        p(ii).Value=0;
                    end
                    if codertarget.data.isParameterInitialized(hObj,'Profiler.Configuration')
                        curVal=codertarget.data.getParameterValue(hObj,'Profiler.Configuration');
                        if ischar(curVal)
                            p(ii).Value=1;
                        end
                        codertarget.data.setParameterValue(hObj,'Profiler.Instrumentation',p(ii).Value);
                    end
                end
                p(ii).DialogRefresh=false;
                p(ii).RowSpan=eval(p(ii).RowSpan);
                p(ii).ColSpan=eval(p(ii).ColSpan);
                p(ii).Alignment=true;
                p(ii).DoNotStore=false;
                info.Parameters{1}{ii}=p(ii);
            end

            ii=ii+1;
            p(ii)=codertarget.parameter.ParameterInfo.getDefaultParameter();
            if isequal(attr.Profiler.InstantPrint,'0')
                values={...
                DAStudio.message('codertarget:ui:ProfilerConfigurationStream');...
                DAStudio.message('codertarget:ui:ProfilerConfigurationLegacy')...
                };
            else
                values={...
                DAStudio.message('codertarget:ui:ProfilerConfigurationStream');...
                };
            end
            p(ii).Entries=values;
            p(ii).Name=DAStudio.message('codertarget:ui:ProfilerConfiguration');
            p(ii).SaveValueAsString=false;
            p(ii).Storage='Profiler.Configuration';
            p(ii).Type='combobox';
            p(ii).Tag='Profiler_Configuration';
            p(ii).Callback='codertarget.profile.internal.profilerCallback';
            p(ii).Visible='codertarget.profile.internal.showConfigurationWidget(hObj)';
            if codertarget.data.isParameterInitialized(hObj,'Profiler.Configuration')
                curVal=codertarget.data.getParameterValue(hObj,'Profiler.Configuration');
                if ischar(curVal)&&ismember(curVal,values)
                    [~,valueidx]=ismember(curVal,values);
                    p(ii).Value=valueidx-1;
                    codertarget.data.setParameterValue(hObj,'Profiler.Configuration',p(ii).Value);
                elseif ischar(curVal)
                    p(ii).Value=numel(values)-1;
                    codertarget.data.setParameterValue(hObj,'Profiler.Configuration',p(ii).Value);
                end
            else
                p(ii).Value=numel(values)-1;
                codertarget.data.setParameterValue(hObj,'Profiler.Configuration',p(ii).Value);
            end
            p(ii).DialogRefresh=false;
            p(ii).RowSpan=eval(p(ii).RowSpan);
            p(ii).ColSpan=eval(p(ii).ColSpan);
            p(ii).Alignment=true;
            p(ii).DoNotStore=false;
            info.Parameters{1}{ii}=p(ii);



            ii=ii+1;
            p(ii)=getTaskFilteringWidget(hObj);
            info.Parameters{1}{ii}=p(ii);



            if~isfield(attr.Profiler,'EnableModelInitLogging')||~isequal(str2double(attr.Profiler.EnableModelInitLogging),0)
                ii=ii+1;
                p(end+1)=codertarget.parameter.ParameterInfo.getDefaultParameter();
                p(ii).Name=DAStudio.message('codertarget:ui:ProfilerLogModelInit');
                p(ii).Storage='Profiler.LogModelInit';
                p(ii).Type='checkbox';
                if codertarget.data.isParameterInitialized(hObj,'Profiler.LogModelInit')
                    p(ii).Value=codertarget.data.getParameterValue(hObj,'Profiler.LogModelInit');
                else
                    p(ii).Value=0;
                end
                p(ii).Visible='codertarget.profile.internal.isStreamingProfilerEnabled(hObj)';
                p(ii).RowSpan=eval(p(ii).RowSpan);
                p(ii).ColSpan=eval(p(ii).ColSpan);
                p(ii).DialogRefresh=false;
                p(ii).DoNotStore=false;

                info.Parameters{1}{ii}=p(ii);
            end


        end
    catch e
        info.ParameterGroups={};
        info.Parameters={};
    end
end

function p=getTaskFilteringWidget(hObj)
    p=codertarget.parameter.ParameterInfo.getDefaultParameter();
    viewOptions={...
    DAStudio.message('codertarget:ui:ProfilerViewLevelOnlyTask');...
    DAStudio.message('codertarget:ui:ProfilerViewLevelAllTask')...
    };
    p.Entries=viewOptions;
    p.Name=DAStudio.message('codertarget:ui:ProfilerViewLevel');
    p.SaveValueAsString=false;
    p.Storage='Profiler.ViewLevel';
    p.Type='combobox';
    p.Tag='Profiler_ViewLevel';


    p.Visible=codertarget.profile.internal.showKernelProfilingOptions(hObj)&&isequal(codertarget.data.getParameterValue(hObj,'Profiler.Instrumentation'),0);
    if codertarget.data.isParameterInitialized(hObj,'Profiler.ViewLevel')
        p.Value=codertarget.data.getParameterValue(hObj,'Profiler.ViewLevel');
    else
        p.Value=0;
    end
    p.DialogRefresh=false;
    p.RowSpan=eval(p.RowSpan);
    p.ColSpan=eval(p.ColSpan);
    p.Alignment=true;
    p.DoNotStore=false;
end

