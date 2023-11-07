classdef Model<handle

    properties(Access=protected)

Data
Labels
        Automation images.internal.app.segmenter.volume.data.Automation
        SessionManager medical.internal.app.labeler.model.SessionManager
        Session medical.internal.app.labeler.model.Session

        History medical.internal.app.labeler.model.History
        Interpolation images.internal.app.utilities.Interpolation
        IO medical.internal.app.labeler.model.IO
        LabelDefinition medical.internal.app.labeler.model.LabelDefinition
        Summary medical.internal.app.labeler.model.Summary
        Publish medical.internal.app.labeler.model.Publish

    end

    properties(Access=private)

        SessionLocation string=string.empty()
        LabelDataLocation string=string.empty()

InterpolationSliceDir

    end

    properties(Access=protected)
        DataFormat medical.internal.app.labeler.enums.DataFormat
    end

    properties(Dependent,Access=protected)
HasImageData
HasSessionData
    end

    events
ErrorThrown
WarningThrown
    end

    methods

        function self=Model(varargin)

            self.createComponents(varargin{:});

            self.wireupAutomation();
            self.wireupHistory();
            self.wireupInterpolation();
            self.wireupIO();
            self.wireupSessionManager();
            self.wireupSession();
            self.wireupLabelDefinitions();
            self.wireupPublish();

        end


        function delete(self)
            if~isempty(self.Data)
                self.Data.clear();
                self.Labels.clear();
            end
            self.Session.delete();
        end


        function clear(self)

            self.addSessionToRecentFiles();

            if self.HasImageData
                self.Data.clear();
                self.Labels.clear();
            end

            self.Automation.clear();
            self.SessionManager.clear();
            self.Session.clear();
            self.History.clear();
            self.LabelDefinition.clear();
            self.Summary.clear();

            self.DataFormat=medical.internal.app.labeler.enums.DataFormat.empty();

        end


        function setDataFormat(self,dataFormat)



            if self.HasImageData
                error('Setting DataFormat in non-empty app');
            end
            self.DataFormat=dataFormat;
            self.Session.DataFormat=dataFormat;

            self.createData();
            self.createLabels();

            self.wireupData();
            self.wireupLabels();

        end

    end

    methods(Access=protected)

        function createComponents(self,varargin)

            self.Automation=images.internal.app.segmenter.volume.data.Automation();
            self.Session=medical.internal.app.labeler.model.Session();
            self.History=medical.internal.app.labeler.model.History();
            self.Interpolation=images.internal.app.utilities.Interpolation();
            self.SessionManager=medical.internal.app.labeler.model.SessionManager();
            self.LabelDefinition=medical.internal.app.labeler.model.LabelDefinition();
            self.Publish=medical.internal.app.labeler.model.Publish();
            self.Summary=medical.internal.app.labeler.model.Summary();

            self.IO=medical.internal.app.labeler.model.IO();
            self.IO.createCacheDirectories();

        end

        function createData(self)

            if self.DataFormat==medical.internal.app.labeler.enums.DataFormat.Volume
                self.Data=medical.internal.app.labeler.model.data.Volume();
            else
                self.Data=medical.internal.app.labeler.model.data.Image();
            end

        end

        function createLabels(self)
            if self.DataFormat==medical.internal.app.labeler.enums.DataFormat.Volume
                self.Labels=medical.internal.app.labeler.model.data.VolumeLabels();
            else
                self.Labels=medical.internal.app.labeler.model.data.ImageLabels();
            end
        end

    end


    methods


        function hasData=get.HasImageData(self)

            hasData=false;

            if isvalid(self.Session)
                hasData=self.Session.NumEntries>0;
            end

        end


        function hasSessionData=get.HasSessionData(self)

            hasSessionData=self.LabelDefinition.NumLabels>0;
            hasSessionData=hasSessionData|self.HasImageData;

        end

    end







    events



AutomationStopped



AutomationRangeUpdated

