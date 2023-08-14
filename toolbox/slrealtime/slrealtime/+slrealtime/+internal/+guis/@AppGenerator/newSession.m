function newSession(this,sourceFile)










    progressDlg=uiprogressdlg(...
    this.getUIFigure(),...
    'Indeterminate','on',...
    'Message',this.CreatingNewSessionMsg_msg,...
    'Title',this.CreatingNewSessionTitle_msg);
    c=onCleanup(@()delete(progressDlg));

    treeSource=[];%#ok
    try

        slrtApp=slrealtime.Application(sourceFile);


        this.SessionSource(1).SourceFile=sourceFile;
        this.SessionSource(1).ModelName=slrtApp.ModelName;
        this.SessionSource(1).NumSigsAndParams=numel(slrtApp.getParameters())+numel(slrtApp.getSignals());
        treeSource=slrtApp;
    catch

        try
            load_system(sourceFile);


            this.SessionSource(1).SourceFile=sourceFile;
            [~,this.SessionSource(1).ModelName]=fileparts(sourceFile);
            this.SessionSource(1).NumSigsAndParams=-1;
            treeSource=sourceFile;
        catch


            this.errorDlg('slrealtime:appdesigner:NewSessionError',...
            sourceFile);
            return;
        end
    end


    this.revertSessionToDefaults();


    this.SessionSavedToFile=[];


    this.createTree(treeSource);
end

