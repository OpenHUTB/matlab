classdef ScenarioSettingsDialog<dialogmgr.DCTableForm




    properties
hVisual
hCameraDialog
hSceneDialog
hAnnotationDialog
    end


    methods
        function this=ScenarioSettingsDialog(hVisual)
            this.Name='Settings';
            this.hVisual=hVisual;
            this.hCameraDialog=phased.scopes.ScenarioCameraDialog(hVisual);
            this.hSceneDialog=phased.scopes.ScenarioSceneDialog(hVisual);
            this.hAnnotationDialog=phased.scopes.ScenarioAnnotationDialog(hVisual);
        end


    end

    methods(Access=protected)
        function initTable(this)


            pv={...
            'DialogBorderDecoration',...
            {'TitlePanelBackgroundColorSource','Auto',...
            'TitlePanelForegroundColorSource','Custom',...
            'TitlePanelForegroundColor',[0,0,0]}};

            d=uidialog(this,'hSceneDialog',...
            this.hSceneDialog,pv{:});
            d.Tag='SceneTag';
            this.newrow

            d=uidialog(this,'hCameraDialog',...
            this.hCameraDialog,pv{:});
            d.Tag='CameraTag';
            this.newrow

            d=uidialog(this,'hAnnotationDialog',...
            this.hAnnotationDialog,pv{:});
            d.Tag='AnnotationTag';


            this.InterColumnSpacing=2;
            this.InterRowSpacing=2;
            this.InnerBorderSpacing=4;
        end
    end
end
