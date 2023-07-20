classdef SupportPackageRootHandler<handle









    properties(Access=protected)
SettingWriterReader
    end


    methods(Access=public,Abstract)
        out=getInstallRoot(obj)
        setInstallRoot(obj,directory)
    end

    methods(Access=public,Static)
        function instance=getHandler()

            writerReader=matlabshared.supportpkg.internal.SupportPackageRootHandler.createSettingWriterReader();
            instance=matlabshared.supportpkg.internal.SingleRootHandler(writerReader);
        end
    end

    methods(Hidden)

        function out=getWriterReader(obj)
            out=obj.SettingWriterReader;
        end
    end

    methods(Access=private,Static)
        function writerReader=createSettingWriterReader()







            overrideFcnStr=matlabshared.supportpkg.internal.SupportPackageRootHandler.getOverrideSettingWriterReader();
            if~isempty(overrideFcnStr)

                factoryFcnHandle=str2func(overrideFcnStr);
                writerReader=factoryFcnHandle();
            else







                sprootFileDir=matlabshared.supportpkg.internal.getSprootSettingFileLocation();
                writerReader=matlabshared.supportpkg.internal.SettingWriterReader(sprootFileDir);
            end
        end

    end

    methods(Static)

        function out=getOverrideSettingWriterReader()
            out=getenv('SUPPORTPACKAGE_INSTALLER_SPROOTSETTINGFILE_WRITERREADER');
        end

    end

    methods(Access=protected)
        function obj=SupportPackageRootHandler(writerReader)

            obj.SettingWriterReader=writerReader;
        end
    end

end