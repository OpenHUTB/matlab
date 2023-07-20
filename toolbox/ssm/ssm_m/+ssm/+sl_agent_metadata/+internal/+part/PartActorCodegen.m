classdef PartActorCodegen<ssm.sl_agent_metadata.internal.part.Part




    properties
        ModelName(1,:)char=''
        BuildFolder(1,:)char=''
    end

    methods
        function obj=PartActorCodegen()
            obj@ssm.sl_agent_metadata.internal.part.Part('binary')
        end

        function populateFileList(obj)
            if isempty(obj.ModelName);return;end


            libext=['.',coder.make.internal.getLibExtension()];
            RelativeBuildDir=fullfile(obj.ModelName,'slprj','raccel_deploy',obj.ModelName);
            srcDir=fullfile(obj.BuildFolder,RelativeBuildDir);
            tgtDir=fullfile(computer,RelativeBuildDir);

            if ispc

                patternName=fullfile(srcDir,'*.obj');
            else

                patternName=fullfile(srcDir,'*.o');
            end
            obj.addPartUsingFilePattern(patternName,tgtDir);


            if ispc
                patternName=fullfile(srcDir,[obj.ModelName,'.exe']);
            else
                patternName=fullfile(srcDir,obj.ModelName);
            end
            obj.addPartUsingFilePattern(patternName,tgtDir);


            patternName=fullfile(srcDir,'*.mat');
            obj.addPartUsingFilePattern(patternName,tgtDir);


            patternName=fullfile(srcDir,[obj.ModelName,'lib',libext]);
            obj.addPartUsingFilePattern(patternName,tgtDir);


            patternName=fullfile(srcDir,'*.m');
            obj.addPartUsingFilePattern(patternName,tgtDir);


            patternName=fullfile(srcDir,'tmwinternal','*.mat');
            obj.addPartUsingFilePattern(patternName,fullfile(tgtDir,'tmwinternal'));

            patternName=fullfile(srcDir,'tmwinternal','*.xml');
            obj.addPartUsingFilePattern(patternName,fullfile(tgtDir,'tmwinternal'));
        end

        function populateInformation(~)

        end

    end
end