AutomationDirectionUpdated

    end

    methods


        function startAutomation(self,alg,isVolume,settingsStruct,hfig)

            if~isVolume

                currentIdx=self.Automation.Current;
                sliceDir=self.Automation.SliceDirection;
                self.changeSlice(currentIdx,sliceDir);
            end

            [labelName,~,~]=self.getCurrentLabel();
            self.Automation.start(alg,labelName,isVolume,settingsStruct,hfig);

        end


        function stopAutomation(self)
            stop(self.Automation);
        end


        function setAutomationSliceDirection(self,sliceDir)

            maxSlice=self.Data.getMaxSliceIndex(sliceDir);
            setDirection(self.Automation,sliceDir);

            evt=medical.internal.app.labeler.events.AutomationSliceDirectionEventData(maxSlice,sliceDir);
            self.notify('AutomationDirectionUpdated',evt)

        end


        function setAutomationRange(self,startVal,endVal)

            sliceDir=self.Automation.SliceDirection;
            maxSlice=self.Data.getMaxSliceIndex(sliceDir);
            setRange(self.Automation,startVal,endVal,maxSlice);

        end

    end

    methods(Access=protected)


        function wireupAutomation(self)

            iterateListener=addlistener(self.Automation,'Iterate',@(src,evt)iterate(self,evt.ExecutionMode,~evt.UseScaledVolume));
            iterateListener.Recursive=true;

            addlistener(self.Automation,'LabelsUpdated',@(src,evt)reactToAutomationUpdate(self,evt.Label));
            addlistener(self.Automation,'ErrorThrown',@(src,evt)notify(self,'ErrorThrown',evt));
            addlistener(self.Automation,'AutomationStarting',@(src,evt)reactToAutomationStarting(self,evt.UseScaledVolume));
            addlistener(self.Automation,'AutomationStopped',@(src,evt)reactToAutomationStopping(self,evt));
            addlistener(self.Automation,'RangeUpdated',@(src,evt)notify(self,'AutomationRangeUpdated',evt));

        end


        function iterate(self,mode,useOriginalData)

            if strcmp(mode,'slice')


                currentIdx=self.Automation.Current;
                sliceDir=self.Automation.SliceDirection;




                slice=self.Data.getSliceForAutomation(useOriginalData,currentIdx,sliceDir);
                labelSlice=self.Labels.getSlice(currentIdx,sliceDir);
                labelSlice=self.convertToCategorical(labelSlice);
                self.Automation.run(slice,labelSlice);

                if self.Automation.Current==self.Automation.End||self.Automation.StopRequested

                    self.Automation.stop();

                else





                    if self.Automation.Start<self.Automation.End
                        self.Automation.setCurrentIdx(self.Automation.Current+1);
                    else
                        self.Automation.setCurrentIdx(self.Automation.Current-1);
                    end
                    self.changeSlice(self.Automation.Current,sliceDir);

                    iterate(self.Automation);

                end

            else


                V=self.Data.getRawDataForAutomation(useOriginalData);
                L=self.Labels.RawData;
                L=self.convertToCategorical(L);

                self.Automation.runOnVolume(V,L,useOriginalData,[],[],[],self.LabelDefinition.Colormap,1);

                stop(self.Automation);

            end

        end


        function reactToAutomationUpdate(self,labels)

            if ismatrix(labels)

                currentIdx=self.Automation.Current;
                sliceDir=self.Automation.SliceDirection;
                labelSlice=self.Labels.getSlice(currentIdx,sliceDir);

                self.History.addToTemporaryStack(labelSlice,currentIdx,sliceDir);

                labels=self.convertToNumeric(labels);
                self.Labels.setSlice(labels,currentIdx,sliceDir);

            else

                labels=self.convertToNumeric(labels);

                self.History.addVolumeBasedAutomationResults(self.Labels.RawData);
                self.Labels.RawData=labels;
                self.reactToLabelsUpdated();
                self.refreshLabels3D();

            end

        end


        function reactToAutomationStarting(self,useOriginalData)
            self.Data.sanitizeDataForAutomation(useOriginalData);
        end


        function reactToAutomationStopping(self,evt)



            self.Data.clearAutomationData();
            self.regenerateSummary();
            self.reactToLabelsUpdated();
            self.History.applyTemporaryStack();
            self.refreshLabels3D();

            notify(self,'AutomationStopped',evt);

        end


        function out=convertToCategorical(self,in)

            valueSet=self.LabelDefinition.Definition.PixelLabelID;
            catNames=self.LabelDefinition.Definition.Name;

            if ismatrix(in)
                out=categorical(in,valueSet,catNames);
            else
                out=images.internal.app.segmenter.volume.data.stitchedCategorical(in,valueSet,catNames);
            end

        end


        function out=convertToNumeric(self,in)

            valueSet=self.LabelDefinition.Definition.PixelLabelID;
            catNames=self.LabelDefinition.Definition.Name;

            out=zeros(size(in),self.Labels.DataType);

            for i=1:length(catNames)
                idx=in==catNames(i);
                out(idx)=valueSet(i);
            end

        end

    end




    events

NewDataFormatUpdated

FirstDataAdded
DataAdded

CurrentlyLoadingData

SetLabelOpacity

