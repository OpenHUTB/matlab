





classdef LVImport<lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog

    properties(Access=private)
SourceObj
    end


    properties(Access=private)
        ImportPanelPos(1,4)int32
    end


    properties(Access=private)
        ImportPanel matlab.ui.container.Panel
    end

    properties(Access=private)

        IsSuccess(1,1)logical=false
        SourceInfo=[];
    end

    methods



        function this=LVImport(title)

            if nargin==0
                title='Import Data';
            end

            height=200;
            if strcmp(title,getString(message('lidar:lidarViewer:ImportSrcObj',...
                getString(message('lidar:lidarViewer:PCAP')))))
                height=230;
            end
            this=this@lidar.internal.lidarViewer.view.dialog.helper.OkCanceDialog(title,[550,height]);


            this.calculatePosition();
            this.createUI();
        end




        function open(this,srcObj)



            this.SourceObj=srcObj;


            srcObj.configureImportPanel(this.ImportPanel);

            this.MainFigure.Visible='on';
        end




        function info=getUserInfo(this)

            info.isSuccess=this.IsSuccess;
            info.info=this.SourceInfo;
        end
    end




    methods(Access=private)
        function calculatePosition(this)


            mainFigDim=this.Size;

            margin=5;

            okButtonTopPos=(this.OkButtonPos(4)+this.OkButtonPos(2));
            importPanelWidth=mainFigDim(1);
            importPanelHeight=mainFigDim(2)-okButtonTopPos-margin;
            importPanelBottomPos=okButtonTopPos+margin;
            this.ImportPanelPos=[0,importPanelBottomPos...
            ,importPanelWidth,importPanelHeight];

        end


        function createUI(this)


            this.createLoaderPanel();

        end


        function createLoaderPanel(this)

            this.ImportPanel=uipanel(...
            'Parent',this.MainFigure,...
            'Position',this.ImportPanelPos,...
            'BorderType','none');
        end

    end




    methods(Access=protected)

        function okClicked(this)
            this.IsSuccess=true;
            [dataPath,dataParams,dataName]=getLoadPanelData(this.SourceObj);
            this.SourceInfo=struct('DataParams',dataParams,...
            'DataName',dataName,'DataPath',dataPath);
            this.close();
        end
    end
end