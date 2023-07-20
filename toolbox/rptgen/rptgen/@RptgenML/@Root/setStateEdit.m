function setStateEdit(this)








    this.Library=this.PrevLibrary;

    if isa(this.Editor,'DAStudio.Explorer')

        set(this.Actions.Report,...
        'Text',getString(message('rptgen:RptgenML_Root:reportLabelAcc')),...
        'Callback','cbkReport(RptgenML.Root,''-rundeferred'');',...
        'Icon',fullfile(matlabroot,'toolbox','rptgen','resources','Report.png'),...
        'StatusTip',getString(message('rptgen:RptgenML_Root:runCurrentLabel')),...
        'Enabled','off');

        treeListener=find(this.Listeners,'EventType','METreeSelectionChanged');
        set(treeListener,'Enabled','on');

        adRG=rptgen.appdata_rg;
        adRG.GenerationStatus='unset';

    end