SessionIsUnsaved
SessionIsSaved

    end

    methods


        function addDataFromFile(self,filenames)

            filenames=string(filenames);

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume

                [filenames,invalidFilenames]=getValidVolumeFiles(filenames);
                errID='medical:medicalLabeler:unsupportedFormatVolume';

            case medical.internal.app.labeler.enums.DataFormat.Image

                [filenames,invalidFilenames]=getValidImageFiles(filenames);
                errID='medical:medicalLabeler:unsupportedFormatImage';

            end

            if~isempty(filenames)
                validateData=true;
                self.Session.addFromFile(filenames,validateData);
            end

            if~isempty(invalidFilenames)
                msg=getString(message(errID,invalidFilenames));
                evt=medical.internal.app.labeler.events.ErrorEventData(msg);
                self.notify('WarningThrown',evt);
            end

            self.updateSessionAsUnsaved();

        end


        function addDataFromDICOMFolder(self,directoryName)
            self.Session.addFromFolder(directoryName);
            self.updateSessionAsUnsaved();
        end


        function addGroundTruthFromFile(self,dataSource)
            gTruthMedical=self.IO.importGroundTruthFromFile(dataSource);
            self.addGroundTruth(gTruthMedical);
        end


        function addGroundTruth(self,gTruthMedical)

            if isempty(gTruthMedical)
                return
            end

            if self.HasImageData

                isGTruthCompatible=self.validateGroundTruthCompatibility(gTruthMedical);

                if~isGTruthCompatible
                    return
                end

            else

                if isa(gTruthMedical.DataSource,'medical.labeler.loading.VolumeSource')
                    newDataFormat=medical.internal.app.labeler.enums.DataFormat.Volume;
                elseif isa(gTruthMedical.DataSource,'medical.labeler.loading.ImageSource')
                    newDataFormat=medical.internal.app.labeler.enums.DataFormat.Image;
                end

                evt=medical.internal.app.labeler.events.ValueEventData(newDataFormat);
                self.notify('NewDataFormatUpdated',evt);

            end



            str=getString(message('medical:medicalLabeler:labelBrowser'));
            evt=medical.internal.app.labeler.events.ValueEventData(str);
            self.notify('CurrentlyLoadingData',evt);

            self.addLabelDefs(gTruthMedical.LabelDefinitions);


            self.Session.addGroundTruth(gTruthMedical.DataSource.Source,gTruthMedical.LabelData);

        end


        function applyCurrentRenderingToAllVolumes(self)
            [preset,renderingStyle,alphaControlPts,colorControlPts]=self.Data.getRenderingSettings();
            self.Session.applyRenderingToAllVolumes(preset,renderingStyle,alphaControlPts,colorControlPts);
            self.updateSessionAsUnsaved();
        end


        function copyDataLocation(self,dataName)
            self.Session.copyDataLocation(dataName);
        end


        function copyLabelLocation(self,dataName)
            self.Session.copyLabelLocation(dataName);
        end


        function removeData(self,dataName)
            self.Session.remove(dataName);
        end


        function removeLabels(self,dataName)

            self.Session.removeLabels(dataName);
            if self.Labels.DataName==dataName

                self.Labels.clear();
                self.reactToLabelsUpdated();
                self.refreshLabels3D();

                self.History.clear();
                self.regenerateSummary();

                hasLabels=false;
                evt=medical.internal.app.labeler.events.DataEventData(dataName,hasLabels);
                self.notify('UpdateLabelStatus',evt)

                self.Session.setLabelDataSource(dataName,"");
                self.Labels.setEmptyData(self.Data.DataSize,self.Data.SpatialDetails);

                self.updateSessionAsUnsaved();

            end

        end


        function setLabelOpacity(self,opacity)
            self.Session.LabelOpacity=opacity;
        end


        function saveSession(self)

            if~self.HasImageData&&~self.HasSessionData
                return;
            end

            if self.HasImageData
                self.saveCurrentLabels();
                self.updateCurrentDataInfo();
            end


            self.Session.LabelDefinitions=self.LabelDefinition.Definition;


            self.SessionManager.saveSessionInfo(self.Session);

            gTruthFile=self.SessionManager.getGroundTruthFilePath();
            self.exportGroundTruthToFile(gTruthFile);

            self.updateSessionAsSaved();

        end


        function openSession(self,folderpath)

            try

                session=self.SessionManager.openSession(folderpath);

                if isa(session,'medical.internal.app.labeler.model.Session')

                    evt=medical.internal.app.labeler.events.ValueEventData(session.DataFormat);
                    self.notify('NewDataFormatUpdated',evt);


                    evt=medical.internal.app.labeler.events.ValueEventData(session.LabelOpacity);
                    self.notify('SetLabelOpacity',evt)



                    if~isempty(session.LabelDefinitions)

                        str=getString(message('medical:medicalLabeler:labelBrowser'));
                        evt=medical.internal.app.labeler.events.ValueEventData(str);
                        self.notify('CurrentlyLoadingData',evt);

                        self.addLabelDefs(session.LabelDefinitions);

                    end

                    self.Session=session;
                    self.wireupSession();



                    if self.HasImageData



                        str=strcat(string(self.DataFormat),'s');
                        evt=medical.internal.app.labeler.events.ValueEventData(str);
                        self.notify('CurrentlyLoadingData',evt);

                        self.reactToFirstDataAdded();



                        dataNames=[self.Session.DataEntries.DataName];
                        labelDataSource=[self.Session.DataEntries.LabelDataSource];
                        hasLabels=labelDataSource~="";
                        evt=medical.internal.app.labeler.events.DataEventData(dataNames,hasLabels);
                        self.notify('DataAdded',evt);

                    end

                elseif isfile(session)





                    self.addGroundTruthFromFile(session);

                    msg=getString(message('medical:medicalLabeler:usingGroundTruthInsteadOfSession'));
                    evt=medical.internal.app.labeler.events.ErrorEventData(msg);
                    self.notify('WarningThrown',evt);

                end

                if self.HasSessionData

                    self.IO.addSessionToRecentFiles(folderpath,self.DataFormat);
                else
                    msg=getString(message('medical:medicalLabeler:noDataInSession'));
                    evt=medical.internal.app.labeler.events.ErrorEventData(msg);
                    self.notify('WarningThrown',evt);
                end

            catch ME

                self.reactToRemoveSessionFromCache(folderpath);

                evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                self.notify('ErrorThrown',evt);


            end

        end


        function updateCurrentDataInfo(self)


            currentDataName=self.Data.DataName;
            if~isempty(currentDataName)



                tempValues=self.Data.getTempValues();
                self.Session.setDataEntryValues(currentDataName,tempValues);

                tempValues=self.Labels.getTempValues();
                self.Session.setDataEntryValues(currentDataName,tempValues);

            end

        end


        function addSessionToRecentFiles(self)
            if self.HasSessionData
                self.IO.addSessionToRecentFiles(self.SessionManager.SessionLocation,self.DataFormat);
            end
        end

    end

    methods(Access=protected)

        function wireupSession(self)

            addlistener(self.Session,'ErrorThrown',@(src,evt)self.notify('ErrorThrown',evt));
            addlistener(self.Session,'DataAdded',@(src,evt)self.notify('DataAdded',evt));
            addlistener(self.Session,'FirstDataAdded',@(src,evt)self.reactToFirstDataAdded());
            addlistener(self.Session,'CurrentlyLoadingData',@(src,evt)self.notify('CurrentlyLoadingData',evt));

        end


        function reactToFirstDataAdded(self)
            self.notify('FirstDataAdded');
        end


        function updateSessionAsUnsaved(self)
            self.notify('SessionIsUnsaved');
        end


        function updateSessionAsSaved(self)
            self.notify('SessionIsSaved');
        end


        function isCompatible=validateGroundTruthCompatibility(self,gTruthMedical)

            isCompatible=true;

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume

                if~isa(gTruthMedical.DataSource,'medical.labeler.loading.VolumeSource')

                    currSessionFormat=getString(message('medical:medicalLabeler:volume'));
                    loadingDataFormat=getString(message('medical:medicalLabeler:image'));
                    errMsg=getString(message('medical:medicalLabeler:incompatibleGroundTruth',loadingDataFormat,currSessionFormat));

                    evt=medical.internal.app.labeler.events.ErrorEventData(errMsg);
                    self.notify('ErrorThrown',evt);

                    isCompatible=false;
                    return;

                end

            case medical.internal.app.labeler.enums.DataFormat.Image

                if~isa(gTruthMedical.DataSource,'medical.labeler.loading.ImageSource')

                    currSessionFormat=getString(message('medical:medicalLabeler:image'));
                    loadingDataFormat=getString(message('medical:medicalLabeler:volume'));
                    errMsg=getString(message('medical:medicalLabeler:incompatibleGroundTruth',loadingDataFormat,currSessionFormat));

                    evt=medical.internal.app.labeler.events.ErrorEventData(errMsg);
                    self.notify('ErrorThrown',evt);

                    isCompatible=false;
                    return;

                end

            end

            TF=self.isCleanDataMerge(gTruthMedical);

            isCompatible=isCompatible&TF;


        end


        function TF=isCleanDataMerge(self,gTruthNew)



            self.saveSession();

            gTruthFile=self.SessionManager.getGroundTruthFilePath();
            if~isfile(gTruthFile)
                TF=true;
                return
            end

            gTruthCurrent=self.IO.importGroundTruthFromFile(gTruthFile);

            try
                gTruthMerged=gTruthCurrent.merge(gTruthNew);%#ok<NASGU> 
                TF=true;
            catch ME
                TF=false;
                self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
            end

        end

    end




    events


