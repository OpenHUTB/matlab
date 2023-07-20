classdef SwlCgSupport<simscape.engine.sli.shared.BaseCgSupport






    methods(Static)
        function[simulatorFcnName,simulatorFcnHeader,requiredLibraries]=support(hExecBlock)
            obj=simscape.engine.sli.swl.SwlCgSupport();
            [simulatorFcnName,simulatorFcnHeader,requiredLibraries]=obj.baseSupport(hExecBlock);
        end
    end

    methods
        function initDerivedProperties(self)
            mxParameter=get_param(self.hExecBlock,'MxParameter');
            self.mxParam=mxParameter.swlData;
            self.index=self.mxParam.graphInd;
        end

        function[fcnName,fcnHeader]=getFcnNameAndHeader(self)
            fcnName=sprintf('%s_%d_simulator',self.nameBase,self.index);
            fcnHeader=strcat(fcnName,'.h');
        end

        function flag=todoCg(self)
            flag=true;
        end

        function[createFcnName,moduleName]=setupCreateFcnNameAndModuleName(self)
            localName=sprintf('%s_%d',self.nameBase,self.index);
            createFcnName=localName;
            moduleName=localName;
        end

        function cgResults=generate(self,cgParams)
            cgResults=self.mxParam.generate(cgParams);
        end

        function[srcFile,hdrFile]=generateGatewayFiles(...
            self,...
            buildDirectory,...
            simulatorFcnName,...
            slsFcnName,...
            slsHeader,...
            varargin)

            srcFile=fullfile(buildDirectory,strcat(simulatorFcnName,'.c'));
            hdrFile=fullfile(buildDirectory,strcat(simulatorFcnName,'.h'));

            solverParams='solverparams';
            modelParams='modelparams';
            solverModelParams='spMp';

            la_sparse_full=sprintf('(%s.mLinearAlgebra == NE_FULL_LA) ? %s : %s',...
            solverParams,...
            'get_rtw_linear_algebra()',...
            'mc_get_csparse_linear_algebra()');

            linalg=sprintf('(%s.mLinearAlgebra == NE_AUTO_LA) ? %s : (%s)',...
            solverParams,...
            'get_auto_linear_algebra()',...
            la_sparse_full);




            src={};
            src{end+1}=sprintf('#ifdef MATLAB_MEX_FILE\n');
            src{end+1}=sprintf('#include "tmwtypes.h"\n');
            src{end+1}=sprintf('#else\n');
            src{end+1}=sprintf('#include "rtwtypes.h"\n');
            src{end+1}=sprintf('#endif\n');
            src{end+1}=self.includeHeader('nesl_rtw_swl.h');
            src{end+1}=self.includeHeader(slsHeader);
            src{end+1}=self.includeHeader(strcat(simulatorFcnName,'.h'));

            src{end+1}=self.declareVariable('static Simulator *','out','NULL');
            src{end+1}=sprintf('Simulator *%s(void)',[simulatorFcnName,'_create']);
            src{end+1}='{';
            src{end+1}=sprintf('if (out == NULL) {\n');
            src{end+1}=self.declareVariable('NeSolverParameters',solverParams,self.struct2Str(self.mxParam.solverParameters));
            src{end+1}=self.declareVariable('NeModelParameters',modelParams,self.struct2Str(self.mxParam.modelParameters));
            src{end+1}=self.declareVariable('NeSolverParameters *',sprintf('%s[2]',solverModelParams));
            src{end+1}=sprintf('spMp[0] = &%s;\n',solverParams);
            src{end+1}=sprintf('spMp[1] = (NeSolverParameters *) &%s;\n',modelParams);
            src{end+1}='{';
            src{end+1}=self.declareVariable('SwitchedLinearSystem *','sls',...
            sprintf('%s((PmAllocator *) %s)',slsFcnName,solverModelParams));
            src{end+1}=sprintf('out = simulator_create(sls, %s, %s, NULL, NULL, 0, DAEMON_CHOICE_NONE);\n',solverParams,linalg);
            src{end+1}='}';
            src{end+1}='}';
            src{end+1}=sprintf('return out;\n');
            src{end+1}='}';

            src{end+1}=sprintf('void %s(void)\n',[simulatorFcnName,'_destroy']);
            src{end+1}='{';
            src{end+1}=sprintf('if (out != NULL) {\n');
            src{end+1}=sprintf('out->mDestroy(out);\n');
            src{end+1}=sprintf('out = NULL;\n');
            src{end+1}='}';
            src{end+1}='}';

            fid=fopen(srcFile,'w');
            fprintf(fid,'%s',self.strCat(src{:}));
            fclose(fid);




            hdr={};
            hdr{end+1}=self.includeProtectionEnter(simulatorFcnName);
            hdr{end+1}=self.includeHeader('nesl_rtw_swl.h');
            hdr{end+1}=self.cppProtectionEnter();
            hdr{end+1}=sprintf('extern Simulator *%s(void);\n',[simulatorFcnName,'_create']);
            hdr{end+1}=sprintf('extern void %s(void);\n',[simulatorFcnName,'_destroy']);
            hdr{end+1}=self.cppProtectionExit();
            hdr{end+1}=self.includeProtectionExit(simulatorFcnName);

            fid=fopen(hdrFile,'w');
            fprintf(fid,'%s',self.strCat(hdr{:}));
            fclose(fid);
        end
    end
end
