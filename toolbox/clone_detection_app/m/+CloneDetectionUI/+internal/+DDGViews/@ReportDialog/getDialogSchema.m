function dlgStruct=getDialogSchema(this)

    try
        loadedObject=load([['m2m_',get_param(this.model,'name')],'/',this.historyVersion,'.mat']);
        activeCloneDetectionUIObj=loadedObject.updatedObj;
    catch
        DAStudio.error('sl_pir_cpp:creator:historyVesionNotFound',this.historyVersion,['m2m_',get_param(this.model,'name')]);
    end
    if~isa(activeCloneDetectionUIObj.m2mObj,'slEnginePir.acrossModelGraphicalCloneDetection')
        this.mdls=[{activeCloneDetectionUIObj.m2mObj.mdl},activeCloneDetectionUIObj.m2mObj.refModels];
        this.backmdlprefix=activeCloneDetectionUIObj.m2mObj.genmodelprefix;
        if~isempty(activeCloneDetectionUIObj.m2mObj.changedLibraries)
            this.changelibraries=activeCloneDetectionUIObj.m2mObj.changedLibraries.keys;
        end
        this.libname=activeCloneDetectionUIObj.m2mObj.libname;
    end

    this.m2m_dir=activeCloneDetectionUIObj.m2mObj.m2m_dir;

    this.title=[get_param(activeCloneDetectionUIObj.model,'name'),'_',this.historyVersion];

    connector.ensureServiceOn;
    reportDisplay.Type='webbrowser';
    reportDisplay.WebKit=true;
    reportDisplay.Url=this.getReportHTML(activeCloneDetectionUIObj);

    reportCont.Name='Report';
    reportCont.Type='group';
    reportCont.LayoutGrid=[48,48];

    reportCont.Items={reportDisplay};


    pushbuttonrestore.Type='pushbutton';
    pushbuttonrestore.Name='Restore';
    pushbuttonrestore.RowSpan=[1,1];
    pushbuttonrestore.ColSpan=[2,2];
    pushbuttonrestore.Tag='restore_to_current';
    pushbuttonrestore.WidgetId='restore_to_current_id';
    pushbuttonrestore.Enabled=activeCloneDetectionUIObj.compareModelButtonEnable;


    pushbuttonrestore.ObjectMethod='restoreModel';


    pushbuttonclose.Type='pushbutton';
    pushbuttonclose.Name='Close';
    pushbuttonclose.RowSpan=[1,1];
    pushbuttonclose.ColSpan=[3,3];
    pushbuttonclose.Tag='cancel';
    pushbuttonclose.WidgetId='cancel_id';
    pushbuttonclose.ObjectMethod='closeReportDialog';

    buttoncont.Name='buttontcont';
    buttoncont.Type='panel';
    buttoncont.LayoutGrid=[1,3];
    buttoncont.ColStretch=[1,0,0];
    buttoncont.Items={pushbuttonrestore,pushbuttonclose};

    dlgStruct.DialogTitle=this.title;
    dlgStruct.Items=[{buttoncont},{reportCont}];
    dlgStruct.DialogTag=this.historyVersion;
    dlgStruct.DialogMode='Slim';
    dlgStruct.StandaloneButtonSet=buttoncont;
    dlgStruct.Geometry=[400,200,700,800];
    dlgStruct.DisplayIcon=fullfile(matlabroot,'toolbox','clone_detection_app','m',...
    'ui','images','detect_16.png');
    dlgStruct.LayoutGrid=[50,50];

end
