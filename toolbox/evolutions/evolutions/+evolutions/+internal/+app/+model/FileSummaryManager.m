classdef FileSummaryManager<handle




    events
    end

    properties(Hidden,Access=protected)
AppModel
    end

    properties(SetAccess=protected,GetAccess=public)
        FullName char
        Name char
        Path char
        CreatedOn char
    end

    properties(SetAccess=protected,GetAccess=public)
        UpdatedOn char
        UpdatedBy char
        Comment char
    end

    methods
        function this=FileSummaryManager(appModel)
            this.AppModel=appModel;
            updateFileSummary(this);
        end
    end

    methods
        function updateFileSummary(this)
            fileListManager=getSubModel(this.AppModel,'FileList');
            if~isempty(fileListManager.CurrentSelected)
                currentFile=fileListManager.CurrentSelected;
                [this.Path,name,ext]=fileparts(currentFile.File);
                this.Name=sprintf("%s%s",name,ext);
            else
                this.Name=char.empty;
                this.Path=char.empty;
                this.CreatedOn=char.empty;
                this.UpdatedOn=char.empty;
                this.UpdatedBy=char.empty;
                this.Comment=char.empty;
            end
        end
    end
end
