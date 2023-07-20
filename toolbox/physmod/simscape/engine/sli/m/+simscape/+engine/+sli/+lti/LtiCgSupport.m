classdef LtiCgSupport<simscape.engine.sli.shared.BaseCgSupport









    properties(Access=private)
        mModel;
    end

    methods(Static)

        function[icFcnName,buildDirectory]=setupIcFiles(hExecBlock)
            obj=simscape.engine.sli.lti.LtiCgSupport();
            icFcnName=obj.baseSupport(hExecBlock);

            Simulink.output.info(message('physmod:simscape:engine:sli:cg:GenerateCodeStart',obj.solverBlockPath).string);

            buildDirectory='';
            rtwSettings=get_param(obj.mModel,'RTWGenSettings');
            if isstruct(rtwSettings)&&~isempty(rtwSettings.RelativeBuildDir)
                buildDirectory=fullfile(pwd,rtwSettings.RelativeBuildDir);
            end
            pm_assert(...
            exist(buildDirectory,'dir'),...
            'Cannot generate code for Physical Networks: Build directory does not exist');
        end

        function finalizeIcFiles(hExecBlock,icGeneratedFiles)
            obj=simscape.engine.sli.lti.LtiCgSupport();
            obj.initBaseProperties(hExecBlock);
            obj.initDerivedProperties();




            hfiles=icGeneratedFiles(endsWith(icGeneratedFiles,'.h'));
            pre={};
            pre{end+1}=sprintf('#ifdef MATLAB_MEX_FILE\n');
            pre{end+1}=sprintf('#include "tmwtypes.h"\n');
            pre{end+1}=sprintf('#else\n');
            pre{end+1}=sprintf('#include "rtwtypes.h"\n');
            pre{end+1}=sprintf('#endif\n');
            pre{end+1}=sprintf('#include <string.h>\n');
            pre{end+1}=obj.cppProtectionEnter();
            post={};
            post{end+1}=obj.cppProtectionExit();

            for idx=1:length(hfiles)
                file=hfiles{idx};

                fid=fopen(file,'r');
                pm_assert(fid~=1,'no source file found');
                C=fread(fid,'char=>char');
                fclose(fid);

                fid=fopen(file,'w');
                fprintf(fid,'%s',obj.strCat(pre{:}));
                fprintf(fid,'%s',C);
                fprintf(fid,'%s',obj.strCat(post{:}));
                fclose(fid);
            end


            obj.postprocess(icGeneratedFiles);


            cfiles=icGeneratedFiles(endsWith(icGeneratedFiles,'.c'));
            [fpaths,fnames,fexts]=fileparts(cfiles);
            sourceFilePaths=fpaths;
            sourceFiles=strcat(fnames,fexts);
            modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(obj.mModel);
            if~isempty(modelCodegenMgr)
                buildInfo=modelCodegenMgr.BuildInfo;
                if~isempty(sourceFiles)
                    buildInfo.addSourceFiles(sourceFiles,sourceFilePaths,'BlockModules');
                end
            end

            Simulink.output.info(message('physmod:simscape:engine:sli:cg:GenerateCodeEnd').string);
        end
    end

    methods
        function initDerivedProperties(self)
            self.mxParam=get_param(self.hExecBlock,'MxParameter');
            self.index=self.mxParam.graphInd;
            self.mModel=pmsl_bdroot(self.hExecBlock);
        end

        function[fcnName,ignore]=getFcnNameAndHeader(self)
            fcnName=sprintf('%s_%d_ic_fcn',self.nameBase,self.index);
            ignore='';
        end

        function flag=todoCg(varargin)
            flag=false;
        end


        function setupCreateFcnNameAndModuleName(varargin)
            assert(false);
        end

        function generate(varargin)
            assert(false)
        end

        function generateGatewayFiles(varargin)
            assert(false)
        end
    end
end
