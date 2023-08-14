classdef LidarCameraViewSection<vision.internal.uitools.NewToolStripSection&...
    driving.internal.groundTruthLabeler.tool.sections.LidarCameraViewSection



    properties

SaveCamViewButton

IsRefreshed

CamViewSaveBtnPopup

        SaveCamViewRepo={}

RestoreCamView

SaveCamViewItems

SaveCamView

OrganizeCamView

LimitsSettingsBtn

FullView

ROIView

IsROIPopupRefreshed
    end

    properties(Constant)
        ICONPATH=fullfile(toolboxdir('lidar'),'lidar','+lidar','+internal','+labeler','+tool','+icons');
    end

    methods(Access=protected)
        function layoutSection(this)
            this.addViewButtons();
            this.addButtons();


            colAddSession=this.addColumn('HorizontalAlignment','center');
            colAddSession.add(this.ProjectedView);


            colAddSession=this.addColumn(...
            'HorizontalAlignment','right');
            colAddSession.add(this.LimitsSettingsBtn);


            colAddSession=this.addColumn();
            colAddSession.add(this.XYView);
            colAddSession.add(this.YZView);
            colAddSession.add(this.XZView);

            colAddSession=this.addColumn();
            colAddSession.add(this.BirdsEyeView);
            colAddSession.add(this.ChaseView);
            colAddSession.add(this.EgoView);

            colAddSession=this.addColumn('HorizontalAlignment','center');
            colAddSession.add(this.EgoDirectionLabel);
            colAddSession.add(this.EgoDirection);


            colAddSession=this.addColumn(...
            'HorizontalAlignment','center');
            colAddSession.add(this.SaveCamViewButton);

            this.refreshCamViewSavePopup();
            this.refreshROIViewPopup();
        end
    end

    methods(Access=private)

        function addButtons(this)
            import matlab.ui.internal.toolstrip.*;


            icon=fullfile(this.ICONPATH,'customCameraViewIcon_24.png');
            titleID='lidar:labeler:lidarCustomCameraView';
            tag='btnCustomCameraView';
            this.SaveCamViewButton=this.createSplitButton(icon,titleID,tag);
            this.SaveCamViewButton.Enabled=true;
            toolTipID='lidar:labeler:lidarCamViewSave';
            this.setToolTipText(this.SaveCamViewButton,toolTipID);


            icon=fullfile(this.ICONPATH,'ROIView_24.png');
            titleID='lidar:labeler:lidarROIView';
            tag='btnROIView';
            this.LimitsSettingsBtn=this.createSplitButton(icon,titleID,tag);
            toolTipID='lidar:labeler:LidarROIViewToolTip';
            this.setToolTipText(this.LimitsSettingsBtn,toolTipID);

        end
    end




    methods
        function TF=isPopupRefreshed(this)
            TF=this.IsRefreshed;
        end


        function setIsRefreshed(this,flag)
            this.IsRefreshed=flag;
        end


        function TF=isROIPopupRefreshed(this)
            TF=this.IsROIPopupRefreshed;
        end


        function setIsROIPopupRefreshed(this,flag)
            this.IsROIPopupRefreshed=flag;
        end


        function refreshCamViewSavePopup(this)
            import matlab.ui.internal.toolstrip.Icon.*;
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();

            this.SaveCamViewItems={};


            text=vision.getMessage('lidar:labeler:LidarDefaultView');
            icon=RESTORE_16;
            tag='itemCameraView';
            this.RestoreCamView=ListItem(text,icon);
            this.RestoreCamView.Tag=tag;
            this.RestoreCamView.ShowDescription=false;
            popup.add(this.RestoreCamView);


            icon=fullfile(this.ICONPATH,'customCameraViewIcon_16.png');
            for i=1:numel(this.SaveCamViewRepo)
                item=ListItem(this.SaveCamViewRepo{i},icon);
                item.Tag=this.SaveCamViewRepo{i};
                item.ShowDescription=false;
                this.SaveCamViewItems{end+1}=item;
                popup.add(this.SaveCamViewItems{end});
            end


            text=vision.getMessage('lidar:labeler:lidarCamViewSave');
            ICON=matlab.ui.internal.toolstrip.Icon.SETTINGS_16;
            tag='itemSaveCameraView';
            this.SaveCamView=ListItem(text,ICON);
            this.SaveCamView.Tag=tag;
            this.SaveCamView.ShowDescription=false;
            popup.add(this.SaveCamView);


            text=vision.getMessage('lidar:labeler:SaveCamViewOrg');
            tag='itemOrganizeCameraView';
            this.OrganizeCamView=ListItem(text,ICON);
            this.OrganizeCamView.Tag=tag;
            this.OrganizeCamView.ShowDescription=false;
            popup.add(this.OrganizeCamView);

            this.CamViewSaveBtnPopup=popup;
            setIsRefreshed(this,true);
        end


        function refreshROIViewPopup(this)
            import matlab.ui.internal.toolstrip.Icon.*;
            import matlab.ui.internal.toolstrip.*;
            popup=PopupList();


            text=vision.getMessage('lidar:labeler:LidarFullView');
            icon=fullfile(this.ICONPATH,'FullView_24.png');
            tag='itemFullView';
            this.FullView=ListItem(text,icon);
            this.FullView.Tag=tag;
            this.FullView.ShowDescription=false;
            popup.add(this.FullView);


            text=vision.getMessage('lidar:labeler:LidarROIView');
            icon=fullfile(this.ICONPATH,'ROIView_24.png');
            tag='itemROIView';
            this.ROIView=ListItem(text,icon);
            this.ROIView.Tag=tag;
            this.ROIView.ShowDescription=false;
            popup.add(this.ROIView);

            setIsROIPopupRefreshed(this,true);
        end


        function appendCameraView(this,newCamViewName)

            this.SaveCamViewRepo{end+1}=newCamViewName;
            this.refreshCamViewSavePopup();
        end


        function resetSaveCameraView(this)


            this.IsRefreshed=true;
            this.SaveCamViewRepo={};
            this.refreshCamViewSavePopup();
        end
    end
end
