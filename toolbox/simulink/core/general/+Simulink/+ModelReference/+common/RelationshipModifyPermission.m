classdef RelationshipModifyPermission<Simulink.ModelReference.common.Relationship






    methods
        function obj=RelationshipModifyPermission(~)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='modifyPermission';
            obj.NoRelationshipInPath=true;
            obj.SubDir={''};
            obj.DirName='info';
        end

        function populate(obj,~)

            file='modifyPermission.xml';
            fid=fopen(file,'w');
            fprintf(fid,'%s\n','<?xml version="1.0" encoding="UTF-8" standalone="yes" ?><modifyPermission/>');
            fclose(fid);
            obj.FileList={file};
        end
    end

    methods(Static)
        function out=getEncryptionCategory()
            out='MODIFY';
        end


        function out=getRelationshipYear()
            out='2018';
        end

    end
end


