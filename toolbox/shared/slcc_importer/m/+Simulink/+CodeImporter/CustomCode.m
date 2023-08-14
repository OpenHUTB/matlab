
















classdef CustomCode<handle

    properties(Hidden,SetAccess=protected)
        RootFolder(1,1)string='';
    end

    properties












        SourceFiles(1,:)string










        InterfaceHeaders(1,:)string










        IncludePaths(1,:)string











        Libraries(1,:)string









        Defines(1,:)string









        Language string="C";








        CompilerFlags(1,:)string








        LinkerFlags(1,:)string









        GlobalVariableInterface(1,1)logical=false;








        FunctionArrayLayout(1,1)internal.CodeImporter.FunctionArrayLayout=internal.CodeImporter.FunctionArrayLayout.NotSpecified;
    end

    properties(Hidden,SetAccess=protected)
        settingsChecksum(1,1)string
        interfaceChecksum(1,1)string
        fullChecksum(1,1)string
    end

    properties(Hidden)
        customCodeSettings(1,1)CGXE.CustomCode.CustomCodeSettings;
        ccInfo=[];
        MetadataFile(1,1)string="";
    end


    methods
        function obj=CustomCode()
            obj.customCodeSettings=CGXE.CustomCode.CustomCodeSettings;
        end
    end


    methods
        function res=get.RootFolder(obj)
            assert(~isempty(obj.RootFolder.char));
            res=obj.RootFolder;
        end
    end


    methods
        function set.SourceFiles(obj,srcs)
            srcs=strip(srcs);
            obj.SourceFiles=srcs;
        end

        function set.InterfaceHeaders(obj,srcs)
            srcs=strip(srcs);
            obj.InterfaceHeaders=srcs;
        end

        function set.IncludePaths(obj,srcs)
            srcs=strip(srcs);
            obj.IncludePaths=srcs;
        end

        function set.Defines(obj,srcs)
            srcs=strip(srcs);
            obj.Defines=srcs;
        end

        function set.CompilerFlags(obj,srcs)
            srcs=strip(srcs);
            obj.CompilerFlags=srcs;
        end

        function set.LinkerFlags(obj,srcs)
            srcs=strip(srcs);
            obj.LinkerFlags=srcs;
        end

        function set.Language(obj,lang)
            validStrings=["C","C++"];
            obj.Language=validatestring(lang,validStrings);
        end

        function set.MetadataFile(obj,metadataFile)
            srcs=strip(metadataFile);
            [~,~,ext]=fileparts(srcs);
            if srcs~=""&&~strcmpi(ext,".mat")&&~strcmpi(ext,".a2l")&&...
                ~strcmpi(ext,".grl")
                errmsg=MException(message('Simulink:CodeImporter:MetadataFileNotCompatible'));
                throw(errmsg);
            end
            obj.MetadataFile=srcs;
        end

    end

    methods(Hidden)
        function updateRootFolder(obj,src)
            obj.RootFolder=src;
        end





        function computeCustomCodeSettings(obj)

            allInterfaceHeaders=obj.InterfaceHeaders(obj.InterfaceHeaders~="");
            allIncludeStr=sprintf('#include "%s"\n',allInterfaceHeaders);
            allSrcsRelative=internal.CodeImporter.Tools.convertToRelativePath(obj.SourceFiles,obj.RootFolder);
            allSrcsStr=sprintf('%s\n',allSrcsRelative{:});
            allIncludeRelativePath=internal.CodeImporter.Tools.convertToRelativePath(obj.IncludePaths,obj.RootFolder);
            allIncludePathStr=sprintf('%s\n',allIncludeRelativePath{:});
            allDefines=sprintf('%s\n',obj.Defines{:});
            allLibraries=sprintf('%s\n',obj.Libraries{:});
            allCompilerFlags=sprintf('%s\n',obj.CompilerFlags{:});
            allLinkerFlags=sprintf('%s\n',obj.LinkerFlags{:});


            obj.customCodeSettings.customCode=allIncludeStr;
            obj.customCodeSettings.userSources=allSrcsStr;
            obj.customCodeSettings.userIncludeDirs=allIncludePathStr;
            obj.customCodeSettings.customUserDefines=allDefines;
            obj.customCodeSettings.userLibraries=allLibraries;
            obj.customCodeSettings.customCompilerFlags=allCompilerFlags;
            obj.customCodeSettings.customLinkerFlags=allLinkerFlags;
        end

        function computeCCInfo(obj)
            obj.computeCustomCodeSettings();
            ccSettings=obj.customCodeSettings;
            lang=obj.Language;
            modelName='';
            obj.ccInfo=cgxeprivate('getCCInfoBase',ccSettings,lang,modelName);
            projRootDir=obj.RootFolder.char;
            obj.ccInfo=cgxeprivate('tokenizeCCInfo',obj.ccInfo,modelName,projRootDir);
        end

        function[settingsChecksum,interfaceChecksum,fullChecksum]=computeChecksum(obj)
            obj.computeCCInfo();
            [settingsChecksum,interfaceChecksum,fullChecksum,~]=cgxeprivate('computeCCChecksumfromCCInfo',obj.ccInfo);
        end

        function updateChecksum(obj,settingsChecksum,interfaceChecksum,fullChecksum)
            obj.settingsChecksum=settingsChecksum;
            obj.interfaceChecksum=interfaceChecksum;
            obj.fullChecksum=fullChecksum;
        end
    end

end