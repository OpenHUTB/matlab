classdef SelectionSection<fusion.internal.scenarioApp.toolstrip.Section





    properties
        Enabled logical=true
    end

    properties(SetAccess=protected)
SelectedPlatformIndex
SelectedSensorIndex

hSensorSelector
hDeleteSensor
hDuplicateSensor

hPlatformSelector
hDeletePlatform
hDuplicatePlatform
    end

    methods
        function index=get.SelectedPlatformIndex(this)
            [~,index]=getCurrentPlatform(this.Application);
        end

        function set.SelectedPlatformIndex(this,index)
            selectPlatformByIndex(this.Application,index);
        end

        function index=get.SelectedSensorIndex(this)
            [~,index]=getCurrentSensor(this.Application);
        end

        function set.SelectedSensorIndex(this,index)
            setCurrentSensorByIndex(this.Application,index);
        end
    end

    methods

        function this=SelectionSection(hApplication,hToolstrip)

            this@fusion.internal.scenarioApp.toolstrip.Section(hApplication,hToolstrip);
            this.Title=msgString(this,'SelectionSectionTitle');
            this.Tag='selection';

            import matlab.ui.internal.toolstrip.*;

            col=addColumn(this,'HorizontalAlignment','right');

            platformSelector=DropDown;
            platformSelector.Tag='platformSelector';
            platformSelector.Description=msgString(this,'PlatformSelectorDescription');
            platformSelector.Enabled=false;
            platformSelector.ValueChangedFcn=this.Application.initCallback(@this.platformSelectorCallback);
            this.hPlatformSelector=platformSelector;
            add(col,this.hPlatformSelector);

            this.hSensorSelector=DropDown;
            this.hSensorSelector.Tag='sensorselector';
            this.hSensorSelector.Enabled=false;
            this.hSensorSelector.Description=msgString(this,'SensorSelectorDescription');
            this.hSensorSelector.ValueChangedFcn=this.Application.initCallback(@this.sensorSelectorCallback);
            add(col,this.hSensorSelector);



            col=addColumn(this,'HorizontalAlignment','right');


            button=Button(...
            Icon.DELETE_16);
            button.ButtonPushedFcn=this.Application.initCallback(@this.deletePlatformCallback);
            button.Tag='deleteplatform';
            button.Description=...
            msgString(this,'DeletePlatformDescription');
            button.Enabled=false;
            this.hDeletePlatform=button;
            add(col,this.hDeletePlatform);


            button=Button(...
            Icon.DELETE_16);
            button.ButtonPushedFcn=this.Application.initCallback(@this.deleteSensorCallback);
            button.Tag='deletesensor';
            button.Description=msgString(this,'DeleteSensorDescription');
            button.Enabled=false;
            this.hDeleteSensor=button;
            add(col,this.hDeleteSensor);



            col=addColumn(this,'HorizontalAlignment','center');


            button=Button(Icon.COPY_16);
            button.ButtonPushedFcn=this.Application.initCallback(@this.duplicatePlatformCallback);
            button.Tag='duplicateplatform';
            button.Description=...
            msgString(this,'DuplicatePlatformDescription');
            button.Enabled=false;
            this.hDuplicatePlatform=button;
            add(col,this.hDuplicatePlatform);


            button=Button(...
            Icon.COPY_16);
            button.ButtonPushedFcn=this.Application.initCallback(@this.duplicateSensorCallback);
            button.Tag='duplicatesensor';
            button.Description=msgString(this,'DuplicateSensorDescription');
            button.Enabled=false;
            this.hDuplicateSensor=button;
            add(col,this.hDuplicateSensor);
        end

        function update(this,platitems,sensoritems)
            updateSensorDropDown(this,sensoritems);
            updatePlatformDropDown(this,platitems);
            enablePlats=~isempty(platitems);
            enableSens=~isempty(sensoritems);
            updateDeleteCopy(this,enablePlats,enableSens);
        end
    end



    methods(Access=protected)

        function updateDeleteCopy(this,enablePlats,enableSens)
            this.hDeleteSensor.Enabled=this.Enabled&&enableSens;
            this.hDeletePlatform.Enabled=this.Enabled&&enablePlats;
            this.hDuplicateSensor.Enabled=this.Enabled&&enableSens;
            this.hDuplicatePlatform.Enabled=this.Enabled&&enablePlats;
        end

        function updateSensorDropDown(this,items)
            if isempty(items)
                this.hSensorSelector.Enabled=false;
                this.hSensorSelector.replaceAllItems({msgString(this,'EmptySensorSelectorText')});
                this.hSensorSelector.SelectedIndex=1;
                this.hSensorSelector.Description=msgString(this,'EmptySensorSelectorDescription');
            else
                this.hSensorSelector.replaceAllItems(items);
                index=this.SelectedSensorIndex;
                if isnan(index)

                    index=-1;
                end
                this.hSensorSelector.SelectedIndex=index;
                this.hSensorSelector.Enabled=true;
                this.hSensorSelector.Description=msgString(this,'SensorSelectorDescription');
            end
        end

        function updatePlatformDropDown(this,items)
            this.hPlatformSelector.ValueChangedFcn=[];
            if isempty(items)
                this.hPlatformSelector.replaceAllItems({msgString(this,'EmptyPlatformSelectorText')});
                this.hPlatformSelector.SelectedIndex=1;
                this.hPlatformSelector.Enabled=false;
                this.hPlatformSelector.Description=msgString(this,'EmptyPlatformSelectorDescription');
                this.hDeletePlatform.Enabled=false;
            else
                this.hPlatformSelector.replaceAllItems(items);
                index=this.SelectedPlatformIndex;
                if isnan(index)

                    index=-1;
                end
                this.hPlatformSelector.SelectedIndex=index;
                this.hPlatformSelector.Enabled=true;
                this.hPlatformSelector.Description=msgString(this,'PlatformSelectorDescription');
            end
            this.hPlatformSelector.ValueChangedFcn=this.Application.initCallback(@this.platformSelectorCallback);
        end

    end

    methods(Hidden)

        function deleteSensorCallback(this,~,~)
            deleteCurrentSensor(this.Application);
        end

        function duplicateSensorCallback(this,~,~)
            this.Application.duplicateSensor();
        end

        function deletePlatformCallback(this,~,~)
            deleteCurrentPlatform(this.Application);
        end

        function duplicatePlatformCallback(this,~,~)
            this.Application.duplicatePlatform();
        end

        function sensorSelectorCallback(this,h,~)
drawnow
            if~isequal(this.SelectedSensorIndex,sscanf(h.SelectedItem,'%i'))
                this.SelectedSensorIndex=sscanf(h.SelectedItem,'%i');
            end
        end

        function platformSelectorCallback(this,h,~)
drawnow
            if~isequal(this.SelectedPlatformIndex,sscanf(h.SelectedItem,'%i'))
                this.SelectedPlatformIndex=sscanf(h.SelectedItem,'%i');
            end
        end

    end
end