





classdef FileSection<vision.internal.labeler.tool.sections.FileSection

    properties
LoadVideo
LoadImageSequence
LoadCustomReader
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


            loadVideoIcon=fullfile(this.IconPath,'LoadVideo.png');
            loadVideoTitleID=vision.getMessage('vision:labeler:AddVideo');
            this.LoadVideo=ListItem(loadVideoTitleID,loadVideoIcon);
            this.LoadVideo.Tag='itemLoadVideo';
            this.LoadVideo.ShowDescription=false;


            loadImageSequenceTitleID=vision.getMessage('vision:labeler:ImageSequence');
            loadImageSequenceIcon=fullfile(this.IconPath,'LoadImageSequence.png');
            this.LoadImageSequence=ListItem(loadImageSequenceTitleID,loadImageSequenceIcon);
            this.LoadImageSequence.Tag='itemLoadImageSequence';
            this.LoadImageSequence.ShowDescription=false;


            loadCustomReaderTitleID=vision.getMessage('vision:labeler:CustomReader');
            loadCustomReaderIcon=fullfile(this.IconPath,'LoadCustomSequence.png');
            this.LoadCustomReader=ListItem(loadCustomReaderTitleID,loadCustomReaderIcon);
            this.LoadCustomReader.Tag='itemLoadCustomReader';
            this.LoadCustomReader.ShowDescription=false;

            importPopup.add(this.LoadVideo);
            importPopup.add(this.LoadImageSequence);
            importPopup.add(this.LoadCustomReader);
        end
    end


end