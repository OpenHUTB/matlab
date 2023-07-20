




classdef RelationshipSystemComposerArchitecture<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipSystemComposerArchitecture(protectedModelCreator)

            assert(protectedModelCreator.HasSystemComposerInfo);
            obj@Simulink.ModelReference.common.Relationship();

            obj.RelationshipName='architecture';
            obj.DirName='systemcomposer';
            obj.SubDir={''};
            obj.NoRelationshipInPath=true;
        end


        function populate(obj,creator)
            modelName=creator.getModelName();


            zcProtModelStr=get_param(modelName,'SerializedProtectedModelString');
            assert(~isempty(zcProtModelStr));
            zcArchFile='architecture.xml';
            fid=fopen(zcArchFile,'w');
            fwrite(fid,zcProtModelStr);
            fclose(fid);

            obj.FileList={zcArchFile};

        end
    end

    methods(Static)
        function out=getEncryptionCategory()
            out='NONE';
        end


        function out=getRelationshipYear()
            out='2020';
        end

    end
end

