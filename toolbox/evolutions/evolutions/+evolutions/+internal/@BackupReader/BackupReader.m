classdef BackupReader<handle




    properties
IdsInBackup
BackupFile
    end

    properties(Hidden,Access=private)
Model
    end

    methods(Access=private)
        function obj=BackupReader
            obj.Model=mf.zero.Model();
            evolutions.model.Backup(obj.Model);
            obj.initializeProps;
        end

        function update(obj,filename)
            obj.initializeProps;
            obj.BackupFile=filename;
            if isfile(filename)
                obj.getIdsFromFile;
            else

                evolutions.model.Backup(obj.Model);
            end
        end

        function initializeProps(obj)
            obj.IdsInBackup=containers.Map;
            obj.Model=mf.zero.Model();
            obj.BackupFile=string.empty;
        end

        function getIdsFromFile(obj)

            model=obj.Model;
            parser=mf.zero.io.XmlParser;
            parser.RemapUuids=false;
            parser.Model=model;
            bd=model.topLevelElements;
            parser.parseFile(obj.BackupFile);

            bd.destroy;
            backup=model.topLevelElements;
            idMap=backup.XmlToBakMap;

            keys=idMap.keys;
            for idx=1:numel(keys)
                obj.IdsInBackup(keys{idx})=idMap.at(keys{idx});
            end
        end

    end

    methods(Static,Access=private)
        function obj=get
            persistent localObj;
            if isempty(localObj)
                localObj=evolutions.internal.BackupReader;
            end
            obj=localObj;
        end
    end

    methods(Static)
        function updateIds(eti)
            obj=evolutions.internal.BackupReader.get;
            backupFile=evolutions.internal.BackupReader.getBackupPath(eti);
            obj.update(backupFile);
        end

        function clearIds
            obj=evolutions.internal.BackupReader.get;
            obj.initializeProps;
        end

        function ids=getCurrentIds
            obj=evolutions.internal.BackupReader.get;
            ids=obj.IdsInBackup;
        end

        function backupFile=getBackupFile(file)
            obj=evolutions.internal.BackupReader.get;
            ids=obj.IdsInBackup;
            if ids.isKey(file)
                backupFile=ids.at(file);
            else

                backupFile=file;
            end
        end

        function tf=hasBackup(file)


            obj=evolutions.internal.BackupReader.get;
            if ismember(file,obj.IdsInBackup.keys)
                tf=true;
            else
                tf=false;
            end
        end

        function addBackupFile(file,bakFile)

            obj=evolutions.internal.BackupReader.get;
            idMap=obj.Model.topLevelElements;

            idMap.XmlToBakMap.add(file,bakFile);

            evolutions.internal.BackupReader.save;
        end


        function save
            obj=evolutions.internal.BackupReader.get;
            serializer=mf.zero.io.XmlSerializer;
            serializer.serializeToFile(obj.Model,obj.BackupFile);
        end

        function tf=hasValidBackupXML(eti)


            backupFile=evolutions.internal.BackupReader.getBackupPath(eti);
            tf=isfile(backupFile);
        end

        function backupFile=getBackupPath(eti)
            backupFile=fullfile(eti.ArtifactRootFolder,...
            "Backup","backup.xml");
        end

        function clearBackup(eti)
            if evolutions.internal.BackupReader.hasValidBackupXML(eti)
                backupFile=evolutions.internal.BackupReader.getBackupPath(eti);
                delete(backupFile);
            end
        end
    end
end


