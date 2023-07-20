function dlgStruct=getDialogSchema(this)




    this.title=message('sl_pir_cpp:toolstrip:TestManagerDialogTitle').getString;

    resultSet=Simulink.CloneDetection.internal.util.gui.runTestManager(get_param(this.model,'Name'));
    this.CheckEquivalencyResult.IsEquivalencyCheckPassed=resultSet.IsEquivalencyCheckPassed;
    this.CheckEquivalencyResult.OriginalModel=resultSet.OriginalModel;
    this.CheckEquivalencyResult.UpdatedModel=resultSet.UpdatedModel;

    connector.ensureServiceOn;
    reportDisplay.Type='webbrowser';
    reportDisplay.WebKit=true;
    reportDisplay.Url=this.getTestManagerResultsHTML(this.model,...
    resultSet.IsEquivalencyCheckPassed);

    pushbuttonclose.Type='pushbutton';
    pushbuttonclose.Name='Close';
    pushbuttonclose.Tag='cancel';
    pushbuttonclose.WidgetId='cancel_id';
    pushbuttonclose.ObjectMethod='closeReportDialog';

    buttoncont.Name='buttontcont';
    buttoncont.Type='panel';
    buttoncont.Items={pushbuttonclose};


    dlgStruct.DialogTitle=this.title;
    dlgStruct.Items={reportDisplay};
    dlgStruct.DialogTag='TMDialog';
    dlgStruct.DisplayIcon=fullfile(matlabroot,'toolbox','clonedetection',...
    '+Simulink','+CloneDetection','+internal','+DDGViews',...
    'ui','images','detect_16.png');
    dlgStruct.StandaloneButtonSet=buttoncont;
    dlgStruct.Geometry=[200,200,500,300];

end


