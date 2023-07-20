function utilEnableLoopSections(blkh,LoopType)







    if~strcmpi(get_param(bdroot(blkh),'SimulationStatus'),'stopped')
        return
    end

    blkObj=get_param(blkh,'Object');
    maskObj=get_param(blkh,'MaskObject');

    switch LoopType
    case 'Speed'

        isTuneLoop=strcmp(blkObj.TuneSpeedLoop,'on');
        isTuneCompLoop=strcmp(blkObj.TuneFluxLoop,'on');
        isUseSameSettings=strcmp(blkObj.UseSameSettingsOuter,'on');


        TuneStr='grpTuneSpeedLoop';
        ExpStr='grpExpSpeedLoop';


        StartStr='StartTimeSpeed';
        StopStr='DurationSpeed';


        GroupCheckStr='UseSameSettingsOuter';
        TunePanelAllStr='grpTuneAllLoopsOuter';
        TunePanelIndStr='grpTuneIndividualLoopsOuter';
        ExpPanelAllStr='grpExperimentSettingsAllOuter';
        ExpPanelIndStr='grpExperimentSettingsIndividualOuter';
    case 'Flux'

        isTuneLoop=strcmp(blkObj.TuneFluxLoop,'on');
        isTuneCompLoop=strcmp(blkObj.TuneSpeedLoop,'on');
        isUseSameSettings=strcmp(blkObj.UseSameSettingsOuter,'on');


        TuneStr='grpTuneFluxLoop';
        ExpStr='grpExpFluxLoop';


        StartStr='StartTimeFlux';
        StopStr='DurationFlux';


        GroupCheckStr='UseSameSettingsOuter';
        TunePanelAllStr='grpTuneAllLoopsOuter';
        TunePanelIndStr='grpTuneIndividualLoopsOuter';
        ExpPanelAllStr='grpExperimentSettingsAllOuter';
        ExpPanelIndStr='grpExperimentSettingsIndividualOuter';
    case 'Qaxis'

        isTuneLoop=strcmp(blkObj.TuneQaxisLoop,'on');
        isTuneCompLoop=strcmp(blkObj.TuneDaxisLoop,'on');
        isUseSameSettings=strcmp(blkObj.UseSameSettingsInner,'on');


        TuneStr='grpTuneQaxisLoop';
        ExpStr='grpExpQaxisLoop';


        StartStr='StartTimeQaxis';
        StopStr='DurationQaxis';


        GroupCheckStr='UseSameSettingsInner';
        TunePanelAllStr='grpTuneAllLoopsInner';
        TunePanelIndStr='grpTuneIndividualLoopsInner';
        ExpPanelAllStr='grpExperimentSettingsAllInner';
        ExpPanelIndStr='grpExperimentSettingsIndividualInner';
    case 'Daxis'

        isTuneLoop=strcmp(blkObj.TuneDaxisLoop,'on');
        isTuneCompLoop=strcmp(blkObj.TuneQaxisLoop,'on');
        isUseSameSettings=strcmp(blkObj.UseSameSettingsInner,'on');


        TuneStr='grpTuneDaxisLoop';
        ExpStr='grpExpDaxisLoop';


        StartStr='StartTimeDaxis';
        StopStr='DurationDaxis';


        GroupCheckStr='UseSameSettingsInner';
        TunePanelAllStr='grpTuneAllLoopsInner';
        TunePanelIndStr='grpTuneIndividualLoopsInner';
        ExpPanelAllStr='grpExperimentSettingsAllInner';
        ExpPanelIndStr='grpExperimentSettingsIndividualInner';
    end


    dlgObj=maskObj.getDialogControl(TuneStr);
    if isTuneLoop
        dlgObj.Enabled='on';
        dlgObj.Visible='on';
    else
        dlgObj.Enabled='off';
        dlgObj.Visible='off';
    end

    dlgObj=maskObj.getDialogControl(ExpStr);
    if isTuneLoop
        dlgObj.Enabled='on';
        dlgObj.Visible='on';
    else
        dlgObj.Enabled='off';
        dlgObj.Visible='off';
    end


    objectCheck=maskObj.Parameters.findobj('Name',GroupCheckStr);
    objectTuneAll=maskObj.getDialogControl(TunePanelAllStr);
    objectTuneInd=maskObj.getDialogControl(TunePanelIndStr);
    objectExpAll=maskObj.getDialogControl(ExpPanelAllStr);
    objectExpInd=maskObj.getDialogControl(ExpPanelIndStr);

    if isTuneLoop&&isTuneCompLoop

        objectCheck.Enabled='on';

        if isUseSameSettings

            objectTuneAll.Enabled='on';
            objectTuneAll.Visible='on';
            objectTuneInd.Enabled='off';
            objectTuneInd.Visible='off';

            objectExpAll.Enabled='on';
            objectExpAll.Visible='on';
            objectExpInd.Enabled='off';
            objectExpInd.Visible='off';
        else

            objectTuneAll.Enabled='off';
            objectTuneAll.Visible='off';
            objectTuneInd.Enabled='on';
            objectTuneInd.Visible='on';

            objectExpAll.Enabled='off';
            objectExpAll.Visible='off';
            objectExpInd.Enabled='on';
            objectExpInd.Visible='on';
        end
    else

        objectCheck.Enabled='off';

        if isTuneLoop||isTuneCompLoop

            objectTuneAll.Enabled='off';
            objectTuneAll.Visible='off';
            objectTuneInd.Enabled='on';
            objectTuneInd.Visible='on';

            objectExpAll.Enabled='off';
            objectExpAll.Visible='off';
            objectExpInd.Enabled='on';
            objectExpInd.Visible='on';
        else

            objectTuneAll.Enabled='off';
            objectTuneAll.Visible='off';
            objectTuneInd.Enabled='off';
            objectTuneInd.Visible='off';

            objectExpAll.Enabled='off';
            objectExpAll.Visible='off';
            objectExpInd.Enabled='off';
            objectExpInd.Visible='off';
        end
    end


    object=maskObj.Parameters.findobj('Name',StartStr);
    if isTuneLoop
        object.Enabled='on';
        object.Visible='on';
    else
        object.Enabled='off';
        object.Visible='off';
    end
    object=maskObj.Parameters.findobj('Name',StopStr);
    if isTuneLoop
        object.Enabled='on';
        object.Visible='on';
    else
        object.Enabled='off';
        object.Visible='off';
    end