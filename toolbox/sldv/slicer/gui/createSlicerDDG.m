function dlg=createSlicerDDG(mdl)




    dlg=[];

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    if ischar(mdl)
        modelName=mdl;
        modelH=get_param(modelName,'Handle');
    else
        modelH=mdl;
        modelName=get_param(modelH,'Name');
    end

    modelslicerprivate('MessageHandler','open',modelName);



    invalid=~SliceUtils.isSlicerAvailable();
    if invalid
        Mex=MException('ModelSlicer:NotLicensed',getString(message(...
        'Sldv:ModelSlicer:ModelSlicer:NotLicensed')));
        modelslicerprivate('MessageHandler','error',Mex);
        modelslicerprivate('MessageHandler','close');
        return;
    end


    msObj=modelslicerprivate('slicerMapper','get',modelH);
    if isa(msObj,'ModelSlicer')&&isvalid(msObj)&&isempty(msObj.dlg)
        Mex=MException('ModelSlicer:APIInUse',getString(message(...
        'Sldv:ModelSlicer:ModelSlicer:APIInUse')));
        modelslicerprivate('MessageHandler','error',Mex);
        modelslicerprivate('MessageHandler','close');
        return;
    end


    if slslicer.internal.checkDesiredSimulationStatus(modelH,'isSimStatusPausedOrCompiled')&&isempty(msObj)
        Mex=MException('ModelSlicer:API:AlreadyCompiled',...
        getString(message('Sldv:ModelSlicer:SLSlicerAPI:ModelIsAlreadyActivated')));
        modelslicerprivate('MessageHandler','error',Mex);
        modelslicerprivate('MessageHandler','close');
        return;
    end


    if strcmp(get_param(modelH,'Dirty'),'on')
        toQuit=showQuestionDialogToSave(modelName);
        if toQuit
            return;
        end
    end


    dlgObj=modelslicerprivate('slicerMapper','getUI',modelH);


    if~isempty(dlgObj)&&ishandle(dlgObj)
        dlgObj.refresh();
        dlg=dlgObj;
        return;
    else
        scfg=SlicerConfiguration.getConfiguration(modelH);
        try

            scfg.modelSlicer.checkCompatibility('CheckType','PreCompile');
        catch Mex
            modelslicerprivate('MessageHandler','error',Mex);
            modelslicerprivate('MessageHandler','close');
            return
        end
        d=SEUdd.ModelSlicerDlg();
        d.Model=scfg;
        sc=scfg.sliceCriteria(scfg.selectedIdx);
        d.Busy=false;
        d.sigListPanel.Model=sc;
        d.criteriaListPanel.Model=scfg;

        dockDialog=scfg.modelSlicer.useEmbeddedDDG;

        if(dockDialog)
            compId='MdlSlicer';
            modelName=get_param(modelH,'Name');
            ed=SlicerConfiguration.findEditor(modelName);

            studio=ed(1).getStudio;
            p=studio.getStudioPosition;
            newPos=updateStudioPosition(p,390,630);
            studio.setStudioPosition(newPos);


            closeSlicerDDG(studio);

            ddgcomp=GLUE2.DDGComponent(studio,compId,d);
            ddgcomp.PersistState=false;
            ddgcomp.DestroyOnHide=true;
            studio.registerComponent(ddgcomp);
            studio.moveComponentToDock(ddgcomp,...
            getString(message('Sldv:ModelSlicer:gui:ModelSlicerProductName')),'Right','Stacked');

            dlg=DAStudio.ToolRoot.getOpenDialogs(d);

            ed.getCanvas.zoomToSceneRect;

            scfg.modelSlicer.origStudioPos=p;
            scfg.modelSlicer.embedDDGComp=ddgcomp;
            scfg.modelSlicer.dockedStudio=studio;
        else
            dlg=DAStudio.Dialog(d);
        end

        scfg.modelSlicer.dlg=dlg;

        modelslicerprivate('slicerMapper','set',modelH,scfg.modelSlicer);
        scfg.storeConfiguration();


        refmodels=[];

        try
            d.criteriaListPanel.toggleHighlightView(dlg);
            if~isempty(scfg.session.refModels)
                refmodels=num2cell(scfg.session.refModels);
            else


                refmodels=Simulink.ModelReference.internal.find_normal_mdlrefs(modelName,...
                'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
            end
        catch Mex
            dlg.setWidgetValue('DialogStatusText',...
            getString(message('Sldv:ModelSlicer:gui:FailedCompile')));
            scfg.modelSlicer.hasError=true;
            scfg.storeConfiguration();
            modelslicerprivate('MessageHandler','error',Mex);
            dlg.refresh();
        end


        allRefModels=zeros(1,numel(refmodels));
        for idx=1:numel(refmodels)
            mdl=refmodels{idx};
            if ischar(mdl)
                load_system(mdl);
                mdl=get_param(mdl,'Handle');
            end
            allRefModels(idx)=mdl;
            modelslicerprivate('slicerMapper','set',mdl,scfg.modelSlicer);
        end

        scfg.createSessionIfNeeded(allRefModels);
        scfg.ShowFastRestartNotif();
    end

    modelslicerprivate('MessageHandler','close')
end

function newPos=updateStudioPosition(existPos,addWidth,height)
    screenPos=get(0,'ScreenSize');
    newPos=existPos;
    if((existPos(3)-existPos(1))<screenPos(3))
        newPos(3)=min(screenPos(3),existPos(3)+addWidth);
    end

    if((existPos(4)-existPos(2))<height)
        newPos(4)=min(screenPos(4),existPos(2)+height);
    end
end



function toQuit=showQuestionDialogToSave(modelName)


    toQuit=false;
    qTitle=getString(message('Sldv:ModelSlicer:gui:UnsavedInEditableHighlightTitle'));
    qStr=getString(message('Sldv:ModelSlicer:gui:UnsavedInEditableHighlightQstr',modelName));
    buttons=questdlg(qStr,qTitle,getString(message('MATLAB:finishdlg:Yes')),...
    getString(message('MATLAB:finishdlg:No')),getString(message('MATLAB:finishdlg:No')));
    switch buttons
    case getString(message('MATLAB:finishdlg:Yes'))
        try
            save_system(modelName)
        catch Mex
            modelslicerprivate('MessageHandler','error',Mex)
            modelslicerprivate('MessageHandler','close');
            toQuit=true;
        end
    otherwise
        Mex=MException('ModelSlicer:UnsavedChangesAtManagerDlg',...
        getString(message('Sldv:ModelSlicer:gui:UnsavedChangesAtManagerDlg',modelName)));
        modelslicerprivate('MessageHandler','error',Mex);
        modelslicerprivate('MessageHandler','close');
        toQuit=true;
    end
end

