classdef DialogManager<handle




    properties(Access=private)
        FigureHandles matlab.ui.Figure
        UIProgressDlgFig matlab.ui.Figure
        UIProgressDlg matlab.ui.dialog.ProgressDialog



        ShowMergeLargeDataDlg(1,1)logical=true
    end

    methods

        function self=DialogManager()
        end

        function clear(self)
            delete(self.FigureHandles);
            delete(self.UIProgressDlg);
            delete(self.UIProgressDlgFig);
        end

    end

    methods




        function dlg=ImportImageAsDlg(self,toolCenter,hasPixelLabels)

            dlgSize=[483,560];
            dlgCenter=toolCenter;

            dlg=vision.internal.imageLabeler.tool.dialogs.ImportImageAsDlg(dlgSize,dlgCenter,hasPixelLabels);
            self.FigureHandles(end+1)=dlg.FigureHandle;
            wait(dlg)

        end




        function dlg=MergeLargeDataDlg(self,toolCenter)

            if~self.ShowMergeLargeDataDlg
                dlg=[];
                return;
            end

            dlgSize=[550,240];
            pos=self.getModelDialogPos(dlgSize,toolCenter);

            dlg=vision.internal.imageLabeler.tool.dialogs.MergeLargeDataDlg(pos);
            self.FigureHandles(end+1)=dlg.FigureHandle;
            wait(dlg);

            self.ShowMergeLargeDataDlg=~dlg.DonotShowDlg;

        end




        function dlg=MandatoryDirectoryDialog(self,toolCenter,groupName)

            dlgSize=[500,90];
            dlgCenter=toolCenter;

            if vision.internal.labeler.jtfeature('useAppContainer')
                dlg=vision.internal.imageLabeler.tool.dialogs.MandatoryDirectoryDialog(dlgSize,dlgCenter,groupName);
                self.FigureHandles(end+1)=dlg.FigureHandle;
            else
                dlg=vision.internal.imageLabeler.tool.dialogs.MandatoryDirectoryDialogFigure(dlgSize,dlgCenter,groupName);
                self.FigureHandles(end+1)=dlg.FigureHandle;
            end
            wait(dlg);

        end




        function openGeneratingOverviewAndThumbnailsDlg(self,toolCenter)



            dlgSize=[400,120];
            pos=self.getModelDialogPos(dlgSize,toolCenter);

            if isvalid(self.UIProgressDlgFig)
                self.UIProgressDlgFig.Visible='on';
                return
            end

            uif=uifigure('Position',pos,...
            'Resize','off',...
            'WindowStyle','modal',...
            'CloseRequestFcn',@(~,~)[]);

            self.UIProgressDlgFig=uif;
            self.FigureHandles(end+1)=uif;

            self.UIProgressDlg=uiprogressdlg(uif,...
            'Title',getString(message('vision:imageLabeler:GeneratingOverviewAndThumbnails')),...
            'Message',{'Image: ','Image Size: '},...
            'Indeterminate','on',...
            'Cancelable','off');
            drawnow;

        end

        function hideGeneratingOverviewAndThumbnailsDlg(self)


            if isvalid(self.UIProgressDlgFig)
                self.UIProgressDlgFig.Visible='off';
                self.UIProgressDlg.Message={'Image: ','Image Size: '};


            end

        end

        function openGeneratingOverviewAndThumbnailsDlgUIFig(self,hParent)

            self.UIProgressDlg=uiprogressdlg(hParent,...
            'Title',getString(message('vision:imageLabeler:GeneratingOverviewAndThumbnails')),...
            'Message',{'Image: ','Image Size: '},...
            'Indeterminate','on',...
            'Cancelable','off');
            drawnow;

        end

        function hideGeneratingOverviewAndThumbnailsDlgUIFig(self)

            if isvalid(self.UIProgressDlg)
                delete(self.UIProgressDlg);
            end

        end

        function updateProgressDlgMsg(self,msg)
            if isvalid(self.UIProgressDlg)
                self.UIProgressDlg.Message=msg;
            end
        end

    end

    methods(Access=private)

        function pos=getModelDialogPos(~,dlgSize,toolCenter)
            pos=round([toolCenter-dlgSize/2,dlgSize]);
        end

    end

end