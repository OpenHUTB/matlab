classdef CADDesignTab<handle

    properties
DesignTab
FileSection
ShapeGallery
BooleanOpns
Actions
Export
ViewSec
        DesignEnabledState=true;
        IconPath=fullfile(matlabroot,'toolbox','shared','em_cad','+cad','+src')
    end

    methods
        function self=CADDesignTab(tabGroupParent)
            if nargin==0
                return;
            end
            self.createDesignTab(tabGroupParent);
            self.addFileSection()
            self.addShapeGallerySection()
            self.addBooleanSection()
            self.addActionsSection()
            self.addExportSection()
        end

        function disableDesignTab(self,val)
            self.disableActions(val);
            self.disableBooleanSection(val);
            self.disableExportSection(val);

            self.disableShapeGallery(val);
            self.disableViewSection(val);
            self.DesignEnabledState=val;
        end
        function createDesignTab(self,tabGroupParent)
            import matlab.ui.internal.toolstrip.*
            tab=Tab("Design");
            tab.Tag="DesignTab";
            tabGroupParent.add(tab);
            self.DesignTab=tab;
        end

        function deleteDesignTab(self)
            self.DesignTab.delete;
        end

        function addFileSection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.DesignTab.addSection("File");
            section.Tag="fileSection";
            self.FileSection.Section=section;

            column=section.addColumn();
            self.FileSection.New.Column=column;
            button=Button(['New',newline,'Session'],Icon.NEW_24);
            button.Tag="NewSession";
            button.Description=getString(message('antenna:pcbantennadesigner:NewSession'));
            column.add(button);
            self.FileSection.New.Button=button;

            column=section.addColumn();
            self.FileSection.File.Column=column;
            button=Button(['Open',newline,'Session'],Icon.OPEN_24);
            button.Tag="OpenSession";
            button.Description=getString(message('antenna:pcbantennadesigner:OpenSession'));
            column.add(button);
            self.FileSection.File.Button=button;

            column=section.addColumn();
            self.FileSection.Save.Column=column;
            button=SplitButton(['Save',newline,'Session'],Icon.SAVE_24);
            button.Tag="SaveSession";
            button.Description=getString(message('antenna:pcbantennadesigner:SaveSession'));
            column.add(button);
            self.FileSection.Save.Button=button;

            popup=PopupList;
            listItem=ListItem('Save Session');
            self.FileSection.SaveItem=listItem;
            popup.add(listItem);
            listItem.Tag='SaveSessionItem';
            listItem.Description=getString(message('antenna:pcbantennadesigner:SaveSession'));

            listItem=ListItem('Save Session As');
            self.FileSection.SaveAsItem=listItem;
            popup.add(listItem);
            listItem.Tag='SaveAsSessionItem';
            listItem.Description=getString(message('antenna:pcbantennadesigner:SaveSessionAs'));

            button.Popup=popup;

            addImportButton(self);

        end

        function disableFileSection(self,val)
            if val
                val=true;
            else
                val=false;
            end
            self.FileSection.New.Button.Enabled=val;
            self.FileSection.File.Button.Enabled=val;
            self.FileSection.Save.Button.Enabled=val;
            self.FileSection.Import.Button.Enabled=val;

        end

        function deleteFileSection(self)
            self.FileSection.Section.delete;
            self.FileSection.New.Button.delete;
            self.FileSection.New.Column.delete;
            self.FileSection.File.Column.delete;
            self.FileSection.File.Button.delete;
            self.FileSection.Save.Column.delete;
            self.FileSection.Save.Button.delete;
            self.FileSection.Import.ImportGerber.delete;
            self.FileSection.Import.ImportMat.delete;
            self.FileSection.Import.Column.delete;
            self.FileSection.Import.Button.delete;


        end

        function addImportButton(self)
            import matlab.ui.internal.toolstrip.*
            column=self.FileSection.Section.addColumn();
            self.FileSection.Import.Column=column;
            button=SplitButton('Import',Icon.IMPORT_24);
            button.Tag="Import";
            button.Description=getString(message('antenna:pcbantennadesigner:ImportGerber'));
            column.add(button);
            self.FileSection.Import.Button=button;
            popup=PopupList;
            listItem=ListItem('Import Gerber File');
            self.FileSection.Import.ImportGerber=listItem;
            listItem.Tag="ImportGerber";
            popup.add(listItem);
            listItem.Description=getString(message('antenna:pcbantennadesigner:ImportGerber'));
            listItem=ListItem('Import .mat file');
            self.FileSection.Import.ImportMat=listItem;
            listItem.Tag="ImportMAT";
            listItem.Description=getString(message('antenna:pcbantennadesigner:ImportMat'));
            popup.add(listItem);
            button.Popup=popup;
        end

        function addShapeGallerySection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.DesignTab.addSection("Shapes");
            section.Tag="ShapesGallery";
            self.ShapeGallery.Section=section;

            column=section.addColumn();
            self.ShapeGallery.Column=column;

            self.ShapeGallery.GalleryPopup=GalleryPopup('DisplayState','list_view');

            self.ShapeGallery.Gallery=Gallery([self.ShapeGallery.GalleryPopup],...
            'MaxColumnCount',3,'MinColumnCount',1);

            add(column,self.ShapeGallery.Gallery)
            addShapeGalleryCategoriesAndItems(self)
        end

        function deleteShapeGallerySection(self)
            self.ShapeGallery.Section.delete;
            self.ShapeGallery.Column.delete;
            self.ShapeGallery.GalleryPopup.delete;
            self.ShapeGallery.Gallery.delete;
            self.ShapeGallery.Rectangle.delete;
            self.ShapeGallery.Circle.delete;
            self.ShapeGallery.Polygon.delete;
        end

        function disableShapeGallery(self,val)
            if val
                val=true;
            else
                val=false;
            end
            self.ShapeGallery.Gallery.Enabled=val;

        end

        function addShapeGalleryCategoriesAndItems(self)
            import matlab.ui.internal.toolstrip.*
            self.ShapeGallery.ShapeCategory=GalleryCategory('Shapes');
            self.ShapeGallery.ShapeCategory.Tag='Shapes';
            self.ShapeGallery.Rectangle=GalleryItem('Rectangle',Icon(fullfile(self.IconPath,'rectangle_24.png')));
            self.ShapeGallery.Rectangle.Tag='Rectangle';
            self.ShapeGallery.Rectangle.Description=getString(message('antenna:pcbantennadesigner:Rectangle'));
            self.ShapeGallery.Circle=GalleryItem('Circle',Icon(fullfile(self.IconPath,'circle_24.png')));
            self.ShapeGallery.Circle.Tag='Circle';
            self.ShapeGallery.Circle.Description=getString(message('antenna:pcbantennadesigner:Circle'));
            self.ShapeGallery.Polygon=GalleryItem('Polygon',Icon(fullfile(self.IconPath,'polygon_24.png')));
            self.ShapeGallery.Polygon.Tag='Polygon';
            self.ShapeGallery.Polygon.Description=getString(message('antenna:pcbantennadesigner:Polygon'));
            self.ShapeGallery.Ellipse=GalleryItem('Ellipse',Icon(fullfile(self.IconPath,'ellipse_24.png')));
            self.ShapeGallery.Ellipse.Tag='Ellipse';
            self.ShapeGallery.Ellipse.Description=getString(message('antenna:pcbantennadesigner:Ellipse'));

            self.ShapeGallery.ShapeCategory.add(self.ShapeGallery.Rectangle);
            self.ShapeGallery.ShapeCategory.add(self.ShapeGallery.Circle);
            self.ShapeGallery.ShapeCategory.add(self.ShapeGallery.Polygon);
            self.ShapeGallery.ShapeCategory.add(self.ShapeGallery.Ellipse);
            self.ShapeGallery.GalleryPopup.add(self.ShapeGallery.ShapeCategory);
            self.ShapeGallery.GalleryPopup.Tag='ShapeGallery';
        end
        function addActionsSection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.DesignTab.addSection("Actions");
            self.Actions.Section=section;
            column=addColumn(section);
            self.Actions.Column1=column;


            button=Button('',Icon.CUT_16);
            button.Tag='Cut';
            button.Description=getString(message('antenna:pcbantennadesigner:Cut'));
            self.Actions.Cut=button;
            add(column,button);
            button=Button('',Icon.PASTE_16);
            button.Tag='Paste';
            button.Description=getString(message('antenna:pcbantennadesigner:Paste'));
            self.Actions.Paste=button;
            add(column,button);
            button=Button('',Icon.UNDO_16);
            button.Tag='Undo';
            button.Description=getString(message('antenna:pcbantennadesigner:Undo'));
            self.Actions.Undo=button;
            add(column,button);

            column=addColumn(section);
            self.Actions.Column2=column;


            button=Button('',Icon.COPY_16);
            self.Actions.Copy=button;
            button.Tag='Copy';
            button.Description=getString(message('antenna:pcbantennadesigner:Copy'));
            add(column,button);
            button=Button('',Icon.DELETE_16);
            self.Actions.Delete=button;
            add(column,button);
            button.Tag='Delete';
            button.Description=getString(message('antenna:pcbantennadesigner:Delete'));
            button=Button('',Icon.REDO_16);
            self.Actions.Redo=button;
            button.Tag='Redo';
            add(column,button);
            button.Description=getString(message('antenna:pcbantennadesigner:Redo'));
        end

        function deleteActionsSection(self)
            self.Actions.Section.delete;
            self.Actions.Column1.delete;
            self.Actions.Column2.delete;
            self.Actions.Undo.delete;
            self.Actions.Cut.delete;
            self.Actions.Paste.delete;
            self.Actions.Redo.delete;
            self.Actions.Copy.delete;
            self.Actions.Delete.delete;
        end

        function disableActions(self,val)
            if val
                val=true;
            else
                val=false;
            end
            self.Actions.Undo.Enabled=val;
            self.Actions.Cut.Enabled=val;
            self.Actions.Paste.Enabled=val;
            self.Actions.Redo.Enabled=val;
            self.Actions.Copy.Enabled=val;
            self.Actions.Delete.Enabled=val;

        end

        function addExportSection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.DesignTab.addSection("Export");
            section.Tag="ExportShape";
            self.Export.Section=section;

            column=section.addColumn();
            self.Export.Column=column;
            button=SplitButton('Export',Icon.EXPORT_24);
            button.Tag="Export";
            button.Description=getString(message('antenna:pcbantennadesigner:ExportButton'));
            column.add(button);
            self.Export.Button=button;

            popup=PopupList;
            listItem=ListItem('Export to MATLAB workspace');
            self.Export.ExportToWorkspace=listItem;
            popup.add(listItem);
            listItem.Tag='ExportToWorkspace';
            listItem.Description=getString(message('antenna:pcbantennadesigner:ExportWorkspace'));
            listItem=ListItem('Export as MATLAB Script');
            self.Export.ExportScript=listItem;
            popup.add(listItem);
            listItem.Tag='ExportScript';
            listItem.Description=getString(message('antenna:pcbantennadesigner:ExportScript'));
            listItem=ListItem('Export as Gerber File');
            self.Export.GerberExport=listItem;
            popup.add(listItem);
            listItem.Tag='GerberExport';
            listItem.Description=getString(message('antenna:pcbantennadesigner:ExportGerber'));
            button.Popup=popup;
        end

        function deleteExportSection(self)
            self.Export.Section.delete;
            self.Export.Column.delete;
            self.Export.Button.delete;
            self.Export.ExportToWorkspace.delete;
            self.Export.ExportScript.delete;
            self.Export.GerberExport.delete;
        end
        function disableExportSection(self,val)
            if val
                val=true;
            else
                val=false;
            end
            self.Export.ExportToWorkspace.Enabled=val;
            self.Export.ExportScript.Enabled=val;
            self.Export.GerberExport.Enabled=val;
            self.Export.Button.Enabled=val;
        end

        function addViewSection(self)
            import matlab.ui.internal.toolstrip.*
            section=self.DesignTab.addSection("View");
            section.Tag="View";
            self.ViewSec.Section=section;

            column=section.addColumn();
            self.ViewSec.Column=column;
            button=Button(['Default',newline,'Layout'],Icon.LAYOUT_24);
            button.Tag="DefaultView";
            button.Description=getString(message('antenna:pcbantennadesigner:DefaultLayoutButton'));
            column.add(button);
            self.ViewSec.Button=button;

        end

        function deleteViewSection(self)
            self.ViewSec.Section.delete;
            self.ViewSec.Column.delete;
            self.ViewSec.Button.delete;
        end
        function disableViewSection(self,val)
            if val
                val=true;
            else
                val=false;
            end
            self.ViewSec.Button.Enabled=val;
        end

        function addBooleanSection(self)
            import matlab.ui.internal.toolstrip.*
            column=self.ShapeGallery.Section.addColumn();
            self.BooleanOpns.Column1=column;
            button=Button('Add',Icon(fullfile(self.IconPath,'add_16.png')));
            add(column,button);
            button.Tag='Add';
            button.Description=getString(message('antenna:pcbantennadesigner:Add'));
            self.BooleanOpns.Add=button;

            button=Button('Intersect',Icon(fullfile(self.IconPath,'intersect_16.png')));
            add(column,button);
            self.BooleanOpns.Intersect=button;
            button.Tag='Intersect';
            button.Description=getString(message('antenna:pcbantennadesigner:Intersect'));


            column=self.ShapeGallery.Section.addColumn();
            self.BooleanOpns.Column2=column;

            button=Button('Subtract',Icon(fullfile(self.IconPath,'subtract_16.png')));
            add(column,button);
            self.BooleanOpns.Subtract=button;
            button.Tag='Subtract';
            button.Description=getString(message('antenna:pcbantennadesigner:Subtract'));

            button=Button('Exclude',Icon(fullfile(self.IconPath,'xor_16.png')));
            add(column,button);
            self.BooleanOpns.Xor=button;
            button.Tag='Xor';
            button.Description=getString(message('antenna:pcbantennadesigner:Xor'));

        end

        function deleteBooleanSection(self)
            self.BooleanOpns.Column1.delete;
            self.BooleanOpns.Column2.delete;
            self.BooleanOpns.Add.delete;
            self.BooleanOpns.Subtract.delete;
            self.BooleanOpns.Xor.delete;
            self.BooleanOpns.Intersect.delete;
        end

        function disableBooleanSection(self,val)
            if val
                val=true;
            else
                val=false;
            end
            self.BooleanOpns.Add.Enabled=val;
            self.BooleanOpns.Subtract.Enabled=val;
            self.BooleanOpns.Xor.Enabled=val;
            self.BooleanOpns.Intersect.Enabled=val;

        end

        function deleteView(self)
            self.deleteActionsSection();
            self.deleteBooleanSection();
            self.deleteExportSection();
            self.deleteFileSection();
            self.deleteShapeGallerySection();
            self.deleteViewSection();
            self.deleteDesignTab();

        end
    end
end
