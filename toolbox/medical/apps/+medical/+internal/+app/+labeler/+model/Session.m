classdef Session<handle




    properties(Hidden)

DataFormat

DataEntries

        LabelOpacity=0.5
LabelDefinitions

    end

    properties(Transient,SetAccess=protected,GetAccess=?matlab.unittest.TestCase)

        CurrentDataName string=string.empty();

    end

    properties(Hidden,Transient,Dependent)
NumEntries
    end

    events
FirstDataAdded
DataAdded
CurrentlyLoadingData

ErrorThrown
    end

    methods


        function delete(self)
            self.DataEntries=[];
            delete(self);
        end


        function clear(self)

            self.DataEntries=[];
            self.DataFormat=[];
            self.CurrentDataName=string.empty();

        end


        function addFromFile(self,dataSource,validateData)













            numEntriesBeforeAdd=length(self.DataEntries);
            numEntriesToAdd=length(dataSource);
            validDataSource={};

            for idx=1:numEntriesToAdd

                currDataSource=string(dataSource{idx});

                try

                    if self.isDataAlreadyLoaded(currDataSource)


                        continue
                    end

                    [~,name,~]=fileparts(currDataSource(1));
                    evt=medical.internal.app.labeler.events.ValueEventData(name);
                    self.notify('CurrentlyLoadingData',evt);

                    if validateData
                        self.validateData(currDataSource);
                    end

                    validDataSource{end+1}=currDataSource;%#ok<AGROW> 

                catch ME

                    switch ME.identifier

                    case 'medical:groundTruthMedical:invalidVolumeOrientation'
                        msg=getString(message('medical:medicalLabeler:invalidVolume',currDataSource));

                    case 'medical:groundTruthMedical:invalidVolumeSize'
                        msg=getString(message('medical:medicalLabeler:invalidVolumeSize',currDataSource));

                    case 'medical:groundTruthMedical:invalidImageOrientation'
                        msg=getString(message('medical:medicalLabeler:invalidImage',currDataSource));

                    case 'medical:groundTruthMedical:invalidImageSize'
                        msg=getString(message('medical:medicalLabeler:invalidImageSize',currDataSource));

                    otherwise
                        msg=ME.message;

                    end

                    self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(msg));
                    return;

                end

            end



            labelDataSource="";
            if~isempty(validDataSource)

                numEntriesToAdd=length(validDataSource);
                for idx=1:numEntriesToAdd
                    currDataSource=string(validDataSource{idx});
                    self.addData(currDataSource,labelDataSource);
                end

            end

            anyNewDataAdded=length(self.DataEntries)>numEntriesBeforeAdd;
            if~anyNewDataAdded
                return
            end


            allDataNames=[self.DataEntries.DataName];
            newDataNames=allDataNames(numEntriesBeforeAdd+1:end);
            hasLabels=false(length(newDataNames),1);

            evt=medical.internal.app.labeler.events.DataEventData(newDataNames,hasLabels);
            self.notify('DataAdded',evt);

        end


        function addFromFolder(self,dataSource)







            dataSource=string(dataSource);

            numEntriesBeforeAdd=length(self.DataEntries);
            numEntriesToAdd=length(dataSource);


            labelDataSource="";

            for idx=1:numEntriesToAdd

                try

                    collection=medical.internal.io.dicomCollectionNew(dataSource{idx},...
                    'IncludeSubfolders',false,...
                    'DisplayWaitbar',false);

                    if isempty(collection)
                        error(message('medical:medicalLabeler:noDICOMVolumeFound'));
                    end

                    if self.isDataAlreadyLoaded(collection.Filenames{1})


                        continue
                    end

                    [~,name,~]=fileparts(dataSource{idx});
                    evt=medical.internal.app.labeler.events.ValueEventData(name);
                    self.notify('CurrentlyLoadingData',evt);

                    self.validateData(collection);
                    self.addData(collection.Filenames{1},labelDataSource);


                catch ME

                    self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                    continue;

                end

            end


            if~isempty(self.DataEntries)
                allDataNames=[self.DataEntries.DataName];
                newDataNames=allDataNames(numEntriesBeforeAdd+1:end);
                hasLabels=false(length(newDataNames),1);

                evt=medical.internal.app.labeler.events.DataEventData(newDataNames,hasLabels);
                self.notify('DataAdded',evt);
            end

        end


        function addGroundTruth(self,dataSource,labelDataSource)




            numEntriesBeforeAdd=length(self.DataEntries);
            numEntriesToAdd=length(dataSource);

            for idx=1:numEntriesToAdd

                if self.isDataAlreadyLoaded(dataSource{idx})
                    continue;
                end

                currentDataSource=string(dataSource{idx});
                [~,name,~]=fileparts(currentDataSource(1));
                evt=medical.internal.app.labeler.events.ValueEventData(name);
                self.notify('CurrentlyLoadingData',evt);

                self.addData(currentDataSource,string(labelDataSource{idx}));

            end


            allDataNames=[self.DataEntries.DataName];
            newDataNames=allDataNames(numEntriesBeforeAdd+1:end);

            labelDataSource=[self.DataEntries.LabelDataSource];
            hasLabels=labelDataSource~="";

            evt=medical.internal.app.labeler.events.DataEventData(newDataNames,hasLabels);
            self.notify('DataAdded',evt);

        end


        function remove(self,dataName)

            allDataNames=[self.DataEntries.DataName];
            idx=find(allDataNames==dataName);
            self.DataEntries(idx)=[];

        end


        function removeLabels(self,dataName)

            allDataNames=[self.DataEntries.DataName];
            idx=find(allDataNames==dataName);
            self.DataEntries(idx).LabelDataSource="";

        end


        function removePixelLabelValue(self,currDataName,pixId)





            for i=1:length(self.DataEntries)

                if self.DataEntries(i).DataName==currDataName
                    continue;
                end

                labelDataSource=self.DataEntries(i).LabelDataSource;
                if isempty(labelDataSource)||labelDataSource==""
                    continue;
                end

                switch self.DataFormat

                case medical.internal.app.labeler.enums.DataFormat.Volume

                    medicalObj=medicalVolume(labelDataSource);
                    labelData=medicalObj.Voxels;
                    idx=labelData==pixId;

                    if any(idx,'all')
                        labelData(idx)=0;
                        medicalObj.Voxels=labelData;
                        medicalObj.write(labelDataSource);
                    end

                case medical.internal.app.labeler.enums.DataFormat.Image

                    data=load(labelDataSource);
                    labelData=data.labels;
                    idx=labelData==pixId;

                    if any(idx,'all')
                        labelData(idx)=0;
                        labels=labelData;
                        save(labelDataSource,'labels');
                    end

                end

            end

        end


        function dataEntry=getEntry(self,dataName)

            dataNames=[self.DataEntries.DataName];
            idx=find(dataNames==dataName);
            dataEntry=self.DataEntries(idx);

        end


        function setDataEntryValues(self,dataName,entryValues)

            dataNames=[self.DataEntries.DataName];
            dataEntryIdx=dataNames==dataName;

            fieldNames=fields(entryValues);
            for i=1:length(fieldNames)
                self.DataEntries(dataEntryIdx).(fieldNames{i})=entryValues.(fieldNames{i});
            end

        end


        function setLabelDataSource(self,dataName,labelDataSource)

            allDataNames=[self.DataEntries.DataName];
            idx=find(allDataNames==dataName);
            self.DataEntries(idx).LabelDataSource=labelDataSource;

        end


        function applyRenderingToAllVolumes(self,preset,renderingStyle,alphaControlPts,colorControlPts)

            for idx=1:length(self.DataEntries)
                self.DataEntries(idx).RenderingPreset=preset;
                self.DataEntries(idx).RenderingStyle=renderingStyle;
                self.DataEntries(idx).AlphaControlPoints=alphaControlPts;
                self.DataEntries(idx).ColorControlPoints=colorControlPts;
            end

        end


        function copyDataLocation(self,dataName)

            allDataNames=[self.DataEntries.DataName];
            idx=find(allDataNames==dataName);
            dataLocation=self.DataEntries(idx).DataSource;

            if length(dataLocation)>1
                dataLocation=fileparts(dataLocation(1));
            end

            clipboard('copy',dataLocation);

        end


        function copyLabelLocation(self,dataName)

            allDataNames=[self.DataEntries.DataName];
            idx=find(allDataNames==dataName);
            labelLocation=self.DataEntries(idx).LabelDataSource;

            clipboard('copy',labelLocation);

        end


        function setLabelOpacity(self,opacity)
            self.LabelOpacity=opacity;
        end


        function[dataSource,labelData]=getDataForGroundTruth(self)

            numEntries=length(self.DataEntries);

            dataSource=cell(numEntries,1);
            labelData=repmat("",[numEntries,1]);

            for idx=1:numEntries

                dataEntry=self.DataEntries(idx);
                dataSource{idx}=dataEntry.DataSource;
                if dataEntry.LabelDataSource~=""
                    labelData(idx)=dataEntry.LabelDataSource;
                end

            end

        end

    end


    methods


        function numEntries=get.NumEntries(self)
            numEntries=length(self.DataEntries);
        end

    end

    methods(Access=protected)


        function addData(self,dataSource,labelDataSource)

            uniqueDataName=self.extractDataName(dataSource);

            newEntry=struct(...
            'DataName',[],...
            'DataSource',[],...
            'LabelDataSource',"",...
            'DataBounds',[],...
            'DataDisplayLimits',[],...
            'DataDisplayLimitsDefault',[],...
            'RenderingPreset',[],...
            'RenderingStyle',[],...
            'AlphaControlPoints',[],...
            'ColorControlPoints',[],...
            'IsDataValidated',false,...
            'IsLabelDataValidated',false,...
            'CastingMethod',[]);

            newEntry.DataName=uniqueDataName;
            newEntry.DataSource=dataSource;
            newEntry.LabelDataSource=labelDataSource;
            newEntry.isDataNumericsValidated=false;

            if self.DataFormat==medical.internal.app.labeler.enums.DataFormat.Volume


                defaultRendering=medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale;
                renderingSettings=defaultRendering.getRenderingSettings();

                newEntry.RenderingPreset=defaultRendering;
                newEntry.RenderingStyle=renderingSettings.RenderingStyle;

                newEntry.AlphaControlPoints=renderingSettings.AlphaControlPoints;
                newEntry.ColorControlPoints=renderingSettings.ColorControlPoints;

            end

            self.DataEntries=[self.DataEntries;newEntry];



            if length(self.DataEntries)==1
                self.notify('FirstDataAdded');
            end

        end


        function validateData(self,dataSource)

            if ischar(dataSource)
                dataSource=string(dataSource);
            end

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume
                medical.labeler.loading.internal.validateVolume(dataSource);

            case medical.internal.app.labeler.enums.DataFormat.Image
                medical.labeler.loading.internal.validateImage(dataSource);

            end

        end


        function TF=isDataAlreadyLoaded(self,dataSource)

            TF=false;

            for idx=1:length(self.DataEntries)

                currentDataSource=self.DataEntries(idx).DataSource;

                if isequal(sort(currentDataSource),sort(dataSource))
                    TF=true;
                    break;
                end

            end

        end


        function dataName=extractDataName(self,dataSource)


            if self.NumEntries>0
                currentDataNames=[self.DataEntries.DataName];
            else
                currentDataNames="";
            end


            if length(dataSource)>1

                [path,~,~]=fileparts(dataSource(1));
                path=strsplit(path,filesep);
                dataName=path(end);

            elseif isfile(dataSource)

                [~,name,ext]=fileparts(dataSource);
                dataName=strcat(name,ext);

            end


            excludeNames=currentDataNames;
            dataName=matlab.lang.makeUniqueStrings(dataName,excludeNames);

        end

    end


end