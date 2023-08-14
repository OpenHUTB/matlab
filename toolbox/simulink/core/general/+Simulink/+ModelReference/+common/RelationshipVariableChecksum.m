




classdef RelationshipVariableChecksum<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipVariableChecksum(~)


            obj.RelationshipName='checksumMismatch';

            obj.NoRelationshipInPath=true;
            obj.SubDir={'versioning','versioning'};
            obj.DirName='info/versioning';

        end


        function populate(obj,creator)

            dataDictionaryFile=creator.getDataDictionaryNameToKeepVariables();
            Simulink.data.dictionary.create(dataDictionaryFile);

            mapFile=creator.getMapFileNameToKeepVariables();
            fid=fopen(mapFile,'wt');
            fclose(fid);

            obj.FileList={dataDictionaryFile,mapFile};

        end

    end
    methods(Static)


        function out=getEncryptionCategory()
            out='SIM';
        end


        function out=getRelationshipYear()
            out='2020';
        end

    end
end