HistoryUpdated

    end

    methods


        function undo(self)

            self.History.undo(self.Labels);
            self.reactToLabelsUpdated();

            self.regenerateSummary();

            self.updateSessionAsUnsaved();

        end


        function redo(self)

            self.History.redo(self.Labels);
            self.reactToLabelsUpdated();

            self.regenerateSummary();

            self.updateSessionAsUnsaved();

        end


        function setUndoStackLength(self,n)
            setLength(self.History,n);
        end

    end

    methods(Access=protected)


        function wireupHistory(self)

            addlistener(self.History,'HistoryUpdated',@(src,evt)notify(self,'HistoryUpdated',evt));

        end

    end




    events



AutoInterpolationFailed

    end

    methods


        function autoInterpolate(self,pos,val,currSliceIdx,sliceDir)

            [slice,idx]=self.Labels.findNeighboringSliceWithLabel(val,currSliceIdx,sliceDir);

            if~isempty(slice)
                self.InterpolationSliceDir=sliceDir;
                self.Interpolation.autoInterpolate(pos,val,slice,currSliceIdx,idx,3);
            end

        end


        function interpolate(self,pos1,pos2,val,idx1,idx2,sliceDir)

            self.InterpolationSliceDir=sliceDir;
            sliceSize=size(self.Data.getSlice(1,sliceDir),[1,2]);
            self.Interpolation.interpolate(pos1,pos2,val,idx1,idx2,3,sliceSize);

        end

    end

    methods(Access=protected)


        function wireupInterpolation(self)

            addlistener(self.Interpolation,'ErrorThrown',@(src,evt)notify(self,'ErrorThrown',evt));
            addlistener(self.Interpolation,'InterpolationCompleted',@(src,evt)setMaskSection(self,evt.Mask,evt.Label,evt.SliceNumber));
            addlistener(self.Interpolation,'AutoInterpolationFailed',@(~,~)notify(self,'AutoInterpolationFailed'));

        end

    end




    events
DisableSaveCustomRenderings
RequestedRecentSessions
    end

    methods


        function saveSnapshot(self,filename,snapshot3D,sliceIdxs,sliceDirs)

            labelColormap=self.LabelDefinition.Colormap;
            labelAlphamap=self.LabelDefinition.Alphamap*self.Session.LabelOpacity;
            contrastLimits=self.Data.DataDisplayLimits;

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume

                [path,name]=fileparts(filename);
                filename=fullfile(path,name);

                if~isempty(snapshot3D)
                    imgName=strcat(filename,'_Volume.png');
                    self.IO.writeImage(snapshot3D,imgName);
                end

                for i=1:length(sliceDirs)

                    [slice,pixelSize]=self.Data.getSlice(sliceIdxs(i),sliceDirs(i));
                    label=self.Labels.getSlice(sliceIdxs(i),sliceDirs(i));
                    img=medical.internal.app.labeler.utils.getOverlayImage(slice,label,labelColormap,labelAlphamap,contrastLimits);

                    if self.Data.IsOblique
                        dirName=medical.internal.app.labeler.utils.ras2Direction(sliceDirs(i));
                    else
                        dirName=string(sliceDirs(i));
                    end
                    imgName=strcat(filename,'_',dirName,'.png');

                    hFig=figure('Visible','off');
                    hIM=image(img);
                    hIM.Parent.DataAspectRatio=[1/pixelSize(2),1/pixelSize(1),1];
                    drawnow;

                    f=getframe(hIM.Parent);
                    img=f.cdata;

                    self.IO.writeImage(img,imgName);

                    delete(hFig);

                end

            case medical.internal.app.labeler.enums.DataFormat.Image

                slice=self.Data.getSlice(sliceIdxs);
                label=self.Labels.getSlice(sliceIdxs);
                img=medical.internal.app.labeler.utils.getOverlayImage(slice,label,labelColormap,labelAlphamap,contrastLimits);

                self.IO.writeImage(img,filename);

            end

        end


        function exportGroundTruthToFile(self,filename)

            [dataSource,labelData]=self.Session.getDataForGroundTruth();

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume
                dataSourceObj=medical.labeler.loading.VolumeSource({});
                dataSourceObj.setSource(dataSource);

            case medical.internal.app.labeler.enums.DataFormat.Image
                dataSourceObj=medical.labeler.loading.ImageSource({});
                dataSourceObj.setSource(dataSource);

            end

            gTruth=groundTruthMedical(dataSourceObj,self.LabelDefinition.Definition,labelData);

            self.IO.exportGroundTruthToFile(filename,gTruth);

        end


        function exportLabelDefsToFile(self,filename)
            self.IO.exportLabelDefsToFile(filename,self.LabelDefinition.Definition);
        end


        function refreshRecentSessions(self)

            [folderpaths,dataFormats]=self.IO.getAllRecentSessions();

            evt=medical.internal.app.labeler.events.RecentFileEventData(folderpaths,dataFormats);
            self.notify('RequestedRecentSessions',evt)

        end

    end

    methods(Access=protected)


        function wireupIO(self)

            addlistener(self.IO,'CacheCreationUnsuccessful',@(src,evt)self.reactToCacheCreationUnsuccessful());
            addlistener(self.IO,'ErrorThrown',@(src,evt)self.notify('ErrorThrown',evt));

        end


        function reactToCacheCreationUnsuccessful(self)

            msg=getString(message('medical:medicalLabeler:cacheCreationUnsuccessful'));
            evt=medical.internal.app.labeler.events.ErrorEventData(msg);
            self.notify('WarningThrown',evt);


            self.notify('DisableSaveCustomRenderings')

        end

    end




    events

