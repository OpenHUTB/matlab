classdef DaeCgSupport<simscape.engine.sli.shared.BaseCgSupport






    methods(Static)
        function[gatewayFcnName,gatewayFcnHeader,requiredLibraries]=support(hExecBlock,regKey)
            obj=simscape.engine.sli.dae.DaeCgSupport();
            [gatewayFcnName,gatewayFcnHeader,requiredLibraries]=obj.baseSupport(hExecBlock,regKey);
        end
    end

    methods
        function initDerivedProperties(self)
            self.mxParam=get_param(self.hExecBlock,'MxParameters');

            execBlockName=get_param(self.hExecBlock,'Name');
            tok=regexp(execBlockName,'OUTPUT_(?<idx>\d+)|STATE_(?<idx>\d+)','names');
            self.index=tok.idx;
        end

        function[fcnName,fcnHeader]=getFcnNameAndHeader(self)
            fcnName=strcat(self.nameBase,'_',self.index,'_gateway');
            fcnHeader=strcat(fcnName,'.h');
        end

        function flag=todoCg(self)
            execBlockName=get_param(self.hExecBlock,'Name');
            match=regexp(execBlockName,'STATE_\d+','ONCE');
            flag=~isempty(match);
        end

        function[createFcnName,moduleName]=setupCreateFcnNameAndModuleName(self)
            localName=sprintf('%s_%s',self.nameBase,self.index);
            createFcnName=[localName,'_dae'];
            moduleName=localName;
        end

        function cgResults=generate(self,cgParams)
            dae=self.mxParam.dae;
            cgResults=dae.generate(cgParams);
        end

        function[srcFile,hdrFile]=generateGatewayFiles(...
            self,...
            buildDirectory,...
            gatewayFcnName,...
            createFcnName,...
            toplevelHeaderFile,...
            varargin)
            dae=self.mxParam.dae;
            pm_assert(~isempty(dae),'DAE not in registry');

            simRegKey=varargin{1}{1};
            srcFile=fullfile(buildDirectory,strcat(gatewayFcnName,'.c'));
            hdrFile=fullfile(buildDirectory,strcat(gatewayFcnName,'.h'));

            modelParams='modelparams';
            solverParams='solverparams';
            outputParameters='outputparameters';




            src={};
            src{end+1}=sprintf('#ifdef MATLAB_MEX_FILE\n');
            src{end+1}=sprintf('#include "tmwtypes.h"\n');
            src{end+1}=sprintf('#else\n');
            src{end+1}=sprintf('#include "rtwtypes.h"\n');
            src{end+1}=sprintf('#endif\n');
            src{end+1}=self.includeHeader('nesl_rtw.h');
            src{end+1}=self.includeHeader(toplevelHeaderFile);
            src{end+1}=self.includeHeader(strcat(gatewayFcnName,'.h'));
            src{end+1}=self.lGatewayFunctionDefine(gatewayFcnName);
            src{end+1}='{';
            src{end+1}=self.declareVariable('NeModelParameters',modelParams,self.struct2Str(self.mxParam.modelParameters));
            src{end+1}=self.declareVariable('NeSolverParameters',solverParams,self.struct2Str(self.mxParam.solverParameters));
            src{end+1}=self.declareVariable('const NeOutputParameters*',outputParameters,'NULL');
            src{end+1}=self.declareVariable('NeDae*','dae');
            src{end+1}=self.declareVariable('size_t','numOutputs','0');

            if simscape.engine.sli.internal.hasRuntimeParameters(dae.ParameterInfo)
                numRtpDaes=1;
                src{end+1}=self.declareVariable('int','rtpDaes[1]','{0}');
            else
                numRtpDaes=0;
                src{end+1}=self.declareVariable('int*','rtpDaes','NULL');
            end

            if dae.hasLogFcn
                numRtwLogDaes=1;
                src{end+1}=self.declareVariable('int','rtwLogDaes[1]','{0}');
            else
                numRtwLogDaes=0;
                src{end+1}=self.declareVariable('int*','rtwLogDaes','NULL');
            end

            src{end+1}=self.lInitializeFromStaticArray('NeOutputParameters',outputParameters,self.structArray2Str(self.mxParam.outputParameters),'numOutputs');
            src{end+1}=self.lCgCallDaeCreateFunction(createFcnName,'dae',...
            modelParams,solverParams);
            daePt=sprintf('&dae');
            src{end+1}=self.lRegisterSimulatorGroup(simRegKey,1,daePt,solverParams,modelParams,...
            'numOutputs',outputParameters,numRtpDaes,'rtpDaes',...
            numRtwLogDaes,'rtwLogDaes');
            src{end+1}='}';

            fid=fopen(srcFile,'w');
            fprintf(fid,'%s',self.strCat(src{:}));
            fclose(fid);




            hdr={};
            hdr{end+1}=self.includeProtectionEnter(gatewayFcnName);
            hdr{end+1}=self.cppProtectionEnter();
            hdr{end+1}=self.lGatewayFunctionDeclare(gatewayFcnName);
            hdr{end+1}=self.cppProtectionExit();
            hdr{end+1}=self.includeProtectionExit(gatewayFcnName);

            fid=fopen(hdrFile,'w');
            fprintf(fid,'%s',self.strCat(hdr{:}));
            fclose(fid);
        end


        function str=lCgAssignVariable(self,lhs,rhs)
            str=sprintf('%s = %s;\n',lhs,rhs);
        end


        function str=lInitializeFromStaticArray(self,type,var_name,value,len_name)
            if strcmpi(value,'NULL')
                str='';
            else
                init_type=self.strCat('static const ',type);
                init_name=self.strCat(var_name,'_init');
                init_array=self.strCat(init_name,'[]');
                len_value=sprintf('sizeof(%s)/sizeof(%s[0])',init_name,init_name);
                str=sprintf('{ \n%s \n%s \n%s }',...
                self.declareVariable(init_type,init_array,value),...
                self.lCgAssignVariable(var_name,init_name),...
                self.lCgAssignVariable(len_name,len_value));
            end
        end


        function str=lCgCallDaeCreateFunction(self,daeFcnName,daeVar,...
            modelParams,solverParams)
            str=sprintf('%s(&%s,\n&%s,\n&%s);',...
            daeFcnName,...
            daeVar,...
            modelParams,...
            solverParams);
        end


        function str=lRegisterSimulatorGroup(self,simRegKey,ndae,dae,sp,mp,nop,op,nRtpDaes,rtpDaes,nRtwLogDaes,rtwLogDaes)
            str=sprintf('%s(%s,\n%d,\n%s,\n&%s,\n&%s,\n%s,\n%s,\n%d,\n%s,\n%d,\n%s);',...
            'nesl_register_simulator_group',...
            simscape.internal.cgstring(simRegKey),...
            ndae,...
            dae,...
            sp,...
            mp,...
            nop,...
            op,...
            nRtpDaes,...
            rtpDaes,...
            nRtwLogDaes,...
            rtwLogDaes);
        end


        function str=lGatewayFunctionDefine(self,fcnName)
            str=sprintf('void %s(void)',fcnName);
        end


        function str=lGatewayFunctionDeclare(self,fcnName)
            str=sprintf('extern %s;',self.lGatewayFunctionDefine(fcnName));
        end

    end
end
