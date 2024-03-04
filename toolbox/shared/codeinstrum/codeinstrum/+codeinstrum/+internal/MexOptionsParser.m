classdef(Hidden=true)MexOptionsParser<codeinstrum.internal.LCBuildOptions


    properties(Constant,Hidden)
        OBJ_FILE_EXTS={'.obj','.o','.glnxa64_o','.maci64_o','.win64_obj','.win32_obj','.res'};
        LIB_FILE_EXTS={'.lib','.so','.dylib','.a','.win32_lib','.win64_lib','.glnxa64_a','.maci64_a'};
        SRC_FILE_EXTS={'.c','.cc','.c++','.cpp','.cp','.cxx'};
    end


    properties
Argv
Otherfiles
IsCompOnly
OutDir
OutName
SldvInfo
SupportSldv
MexVars
    end


    methods

        function this=MexOptionsParser(argv)
            if nargin<1
                this=this.init();
            else
                this=this.parse(argv);
            end
        end


        function dbg=isDebug(this)
            dbg=any(strcmp('-g',this.Argv));
        end




        function this=parse(this,argv)

            validateattributes(argv,{'cell'},{},'','input arguments');

            this=this.init();

            argc=numel(argv);
            argvIn=1;
            argvOut=1;

            this.Argv=cell(size(argv));

            while argvIn<=argc

                opt=argv{argvIn};
                validateattributes(opt,{'char'},{'row'},'','',argvIn);
                opt=strtrim(opt);

                if opt(1)=='-'

                    if strcmp(opt,'-ifcn')
                        argvIn=argvIn+1;
                        validateattributes(argv{argvIn},{'char'},{'row'},'','',argvIn);
                        this.FcnToIgnore{end+1}=strtrim(argv{argvIn});

                    elseif strcmp(opt,'-idir')
                        argvIn=argvIn+1;
                        validateattributes(argv{argvIn},{'char'},{'row'},'','',argvIn);
                        this.DirToIgnore{end+1}=strtrim(argv{argvIn});

                    elseif strcmp(opt,'-ifile')
                        argvIn=argvIn+1;
                        validateattributes(argv{argvIn},{'char'},{'row'},'','',argvIn);
                        this.FileToIgnore{end+1}=strtrim(argv{argvIn});

                    elseif strcmp(opt,'-internalfile')
                        argvIn=argvIn+1;
                        validateattributes(argv{argvIn},{'char'},{'row'},'','',argvIn);
                        this.InternalFileToIgnore{end+1}=strtrim(argv{argvIn});

                    elseif strcmpi(opt,'-sldvinfo')
                        argvIn=argvIn+1;
                        sldvInfo=argv{argvIn};
                        if isa(sldvInfo,'sldv.code.sfcn.internal.StaticSFcnInfoWriter')
                            this.SldvInfo=sldvInfo;
                            this.SupportSldv=true;
                        end
                    elseif strcmp(opt,'-sldv')
                        this.SupportSldv=true;
                    else

                        if strncmp(opt,'-D',2)
                            nKeepArg(opt);
                            this.Defines{end+1}=opt(3:end);

                        elseif strncmp(opt,'-U',2)
                            nKeepArg(opt);
                            this.Undefines{end+1}=opt(3:end);

                        elseif strncmp(opt,'-I',2)
                            nKeepArg(opt);
                            this.Includes{end+1}=opt(3:end);

                        elseif strcmp(opt,'-f')
                            nKeepArg(opt);
                            argvIn=argvIn+1;
                            validateattributes(argv{argvIn},{'char'},{'row'},'','',argvIn);
                            nKeepArg(strtrim(argv{argvIn}));

                        elseif strcmp(opt,'-outdir')||strcmp(opt,'-output')
                            argvIn=argvIn+1;
                            validateattributes(argv{argvIn},{'char'},{'row'},'','',argvIn);
                            optVal=strtrim(argv{argvIn});

                            if strcmp(opt,'-outdir')
                                this.OutDir=optVal;
                            else
                                this.OutName=optVal;
                            end

                        elseif strcmp(opt,'-cxx')
                            this.ForceCxx=true;
                            nKeepArg(opt);

                        elseif strcmp(opt,'-c')
                            this.IsCompOnly=true;
                            nKeepArg(opt);

                        else
                            nKeepArg(opt);
                        end
                    end

                elseif ispc&&opt(1)=='@'
                    if exist(opt(2:end),'file')
                        nKeepArg(opt);
                    else
                        nParseFile(opt);
                    end
                else
                    indexes=strfind(opt,'=');
                    if~isempty(indexes)
                        idx=indexes(1);

                        varName=opt(1:idx-1);
                        if any(strcmp(varName,{'COMPFLAGS','CFLAGS','CXXFLAGS'}))
                            varValue=opt(idx+1:end);
                            this.MexVars(varName)=varValue;
                        end
                    end

                    if~isempty(regexp(opt,'\w=.*','start'))
                        nKeepArg(opt);
                    else
                        nParseFile(opt);
                    end
                end

                argvIn=argvIn+1;
            end


            this.Argv(argvOut:argc)=[];

            function nParseFile(file)
                [~,~,fext]=fileparts(file);
                if ismember(fext,this.OBJ_FILE_EXTS)||ismember(fext,this.LIB_FILE_EXTS)
                    this.Otherfiles{end+1}=file;
                elseif ismember(fext,this.SRC_FILE_EXTS)
                    this.Sources{end+1}=file;
                else
                    nKeepArg(opt);
                end
            end

            function nKeepArg(opt)
                this.Argv{argvOut}=opt;
                argvOut=argvOut+1;
            end
        end
    end

    methods(Access='protected')



        function this=init(this)
            this=init@codeinstrum.internal.LCBuildOptions(this);
            this.Argv={};
            this.Otherfiles={};
            this.IsCompOnly=false;
            this.OutDir='';
            this.OutName='';
            this.SldvInfo=[];
            this.SupportSldv=false;
            this.MexVars=containers.Map('KeyType','char','ValueType','any');
        end
    end
end



