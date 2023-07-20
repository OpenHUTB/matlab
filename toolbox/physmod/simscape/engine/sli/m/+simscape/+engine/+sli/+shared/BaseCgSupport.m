classdef(Abstract)BaseCgSupport<handle















    properties

hExecBlock
solverBlockPath
nameBase


        mxParam;
        index;
    end

    methods(Abstract=true)
        initDerivedProperties();
        [fcnName,fcnHeader]=getFcnNameAndHeader()
        flag=todoCg()
        [createFcnName,moduleName]=setupCreateFcnNameAndModuleName()
        cgResults=generate(cgParams)
        [srcFile,hrdFile]=generateGatewayFiles(varargin)
    end

    methods
        function[gatewayFcnName,gatewayFcnHeader,requiredLibraries]=baseSupport(self,hExecBlock,varargin)
            self.initBaseProperties(hExecBlock);
            self.initDerivedProperties();

            hModel=pmsl_bdroot(self.hExecBlock);




            [gatewayFcnName,gatewayFcnHeader]=self.getFcnNameAndHeader();




            if~self.todoCg()
                requiredLibraries={};
                return;
            end

            Simulink.output.info(message('physmod:simscape:engine:sli:cg:GenerateCodeStart',self.solverBlockPath).string);




            sourceFiles={};
            sourceFilePaths={};


            sizeTSize=num2str(get_param(hModel,'ProdBitPerSizeT'));
            targetFile=get_param(hModel,'SystemTargetFile');
            if(strcmpi(targetFile,'rsim.tlc')||...
                strcmpi(targetFile,'raccel.tlc'))
                sizeTSize='64';

            end




            buildDirectory='';
            rtwSettings=get_param(hModel,'RTWGenSettings');
            if isstruct(rtwSettings)&&~isempty(rtwSettings.RelativeBuildDir)
                buildDirectory=fullfile(pwd,rtwSettings.RelativeBuildDir,filesep);
            end
            pm_assert(exist(buildDirectory,'dir'),...
            'Cannot generate code for Physical Networks: Build directory does not exist');




            [createFcnName,moduleName]=self.setupCreateFcnNameAndModuleName();



            simscape.compiler.mli.clear_target_files(buildDirectory,{moduleName});




            isCppModelRefSimTarget=slfeature('ModelReferenceHonorsSimTargetLang')>0&&...
            strcmp(get_param(hModel,'ModelReferenceSimTargetType'),'Accelerator')&&...
            strcmp(get_param(hModel,'SimTargetLang'),'C++');
            mlfcnFiles=simscape.compiler.mli.mlfcncg(buildDirectory,sizeTSize,isCppModelRefSimTarget);
            self.postprocess(mlfcnFiles);
            for j=1:length(mlfcnFiles)
                [filepath,name,ext]=fileparts(mlfcnFiles{j});
                if strcmp(ext,'.c')
                    sourceFiles{end+1}=strcat(name,ext);%#ok
                    sourceFilePaths{end+1}=filepath;%#ok
                end
            end




            ec=self.determineCoding(hModel);




            cgParams=simscape.internal.CgParams;
            cgParams.MatlabRoot=matlabroot;
            cgParams.Directory=buildDirectory;
            cgParams.ModuleName=moduleName;
            cgParams.CreateFcnName=createFcnName;
            cgParams.Coding=ec;

















            cgResults=self.generate(cgParams);



            toplevelHeaderFile=strcat(cgParams.ModuleName,'.h');
            toplevelHeaderFound=false;
            for j=1:length(cgResults.GeneratedFiles)
                [filepath,name,ext]=fileparts(cgResults.GeneratedFiles{j});
                if strcmp(ext,'.c')
                    sourceFiles{end+1}=strcat(name,ext);%#ok
                    sourceFilePaths{end+1}=filepath;%#ok
                    continue
                end
                if strcmp(strcat(name,ext),toplevelHeaderFile)
                    pm_assert(~toplevelHeaderFound,'Top-level header not unique');
                    toplevelHeaderFound=true;
                end
            end
            pm_assert(toplevelHeaderFound,'Top-level header not found');




            self.postprocess(cgResults.GeneratedFiles);


            [gatewaySrcFile,gatewayHdrFile]=self.generateGatewayFiles(...
            buildDirectory,...
            gatewayFcnName,...
            createFcnName,...
            toplevelHeaderFile,...
            varargin);

            self.postprocess({gatewaySrcFile,gatewayHdrFile});

            [fpath,fname,fext]=fileparts(gatewaySrcFile);
            sourceFiles{end+1}=strcat(fname,fext);
            sourceFilePaths{end+1}=fpath;





            modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(hModel);
            if~isempty(modelCodegenMgr)
                buildInfo=modelCodegenMgr.BuildInfo;
                if~isempty(sourceFiles)
                    buildInfo.addSourceFiles(sourceFiles,sourceFilePaths,'BlockModules');
                end
                if~isempty(cgResults.RequiredDynamicLibraries)
                    buildInfo.addSysLibs(cgResults.RequiredDynamicLibraries);
                end
            end

            requiredLibraries=cgResults.RequiredLibraries;

            Simulink.output.info(message('physmod:simscape:engine:sli:cg:GenerateCodeEnd').string);
        end

        function initBaseProperties(self,hExecBlock)
            self.hExecBlock=hExecBlock;
            hSolverBlock=get_param(get_param(hExecBlock,'Parent'),'Parent');
            pm_assert(strcmpi(get_param(hSolverBlock,'SubClassName'),'solver'));
            self.solverBlockPath=pmsl_sanitizename(getfullname(hSolverBlock));
            self.nameBase=nesl_solverid(hSolverBlock);
        end





        function enc=determineCoding(self,m)






            modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(m);


            isModelReference=pmsl_ismodelref(m);

            isSimulationTarget=false;
            if isModelReference
                if slprivate('isSimulationBuild',get_param(m,'Name'),...
                    modelCodegenMgr.MdlRefBuildArgs.ModelReferenceTargetType)
                    isSimulationTarget=true;
                end
            else
                targetName=get_param(m,'SystemTargetFile');
                isSimulationTarget=strcmp(targetName,'raccel.tlc');
            end

            if isSimulationTarget
                enc='UTF-8';
            else
                enc=slCharacterEncoding;
            end
        end


        function str=structArray2Str(self,pa)
            if isempty(pa)
                str='NULL';
            else
                str='{ ';
                for i=1:length(pa)
                    str=[str,self.struct2Str(pa{i}),', '];%#ok
                end
                str=[str,' }'];
            end
        end


        function str=struct2Str(self,p)
            str='{ ';
            fn=fields(get(p));
            for j=1:length(fn)
                str=[str,self.num2Str(p,fn{j}),', '];%#ok
            end
            str=[str,' }'];
        end


        function str=num2Str(self,obj,prop)

            choices=set(obj,prop);
            if~isempty(choices)





                propValue=obj.(prop);
                propStr=num2str(find(strcmpi(choices,propValue))-1);
                cls=class(obj);
                nativeTypes=ne_nativetypes(strrep(cls,'NetworkEngine.',''));
                str=sprintf('(%s) %s',nativeTypes.(prop),propStr);
            elseif ischar(obj.(prop))



                str=obj.(prop);
                toundos={'\n'};
                for i=1:length(toundos)
                    str=strrep(str,sprintf(toundos{i}),toundos{i});
                end
                str=['"',str,'"'];
            else



                str=num2str(obj.(prop));
            end

        end


        function prependFileInPlace(self,file,preamble)



            fid=fopen(file,'r');
            pm_assert(fid~=1,'no source file found');
            C=fread(fid,'char=>char');
            fclose(fid);

            fid=fopen(file,'w');
            fprintf(fid,'%s',preamble);
            fprintf(fid,'%s',C);
            fclose(fid);
        end


        function prependFileInChunks(self,file,preamble,numchar)



            file_tmp=[file,'_tmp'];

            fid_tmp=fopen(file_tmp,'w');
            fprintf(fid_tmp,preamble);

            fid=fopen(file,'r');
            while~feof(fid)
                fprintf(fid_tmp,'%s',fread(fid,numchar,'char=>char'));
            end
            fclose(fid);

            fclose(fid_tmp);


            movefile(file_tmp,file);
        end



        function addPreamble(self,file,preamble)

            size=2^20;

            d=dir(file);

            if d.bytes<size

                self.prependFileInPlace(file,preamble);
            else

                size_char=2;
                numchar=size/size_char;
                self.prependFileInChunks(file,preamble,numchar);
            end

        end


        function postprocess(self,files)
            preamble=sprintf(...
            ['/* Simscape target specific file.\n ',...
            '* This file is generated for the Simscape network',...
            ' associated with the solver block ''%s''.\n */\n'],...
            self.solverBlockPath);

            for idx=1:length(files)
                file=files{idx};

                self.addPreamble(file,preamble);

                c_beautifier(file);
            end
        end


        function ext=libraryExtension(self)
            persistent libExt;
            if isempty(libExt)
                if ispc
                    libExt='lib';
                elseif ismac
                    libExt='dylib';
                elseif isunix
                    libExt='so';
                else
                    assert(0,'unrecognized platform');
                end
            end
            ext=libExt;
        end


        function loc=libraryLocation(self)
            persistent libLoc;
            if isempty(libLoc)
                libLoc=fullfile(matlabroot,'bin',computer('arch'));
            end
            loc=libLoc;
        end


        function str=declareVariable(self,type,name,value)
            if nargin<4
                str=sprintf('%s %s;\n',type,name);
            else
                str=sprintf('%s %s = %s;\n',type,name,value);
            end
        end


        function str=includeHeader(self,hdr)
            str=sprintf('#include "%s"\n',hdr);
        end


        function str=includeProtectionEnter(self,hfileName)
            str=sprintf('#ifndef __%s_h__\n#define __%s_h__\n',hfileName,hfileName);
        end


        function str=includeProtectionExit(self,hfileName)
            str=sprintf('#endif  /* #ifndef __%s_h__ */\n',hfileName);
        end


        function str=cppProtectionEnter(self)
            str=sprintf('#ifdef __cplusplus\n    extern "C" {\n#endif\n');
        end


        function str=cppProtectionExit(self)
            str=sprintf('#ifdef __cplusplus\n     } \n#endif\n');
        end


        function str=strCat(self,varargin)

            str=cat(2,varargin{:});
        end
    end
end


