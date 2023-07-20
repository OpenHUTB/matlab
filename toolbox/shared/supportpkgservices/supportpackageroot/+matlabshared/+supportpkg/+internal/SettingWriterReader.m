classdef SettingWriterReader<handle





    properties(Access=protected)
SettingDir
    end

    properties(SetAccess=immutable)
SettingFileFullPath
    end

    properties(Access=protected,Constant)
        SETTING_FILE_NAME='supportpackagerootsetting.xml';
        DEFAULT_TOKEN='__DEFAULT__';
    end

    methods(Access=public)

        function obj=SettingWriterReader(settingDir)
            validateattributes(settingDir,{'char','string'},{'nonempty','scalartext'},'matlabshared.supportpkg.internal.SettingWriterReader','settingDir');
            assert(logical(exist(settingDir,'dir')),sprintf('Setting Directory does not exist: %s',settingDir));
            obj.SettingDir=settingDir;
            obj.SettingFileFullPath=fullfile(obj.SettingDir,obj.SETTING_FILE_NAME);
        end

        function writeRootSetting(obj,settingValue)



            validateattributes(settingValue,{'char','string'},{'nonempty','scalartext'},'matlabshared.supportpkg.internal.SettingWriterReader','settingValue');
            if~logical(exist(obj.SettingFileFullPath,'file'))
                try
                    obj.createDefaultSettingFile();
                catch ME
                    throw(ME);
                end
            end
            try
                currentSetting=obj.readRootSetting();
            catch

                currentSetting='';
            end


            if strcmp(currentSetting,settingValue)
                return;
            end

            obj.writeSettingXMLFile(settingValue);
            obj.pollForSettingFileWrite();
        end

        function settingValue=readRootSetting(obj)





            settingValue=matlabshared.supportpkg.internal.util.readSprootSettingFile(obj.SettingFileFullPath);
        end

        function writeSettingXMLFile(obj,spRoot)



            [status,~]=obj.writeSettingXMLFileImpl(spRoot);
            if status<0
                error(message('supportpkgservices:supportpackageroot:NoWritePermissions',spRoot));
            end
        end

        function[status,stdOut]=writeSettingXMLFileImpl(obj,spRoot)





            validateattributes(spRoot,{'char','string'},{'nonempty','scalartext'},'matlabshared.supportpkg.internal.SettingWriterReader','spRoot');
            writerExecutableJar=fullfile(matlabroot,'java','jar','toolbox','shared','supportpkgservices','sprootsettingwriter.jar');
            javaExe=['"',fullfile(matlabroot,'sys','java','jre',computer('arch'),'jre','bin','java'),'"'];
            cmd=[javaExe,' -jar ','"',writerExecutableJar,'" ','"',obj.SettingFileFullPath,'" ',spRoot];
            if ispc
                [status,stdOut]=system(cmd,'-runAsAdmin');
            else





                stdOut='';
                if logical(exist(obj.SettingFileFullPath,'file'))
                    [~,sFileAttrib,~]=fileattrib(obj.SettingFileFullPath);
                    isWriteable=sFileAttrib.UserWrite;
                    if~isWriteable



                        [isWriteable,stdOut,~]=fileattrib(obj.SettingFileFullPath,'+w','a');
                    end
                else


                    [~,sDirAttrib,~]=fileattrib(obj.SettingDir);
                    isWriteable=sDirAttrib.UserWrite;
                end





                if~isWriteable
                    status=-1;
                else
                    [status,stdOut]=system(cmd);
                end
            end
        end
    end

    methods(Access={?matlabshared.supportpkg.internal.SingleRootHandler,?MockSettingWriterReader})
        function createDefaultSettingFile(obj)


            obj.writeSettingXMLFile(matlabshared.supportpkg.internal.SettingWriterReader.DEFAULT_TOKEN)

            obj.pollForSettingFileWrite();
        end

        function pollForSettingFileWrite(obj)
            while(1)
                if logical(exist(obj.SettingFileFullPath,'file'))
                    break;
                end
            end
        end
    end

end