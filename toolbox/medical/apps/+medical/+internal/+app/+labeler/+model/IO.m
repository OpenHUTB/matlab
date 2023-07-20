classdef IO<handle




    properties(SetAccess=protected,GetAccess=?matlab.unittest.TestCase)

        RecentSessionsCache=fullfile(prefdir,'medical','MedicalLabeler','RecentSessionsCache.mat');
        RecentSessionsMaxHistoryLength(1,1)=10;

        CustomVolumeRenderingCache=fullfile(prefdir,'medical','MedicalLabeler','CustomVolumeRenderingCache.mat');

    end

    events

CacheCreationUnsuccessful

ErrorThrown

    end

    methods


        function createCacheDirectories(self)





            [cacheDir,~,~]=fileparts(self.RecentSessionsCache);
            if~isfolder(cacheDir)
                mkdir(cacheDir);
            end


            [cacheDir,~,~]=fileparts(self.CustomVolumeRenderingCache);
            if~isfolder(cacheDir)
                mkdir(cacheDir);
            end

        end


        function gTruth=importGroundTruthFromFile(self,filename)

            gTruth=[];

            try

                gTruth=medical.internal.app.labeler.utils.readGTruthMedicalFromMATFile(filename);

            catch ME

                self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                return;

            end

        end


        function exportGroundTruthToFile(self,filename,gTruthMed)

            try

                save(filename,'gTruthMed');

            catch ME

                self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                return;

            end

        end


        function labelDefs=importLabelDefsFromFile(self,filename)

            try

                data=load(filename);
                labelDefs=data.labelDefinitions;

            catch ME






                if isequal(ME.identifier,'MATLAB:nonExistentField')

                    str=getString(message('medical:medicalLabeler:invalidLabelDefsFile'));
                    self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(str));

                else
                    self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                end

            end

        end


        function labelDefs=exportLabelDefsToFile(self,filename,labelDefs)




            labelDefinitions=labelDefs;

            try

                save(filename,'labelDefinitions');

            catch ME

                self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                return;

            end

        end


        function writeImage(self,img,filename)

            try
                imwrite(img,filename);
            catch ME
                self.notify('ErrorThrown',medical.internal.app.labeler.events.ErrorEventData(ME.message));
                return;
            end

        end


        function writeLabels(self,filename,medicalObj)

            try

                if isa(medicalObj,'medicalVolume')

                    medicalObj.write(filename);

                else

                    labels=medicalObj;
                    save(filename,'labels');

                end

            catch ME
                evt=medical.internal.app.labeler.events.ErrorEventData(ME.message);
                self.notify('ErrorThrown',evt);
            end

        end

    end




    methods


        function addSessionToRecentFiles(self,folderpath,sessionDataFormat)

            recentSessions=string.empty;
            dataFormats=[];

            folderpath=string(folderpath);

            if isfile(self.RecentSessionsCache)

                data=load(self.RecentSessionsCache);
                recentSessions=data.recentSessions;
                dataFormats=data.dataFormats;


                idx=find(recentSessions==folderpath);
                recentSessions(idx)=[];
                dataFormats(idx)=[];

            end


            idx=recentSessions==folderpath;
            recentSessions(idx)=[];
            dataFormats(idx)=[];


            recentSessions=[folderpath;recentSessions(:)];
            dataFormats=[sessionDataFormat;dataFormats];


            idx=min(length(recentSessions),self.RecentSessionsMaxHistoryLength);
            recentSessions=recentSessions(1:idx);
            dataFormats=dataFormats(1:idx);


            save(self.RecentSessionsCache,'recentSessions','dataFormats');

        end


        function[recentSessions,dataFormats]=getAllRecentSessions(self)

            recentSessions=string.empty();
            dataFormats=[];

            if isfile(self.RecentSessionsCache)
                data=load(self.RecentSessionsCache);
                recentSessions=data.recentSessions;
                dataFormats=data.dataFormats;
            end


            idx=~isfolder(recentSessions);

            if any(idx)
                recentSessions(idx)=[];
                dataFormats(idx)=[];


                save(self.RecentSessionsCache,'recentSessions','dataFormats');
            end

        end


        function removeSessionFromRecentFiles(self,folderpath)

            recentSessions=string.empty;
            dataFormats=[];

            folderpath=string(folderpath);

            if isfile(self.RecentSessionsCache)
                data=load(self.RecentSessionsCache);
                recentSessions=data.recentSessions;
                dataFormats=data.dataFormats;
            end


            idx=recentSessions==folderpath;
            recentSessions(idx)=[];
            dataFormats(idx)=[];


            save(self.RecentSessionsCache,'recentSessions','dataFormats');

        end

    end




    methods


        function saveCustomVolumeRendering(self,renderingInfo)

            savedRenderings=struct.empty();

            renderingInfo.Tag=string(renderingInfo.Tag);

            if isfile(self.CustomVolumeRenderingCache)
                data=load(self.CustomVolumeRenderingCache);
                savedRenderings=data.savedRenderings;
            end

            savedRenderings=[savedRenderings,renderingInfo];


            save(self.CustomVolumeRenderingCache,'savedRenderings');

        end


        function removeCustomVolumeRendering(self,removeRenderingTag)

            savedRenderings=struct.empty();
            removeRenderingTag=string(removeRenderingTag);

            if isfile(self.CustomVolumeRenderingCache)
                data=load(self.CustomVolumeRenderingCache);
                savedRenderings=data.savedRenderings;
            end

            tags=[savedRenderings.Tag];
            idx=true(1,numel(savedRenderings));

            for i=1:numel(removeRenderingTag)

                j=find(tags==removeRenderingTag(i));
                if~isempty(j)
                    idx(j)=false;
                end

            end

            savedRenderings=savedRenderings(idx);


            save(self.CustomVolumeRenderingCache,'savedRenderings');

        end


        function renderingSettings=getCustomVolumeRendering(self,renderingTag)

            renderingSettings=struct.empty();

            renderingTag=string(renderingTag);

            if isfile(self.CustomVolumeRenderingCache)

                data=load(self.CustomVolumeRenderingCache);
                savedRenderings=data.savedRenderings;

                savedRenderingTags=[savedRenderings.Tag];
                idx=savedRenderingTags==renderingTag;

                renderingSettings=savedRenderings(idx);

            end

        end


        function renderingSettings=getAllCustomVolumeRendering(self)

            renderingSettings=struct.empty();

            if isfile(self.CustomVolumeRenderingCache)

                data=load(self.CustomVolumeRenderingCache);
                renderingSettings=data.savedRenderings;
            end

        end

    end

end
