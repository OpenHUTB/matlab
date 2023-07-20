classdef SessionManager<handle




    properties
        SessionLocation string=string.empty()
    end

    properties(Constant)

        LabelDataFolderName(1,1)string="LabelData";
        GroundTruthFileName(1,1)string="groundTruthMed.mat";

        TempFolderName(1,1)string="AppData";
        SessionInfoFileName(1,1)string="Session.mat";

    end

    events
ErrorThrown
WarningThrown

RemoveSessionFromCache
SessionLocationSet
    end

    methods


        function clear(self)
            self.SessionLocation=string.empty();
        end


        function setSessionLocation(self,filepath)

            self.SessionLocation=filepath;

            labelDataFolder=fullfile(self.SessionLocation,self.LabelDataFolderName);
            if~isfolder(labelDataFolder)
                mkdir(labelDataFolder);
            end

            tempFolder=fullfile(self.SessionLocation,self.TempFolderName);
            if~isfolder(tempFolder)
                mkdir(tempFolder);
            end

            evt=medical.internal.app.labeler.events.ValueEventData(self.SessionLocation);
            self.notify('SessionLocationSet',evt)

        end


        function session=openSession(self,folderpath)

            if~self.isValidSessionFolder(folderpath)
                error(getString(message('medical:medicalLabeler:invalidSessionFolder')));
            end

            if~medical.internal.app.labeler.utils.hasWriteAccess(folderpath)
                error(getString(message('medical:medicalLabeler:noWriteAccessSessionFolder')));
            end

            tempSessionInfoFile=fullfile(folderpath,self.TempFolderName,self.SessionInfoFileName);

            if isfile(tempSessionInfoFile)

                data=load(tempSessionInfoFile);
                session=data.sessionInfo;





                lastwarn('')
                warnState=warning('off','medical:groundTruthMedical:missingSource');

                gTruthFilename=fullfile(folderpath,self.GroundTruthFileName);
                data=load(gTruthFilename);

                warning(warnState);

                gTruth=data.gTruthMed;

                [~,msgId]=lastwarn();
                if isequal(msgId,'medical:groundTruthMedical:missingSource')
                    error(getString(message('medical:medicalLabeler:missingSourceSession',gTruthFilename)));
                end


                if isa(gTruth.DataSource,'medical.labeler.loading.VolumeSource')

                    sessionSource=cell(0,1);
                    labelDataSource=string(sessionSource);
                    if~isempty(session.DataEntries)
                        sessionSource={session.DataEntries.DataSource}';
                        labelDataSource=[session.DataEntries.LabelDataSource]';
                    end

                elseif isa(gTruth.DataSource,'medical.labeler.loading.ImageSource')

                    sessionSource=string(cell(0,1));
                    labelDataSource=string(sessionSource);
                    if~isempty(session.DataEntries)
                        sessionSource=[session.DataEntries.DataSource]';
                        labelDataSource=[session.DataEntries.LabelDataSource]';
                    end

                end

                if~isequal(sessionSource,gTruth.DataSource.Source)||~isequal(labelDataSource,gTruth.LabelData)






                    session=fullfile(folderpath,self.GroundTruthFileName);
                end


                self.setSessionLocation(folderpath);

            else



                session=fullfile(folderpath,self.GroundTruthFileName);


                self.setSessionLocation(folderpath);

            end

        end


        function saveSessionInfo(self,sessionInfo)

            sessionFile=fullfile(self.SessionLocation,self.TempFolderName,self.SessionInfoFileName);
            save(sessionFile,'sessionInfo');

        end


        function filepath=getGroundTruthFilePath(self)
            filepath=fullfile(self.SessionLocation,self.GroundTruthFileName);
        end


        function filepath=getLabelDataLocation(self)
            filepath=fullfile(self.SessionLocation,self.LabelDataFolderName);
        end

    end

    methods(Access=protected)


        function TF=isValidSessionFolder(self,folderName)

            TF=true;
            hasLabelDataFolder=isfolder(fullfile(folderName,self.LabelDataFolderName));
            hasGroundTruthObj=isfile(fullfile(folderName,self.GroundTruthFileName));

            if~hasLabelDataFolder||~hasGroundTruthObj
                TF=false;
            end

        end

    end

end
