




classdef Summary<rtw.report.Summary
    properties(Transient)
        ProtectedMdl=[];
    end
    methods
        function obj=Summary(model)
            obj=obj@rtw.report.Summary(model);
        end
        function out=getTitle(obj)
            out=DAStudio.message('Simulink:protectedModel:ProtectedMdlRptTitle',obj.ModelName);
        end
    end
    methods
        function execute(obj)

            obj.AddSectionNumber=false;
            obj.AddSectionShrinkButton=false;
            obj.AddSectionToToc=false;

            pEnvInfo=Advisor.Paragraph;
            data=obj.getSummary;
            table=Advisor.Table(size(data,1),size(data,2));
            table.setStyle('AltRow');
            table.setEntries(obj.getSummary);
            pEnvInfo.addItem(table);
            obj.getConfigSetLink(pEnvInfo);

            obj.addSection('sec_environment',DAStudio.message('RTW:report:EnvironmentShortTitle'),...
            DAStudio.message('RTW:report:ProtectedModelSummary',obj.ModelName),...
            pEnvInfo);

            pSuppFunc=Advisor.Paragraph;


            dataContents=obj.getContents;
            tableContents=Advisor.Table(size(dataContents,1),size(dataContents,2));
            tableContents.setStyle('AltRow');
            tableContents.setEntries(obj.getContents);
            pSuppFunc.addItem(tableContents);

            obj.addSection('sec_supported_functionality',DAStudio.message('RTW:report:SupportedFunctionalityShortTitle'),...
            DAStudio.message('RTW:report:ProtectedModelSupportedFunctionality',obj.ModelName),...
            pSuppFunc);
        end
    end
    methods(Access=private)

        function getConfigSetLink(obj,p)
            configSetMatFileName=fullfile('..','cs.mat');
            table=Advisor.Table(1,1);
            table.setBorder(0);
            table.setAttribute('cellpadding','0');

            aHref_CS=Advisor.Element;
            aText=Advisor.Text;


            aHref_CS.setTag('a');
            aHref_CS.setAttribute('href',[configSetMatFileName,'?',obj.ModelName]);
            aHref_CS.setAttribute('id','linkToCS');
            link_txt='click to open';
            aHref_CS.setContent(link_txt);

            aHiddenLink_CS=Advisor.Element;
            aHiddenLink_CS.setTag('span');
            aHiddenLink_CS.setAttribute('style','display:none');
            aHiddenLink_CS.setAttribute('id','linkToCS_disabled');
            aHiddenLink_CS.setAttribute('title',DAStudio.message('RTW:report:SummaryLinkUnavailable'));
            aHiddenLink_CS.setContent(link_txt);

            aText.setContent([DAStudio.message('RTW:report:SummaryConfigSetLinkLabelProtectedModel')...
            ,aHref_CS.emitHTML,aHiddenLink_CS.emitHTML]);
            table.setEntry(1,1,aText.emitHTML);

            p.addItem(table);
        end
        function out=getBuildInfoFile(obj)
            fpath=obj.ProtectedMdl.getTgtDir();
            buildDirs=obj.ProtectedMdl.getBuildDir(obj.ProtectedMdl.ModelName);
            if obj.ProtectedMdl.supportsCodeGen()
                switch(obj.ProtectedMdl.currentMode)
                case 'SIM'
                    out=fullfile(fpath,buildDirs.ModelRefRelativeRootSimDir,obj.ProtectedMdl.ModelName,'buildInfo.mat');
                case 'RTW'
                    out=fullfile(fpath,buildDirs.ModelRefRelativeRootTgtDir,obj.ProtectedMdl.ModelName,'buildInfo.mat');
                case 'NONE'
                    out=fullfile(fpath,buildDirs.RelativeBuildDir,'buildInfo.mat');
                otherwise
                    assert(false,'Unexpected obj.ProtectedMdl.currentMode value: "%s"',obj.ProtectedMdl.currentMode);
                end
            end
        end
        function out=getSummary(obj)


            simulinkVersionStruct=ver('simulink');
            out={DAStudio.message('RTW:report:ModelVersion'),...
            obj.ModelVersion;
            DAStudio.message('RTW:report:SimulinkVersion'),...
            simulinkVersionStruct.Version;
            DAStudio.message('RTW:report:SimulinkCoderVersion'),...
            obj.CoderVersion;};

            if obj.ProtectedMdl.getSupportsHDL
                hdlcoderVersionStruct=ver('hdlcoder');
                out=[out;{DAStudio.message('RTW:report:HDLCoderVersion'),hdlcoderVersionStruct.Version}];
            end

            out=[out;...
            {DAStudio.message('RTW:report:ProtectedModelSourceCodeGeneratedOn'),...
            obj.TimeStamp};...
            {DAStudio.message('RTW:report:Architecture'),...
            computer('arch')}];
        end

        function out=getContents(obj)

            if obj.ProtectedMdl.ObfuscateCode
                ofc=DAStudio.message('RTW:report:on');
            else
                ofc=DAStudio.message('RTW:report:off');
            end

            if obj.ProtectedMdl.concurrentTasking
                concurrentTasking=DAStudio.message('RTW:report:on');
            else
                concurrentTasking=DAStudio.message('RTW:report:off');
            end


            if~obj.ProtectedMdl.isViewOnly()
                if obj.ProtectedMdl.Encrypt&&~isempty(Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(obj.ProtectedMdl.ModelName,'SIM'))
                    addSimSupport=DAStudio.message('RTW:report:onwithpassword');
                else
                    addSimSupport=DAStudio.message('RTW:report:on');
                end

            else
                addSimSupport=DAStudio.message('RTW:report:off');
            end


            if obj.ProtectedMdl.supportsView()
                if obj.ProtectedMdl.Encrypt&&~isempty(Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(obj.ProtectedMdl.ModelName,'VIEW'))
                    addViewSupport=DAStudio.message('RTW:report:onwithpassword');
                else
                    addViewSupport=DAStudio.message('RTW:report:on');
                end
            else
                addViewSupport=DAStudio.message('RTW:report:off');
            end


            if obj.ProtectedMdl.supportsCodeGen()&&obj.ProtectedMdl.getSupportsC()
                if obj.ProtectedMdl.Encrypt&&~isempty(Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(obj.ProtectedMdl.ModelName,'RTW'))
                    addCodeGenSupport=DAStudio.message('RTW:report:onwithpassword');
                else
                    addCodeGenSupport=DAStudio.message('RTW:report:on');
                end
            else
                addCodeGenSupport=DAStudio.message('RTW:report:off');
            end


            if obj.ProtectedMdl.supportsHDLCodeGen()
                if obj.ProtectedMdl.Encrypt&&~isempty(Simulink.ModelReference.ProtectedModel.PasswordManager.getPasswordForEncryptionCategory(obj.ProtectedMdl.ModelName,'HDL'))
                    addHDLCodeGenSupport=DAStudio.message('RTW:report:onwithpassword');
                else
                    addHDLCodeGenSupport=DAStudio.message('RTW:report:on');
                end
            else
                addHDLCodeGenSupport=DAStudio.message('RTW:report:off');
            end

            out={DAStudio.message('Simulink:protectedModel:ProtectedModelReportView'),...
            addViewSupport;
            DAStudio.message('Simulink:protectedModel:ProtectedModelReportSim'),...
            addSimSupport;
            DAStudio.message('Simulink:protectedModel:ProtectedModelReportCodeGen'),...
            addCodeGenSupport;
            DAStudio.message('Simulink:protectedModel:ProtectedModelReportHDLCodeGen'),...
            addHDLCodeGenSupport;};

            out=[out;
            {DAStudio.message('Simulink:protectedModel:concurrentTaskingSupport'),...
            concurrentTasking};];



            if obj.ProtectedMdl.supportsCodeGen()&&obj.ProtectedMdl.getSupportsC()


                out=[out;
                {DAStudio.message('Simulink:protectedModel:ProtectedModelReportCodeInterface'),...
                obj.ProtectedMdl.CodeInterface};];

                if obj.ProtectedMdl.BinariesAndHeadersOnly
                    gencodecontent=DAStudio.message('Simulink:protectedModel:ProtectedModelContentsBinaries');
                else
                    if obj.ProtectedMdl.ObfuscateCode
                        gencodecontent=DAStudio.message('Simulink:protectedModel:ProtectedModelContentsObfuscatedSourceCode');
                    else
                        gencodecontent=DAStudio.message('Simulink:protectedModel:ProtectedModelContentsSourceCode');
                    end
                end




                if strcmp(obj.ProtectedMdl.currentMode,'SIM')


                    target=strjoin(obj.ProtectedMdl.getSupportedTargets(),',');
                else


                    target=obj.ProtectedMdl.Target;
                end

                out=[out;
                {DAStudio.message('Simulink:protectedModel:ProtectedModelTarget'),...
                target};
                {DAStudio.message('Simulink:protectedModel:ProtectedModelObfuscate'),...
                ofc};
                {DAStudio.message('Simulink:protectedModel:ProtectedModelCodeContent'),...
                gencodecontent};];
            end

            if obj.ProtectedMdl.packageSourceCode()&&any(strcmp(obj.ProtectedMdl.currentMode,{'NONE','RTW'}))
                fullFileName=obj.getBuildInfoFile();



                varList=whos('-file',fullFileName);
                assert(~isempty(varList),'BuildInfo is unexpectedly empty');
                varListNames={varList(:).name};
                assert(~isempty(intersect(varListNames,'buildInfo')));



                bi=load(fullFileName);
                [lToolchainInfo,lTMFProperties]=...
                coder.make.internal.resolveToolchainOrTMF(bi.buildOpts.BuildMethod);
                if~isempty(lTMFProperties)
                    [~,fname,fext]=fileparts(lTMFProperties.TemplateMakefile);
                    out=[out;
                    {DAStudio.message('RTW:report:ProtectedModelReportTMF'),...
                    [fname,fext]}];
                else

                    tcName=lToolchainInfo.Name;
                    out=[out;
                    {DAStudio.message('RTW:report:ProtectedModelReportToolchain'),...
                    tcName}];
                end
            end
        end
    end
end