LabelsUpdated

UpdateLabelStatus
UpdateLabels3D

    end

    methods


        function refreshLabels3D(self)
            evt=medical.internal.app.labeler.events.ValueEventData(self.Labels.RawData());
            self.notify('UpdateLabels3D',evt);
        end


        function setMask(self,mask,val,prior,offset,idx,sliceDir)

            if~isnumeric(val)
                i=find(self.LabelDefinition.Definition.Name==string(val));
                val=self.LabelDefinition.Definition.PixelLabelID(i);
            end

            if isempty(prior)

                self.History.add(self.Labels,mask,idx,sliceDir);
            else


                self.History.add(self.Labels,mask|prior,idx,sliceDir);
            end

            self.Labels.setMask(mask,val,prior,self.History.Prior,offset,idx,sliceDir);



            regenerateSummary(self);


            self.updateSessionAsUnsaved();

        end


        function setMaskSection(self,mask,val,sliceNumber)

            self.History.add(self.Labels,mask,sliceNumber,self.InterpolationSliceDir);
            self.Labels.setMaskSection(mask,val,sliceNumber,self.InterpolationSliceDir);

            regenerateSummary(self);

            self.updateSessionAsUnsaved();

        end


        function mergeWithExistingSlice(self,mask,idx,sliceDir)



            slice=getSlice(self.Labels,idx,sliceDir);
            mask(mask==0)=slice(mask==0);

            self.History.add(self.Labels,mask,idx,sliceDir);
            self.Labels.setSlice(mask,idx,sliceDir);



            regenerateSummary(self);


        end


        function setPriorMask(self,mask,holeMask,parentMask,idx,sliceDir)

            currSlice=self.Labels.getSlice(idx,sliceDir);
            self.History.updatePrior(currSlice,mask);
            self.Labels.updateNestingMasks(holeMask,parentMask,idx,sliceDir);

        end


        function fillRegion(self,mask,val,idx,sliceDir)

            slice=getSlice(self.Labels,idx,sliceDir);

            BW=slice==slice(mask);
            BW=imfill(~BW,find(mask(:)))&BW;

            self.History.add(self.Labels,BW,idx,sliceDir);

            self.Labels.setMask(BW,val,logical.empty(),uint8.empty(),0,idx,sliceDir);

            regenerateSummary(self);


        end


        function floodFill(self,mask,val,L,tol,idx,sliceDir)

            if isempty(L)
                L=self.Volume.getSlice(idx,sliceDir);
            end

            [row,col]=find(mask,1);

            if size(L,3)==3
                L=sum((L-L(row,col,:)).^2,3);
            end

            L=mat2gray(L);
            BW=grayconnected(L,row,col,tol);

            self.History.add(self.Labels,BW,idx,sliceDir);

            self.Labels.setMask(BW,val,logical.empty,uint8.empty,0,idx,sliceDir);

            regenerateSummary(self);


        end

    end

    methods(Access=protected)


        function wireupLabels(self)

            addlistener(self.Labels,'ErrorThrown',@(src,evt)self.notify('ErrorThrown',evt));
            addlistener(self.Labels,'LabelsUpdated',@(src,evt)self.reactToLabelsUpdated());
            addlistener(self.Labels,'UpdateLabelStatus',@(src,evt)self.notify('UpdateLabelStatus',evt));

        end


        function reactToLabelsUpdated(self)
            self.notify('LabelsUpdated');
        end

    end




    events

LabelDefinitionsUpdated

LabelDefinitionAdded

LabelColorUpdated
LabelAlphaUpdated

CustomizeLabelVisibilityRequested

    end

    methods


        function addNewLabelDefinition(self)

            self.LabelDefinition.new();

            if self.DataFormat==medical.internal.app.labeler.enums.DataFormat.Volume

                self.updateLabelVolumeAlpha();



                if self.LabelDefinition.NumLabels==1
                    self.updateLabelVolumeColor();
                end

            end

            self.updateSessionAsUnsaved();

        end


        function addLabelDefsFromFile(self,dataSource)

            try
                labelDefs=self.IO.importLabelDefsFromFile(dataSource);

            catch ME

                self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                return;

            end

            self.addLabelDefs(labelDefs);

        end


        function labelNameChanged(self,oldName,newName)
            self.LabelDefinition.changeName(oldName,newName);
            self.updateSessionAsUnsaved();
        end


        function labelColorChanged(self,labelName,newColor)

            self.LabelDefinition.changeColor(labelName,newColor);
            self.regenerateSummary();

            cmap=self.LabelDefinition.Colormap;
            evt=medical.internal.app.labeler.events.ValueEventData(cmap);
            self.notify('LabelColorUpdated',evt);

            self.updateSessionAsUnsaved();

        end


        function labelVisibilityChanged(self,labelName,TF)

            self.LabelDefinition.changeVisibility(labelName,TF);

            amap=self.LabelDefinition.Alphamap;
            evt=medical.internal.app.labeler.events.ValueEventData(amap);
            self.notify('LabelAlphaUpdated',evt);

            self.updateSessionAsUnsaved();

        end


        function labelDeleted(self,labelName)

            labelDefs=self.LabelDefinition.Definition;

            idx=find(labelDefs.Name==labelName);
            pixIds=labelDefs.PixelLabelID(idx);

            self.LabelDefinition.remove(labelName);

            if self.HasImageData

                self.Labels.removePixelLabelValue(pixIds);
                self.Session.removePixelLabelValue(self.Data.DataName,pixIds);

                if self.DataFormat==medical.internal.app.labeler.enums.DataFormat.Volume
                    self.updateLabelVolumeAlpha();
                end

                self.History.clear();
                self.regenerateSummary();

            end

            self.saveSession();

        end


        function[name,idx,color]=getCurrentLabel(self)



            [name,idx,color]=self.LabelDefinition.getCurrentLabel();
        end


        function setCurrentLabel(self,labelName)
            self.LabelDefinition.setCurrentLabel(labelName);
            self.regenerateSummary();
        end


        function names=getLabelDefinitionNames(self)


            names=self.LabelDefinition.Definition.Name;
        end

    end

    methods(Access=protected)


        function wireupLabelDefinitions(self)

            addlistener(self.LabelDefinition,'LabelDefinitionsUpdated',@(src,evt)self.notify('LabelDefinitionsUpdated',evt));
            addlistener(self.LabelDefinition,'ErrorThrown',@(src,evt)self.notify('ErrorThrown',evt));

        end


        function addLabelDefs(self,labelDefs)

            numLabelsBeforeAdd=self.LabelDefinition.NumLabels;

            currLabelDefs=self.LabelDefinition.Definition;

            try

                self.LabelDefinition.add(labelDefs);

            catch ME



                self.LabelDefinition.Definition=currLabelDefs;
                self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                return;

            end




            if self.DataFormat==medical.internal.app.labeler.enums.DataFormat.Volume

                self.updateLabelVolumeAlpha();



                if numLabelsBeforeAdd==0
                    self.updateLabelVolumeColor();
                end

            end

        end

    end




    events

