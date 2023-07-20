classdef PolygonSection<vision.internal.uitools.NewToolStripSection




    properties
PolygonButton
SmartPolygonButton
SmartPolygonEditorButton
    end

    properties
UseAppContainer
    end

    properties(Constant)
        IconPath=fullfile(toolboxdir('vision'),'vision','+vision','+internal','+labeler','+tool','+icons');
    end

    methods
        function this=PolygonSection()
            this.UseAppContainer=useAppContainer();
            this.createSection();
            this.layoutSection();
        end
    end

    methods(Access=private)
        function createSection(this)
            polygonSectionTitle=getString(message('vision:labeler:Polygon'));
            polygonSectionTag='sectionPolygon';

            this.Section=matlab.ui.internal.toolstrip.Section(polygonSectionTitle);
            this.Section.Tag=polygonSectionTag;
        end

        function layoutSection(this)
            this.addPolygonButton();
            colAddSession=this.addColumn();
            colAddSession.add(this.PolygonButton);

            if~this.UseAppContainer
                this.addSmartPolygonButton();
                colAddSession=this.addColumn();
                colAddSession.add(this.SmartPolygonButton);

                this.addSmartPolygonEditorButton();
                colAddSession=this.addColumn();
                colAddSession.add(this.SmartPolygonEditorButton);
            end

        end

        function addPolygonButton(this)
            import matlab.ui.internal.toolstrip.*;


            addPolygonTitleId='vision:labeler:Polygon';
            addPolygonIcon=fullfile(this.IconPath,'draw_polygon_24.png');
            addPolygonTag='btnAddPolygon';
            this.PolygonButton=this.createToggleButton(addPolygonIcon,...
            addPolygonTitleId,addPolygonTag);
            toolTipID='vision:labeler:AddPolygonTooltip';
            this.setToolTipText(this.PolygonButton,toolTipID);
        end

        function addSmartPolygonButton(this)
            import matlab.ui.internal.toolstrip.*;


            addSmartPolygonTitleId='vision:labeler:AddSmartPolygon';
            addSmartPolygonIcon=fullfile(toolboxdir('images'),'icons','GrabCut_24.png');
            addSmartPolygonTag='btnAddSmartPolygon';
            this.SmartPolygonButton=this.createToggleButton(addSmartPolygonIcon,...
            addSmartPolygonTitleId,addSmartPolygonTag);
            toolTipID='vision:labeler:AddSmartPolygonTooltip';
            this.setToolTipText(this.SmartPolygonButton,toolTipID);
        end

        function addSmartPolygonEditorButton(this)
            import matlab.ui.internal.toolstrip.*;


            addSmartPolygonTitleId='vision:labeler:AddSmartPolygonEditor';
            addSmartPolygonIcon=fullfile(toolboxdir('images'),'icons','GrabCut_Edit_24.png');
            addSmartPolygonTag='btnSmartPolygonEditor';
            this.SmartPolygonEditorButton=this.createButton(addSmartPolygonIcon,...
            addSmartPolygonTitleId,addSmartPolygonTag);
            toolTipID='vision:labeler:AddSmartPolygonEditorTooltip';
            this.setToolTipText(this.SmartPolygonEditorButton,toolTipID);
        end

    end
end

function tf=useAppContainer()
    tf=vision.internal.labeler.jtfeature('UseAppContainer');
end