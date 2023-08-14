classdef ImportDataDialog<controllib.ui.internal.dialog.AbstractDialog





    properties(Access='private')

        ImagesPathEdit;
        PointcloudsPathEdit;

        CheckerboardSquareSizeEdit;
        CheckerboardPaddingEdit;
        CheckerboardUnitsCbx;

        OkayBtn;
        CancelBtn;
        BrowseImagesPathBtn;
        BrowsePointcloudsPathBtn;

        ErrorMsgLabel;

        ParentFig;

        InputPaths;
        CbSettings;
        DisableCBOptions;

        IsOkayClicked=false;

        FigBusy=false;
        UIPanel=[];
    end

    properties(Hidden)
        FigureTag='addDataDiag';
    end

    methods

        function this=ImportDataDialog()
            this.CloseMode='destroy';
        end

        function[inputPaths,cbSettings]=showDiag(this,title,parent,disableCBOptions,cbDefaultSettings)
            this.Title=title;
            this.DisableCBOptions=disableCBOptions;
            this.CbSettings=cbDefaultSettings;

            this.ParentFig=parent;
            this.IsOkayClicked=false;

            show(this,parent);
            this.UIFigure.CloseRequestFcn=@(es,ed)cbCancelBtn(this);

            uiwait(this.UIFigure);

            inputPaths=[];
            cbSettings=[];
            if(this.IsOkayClicked)
                inputPaths=this.InputPaths;
                cbSettings=this.CbSettings;
            end

        end
    end

    methods(Access='protected')
        function buildUI(this)

            figSize=[500,300];
            this.UIFigure.WindowStyle='modal';
            this.UIFigure.Position=[this.UIFigure.Position(1),this.UIFigure.Position(2),figSize(1),figSize(2)];
            this.UIFigure.Resize='off';
            this.UIFigure.Tag=this.FigureTag;
            this.UIFigure.Name=this.Title;


            cbxItems=[string(message('lidar:lidarCameraCalibrator:checkerboardUnitsMillimeters')),...
            string(message('lidar:lidarCameraCalibrator:checkerboardUnitsCentimeters')),...
            string(message('lidar:lidarCameraCalibrator:checkerboardUnitsMeters')),...
            string(message('lidar:lidarCameraCalibrator:checkerboardUnitsInches'))];

            cbxItemsInd=find(strcmpi(string(this.CbSettings.Units),["millimeters","centimeters","meters","inches"]));
            if(isempty(cbxItemsInd))
                cbxItemsInd=1;
            end


            defaultCbUnits=cbxItems(cbxItemsInd);
            defaultCBSize=this.CbSettings.Squaresize;
            defaultPadding=this.CbSettings.Padding;

            this.UIPanel=uipanel('Parent',this.UIFigure,'Position',[1,1,this.UIFigure.Position(3),this.UIFigure.Position(4)]);

            labelImgsPath=uilabel("Text",...
            string(message('lidar:lidarCameraCalibrator:imageFolderLabelText'))+" : ",'Parent',this.UIPanel);
            this.ImagesPathEdit=uieditfield('Editable',true,'Parent',this.UIPanel);

            this.BrowseImagesPathBtn=uibutton('Parent',this.UIPanel,...
            "Text",string(message('lidar:lidarCameraCalibrator:browseBtn')));

            labelPtcFilesPath=uilabel("Text",...
            string(message('lidar:lidarCameraCalibrator:pointCloudFolderLabelText'))+" : ",'Parent',this.UIPanel);
            this.PointcloudsPathEdit=uieditfield('Editable',true,'Parent',this.UIPanel);

            this.BrowsePointcloudsPathBtn=uibutton('Parent',this.UIPanel,...
            "Text",string(message('lidar:lidarCameraCalibrator:browseBtn')));

            cbPanels=uipanel('Parent',this.UIPanel,...
            'Title',string(message('lidar:lidarCameraCalibrator:checkerboardPanelText')));

            labelPadding=uilabel("Text",...
            string(message('lidar:lidarCameraCalibrator:checkerboardPaddingLabelText'))+" : ",'Parent',cbPanels);
            labelCbSize=uilabel("Text",...
            string(message('lidar:lidarCameraCalibrator:checkerboardSquaresizeLabelText'))+" : ",'Parent',cbPanels);

            this.CheckerboardUnitsCbx=uidropdown("Items",cbxItems,'Parent',cbPanels);
            this.CheckerboardUnitsCbx.Value=defaultCbUnits;
            this.OkayBtn=uibutton('Parent',this.UIPanel,...
            "Text",string(message('lidar:lidarCameraCalibrator:okBtn')));
            this.CancelBtn=uibutton('Parent',this.UIPanel,...
            "Text",string(message('lidar:lidarCameraCalibrator:cancelBtn')));

            this.CheckerboardSquareSizeEdit=uieditfield('numeric','Editable',true,'Parent',cbPanels);
            this.CheckerboardPaddingEdit=uieditfield('Value',mat2str(defaultPadding),'Editable',true,'Parent',cbPanels);


            this.ErrorMsgLabel=uilabel(this.UIPanel,'FontColor','red','Text','');



            this.UIFigure.Tag=this.FigureTag;

            this.ImagesPathEdit.Tooltip=string(message('lidar:lidarCameraCalibrator:imageFolderInputTooltip'));
            this.PointcloudsPathEdit.Tooltip=string(message('lidar:lidarCameraCalibrator:pointCloudFolderInputTooltip'));

            this.CheckerboardSquareSizeEdit.Tooltip=string(message('lidar:lidarCameraCalibrator:checkerboardSquaresizeInputTooltip'));
            this.CheckerboardPaddingEdit.Tooltip=string(message('lidar:lidarCameraCalibrator:checkerboardPaddingInputTooltip'));
            this.CheckerboardUnitsCbx.Tooltip=string(message('lidar:lidarCameraCalibrator:checkerboardUnitsTooltip'));

            this.OkayBtn.Enable=false;
            widthPadding=24;
            heightPadding=8;
            controlHeight=24;



            x=widthPadding;
            y=270;
            labelWidth=300;
            labelImgsPath.Position=[x,y,labelWidth,controlHeight];

            x=widthPadding;
            y=y-labelImgsPath.Position(4)-heightPadding;

            editFieldWidth=350;
            this.ImagesPathEdit.Position=[x,y,editFieldWidth,controlHeight];

            x=widthPadding+this.ImagesPathEdit.Position(1)+this.ImagesPathEdit.Position(3);
            browseBtn1Width=80;
            this.BrowseImagesPathBtn.Position=[x,y,browseBtn1Width,controlHeight];


            x=widthPadding;
            y=y-this.ImagesPathEdit.Position(4)-heightPadding;


            labelWidth=300;
            labelPtcFilesPath.Position=[x,y,labelWidth,controlHeight];

            x=widthPadding;
            y=y-labelPtcFilesPath.Position(4)-heightPadding;
            editFieldWidth=350;
            this.PointcloudsPathEdit.Position=[x,y,editFieldWidth,controlHeight];

            x=widthPadding+this.PointcloudsPathEdit.Position(1)+this.PointcloudsPathEdit.Position(3);

            browseBtn2Width=80;
            this.BrowsePointcloudsPathBtn.Position=[x,y,browseBtn2Width,controlHeight];

            cbPanelsWidth=350;
            cbPanelsHeight=90;
            x=widthPadding*0+this.UIFigure.Position(3)/2-cbPanelsWidth/2;
            y=y-cbPanelsHeight-heightPadding*2;


            cbPanels.Position=[x,y,cbPanelsWidth,cbPanelsHeight];

            labelWidth=120;
            labelCbSize.Position=[10,40,labelWidth,controlHeight];

            editFieldWidth=80;
            this.CheckerboardSquareSizeEdit.Position=[labelWidth-10,40,editFieldWidth,20];
            this.CheckerboardUnitsCbx.Position=[this.CheckerboardSquareSizeEdit.Position(1)+5+editFieldWidth,40,150,20];


            labelWidth=100;
            labelPadding.Position=[10,10,labelWidth,controlHeight];


            editFieldWidth=145;
            this.CheckerboardPaddingEdit.Position=[labelWidth+10,10,editFieldWidth,20];



            okayBtnWidth=80;
            x=0+this.UIFigure.Position(3)/2-okayBtnWidth-10;
            y=y-heightPadding-controlHeight-5;
            this.OkayBtn.Position=[x,y,okayBtnWidth,controlHeight];

            cancelBtnWidth=80;
            x=this.OkayBtn.Position(1)+this.OkayBtn.Position(3)+10;
            this.CancelBtn.Position=[x,y,cancelBtnWidth,controlHeight];

            this.ErrorMsgLabel.Position=[5,2,figSize(1)-10,controlHeight];

            if(this.DisableCBOptions)
                this.CheckerboardSquareSizeEdit.Value=defaultCBSize;

                labelPadding.Enable=false;
                labelCbSize.Enable=false;
                this.CheckerboardPaddingEdit.Enable=false;
                this.CheckerboardSquareSizeEdit.Enable=false;
                this.CheckerboardUnitsCbx.Enable=false;
            end
        end

        function connectUI(this)

            addlistener(this.BrowseImagesPathBtn,'ButtonPushed',@(es,ed)cbBrowseBtn(this,this.ImagesPathEdit,this.PointcloudsPathEdit.Value));
            addlistener(this.BrowsePointcloudsPathBtn,'ButtonPushed',@(es,ed)cbBrowseBtn(this,this.PointcloudsPathEdit,this.ImagesPathEdit.Value));
            addlistener(this.OkayBtn,'ButtonPushed',@(es,ed)cbOkayBtn(this));
            addlistener(this.CancelBtn,'ButtonPushed',@(es,ed)cbCancelBtn(this));

            addlistener(this.ImagesPathEdit,'ValueChanged',@(es,ed)cbEnableOkBtn(this));
            addlistener(this.PointcloudsPathEdit,'ValueChanged',@(es,ed)cbEnableOkBtn(this));
            addlistener(this.CheckerboardPaddingEdit,'ValueChanged',@(es,ed)cbEnableOkBtn(this));
            addlistener(this.CheckerboardSquareSizeEdit,'ValueChanged',@(es,ed)cbEnableOkBtn(this));
        end

    end

    methods(Access='private')

        function setBusy(this,flag)
            persistent mousePointer;
            if(flag)

                this.FigBusy=true;
                mousePointer=this.UIFigure.Pointer;
                this.UIFigure.Pointer="watch";
                this.UIPanel.Enable='off';
            else
                if(isempty(mousePointer))
                    mousePointer=this.UIFigure.Pointer;
                end

                this.FigBusy=false;
                this.UIFigure.Pointer=mousePointer;
                this.UIPanel.Enable='on';
            end
        end
        function cbBrowseBtn(this,editDataPath,startPath)
            persistent currentlyBrowsing;
            if(isempty(currentlyBrowsing))
                currentlyBrowsing=true;

                setBusy(this,true);

                if(~isempty(editDataPath.Value)&&isfolder(editDataPath.Value))


                    startPath=editDataPath.Value;
                elseif(~isempty(char(startPath))&&isfolder(startPath))






                    filesep_indices=strfind(startPath,filesep);
                    if(~isempty(filesep_indices)&&filesep_indices(end)-1>1)
                        tempPath=startPath(1:filesep_indices(end)-1);
                        if(~isempty(tempPath)&&isfolder(tempPath))
                            startPath=tempPath;
                        end
                    end
                else
                    startPath=pwd;
                end
                selectedDir=uigetdir(startPath);
                if(~isvalid(this.UIFigure))

                    return;
                end
                if(selectedDir~=0)
                    editDataPath.Value=selectedDir;
                end
                cbEnableOkBtn(this);

                currentlyBrowsing=[];
                setBusy(this,false);

                if(~isempty(this.ParentFig)&&isa(this.ParentFig,'matlab.ui.container.internal.AppContainer'))
                    this.ParentFig.bringToFront();
                end
                figure(this.UIFigure);
            end
        end

        function cbCancelBtn(this)
            if(this.FigBusy)
                return;
            end
            this.close();
        end

        function cbOkayBtn(this)

            try
                imageDatastore(this.ImagesPathEdit.Value);
            catch
                uialert(this.UIFigure,...
                string(message('lidar:lidarCameraCalibrator:noImageFiles')),...
                this.Title,'Icon','error');
                return;
            end

            try
                fileDatastore(this.PointcloudsPathEdit.Value,'ReadFcn',@pcread,'FileExtensions',{'.pcd','.ply'});
            catch
                uialert(this.UIFigure,...
                string(message('lidar:lidarCameraCalibrator:noPointcloudFiles')),...
                this.Title,'Icon','error');
                return;
            end

            this.InputPaths.ImagesPath=this.ImagesPathEdit.Value;
            this.InputPaths.PointCloudsPath=this.PointcloudsPathEdit.Value;

            this.CbSettings.Squaresize=this.CheckerboardSquareSizeEdit.Value;
            this.CbSettings.Padding=str2num(this.CheckerboardPaddingEdit.Value);

            cbxUnitsSelIndex=strcmpi(this.CheckerboardUnitsCbx.Value,this.CheckerboardUnitsCbx.Items);
            cbxUnitsStr=["millimeters","centimeters","meters","inches"];
            this.CbSettings.Units=char(cbxUnitsStr(cbxUnitsSelIndex));

            uiresume(this.UIFigure);
            this.UIFigure.Visible="off";
            this.IsOkayClicked=true;
            this.close();
        end

        function cbEnableOkBtn(this)
            this.OkayBtn.Enable=false;
            this.ErrorMsgLabel.Text='';


            if(isempty(this.ImagesPathEdit.Value))
                return;
            elseif(~isfolder(this.ImagesPathEdit.Value))
                this.ImagesPathEdit.FontColor='red';
                this.ErrorMsgLabel.Text="* "+string(message('lidar:lidarCameraCalibrator:wrongImagesPathInput'));
                return;
            else
                this.ImagesPathEdit.FontColor='black';
            end

            if(isempty(this.PointcloudsPathEdit.Value))
                return;
            elseif(~isfolder(this.PointcloudsPathEdit.Value))
                this.PointcloudsPathEdit.FontColor='red';
                this.ErrorMsgLabel.Text="* "+string(message('lidar:lidarCameraCalibrator:wrongPointcloudsPathInput'));
                return;
            else
                this.PointcloudsPathEdit.FontColor='black';
            end

            if(isempty(this.CheckerboardSquareSizeEdit.Value))
                return;
            elseif(this.CheckerboardSquareSizeEdit.Value<=0)
                this.CheckerboardSquareSizeEdit.FontColor='red';
                this.ErrorMsgLabel.Text="* "+string(message('lidar:lidarCameraCalibrator:wrongSquaresizeInput'));
                return;
            else
                this.CheckerboardSquareSizeEdit.FontColor='black';
            end

            if(isempty(this.CheckerboardPaddingEdit.Value))
                this.CheckerboardPaddingEdit.FontColor='red';
                this.ErrorMsgLabel.Text="* "+string(message('lidar:lidarCameraCalibrator:wrongPaddingInput'));
                return;
            else

                [val,flag]=str2num(this.CheckerboardPaddingEdit.Value);
                wrongPadding=false;
                if(flag)
                    if(length(val)~=4)
                        wrongPadding=true;
                    else
                        if(any(val<0))
                            wrongPadding=true;
                        end
                    end
                else
                    wrongPadding=true;
                end
                if(~wrongPadding)
                    this.CheckerboardPaddingEdit.FontColor='black';
                else
                    this.CheckerboardPaddingEdit.FontColor='red';
                    this.ErrorMsgLabel.Text="* "+string(message('lidar:lidarCameraCalibrator:wrongPaddingInput'));
                    return;
                end
            end

            this.OkayBtn.Enable=true;
        end
    end
end
