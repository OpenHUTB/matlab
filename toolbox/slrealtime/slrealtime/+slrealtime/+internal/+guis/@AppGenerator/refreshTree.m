function refreshTree(this)






    signals=this.TreeConfigureSignals.Value;
    parameters=this.TreeConfigureParameters.Value;
    search=this.SearchEditField.Value;
    sourceFile=this.SessionSource(1).SourceFile;
    try
        slrtApp=slrealtime.Application(sourceFile);
        treeSource=slrtApp;
    catch
        try
            load_system(sourceFile);
        catch
            slrealtime.internal.throw.Error(...
            'slrealtime:appdesigner:ModelNotFound',...
            this.SessionSource(1).ModelName);
        end
        treeSource=sourceFile;
    end
    this.createTree(treeSource,'Signals',signals,'Parameters',parameters,'Search',search);
end