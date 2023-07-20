






classdef FileSection<vision.internal.labeler.tool.sections.FileSection


    properties
LoadImagesDirectory
LoadImagesDatastore
    end

    methods
        function this=FileSection()
            this@vision.internal.labeler.tool.sections.FileSection();
        end
    end

    methods(Access=protected)
        function addImportDataSourceList(this,importPopup)
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.toolstrip.Icon.*;


            loadImagesDirectoryIcon=ADD_16;
            loadImagesDirectoryTitleID=vision.getMessage('vision:imageLabeler:FromFile');
            this.LoadImagesDirectory=ListItem(loadImagesDirectoryTitleID,loadImagesDirectoryIcon);
            this.LoadImagesDirectory.Description=vision.getMessage('vision:imageLabeler:FromFileDescription');
            this.LoadImagesDirectory.Tag='itemLoadVideo';
            this.LoadImagesDirectory.ShowDescription=true;


            loadImagesDatastoreTitleID=vision.getMessage('vision:imageLabeler:FromWorkspace');
            loadImagesDatastoreIcon=fullfile(this.IconPath,'LoadImageSequence.png');
            this.LoadImagesDatastore=ListItem(loadImagesDatastoreTitleID,loadImagesDatastoreIcon);
            this.LoadImagesDatastore.Description=vision.getMessage('vision:imageLabeler:FromWorkspaceDescription');
            this.LoadImagesDatastore.Tag='itemLoadImageSequence';
            this.LoadImagesDatastore.ShowDescription=true;

            importPopup.add(this.LoadImagesDirectory);
            if~isdeployed()
                importPopup.add(this.LoadImagesDatastore);
            end
        end
    end
end
