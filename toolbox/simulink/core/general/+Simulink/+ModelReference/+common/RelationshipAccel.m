




classdef RelationshipAccel<Simulink.ModelReference.common.Relationship

    methods
        function obj=RelationshipAccel(~)

            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='sim';
            obj.DirName='accel';
        end


        function populate(obj,creator)


            libext=['.',coder.make.internal.getLibExtension()];


            listOfModelsWithBuildDirInfo=creator.getListOfOrderedSubModels();



            lSystemTargetFile=get_param(creator.ModelName,'SystemTargetFile');

            for i=1:length(listOfModelsWithBuildDirInfo)
                [~,currentModel,~]=fileparts(listOfModelsWithBuildDirInfo(i).name);

                buildDirs=listOfModelsWithBuildDirInfo(i).buildDir;



                patternName=fullfile(buildDirs.ModelRefRelativeSimDir,'*.h');
                obj.addPartUsingFilePattern(patternName,buildDirs.ModelRefRelativeSimDir,...
                {[currentModel,'_private.h'],...
                [currentModel,'_capi.h']});

                if ispc

                    patternName=fullfile(buildDirs.ModelRefRelativeSimDir,'*_capi_host.obj');
                else

                    patternName=fullfile(buildDirs.ModelRefRelativeSimDir,'*_capi_host.o');
                end
                obj.addPartUsingFilePattern(patternName,buildDirs.ModelRefRelativeSimDir);


                patternName=fullfile(buildDirs.ModelRefRelativeSimDir,'buildInfo.mat');
                obj.updateBuildInfo(patternName);
                obj.addPartUsingFilePattern(patternName,buildDirs.ModelRefRelativeSimDir);


                fileName=[currentModel,coder.internal.modelreference.MdlInitializeSizesWriter.JacobianDataFileSuffix];
                patternName=fullfile(buildDirs.ModelRefRelativeSimDir,fileName);
                if~isempty(dir(patternName))
                    obj.addPartUsingFilePattern(patternName,buildDirs.ModelRefRelativeSimDir);
                end


                patternName=fullfile(buildDirs.ModelRefRelativeSimDir,[currentModel,'lib',libext]);
                obj.addPartUsingFilePattern(patternName,buildDirs.ModelRefRelativeSimDir);


                patternName=fullfile(buildDirs.ModelRefRelativeSimDir,'*.rsp');
                obj.addPartUsingFilePattern(patternName,buildDirs.ModelRefRelativeSimDir);


                patternName=fullfile(buildDirs.ModelRefRelativeSimDir,'tmwinternal','binfo_mdlref.mat');
                obj.updateBInfo(patternName);
                obj.addPartUsingFilePattern(patternName,fullfile(buildDirs.ModelRefRelativeSimDir,'tmwinternal'));

                patternName=fullfile(buildDirs.ModelRefRelativeSimDir,'tmwinternal','minfo_mdlref.mat');
                obj.addPartUsingFilePattern(patternName,fullfile(buildDirs.ModelRefRelativeSimDir,'tmwinternal'));
            end
        end
    end
    methods(Static)
        function out=getEncryptionCategory()
            out='SIM';
        end


        function out=getRelationshipYear()
            out='2012';
        end

    end
end


