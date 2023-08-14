






classdef LVIOPCDFileSource<lidar.internal.lidarViewer.lidarViewerIO.LVIOSource

    properties(Constant)
        IOSourceName=getString(message('lidar:lidarViewer:PCDSequence'))
    end

    properties(Access=private,Hidden)
ParentPanel
FileBrowserButton
FileBrowserEditBox
DescriptionText
    end

    properties(Access=private,Hidden)
FileBrowserButtonPos
FileEditBoxPos
DescriptionTextPos
    end

    properties
FileDataStore
    end

    properties(Constant,Hidden)
        MARGIN=15;
        SPACING=40;
        UICOMPONENTHEIGHT=30;
        BROWSEBUTTONWIDTH=100
    end




    methods
        function configureImportPanel(this,panel)


            this.ParentPanel=panel;
            this.computePosition();
            this.createUI();
        end



        function[dataPath,dataParams,dataName]=getLoadPanelData(this)
            dataPath=this.FileBrowserEditBox.Value;

            dataParams=[];

            [~,folderName,~]=fileparts(this.FileBrowserEditBox.Value);
            dataName=this.getUniqueName(folderName);
        end
    end




    methods(Access=private)
        function computePosition(this)


            panelPos=this.ParentPanel.Position;


            bottomPos=panelPos(4)*0.55;
            this.DescriptionTextPos=[this.MARGIN,bottomPos...
            ,panelPos(3)-2*this.MARGIN,22];


            fileEditBoxWidth=panelPos(3)-this.BROWSEBUTTONWIDTH-3*this.MARGIN;
            bottomPos=bottomPos-this.SPACING;
            this.FileEditBoxPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            this.FileBrowserButtonPos=[fileEditBoxWidth+2*this.MARGIN...
            ,bottomPos,this.BROWSEBUTTONWIDTH,this.UICOMPONENTHEIGHT];
        end


        function createUI(this)
            this.createDescriptionText();

            this.createFileBrowserEB();

            this.createFileBrowserButton();
        end


        function createDescriptionText(this)
            this.DescriptionText=uilabel(...
            'Parent',this.ParentPanel,...
            'Position',this.DescriptionTextPos,...
            'Text',getString(message('lidar:lidarViewer:ImportDescPCD')));
        end


        function createFileBrowserEB(this)
            this.FileBrowserEditBox=uieditfield(...
            'Parent',this.ParentPanel,...
            'Tag','fileBrowserEB',...
            'Position',this.FileEditBoxPos);
        end


        function createFileBrowserButton(this)
            this.FileBrowserButton=uibutton(...
            'Parent',this.ParentPanel,...
            'Position',this.FileBrowserButtonPos,...
            'Text',getString(message('lidar:lidarViewer:Browse')),...
            'Tag','browseBttn',...
            'ButtonPushedFcn',@(~,~)requestToBrowseFile(this));
        end


        function requestToBrowseFile(this)

            persistent cachedPath

            if isempty(cachedPath)
                cachedPath=pwd;
            end
            chosenDirectory=uigetdir(cachedPath,'Pick a folder');


            this.bringToFront();
            hFig=ancestor(this.ParentPanel,'figure');
            figure(hFig);

            if chosenDirectory==0
                return
            end
            if~isfolder(chosenDirectory)
                return;
            end


            this.FileBrowserEditBox.Value=chosenDirectory;
            cachedPath=chosenDirectory;
        end
    end




    methods
        function data=readData(this,index)
            data=this.createDataStruct();
            data.PointCloud=pcread(this.FileDataStore.Files{index});
            data.ScalarData.Name=this.Scalars;
            data.ScalarData.Value=[];

        end
    end




    methods
        function loadData(this,dataName,dataParams,dataPath)

            ext={'.pcd','.ply'};
            fileName=dataPath;
            this.FileDataStore=...
            fileDatastore(fileName,'ReadFcn',@pcread,'FileExtensions',ext);

            this.TimeVector=seconds(0:1:numel(this.FileDataStore.Files)-1)';
            this.DataName=dataName;
            this.DataParams=dataParams;
            this.DataPath=dataPath;
            this.Scalars={};
        end
    end
end