





classdef AlgorithmSection<handle

    properties

        CustomEditDropDown matlab.ui.internal.toolstrip.DropDownButton

        EditsGallery matlab.ui.internal.toolstrip.Gallery

        SpatialEditsCategory matlab.ui.internal.toolstrip.GalleryCategory

        TemporalEditsCategory matlab.ui.internal.toolstrip.GalleryCategory
    end

    properties(Access=private)

Tab

    end

    methods



        function this=AlgorithmSection(tab)
            this.Tab=tab;
            this.createWidgtes();
            this.addButtons();
        end
    end




    methods(Access=private)
        function createWidgtes(this)


            this.createCustomEditDropDown();

            this.createEditsGallery();
        end


        function createEditsGallery(this)

            import matlab.ui.internal.toolstrip.*
            import matlab.ui.internal.toolstrip.Icon.*;


            popup=GalleryPopup();


            this.SpatialEditsCategory=GalleryCategory(getString(message('lidar:lidarViewer:SpatialAlgorithms')));
            this.SpatialEditsCategory.Tag='SpatialEditsCategory';
            popup.add(this.SpatialEditsCategory);


            this.TemporalEditsCategory=GalleryCategory(getString(message('lidar:lidarViewer:TemporalAlgorithms')));
            popup.add(this.TemporalEditsCategory);

            this.EditsGallery=Gallery(popup,'MaxColumnCount',4,'MinColumnCount',2);
        end


        function addButtons(this)

            section=addSection(this.Tab,getString(message('lidar:lidarViewer:Algorithm')));

            column=section.addColumn('HorizontalAlignment','center','Width',60);
            column.add(this.CustomEditDropDown);

            column=section.addColumn('HorizontalAlignment','center','Width',60);
            column.add(this.EditsGallery);
        end


        function createCustomEditDropDown(this)

            import matlab.ui.internal.toolstrip.Icon.*;

            icon=NEW_24;
            labelId=getString(message('lidar:lidarViewer:CustomEdit'));
            this.CustomEditDropDown=...
            matlab.ui.internal.toolstrip.DropDownButton(labelId,icon);
            this.CustomEditDropDown.Tag='CustomEditsBtn';
            this.CustomEditDropDown.Description=getString(message('lidar:lidarViewer:CustomEditDescription'));
        end


        function galleryItem=createGalleryItem(~,name,icon)
            import matlab.ui.internal.toolstrip.*
            galleryItem=GalleryItem(name,icon);
        end
    end

end