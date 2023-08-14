



classdef PluginPostCodeGen<downstream.plugin.PluginBase



    properties
        ProjectName='';
        ProjectFileName='';
        TclFileName='';


        rootModuleName='';
        createSmartDesign='';
        generateComp='';
        instantiateModule='';
        connectPinPort='';

        tclAddSourceFileBegin='';
        tclAddSourceFileForPre='';
        tclAddSourceFileForPost='';
        tclAddSourceFileEnd='';
        tclPostFileAdd='';
        tclSourceTop='';
        tclAddSimFileBegin='';
        tclAddSimFileForPre='';
        tclAddSimFileForPost='';
        tclAddSimFileEnd='';
        tclPostSimFileAdd='';
        tclSimTop='';
        tclExternalSimScriptGen='';
        tclExternalSimScriptsPostFix='';
        tclRemoveSourceFile='';
        tclSourceExtTclFileBegin='';
        tclAddSDCFile='';
        tclAddXDCFile='';
        tclAddInternalTclFile='';
        tclCoeDir='';
        tclCoeDirSetName='';
        tclCreateCoeDir='';

        tclCreateLibrary='';

        tclAddLibrarySpec='';

        cmd_captureError='';
        cmd_logRegExp='';
    end

    methods
        function parsePluginFile(obj,hToolDriver)
            hToolDriver.hTool.ProjectName=obj.ProjectName;
            hToolDriver.hTool.ProjectFileName=obj.ProjectFileName;
            hToolDriver.hEmitter.TclFileName=obj.TclFileName;

            hToolDriver.hEmitter.tclAddSourceFileBegin=obj.tclAddSourceFileBegin;
            hToolDriver.hEmitter.tclAddSourceFileForPre=obj.tclAddSourceFileForPre;
            hToolDriver.hEmitter.tclAddSourceFileForPost=obj.tclAddSourceFileForPost;
            hToolDriver.hEmitter.tclAddSourceFileEnd=obj.tclAddSourceFileEnd;
            hToolDriver.hEmitter.tclPostFileAdd=obj.tclPostFileAdd;
            hToolDriver.hEmitter.tclSourceTop=obj.tclSourceTop;

            hToolDriver.hEmitter.rootModuleName=obj.rootModuleName;
            hToolDriver.hEmitter.createSmartDesign=obj.createSmartDesign;
            hToolDriver.hEmitter.generateComp=obj.generateComp;
            hToolDriver.hEmitter.instantiateModule=obj.instantiateModule;
            hToolDriver.hEmitter.connectPinPort=obj.connectPinPort;

            hToolDriver.hEmitter.tclAddSimFileBegin=obj.tclAddSimFileBegin;
            hToolDriver.hEmitter.tclAddSimFileForPre=obj.tclAddSimFileForPre;
            hToolDriver.hEmitter.tclAddSimFileForPost=obj.tclAddSimFileForPost;
            hToolDriver.hEmitter.tclAddSimFileEnd=obj.tclAddSimFileEnd;
            hToolDriver.hEmitter.tclPostSimFileAdd=obj.tclPostSimFileAdd;
            hToolDriver.hEmitter.tclSimTop=obj.tclSimTop;
            hToolDriver.hEmitter.tclExternalSimScriptGen=obj.tclExternalSimScriptGen;
            hToolDriver.hEmitter.tclExternalSimScriptsPostFix=obj.tclExternalSimScriptsPostFix;
            hToolDriver.hEmitter.tclRemoveSourceFile=obj.tclRemoveSourceFile;
            hToolDriver.hEmitter.tclSourceExtTclFileBegin=obj.tclSourceExtTclFileBegin;
            hToolDriver.hEmitter.tclAddSDCFile=obj.tclAddSDCFile;
            hToolDriver.hEmitter.tclAddXDCFile=obj.tclAddXDCFile;
            hToolDriver.hEmitter.tclAddInternalTclFile=obj.tclAddInternalTclFile;
            hToolDriver.hEmitter.tclCoeDir=obj.tclCoeDir;
            hToolDriver.hEmitter.tclCoeDirSetName=obj.tclCoeDirSetName;
            hToolDriver.hEmitter.tclCreateCoeDir=obj.tclCreateCoeDir;
            hToolDriver.hEmitter.tclCreateLibrary=obj.tclCreateLibrary;
            hToolDriver.hEmitter.tclAddLibrarySpec=obj.tclAddLibrarySpec;

            hToolDriver.hTool.cmd_captureError=obj.cmd_captureError;
            hToolDriver.hTool.cmd_logRegExp=obj.cmd_logRegExp;
        end
    end

    methods(Static)
        function plugin=loadPluginFile(pluginPackage,hToolDriver)
            pluginName='plugin_postcodegen(hToolDriver)';
            cmdStr=sprintf('%s.%s',pluginPackage,pluginName);
            try
                plugin=eval(cmdStr);
            catch me
                error(message('hdlcommon:workflow:InvalidPluginFile',cmdStr));
            end
        end
    end
end
