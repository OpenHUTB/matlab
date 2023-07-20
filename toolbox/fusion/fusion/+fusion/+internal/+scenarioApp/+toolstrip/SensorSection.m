classdef SensorSection<fusion.internal.scenarioApp.toolstrip.Section





    properties
        SensorEnabled=true
    end

    properties(SetAccess=protected,Hidden)

AddSensorGallery
RadarCategory
IRCategory
SonarCategory
RadarItems
IRItems
SonarItems

    end

    methods
        function this=SensorSection(hApplication,hToolstrip)
            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);
            import matlab.ui.internal.toolstrip.*


            this.Title=msgString(this,'SensorSectionTitle');
            this.Tag='sensor';
            createSensorGallery(this);
        end

    end

    methods(Hidden)

        function deleteGallery(this)
            delete(this.AddSensorGallery)
        end

        function updateSensorGallery(this)
            import matlab.ui.internal.toolstrip.*
            hApp=this.Application;
            classSpecs=getSensorClassSpecifications(hApp);
            allIds=getAllIds(classSpecs);
            radarCategory=this.RadarCategory;
            irCategory=this.IRCategory;
            sonarCategory=this.SonarCategory;
            oldRadar=this.RadarItems;
            for indx=1:numel(oldRadar)
                if~isempty(radarCategory.contains(oldRadar(indx).Tag))
                    remove(radarCategory,oldRadar(indx));
                end
            end
            oldIR=this.IRItems;
            for indx=1:numel(oldIR)
                remove(irCategory,oldIR);
            end
            oldSonar=this.SonarItems;
            for indx=1:numel(oldSonar)
                remove(seaCategory,oldSonar);
            end

            radarItems=GalleryItem.empty;
            irItems=GalleryItem.empty;
            sonarItems=GalleryItem.empty;

            for indx=1:numel(allIds)
                spec=getSpecification(classSpecs,allIds(indx));

                item=GalleryItem();
                item.ItemPushedFcn=this.Application.initCallback(...
                @this.addSensorCallback,spec);
                item.Tag=sprintf('addClassId%d',spec.id);
                switch spec.Category
                case 'radar'
                    switch spec.name
                    case 'No Scanning'
                        text=msgString(this,'NoScanningRadarText');
                        icon=Icon(fullfile(this.IconDirectory,'no_scanning_radar_24.png'));
                        desc=msgString(this,'NoScanningRadarDescription');
                    case 'Rotator'
                        text=msgString(this,'RotatorRadarText');
                        icon=Icon(fullfile(this.IconDirectory,'rotator_radar_24.png'));
                        desc=msgString(this,'RotatorRadarDescription');
                    case 'Raster'
                        text=msgString(this,'RasterRadarText');
                        icon=Icon(fullfile(this.IconDirectory,'raster_radar_24_2.png'));
                        desc=msgString(this,'RasterRadarDescription');
                    case 'Sector'
                        text=msgString(this,'SectorRadarText');
                        icon=Icon(fullfile(this.IconDirectory,'sector_radar_24.png'));
                        desc=msgString(this,'SectorRadarDescription');
                    otherwise
                        text=spec.name;
                        icon=Icon(fullfile(this.IconDirectory,'sensor_24.png'));
                        desc=msgString(this,'DefaultRadarDescription',spec.name);
                    end

                    item.Text=text;
                    item.Description=desc;
                    item.Icon=icon;
                    radarItems(end+1)=item;%#ok<AGROW>
                    add(radarCategory,item);
                end
            end

            this.RadarCategory=radarCategory;
            this.IRCategory=irCategory;
            this.SonarCategory=sonarCategory;
            this.RadarItems=radarItems;
            this.SonarItems=sonarItems;
            this.IRItems=irItems;

        end

        function update(this,enable)

            this.AddSensorGallery.Enabled=this.SensorEnabled&&enable;
        end

    end

    methods(Access=protected)

        function createSensorGallery(this)

            import matlab.ui.internal.toolstrip.*

            radarCategory=GalleryCategory(msgString(this,'RadarGallery'));
            radarCategory.Tag='AddSensorRadarCategory';
            irCategory=GalleryCategory(msgString(this,'InfraredGallery'));
            irCategory.Tag='AddSensorIRCategory';
            sonarCategory=GalleryCategory(msgString(this,'SonarGallery'));
            sonarCategory.Tag='AddSensorSonarCategory';
            settingsCategory=GalleryCategory(this.msgString('SensorClassSettings'));
            settingsCategory.Tag='SensorClassEditor';

            editClass=GalleryItem(this.msgString('EditSensorClass'),...
            Icon(fullfile(this.IconDirectory,'edit_sensor_class_24.png')));
            editClass.Tag='EditSensorClasses';
            editClass.Description=this.msgString('EditSensorClassDescription');
            editClass.ItemPushedFcn=this.Application.initCallback(@this.editClassesCallback);
            add(settingsCategory,editClass);

            popup=GalleryPopup('DisplayState','list_view');
            popup.Tag='sensorGalleryPopup';
            popup.add(radarCategory);
            popup.add(irCategory);
            popup.add(sonarCategory);
            popup.add(settingsCategory);


            addSensorGallery=Gallery(popup,'MaxColumnCount',4);

            addSensorGallery.Description=msgString(this,'SensorGalleryDescription');
            addSensorGallery.Tag='addSensor';
            addSensorGallery.Enabled=false;
            this.AddSensorGallery=addSensorGallery;
            this.IRCategory=irCategory;
            this.RadarCategory=radarCategory;
            this.SonarCategory=sonarCategory;
            updateSensorGallery(this);

            add(addColumn(this,'HorizontalAlignment','center'),addSensorGallery);
        end

    end

    methods(Access=protected)

        function addSensorCallback(this,~,~,sensor)
            this.Application.addSensorMode(sensor);
        end

        function editClassesCallback(this,~,~)
            editSensorClassSpecifications(this.Application);
        end
    end

end