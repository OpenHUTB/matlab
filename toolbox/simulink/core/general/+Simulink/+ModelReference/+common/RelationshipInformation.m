




classdef RelationshipInformation<Simulink.ModelReference.common.Relationship

    methods

        function obj=RelationshipInformation(~)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='extraInformation';
            obj.NoRelationshipInPath=true;
            obj.SubDir={''};
            obj.DirName='info';
        end


        function populate(obj,creator)

            gi=creator.getExtraInformation();%#ok<NASGU>

            eifile='extraInformation.mat';
            save(eifile,'gi');

            obj.FileList={eifile};
        end

        function out=getPurpose(~)
            out='extraInfo';
        end
    end

    methods(Static)
        function out=getEncryptionCategory()
            out='NONE';
        end


        function out=getRelationshipYear()
            out='2012';
        end

    end
end

