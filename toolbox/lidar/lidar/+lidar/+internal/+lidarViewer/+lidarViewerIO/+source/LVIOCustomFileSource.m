










classdef LVIOCustomFileSource<lidar.internal.lidarViewer.lidarViewerIO.LVIOSource

    properties(Constant)
        IOSourceName=getString(message('lidar:lidarViewer:CustomFile'))
    end

    properties(Access=private)
FunctionHandle
    end

    properties(Access=private,Hidden)
ParentPanel
ReaderFcnText
ReaderFcnBox
SourceNameText
SourceNameBox

DescriptionText
    end

    properties(Access=private,Hidden)
DescriptionTextPos
ReaderFcnTextPos
ReaderFcnBoxPos
SourceNameTextPos
SourceNameBoxPos
    end

    properties
FileReader
    end

    properties(Constant,Hidden)
        MARGIN=40;
        SPACING=40;
        UICOMPONENTHEIGHT=30;
        WIDTH=5;
    end




    methods
        function configureImportPanel(this,panel)


            this.ParentPanel=panel;
            this.computePosition();
            this.createUI();
        end



        function[dataPath,dataParams,dataName]=getLoadPanelData(this)
            dataPath=this.SourceNameBox.Value;

            dataParams=[];
            dataParams.FunctionHandle=string(this.ReaderFcnBox.Value);

            [~,folderName,~]=fileparts(this.SourceNameBox.Value);
            dataName=strcat(this.IOSourceName,'_',folderName);
        end
    end




    methods(Access=private)
        function computePosition(this)


            panelPos=this.ParentPanel.Position;
            spacing=panelPos(4)*0.2;


            bottomPos=panelPos(4)*0.70;
            this.ReaderFcnTextPos=[this.MARGIN,bottomPos...
            ,panelPos(3)-this.MARGIN,this.UICOMPONENTHEIGHT];


            fileEditBoxWidth=panelPos(3)-this.WIDTH-2*this.MARGIN;
            bottomPos=bottomPos-spacing;
            this.ReaderFcnBoxPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            bottomPos=bottomPos-spacing;
            this.SourceNameTextPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];


            bottomPos=bottomPos-spacing;
            this.SourceNameBoxPos=[this.MARGIN,bottomPos...
            ,fileEditBoxWidth,this.UICOMPONENTHEIGHT];
        end


        function createUI(this)
            this.createFileBrowseComponents();
        end


        function createFileBrowseComponents(this)
            this.ReaderFcnText=uilabel('Parent',this.ParentPanel,...
            'Text','Custom Reader Function:',...
            'Position',this.ReaderFcnTextPos,...
            'Tag','readerFcnTxt');

            this.ReaderFcnBox=uieditfield('Parent',this.ParentPanel,...
            'Value','',...
            'Position',this.ReaderFcnBoxPos,...
            'Tag','readerFcnTxtBox');

            this.SourceNameText=uilabel('Parent',this.ParentPanel,...
            'Text','Source Name:',...
            'Position',this.SourceNameTextPos,...
            'Tag','sourceNameTxt');

            this.SourceNameBox=uieditfield('Parent',this.ParentPanel,...
            'Value','',...
            'Position',this.SourceNameBoxPos,...
            'Tag','sourceNameTxtBox');
        end

    end




    methods
        function data=readData(this,index)

            data=this.createDataStruct();
            data.PointCloud=this.FunctionHandle(this.FileReader,index);
        end
    end




    methods
        function loadData(this,dataName,dataParams,dataPath)


            functionHandle=dataParams.FunctionHandle;
            this.FileReader=dataPath;

            if~isa(functionHandle,'function_handle')

                absolutePathFileName=which(functionHandle);

                if(isempty(absolutePathFileName))
                    errorMessage=vision.getMessage('lidar:lidarViewer:pathNotFound',functionHandle);
                    error(errorMessage);
                    return;
                end

                [~,fileName,fileExt]=fileparts(absolutePathFileName);

                if~(exist(fileName,'file')&&strcmpi(fileExt,'.m'))
                    errorMessage=vision.getMessage('lidar:lidarViewer:CustomReaderNotValid',functionHandle);
                    error(errorMessage);
                end

                functionHandle=str2func(fileName);
            end

            this.FunctionHandle=functionHandle;
            this.TimeVector=this.FunctionHandle(this.FileReader);

            this.DataName=dataName;
            this.DataParams=dataParams;
            this.DataPath=dataPath;
        end
    end

end