InitializeSliceViews
IsCurrentDataOblique
VolumeLoaded

VolumeRenderingSettingsUpdated
LabelVolumeColorUpdated
LabelVolumeAlphaUpdated
UpdateToCustomRenderingPreset


RequestedSlice
ChangeSlice
RequestedVoxelInfo
RequestedUserDefinedVolumeRenderingSettings

UpdateContrastLimits

    end

    methods


        function redrawVolume(self)
            self.updateVolume();
            self.updateVolumeRenderingSettings();
        end


        function[slice,labelSlice,maxIdx,labelColormap,labelVisible]=getSlice(self,index,sliceDirection)

            slice=self.Data.getSlice(index,sliceDirection);
            labelSlice=self.Labels.getSlice(index,sliceDirection);
            maxIdx=self.Data.getMaxSliceIndex(sliceDirection);
            labelColormap=self.LabelDefinition.Colormap;
            labelVisible=self.LabelDefinition.Alphamap;

        end


        function changeSlice(self,idx,sliceDirection)

            evt=medical.internal.app.labeler.events.SliceEventData(idx,sliceDirection);
            self.notify('ChangeSlice',evt);

        end


        function getVoxelInfo(self,position,idx,sliceDirection)

            position=round(position);
            intensity=self.Data.getIntensity(position,idx,sliceDirection);

            evt=medical.internal.app.labeler.events.VoxelIntensityEventData(position,idx,sliceDirection);
            evt.Intensity=intensity;
            self.notify('RequestedVoxelInfo',evt);

        end


        function updateDefaultContrastLimits(self)

            cLim=self.Data.DataDisplayLimitsDefault;


            self.Data.DataDisplayLimits=cLim;

            evtData=medical.internal.app.labeler.events.ValueEventData(cLim);
            self.notify('UpdateContrastLimits',evtData);

            self.updateSessionAsUnsaved();

        end


        function setContrastLimits(self,dataDisplayLimits)
            self.Data.DataDisplayLimits=dataDisplayLimits;
            self.updateSessionAsUnsaved();
        end


        function updateFromPresetVolumeRendering(self,preset)

            renderingSettings=preset.getRenderingSettings();

            self.Data.setVolumeRenderingSettings(preset,...
            renderingSettings.RenderingStyle,...
            renderingSettings.AlphaControlPoints,...
            renderingSettings.ColorControlPoints);

            self.updateVolumeRenderingSettings();

            self.updateSessionAsUnsaved();

        end


        function updateFromUserDefinedVolumeRendering(self,renderingTag)

            renderingSettings=self.IO.getCustomVolumeRendering(renderingTag);

            if isempty(renderingSettings)

                evt=medical.internal.app.labeler.events.ErrorEventData(getString(message('medical:medicalLabeler:userDefinedRenderingNotRetrieved')));
                self.notify('WarningThrown',evt);



                self.updateVolumeRenderingSettings();




                self.refreshUserDefinedVolumeRenderings();

            else

                self.Data.setVolumeRenderingSettings(renderingTag,...
                renderingSettings.RenderingStyle,...
                renderingSettings.AlphaControlPoints,...
                renderingSettings.ColorControlPoints);

                self.updateVolumeRenderingSettings();

            end

            self.updateSessionAsUnsaved();

        end


        function saveUserDefinedVolumeRendering(self,renderingInfo)
            self.Data.setVolumeRenderingPreset(renderingInfo.Tag);
            self.IO.saveCustomVolumeRendering(renderingInfo);
        end


        function removeUserDefinedVolumeRendering(self,renderingTag)
            if self.Data.RenderingPreset==renderingTag
                self.Data.setVolumeRenderingPreset(medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset);
            end
            self.IO.removeCustomVolumeRendering(renderingTag);
        end


        function refreshUserDefinedVolumeRenderings(self)

            renderingSettings=self.IO.getAllCustomVolumeRendering();
            evt=medical.internal.app.labeler.events.ValueEventData(renderingSettings);
            self.notify('RequestedUserDefinedVolumeRenderingSettings',evt)

        end


        function setRenderingStyle(self,renderingStyle)
            self.Data.RenderingStyle=renderingStyle;
            self.updateSessionAsUnsaved();
        end


        function setColorControlPoints(self,controlPoints)

            self.Data.ColorControlPoints=controlPoints;



            self.updateToCustomRenderingPreset();

            self.updateSessionAsUnsaved();

        end


        function setAlphaControlPoints(self,controlPoints)

            self.Data.AlphaControlPoints=controlPoints;



            self.updateToCustomRenderingPreset();

            self.updateSessionAsUnsaved();

        end


        function updateToCustomRenderingPreset(self)

            preset=medical.internal.app.labeler.model.PresetRenderingOptions.CustomPreset;
            self.Data.RenderingPreset=preset;

            self.notify('UpdateToCustomRenderingPreset');

            self.updateSessionAsUnsaved();

        end


        function updateLabelVolumeAlpha(self)

            amap=self.LabelDefinition.Alphamap;
            evt=medical.internal.app.labeler.events.ValueEventData(amap);
            self.notify('LabelVolumeAlphaUpdated',evt);

        end


        function updateLabelVolumeColor(self)

            cmap=self.LabelDefinition.Colormap;
            evt=medical.internal.app.labeler.events.ValueEventData(cmap);
            self.notify('LabelVolumeColorUpdated',evt);

        end


        function readData(self,dataName)

            currentDataName=self.Data.DataName;
            if~isempty(currentDataName)







                self.Data.clear();
                self.Labels.clear();

            end

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume
                self.readVolumeData(dataName);
            case medical.internal.app.labeler.enums.DataFormat.Image
                self.readImageData(dataName);

            end

            self.History.clear();

            self.regenerateSummary();

        end


        function readVolumeData(self,dataName)

            try


                dataEntry=self.Session.getEntry(dataName);
                renderingPreset=dataEntry.RenderingPreset;
                renderingStyle=dataEntry.RenderingStyle;
                alphaControlPoints=dataEntry.AlphaControlPoints;
                colorControlPoints=dataEntry.ColorControlPoints;






                if~isa(dataEntry.RenderingPreset,'medical.internal.app.labeler.model.PresetRenderingOptions')

                    renderingSettings=self.IO.getCustomVolumeRendering(dataEntry.RenderingPreset);
                    if isempty(renderingSettings)

                        evt=medical.internal.app.labeler.events.ErrorEventData(getString(message('medical:medicalLabeler:userDefinedRenderingNotRetrieved')));
                        self.notify('WarningThrown',evt);


                        renderingPreset=medical.internal.app.labeler.model.PresetRenderingOptions.LinearGrayscale;
                        renderingSettings=renderingPreset.getRenderingSettings();
                        renderingStyle=renderingSettings.RenderingStyle;
                        alphaControlPoints=renderingSettings.AlphaControlPoints;
                        colorControlPoints=renderingSettings.ColorControlPoints;




                        self.refreshUserDefinedVolumeRenderings();

                    end

                end

                self.Data.read(dataEntry.DataName,dataEntry.DataSource,...
                dataEntry.DataBounds,dataEntry.DataDisplayLimits,dataEntry.DataDisplayLimitsDefault,dataEntry.IsDataValidated,...
                renderingPreset,renderingStyle,alphaControlPoints,colorControlPoints,...
                dataEntry.CastingMethod);

                if dataEntry.LabelDataSource==""



                    self.Labels.DataName=dataEntry.DataName;
                    self.Labels.setEmptyData(self.Data.DataSize,self.Data.SpatialDetails);

                else

                    self.Labels.read(dataEntry.DataName,dataEntry.LabelDataSource,...
                    dataEntry.IsLabelDataValidated,self.Data.DataSize);

                end

            catch ME
                evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                self.notify('ErrorThrown',evt);
            end


            evt=medical.internal.app.labeler.events.InitailizeDisplayEventData(...
            self.Data.DataDisplayLimits,...
            self.Data.getNumSlices(),...
            self.Data.getPixelSpacing(),...
            self.Data.IsRGB);
            self.notify('InitializeSliceViews',evt);


            evt=medical.internal.app.labeler.events.ValueEventData(self.Data.IsOblique);
            self.notify('IsCurrentDataOblique',evt);


            self.updateVolume();
            self.updateVolumeRenderingSettings();

        end


        function readImageData(self,dataName)

            try


                dataEntry=self.Session.getEntry(dataName);
                self.Data.read(dataEntry.DataName,dataEntry.DataSource,...
                dataEntry.DataBounds,dataEntry.DataDisplayLimits,dataEntry.DataDisplayLimitsDefault,...
                dataEntry.IsDataValidated,dataEntry.CastingMethod);

                if dataEntry.LabelDataSource==""



                    self.Labels.DataName=dataEntry.DataName;
                    self.Labels.setEmptyData(self.Data.DataSize);

                else

                    self.Labels.read(dataEntry.DataName,dataEntry.LabelDataSource,...
                    dataEntry.IsLabelDataValidated,self.Data.DataSize);

                end

            catch ME
                evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                self.notify('ErrorThrown',evt);
            end


            evt=medical.internal.app.labeler.events.InitailizeDisplayEventData(...
            self.Data.DataDisplayLimits,...
            self.Data.getNumSlices(),...
            self.Data.getPixelSpacing(),...
            self.Data.IsRGB);
            self.notify('InitializeSliceViews',evt);

        end


        function saveCurrentLabels(self)

            currentDataName=self.Data.DataName;
            if~isempty(currentDataName)

                if self.Labels.HasNonEmptyLabels&&self.Labels.IsDirty

                    labelDataSource=self.Labels.LabelDataSource;

                    if labelDataSource==""


                        [~,dataName,~]=fileparts(currentDataName);
                        filename=strtok(dataName,'.');

                        fileLocation=self.SessionManager.getLabelDataLocation();
                        filename=medical.internal.app.labeler.utils.getUniqueFilename(fileLocation,filename);

                        labelDataSource=fullfile(fileLocation,filename);

                        switch self.DataFormat
                        case medical.internal.app.labeler.enums.DataFormat.Volume
                            labelDataSource=strcat(labelDataSource,'.nii');
                        case medical.internal.app.labeler.enums.DataFormat.Image
                            labelDataSource=strcat(labelDataSource,'.mat');
                        end


                        self.IO.writeLabels(labelDataSource,self.Labels.Data);

                        self.Labels.LabelDataSource=labelDataSource;
                        self.Session.setLabelDataSource(currentDataName,labelDataSource);

                    else
                        labelDataSource=self.Labels.LabelDataSource;
                        self.IO.writeLabels(labelDataSource,self.Labels.Data);
                    end

                end

            end

        end


        function updateVolume(self)

            s=settings;
            displayConvention=s.medical.apps.labeler.DisplayConvention.ActiveValue;

            [data,axesLabels,tform]=self.Data.getDataForDisplay(displayConvention);
            labels=self.Labels.getDataForDisplay(displayConvention);

            evt=medical.internal.app.labeler.events.VolumeLoadedEventData(...
            data,labels,...
            tform,self.Data.DataBounds,...
            axesLabels);
            self.notify('VolumeLoaded',evt);

        end


        function updateVolumeRenderingSettings(self)

            evt=medical.internal.app.labeler.events.VolumeRenderingSettingsChangedEventData(...
            self.Data.RenderingPreset,self.Data.RenderingStyle,...
            self.Data.AlphaControlPoints,self.Data.ColorControlPoints);
            self.notify('VolumeRenderingSettingsUpdated',evt);

        end

    end

    methods(Access=protected)


        function wireupData(self)

            addlistener(self.Data,'ErrorThrown',@(src,evt)self.notify('ErrorThrown',evt));

        end

    end




    methods


        function publishRequested(self,publishFormat,path,rangeStart,rangeEnd,screenshot3D,sliceDir)

            labelColormap=self.LabelDefinition.Colormap;
            labelAlphamap=self.LabelDefinition.Alphamap*self.Session.LabelOpacity;

            switch publishFormat

            case medical.internal.app.labeler.enums.PublishFormat.Images
                self.Publish.publishImages(self.Data,self.Labels,...
                labelColormap,labelAlphamap,...
                path,rangeStart,rangeEnd,screenshot3D,sliceDir);

            case medical.internal.app.labeler.enums.PublishFormat.PDF
                self.Publish.publishPDF(self.Data,self.Labels,...
                labelColormap,labelAlphamap,...
                path,rangeStart,rangeEnd,screenshot3D,sliceDir);

            end

        end

    end

    methods(Access=protected)


        function wireupPublish(self)
            addlistener(self.Publish,'ErrorThrown',@(src,evt)self.notify('ErrorThrown',evt));
        end

    end




    events

