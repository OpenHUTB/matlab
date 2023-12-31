








function scheduleInfo=extractExportFcnSchedulerInfo(testComp)


    scheduleInfo=sldv.code.xil.internal.SldvExportFcnSchedulerInfo.defaultSchedulingInfo();


    try

        analyzedModelName=get_param(testComp.analysisInfo.analyzedModelH,'Name');
        blkPath=[analyzedModelName,'/_SldvExportFcnScheduler'];

        if get_param(blkPath,'Tag')=="__SLT_FCN_CALL__"

            rt=sfroot;
            machine=rt.find('-isa','Stateflow.Machine','Name',analyzedModelName);
            if~isempty(machine)
                blkUDD=machine.find('-isa','Stateflow.EMChart','Path',blkPath);
                if~isempty(blkUDD)

                    obj=sldv.code.xil.internal.SldvExportFcnSchedulerInfo(blkUDD.Script);
                    [status,sInfo]=obj.extract();
                    if status&&~isempty(sInfo.FcnTriggerPortVarName)


                        scheduleInfo=sInfo;
                        return
                    end
                end
            end
        end
    catch ME
        if sldv.code.internal.feature('disableErrorRecovery',true)
            rethrow(ME);
        end
    end


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


