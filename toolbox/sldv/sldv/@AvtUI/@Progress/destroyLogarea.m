function destroyLogarea(dlgSrc,dialogH)






    if~isempty(dlgSrc.ElapsedTimer)
        if strcmp(dlgSrc.ElapsedTimer.Running,'on')
            stop(dlgSrc.ElapsedTimer);
        end
        delete(dlgSrc.ElapsedTimer);
        dlgSrc.ElapsedTimer=[];
    end



    cleanAnalysisLauncher(dlgSrc);

    if~isempty(dlgSrc.testComp)&&ishandle(dlgSrc.testComp)


        if(true==dlgSrc.sldvCoreAnalInProgress)
            abortAnalysis(dlgSrc,dialogH);
        end
    end

    modelName=dlgSrc.modelName;
    sldvprivate('closeModelView',modelName);

    dlgSrc.abortSignal=true;
    dlgSrc.stopped=true;
    dlgSrc.closed=true;


    if~isempty(dlgSrc.selectDialogH)
        src=dlgSrc.selectDialogH.getSource;
        src.deleteResultDialogH();
        imd=DAStudio.imDialog.getIMWidgets(dlgSrc.selectDialogH);
        imd.clickCancel(dlgSrc.selectDialogH);
    end
end

function cleanAnalysisLauncher(dlgSrc)
    if~isempty(dlgSrc.Launcher)
        stop(dlgSrc.Launcher);
        clear('dlgSrc.ExecListener');
        dlgSrc.ExecListener=[];
        clear('dlgSrc.Launcher');
        dlgSrc.Launcher=[];
    end
end