SessionLocationSet

    end

    methods


        function setSessionLocation(self,folderpath)

            self.SessionManager.setSessionLocation(folderpath);








            gTruthFile=self.SessionManager.getGroundTruthFilePath();
            self.exportGroundTruthToFile(gTruthFile);

            self.SessionManager.saveSessionInfo(self.Session);

        end


        function setLabelDataLocation(self,filepath)
            self.setSessionLocation(filepath);
        end


    end

    methods(Access=protected)


        function wireupSessionManager(self)

            addlistener(self.SessionManager,'ErrorThrown',@(src,evt)notify(self,'ErrorThrown',evt));
            addlistener(self.SessionManager,'WarningThrown',@(src,evt)notify(self,'WarningThrown',evt));
            addlistener(self.SessionManager,'SessionLocationSet',@(src,evt)notify(self,'SessionLocationSet',evt));
            addlistener(self.SessionManager,'RemoveSessionFromCache',@(src,evt)reactToRemoveSessionFromCache(self,evt.Value));

        end


        function reactToRemoveSessionFromCache(self,folderpath)
            self.IO.removeSessionFromRecentFiles(folderpath);
            self.refreshRecentSessions();
        end

    end




    events



SummaryUpdated

    end

    methods


        function[summary,color]=createSummary(self,idx,color,sliceDir)

            dim=self.Data.getPlaneMapping(sliceDir);
            summary=self.Summary.create(self.Labels.RawData,dim,idx);

        end

    end

    methods(Access=protected)


        function regenerateSummary(self)




            if~self.HasImageData
                return
            end

            switch self.DataFormat

            case medical.internal.app.labeler.enums.DataFormat.Volume

                sliceDir=[...
                medical.internal.app.labeler.enums.SliceDirection.Transverse,...
                medical.internal.app.labeler.enums.SliceDirection.Sagittal,...
                medical.internal.app.labeler.enums.SliceDirection.Coronal,...
                ];
                planeMapping=self.Data.getPlaneMappingTSC();



            case medical.internal.app.labeler.enums.DataFormat.Image
                sliceDir=medical.internal.app.labeler.enums.SliceDirection.Unknown;
                planeMapping=3;

            end

            labelData=self.Labels.RawData;
            [~,currentLabelPixelID,currColor]=getCurrentLabel(self);
            if isempty(currColor)




                currColor=[0,0,0];
            end

            for idx=1:length(sliceDir)

                if isempty(labelData)
                    summaryData=single(0);
                else
                    summaryData=self.Summary.create(labelData,planeMapping(idx),currentLabelPixelID);
                end

                evt=images.internal.app.segmenter.volume.events.SummaryUpdatedEventData(summaryData,currColor);
                evt.SliceDirection=sliceDir(idx);
                self.notify('SummaryUpdated',evt);

            end

        end

    end

end

function[filenamesNew,invalidFilenames]=getValidVolumeFiles(filenames)

    filenamesNew=string.empty();
    invalidFilenames='';

    for idx=1:length(filenames)

        if medical.labeler.loading.internal.isValidVolumeSourceFile(filenames(idx))
            filenamesNew(end+1)=filenames(idx);%#ok<*AGROW> 
        else
            invalidFilenames=[invalidFilenames,newline,char(filenames(idx))];
        end

    end

end

function[filenamesNew,invalidFilenames]=getValidImageFiles(filenames)

    filenamesNew=string.empty();
    invalidFilenames='';

    for idx=1:length(filenames)

        if medical.labeler.loading.internal.isValidImageSourceFile(filenames(idx))
            filenamesNew(end+1)=filenames(idx);%#ok<*AGROW> 
        else
            invalidFilenames=[invalidFilenames,newline,char(filenames(idx))];
        end

    end

end
