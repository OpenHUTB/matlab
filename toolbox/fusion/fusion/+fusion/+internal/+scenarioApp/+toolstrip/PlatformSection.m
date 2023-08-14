classdef PlatformSection<fusion.internal.scenarioApp.toolstrip.Section





    properties
        PlatformEnabled=true
    end

    properties(SetAccess=protected,Hidden)

GroundCategory
AirCategory
SeaCategory
GroundItems
AirItems
SeaItems
AddPlatformGallery

    end

    methods
        function this=PlatformSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);
            import matlab.ui.internal.toolstrip.*


            this.Title=msgString(this,'PlatformSectionTitle');
            this.Tag='platform';

            createPlatformGallery(this);
        end

    end

    methods(Hidden)

        function deleteGallery(this)
            delete(this.AddPlatformGallery);
        end

        function updatePlatformGallery(this)
            import matlab.ui.internal.toolstrip.*
            hApp=this.Application;
            classSpecs=getPlatformClassSpecifications(hApp);
            allIds=getAllIds(classSpecs);
            groundCategory=this.GroundCategory;
            airCategory=this.AirCategory;
            seaCategory=this.SeaCategory;
            oldGround=this.GroundItems;
            for indx=1:numel(oldGround)
                remove(groundCategory,oldGround(indx));
            end
            oldAir=this.AirItems;
            for indx=1:numel(oldAir)
                remove(airCategory,oldAir(indx));
            end
            oldSea=this.SeaItems;
            for indx=1:numel(oldSea)
                remove(seaCategory,oldSea(indx));
            end

            groundItems=GalleryItem.empty;
            airItems=GalleryItem.empty;
            seaItems=GalleryItem.empty;

            defaultPlatformIcon=Icon(fullfile(this.IconDirectory,'platform_24.png'));
            for indx=1:numel(allIds)
                spec=getSpecification(classSpecs,allIds(indx));

                item=GalleryItem(spec.name);
                item.ItemPushedFcn=...
                this.Application.initCallback(...
                @this.addPlatformCallback,spec);
                switch lower(spec.Category)
                case 'air'
                    if strcmp(spec.name,'Plane')
                        icon=Icon(fullfile(this.IconDirectory,'plane_24.png'));
                        item.Icon=icon;
                        item.Description=msgString(this,'PlaneDescription');
                    else
                        item.Icon=defaultPlatformIcon;
                        item.Description=msgString(this,'DefaultDescription');
                    end
                    item.Tag=sprintf('addClassId%d',spec.id);
                    airItems(end+1)=item;%#ok<AGROW>
                    add(airCategory,item);
                case 'ground'
                    switch spec.name
                    case 'Car'
                        icon=Icon(fullfile(this.IconDirectory,'car_24.png'));
                        desc=msgString(this,'CarDescription');
                    case 'Tower'
                        icon=Icon(fullfile(this.IconDirectory,'tower_24.png'));
                        desc=msgString(this,'TowerDescription');
                    otherwise
                        icon=defaultPlatformIcon;
                        desc=msgString(this,'DefaultDescription');
                    end
                    item.Icon=icon;
                    item.Description=desc;
                    groundItems(end+1)=item;%#ok<AGROW>
                    add(groundCategory,item);
                case 'maritime'
                    if strcmp(spec.name,'Boat')
                        item.Icon=Icon(fullfile(this.IconDirectory,'boat_24.png'));
                        item.Description=msgString(this,'BoatDescription');
                    else
                        item.Icon=defaultPlatformIcon;
                        item.Description=msgString(this,'DefaultDescription');
                    end
                    seaItems(end+1)=item;%#ok<AGROW>
                    add(seaCategory,item);
                end

            end

            this.GroundItems=groundItems;
            this.SeaItems=seaItems;
            this.AirItems=airItems;

        end

        function update(this)


        end

    end

    methods(Access=protected)
        function createPlatformGallery(this)

            import matlab.ui.internal.toolstrip.*

            groundCategory=GalleryCategory('Ground');
            groundCategory.Tag='AddPlatformGroundCategory';
            airCategory=GalleryCategory('Air');
            airCategory.Tag='AddPlatformAirCategory';
            seaCategory=GalleryCategory('Maritime');
            seaCategory.Tag='AddPlatformSeaCategory';

            settingsCategory=GalleryCategory(this.msgString('PlatformClassSettings'));

            editClass=GalleryItem(this.msgString('EditPlatformClass'),...
            Icon(fullfile(this.IconDirectory,'edit_platform_class_24.png')));
            editClass.Tag='EditPlatformClasses';
            editClass.Description=this.msgString('EditPlatformClassDescription');
            editClass.ItemPushedFcn=...
            this.Application.initCallback(@this.editClassesCallback);

            add(settingsCategory,editClass);

            popup=GalleryPopup('DisplayState','list_view');
            popup.Tag='platformGalleryPopup';
            popup.add(airCategory);
            popup.add(groundCategory);
            popup.add(seaCategory);
            popup.add(settingsCategory);


            addPlatformGallery=Gallery(popup,...
            'MaxColumnCount',4);
            addPlatformGallery.Description=...
            msgString(this,'AddPlatformDescription');
            addPlatformGallery.Tag='addPlatform';

            this.AirCategory=airCategory;
            this.GroundCategory=groundCategory;
            this.SeaCategory=seaCategory;
            updatePlatformGallery(this);

            add(addColumn(this),addPlatformGallery);
            this.AddPlatformGallery=addPlatformGallery;
        end
    end

    methods(Access=protected)
        function editClassesCallback(this,~,~)
            editPlatformClassSpecifications(this.Application);
        end

        function newClassCallback(this,~,~)
            createPlatformClassSpecification(this.Application);
        end

        function addPlatformCallback(this,~,~,spec)
            this.Application.addPlatformMode(spec);
        end
    end

end