function dlgCloseMethod(this,dlg,actionStr)




    msdlg=this.modelSlicerDlg;
    sc=this.Model;
    scfg=msdlg.getSource.Model;
    slicerObj=sc.modelSlicer;

    usingSdi=slicerObj.isThisUsingSdi();
    sc.createSdiViewIfNeeded();
    origInitializedFastRestart=scfg.initializedInFastRestart();
    simHandler=scfg.modelSlicer.simHandler;

    if strcmpi(actionStr,'ok')

        msdlg.setWidgetValue('DialogStatusText',...
        getString(message('Sldv:ModelSlicer:gui:RunningSimulation')))
        modelslicerprivate('MessageHandler','open',scfg.modelSlicer.model)


        sc.addSdiLoggingPointsForSeeds(dlg.getWidgetValue('CheckLogSeeds'));



        terminatedFastRestart=origInitializedFastRestart&&...
        strcmp(get_param(sc.modelSlicer.model,'SimulationStatus'),'stopped');
        try
            slicerObj.enableSdiSlicerController(false);
            if usingSdi
                slicerObj.clearSdi();
            end



            if~origInitializedFastRestart&&...
                strcmpi(get_param(sc.modelSlicer.model,'FastRestart'),'on')

                sc.modelSlicer.compileModel();
            end

            sc.collectCoverage(scfg,this.SimStartTime,this.SimStopTime,[],simHandler,this.SaveFilePath);

            sc.removeAddedSdiLoggingPointsForSeeds();


            sc.setViewToCurrentRun();

            sc.dirty=true;


            initializeAfterSimulation(this,terminatedFastRestart);
            modelslicerprivate('MessageHandler','close')
        catch ex


            clearCoverage(this);
            warnCoverageCollectionFailed(this,ex);
        end
    else



        restoreInitialStateIfMdlClosed(this,origInitializedFastRestart);
        msdlg.setWidgetValue('DialogStatusText',...
        getString(message('Sldv:ModelSlicer:gui:SimulationCanceled')));
    end
    slicerObj.enableSdiSlicerController(true);

    msdlg.getSource.runSimDlg=[];
    msdlg.getSource.Busy=false;
    msdlg.refresh();

end

function initializeAfterSimulation(obj,terminatedFastRestart)
    msdlg=obj.modelSlicerDlg;
    d=msdlg.getSource;
    sc=obj.Model;
    scfg=msdlg.getSource.Model;
    if scfg.initializedInFastRestart()

        d.criteriaListPanel.refreshHighlight(msdlg);
        msdlg.setWidgetValue('DialogStatusText',...
        getString(message('Sldv:ModelSlicer:gui:Ready')));
    elseif terminatedFastRestart||obj.initialized

        msdlg.setWidgetValue('DialogStatusText',...
        getString(message('Sldv:ModelSlicer:gui:Highlightingddd')))
        if terminatedFastRestart
            set_param(sc.modelSlicer.model,'FastRestart','on');
        end
        d.criteriaListPanel.toggleHighlightView(msdlg);
    else

        msdlg.setWidgetValue('DialogStatusText',...
        getString(message('Sldv:ModelSlicer:gui:ActivateHighlight')))
    end
end

function restoreInitialStateIfMdlClosed(obj,origInitializedFastRestart)
    msdlg=obj.modelSlicerDlg;
    if~origInitializedFastRestart&&obj.initialized&&~obj.mdlClose

        msdlg.setWidgetValue('DialogStatusText',...
        getString(message('Sldv:ModelSlicer:gui:Highlightingddd')))
        d=msdlg.getSource;
        d.criteriaListPanel.toggleHighlightView(msdlg);
        msdlg.setWidgetValue('DialogStatusText',...
        getString(message('Sldv:ModelSlicer:gui:Ready')))
    end
end

function clearCoverage(obj)
    sc=obj.Model;
    msdlg=obj.modelSlicerDlg;
    sc.useCvd=false;
    sc.cvd=[];
    sc.cvFileName='';
    sc.dirty=true;
    msdlg.setWidgetValue('DialogStatusText',...
    getString(message('Sldv:ModelSlicer:gui:FailedMeasureCoverage')))


    sc.modelSlicer.enableSdiSlicerController(false);
end

function warnCoverageCollectionFailed(obj,ex)
    msdlg=obj.modelSlicerDlg;
    scfg=msdlg.getSource.Model;
    Mex=MException('ModelSlicer:FailedToApplyTimeWindow',...
    getString(message('Sldv:ModelSlicer:gui:FailedToApplyTimeWindow')));
    Mex=Mex.addCause(ex);
    modelslicerprivate('MessageHandler','warning',Mex,obj.Model);
    if~scfg.initializedInFastRestart()
        d=msdlg.getSource;
        d.criteriaListPanel.toggleHighlightView(msdlg);
    end
    modelslicerprivate('MessageHandler','close')
end