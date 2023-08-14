classdef(Hidden=true)StandardChecksBuildManager<coder.assumptions.CheckBuildManager








    methods(Access=public)

        function addToLibrary(this,aBuildInfo,~,~)

            xilSrcPath=rtw.pil.RtIOStreamApplicationFramework.getXILSrcPath;
            staticCASrcs=coder.assumptions.CoderAssumptions.getLibraryStaticSources;
            staticCASrcsPath=repmat({xilSrcPath},size(staticCASrcs));
            modelCASrcs={coder.assumptions.CoderAssumptions.getSourceFileName(this.ComponentName)};
            modelCASrcsPath={this.CAPath};
            aBuildInfo.addSourceFiles([staticCASrcs,modelCASrcs],...
            [staticCASrcsPath,modelCASrcsPath]);


            staticCAIncls=coder.assumptions.CoderAssumptions.getLibraryStaticHeaders;
            staticCAInclsPath=repmat({xilSrcPath},size(staticCAIncls));
            modelCAIncls=[...
            {coder.assumptions.CoderAssumptions.getHeaderFileName(this.ComponentName)},...
            {coder.assumptions.CoderAssumptions.getPreprocessorHeaderFileName(this.ComponentName)},...
            {coder.assumptions.CoderAssumptions.getEntryPointHeaderFileName}];
            modelCAInclsPath=repmat({this.CAPath},size(modelCAIncls));
            aBuildInfo.addIncludeFiles([staticCAIncls,modelCAIncls],...
            [staticCAInclsPath,modelCAInclsPath]);


            longLongMode=this.ConfigInterface.getParam('TargetLongLongMode');
            checkLongLong=strcmp(longLongMode,'on');
            caCheckLongLongDefineName='CA_CHECK_LONG_LONG_ENABLED';
            aBuildInfo.addDefines(sprintf('%s=%d',caCheckLongLongDefineName,checkLongLong),'OPTS');


            dynamicMemoryMode=this.ConfigInterface.getParam('GenerateAllocFcn');
            checkDynamicMemory=strcmp(dynamicMemoryMode,'on');
            caCheckDynamicMemoryDefineName='CA_CHECK_DYNAMIC_MEMORY';
            aBuildInfo.addDefines(sprintf('%s=%d',caCheckDynamicMemoryDefineName,checkDynamicMemory),'OPTS');

        end
    end

end
