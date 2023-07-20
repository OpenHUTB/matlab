classdef(Sealed=true)ToolsInfo<realtime.Info






    properties(SetAccess='private')
        IncludePathDelimiter='';
        PreprocSymbolDelimiter='';
        RTIOStreamFileName='';
        RTIOStreamFilePath='';
        SetExtModeSettings='';
        PreBuildUtility='';
        BuildUtility='';
        PreDownloadUtility='';
        PreDownloadUtilityFlags='';
        PreDownloadFileExtension='';
        DownloadUtility='';
        DownloadUtilityFlags='';
        DownloadFileExtension='';
        PostDownloadUtility='';
        PostDownloadUtilityFlags='';
        PostDownloadFileExtension='';
        RunUtility='';
        RunUtilityFlags='';
        RunFileExtension='';
        RunOnEntry='';
        PostRunUtility='';
        ErrorHandling='';
        ExitUtility='';
        XMakefileTemplate='';
        XMakefileConfiguration='';
        XMakefileTemplateLocation='';
    end

    properties(Constant)
    end


    methods
        function h=ToolsInfo(filePathName,hardwareName,varargin)
            h.deserialize(filePathName,hardwareName,varargin);
        end

        function set(h,property,value)
            h.(property)=value;
        end
    end


    methods(Access='private')
    end
end
