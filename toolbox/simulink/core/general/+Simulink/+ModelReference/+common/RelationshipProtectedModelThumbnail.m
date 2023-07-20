



classdef RelationshipProtectedModelThumbnail<Simulink.ModelReference.common.Relationship



    properties
    end

    methods

        function obj=RelationshipProtectedModelThumbnail(~)


            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='thumbnail';
            obj.DirName='thumbnail';
        end


        function populate(obj,~)

            thumbnailDir=fullfile('slprj','thumbnail');
            thumbnailPart=fullfile(thumbnailDir,'*.png');
            obj.addPartUsingFilePattern(thumbnailPart,'thumbnail');
        end
    end

    methods(Static)
        function out=getEncryptionCategory()
            out='NONE';
        end


        function out=getRelationshipYear()
            out='2013';
        end

    end
end