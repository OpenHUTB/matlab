function createTree(this,treeSource,varargin)






    delete(this.Tree.Children);
    this.TreeFullyProcessed=false;
    this.treeSelectionChanged();

    try
        try
            slrealtime.internal.ApplicationTree.populate(...
            this.Tree,treeSource,varargin{:});
        catch ME





            if this.handleUpdateDiagramOrRethrow(ME)



                slrealtime.internal.ApplicationTree.populate(...
                this.Tree,treeSource,varargin{:});
            end
        end
    catch ME
        if~isempty(ME.cause)
            str=join(cellfun(@(x)x.message,ME.cause,'UniformOutput',false),newline);
            errorStr=[newline,newline,str{1}];
        else
            errorStr=ME.message;
        end
        this.errorDlg('slrealtime:appdesigner:CreateTreeError',errorStr);
    end
end
