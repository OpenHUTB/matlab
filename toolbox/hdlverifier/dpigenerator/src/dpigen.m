function varargout=dpigen(varargin)























































































































    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if~(builtin('license','checkout','EDA_Simulator_Link'))
        error(message('HDLLink:DPIG:UnableToCheckOutLicense'));
    end

    currentPath=path;
    restorePath=onCleanup(@()path(currentPath));
    currentDir=pwd;
    restoreDir=onCleanup(@()cd(currentDir));

    restoreObj=onCleanup(@()CleanStaticProp());


    argc=1;
    N=numel(varargin);
    PortsDataTypeBitMatchRequested=false;
    ConfigObjectGiven=false;
    TestBenchGiven=false;
    ComponentTemplateTypeGiven=false;
    MultipleMATLABFiles=false;
    OutputNameGiven=false;



    MATLABFuncName='';

    DebugTest=false;

    while argc<=N
        arg=varargin{argc};
        argc=argc+1;
        if ischar(arg)
            arg=strtrim(arg);
            if~isempty(arg)&&coder.internal.isOptionPrefix(arg(1))
                op=arg(2:end);
                switch op
                case 'config'





                    assert(~(length(varargin)<argc),message('HDLLink:DPIG:NoConfigObject'));
                    tempcfg=varargin{argc};
                    assert(~coder.internal.isOptionPrefix(tempcfg(1)),message('HDLLink:DPIG:NoConfigObject'));

                    if ischar(varargin{argc})
                        cfglocal=evalin('caller',varargin{argc});
                    else
                        cfglocal=varargin{argc};
                    end



                    assert(isa(cfglocal,'coder.CodeConfig')&&strcmpi(cfglocal.OutputType,'DLL'),message('HDLLink:DPIG:InvalidConfigObjType'));
















                    OriginalProp.PostCodeGenCommand='';
                    RestoreConfig=onCleanup(@(in1,in2)l_RestoreConfigObj(cfglocal,OriginalProp));


                    cfglocal.FilePartitionMethod='SingleFile';
                    cfglocal.MultiInstanceCode=true;


                    p=MATLAB_DPICGen.DPICGenInst;
                    p.configObj=copy(cfglocal);
                    cfglocal.PostCodeGenCommand='MATLAB_DPICGen.DPICGenInst.PostCodeGenHook(projectName, buildInfo)';











                    assert(~cfglocal.PreserveArrayDimensions,message('HDLLink:DPIG:PreserveArrayDimensionsNotSupported'));

                    varargin{argc}='cfglocal';
                    ConfigObjectGiven=true;
                    argc=argc+1;
                case 'args'

                    assert(~(length(varargin)<argc),message('HDLLink:DPIG:NoArgs'));
                    tempargs=varargin{argc};



                    if ischar(varargin{argc})
                        assert(~coder.internal.isOptionPrefix(tempargs(1)),message('HDLLink:DPIG:NoArgs'));
                        argslocal=evalin('caller',varargin{argc});
                    else
                        argslocal=varargin{argc};
                    end
                    p=MATLAB_DPICGen.DPICGenInst;
                    p.InputArgs=argslocal;
                    varargin{argc}='argslocal';
                    argc=argc+1;
                case 'o'
                    OutputNameGiven=true;
                    if length(varargin)<argc
                        DLLOutputName='';
                    else
                        tempArg=varargin{argc};
                        if isempty(tempArg)||coder.internal.isOptionPrefix(tempArg(1))
                            DLLOutputName='';
                        else
                            DLLOutputName=varargin{argc};
                            argc=argc+1;
                        end
                    end
                    p=MATLAB_DPICGen.DPICGenInst;
                    p.dllOutputName=DLLOutputName;
                case{'PortsDataType','FixedPointDataType'}
                    p=MATLAB_DPICGen.DPICGenInst;
                    p.PortsDataType=varargin{argc};
                    assert(any(strcmpi(p.PortsDataType,{'CompatibleCType','BitVector','LogicVector'})),message('HDLLink:DPIG:InvalidPortsDataTypeEnum'));
                    varargin=[varargin(1:argc-2),varargin(argc+1:end)];
                    PortsDataTypeBitMatchRequested=true;
                    argc=argc-1;
                    N=numel(varargin);
                case 'ComponentTemplateType'
                    p=MATLAB_DPICGen.DPICGenInst;
                    p.ComponentTemplateType=varargin{argc};
                    assert(any(strcmpi(p.ComponentTemplateType,{'Sequential','Combinational'})),message('HDLLink:DPIG:InvalidComponentTemplateTypeEnum'));
                    varargin=[varargin(1:argc-2),varargin(argc+1:end)];
                    argc=argc-1;
                    N=numel(varargin);
                    ComponentTemplateTypeGiven=true;
                    if strcmpi(p.ComponentTemplateType,'Combinational')



                        warning(message('HDLLink:DPIG:CombTemplateWarning'));
                    end
                case{'testbench','TestBench'}


                    l_CheckTestBench(varargin,argc);
                    p=MATLAB_DPICGen.DPICGenInst;
                    [~,p.tbModuleName,~]=fileparts(varargin{argc});
                    varargin=[varargin(1:argc-2),varargin(argc+1:end)];
                    argc=argc-1;
                    N=numel(varargin);
                    TestBenchGiven=true;
                    p.testBench=TestBenchGiven;
                    p.topDir=currentDir;
                case{'I','i'}

                    l_CheckIncludeDir(varargin,argc)
                    argc=argc+1;
                case 'c'
                    p=MATLAB_DPICGen.DPICGenInst;
                    p.GenCodeOnly=true;
                case{'global','globals'}


                    assert(~(length(varargin)<argc),message('HDLLink:DPIG:NoGlobal'));
                    tempargs=varargin{argc};



                    if ischar(varargin{argc})
                        assert(~coder.internal.isOptionPrefix(tempargs(1)),message('HDLLink:DPIG:NoGlobal'));
                        globallocal=evalin('caller',varargin{argc});
                    else
                        globallocal=varargin{argc};
                    end
                    varargin{argc}='globallocal';
                    argc=argc+1;
                case 'd'
                    argc=argc+1;
                case{'report','launchreport'}
                case 'rowmajor'
                case 'ShowCodegenInput'
                    DebugTest=true;
                otherwise
                    error(message('HDLLink:DPIG:UnrecognizedOption',op));
                end
            else


                [pathstr,name,ext]=fileparts(arg);





                if strcmp(ext,'.m')||strcmp(ext,'')||strcmp(ext,'.mlx')


                    MATLABFuncName=name;
                    if exist(which(fullfile(pathstr,name)),'file')==2
                        assert(~MultipleMATLABFiles,message('HDLLink:DPIG:MultipleMATLABFiles'));
                        MultipleMATLABFiles=true;
                        MATLABFuncName=name;
                    end
                end

            end
        end
    end

    if~PortsDataTypeBitMatchRequested

        p=MATLAB_DPICGen.DPICGenInst;
        p.PortsDataType='CompatibleCType';
    end

    if~ComponentTemplateTypeGiven

        p=MATLAB_DPICGen.DPICGenInst;
        p.ComponentTemplateType='Sequential';
    end

    if~ConfigObjectGiven


        cfglocal=coder.config('dll');
        cfglocal.FilePartitionMethod='SingleFile';
        cfglocal.MultiInstanceCode=true;
        p=MATLAB_DPICGen.DPICGenInst;


        p.configObj=copy(cfglocal);
        cfglocal.PostCodeGenCommand='MATLAB_DPICGen.DPICGenInst.PostCodeGenHook(projectName, buildInfo)';











        varargin=[{'-config','cfglocal'},varargin];
    end

    if cfglocal.OutputType=="DLL"

        fc=coder.internal.FeatureControl;
        fc.ExportStyle='File';
        varargin=[{'-feature','fc'},varargin];
    end

    if~OutputNameGiven

        DLLOutputName=['lib',MATLABFuncName,'_dpi'];
        p=MATLAB_DPICGen.DPICGenInst;
        p.dllOutputName=DLLOutputName;
        varargin=[{'-o',DLLOutputName},varargin];
    end

    str=strjoin(['codegen',varargin]);

    if DebugTest
        varargout={str};
        return;
    end

    try
        eval(str);
    catch Err
        rethrow(Err);
    end

    IsHDLSimulatorToolChain=~isempty(strfind(MATLAB_DPICGen.DPICGenInst.configObj.Toolchain,'QuestaSim/Modelsim'))||...
    ~isempty(strfind(MATLAB_DPICGen.DPICGenInst.configObj.Toolchain,'Xcelium'));

    if IsHDLSimulatorToolChain
        moduleName=MATLAB_DPICGen.DPICGenInst.moduleName;
        configObj=MATLAB_DPICGen.DPICGenInst.configObj;
        genCodeOnly=MATLAB_DPICGen.DPICGenInst.GenCodeOnly;
        srcPath=MATLAB_DPICGen.DPICGenInst.SrcPath;
        dpigenerator_MATLAB_HDLToolChainCompile(moduleName,configObj,srcPath,genCodeOnly);
    end
end


function l_CheckTestBench(arguments,argcount)

    assert(~(length(arguments)<argcount)&&~isempty(arguments{argcount}),message('HDLLink:DPITestbench:NoTestBench'));

    testbenchName=arguments{argcount};
    assert(ischar(testbenchName),message('HDLLink:DPITestbench:TestBenchHasToBeString'));
    assert(~coder.internal.isOptionPrefix(testbenchName(1)),message('HDLLink:DPITestbench:NoTestBench'));


    [~,~,ext]=fileparts(testbenchName);
    if~(strcmp(ext,'.m')||strcmp(ext,'')||strcmp(ext,'.mlx'))
        error(message('HDLLink:DPITestbench:BadFileExt',ext));
    end
end

function l_CheckIncludeDir(arguments,argcount)


    assert(~(length(arguments)<argcount)&&~isempty(arguments{argcount}),message('HDLLink:DPIG:NoIncludeDirectories'));
    TempInclude=arguments{argcount};
    assert(ischar(TempInclude),message('HDLLink:DPIG:IncludeDirMustBeString'));
    assert(~coder.internal.isOptionPrefix(TempInclude(1)),message('HDLLink:DPIG:NoIncludeDirectories'));
end

function l_RestoreConfigObj(cfgl,~)





    cfgl.PostCodeGenCommand='';
end

function CleanStaticProp
    obj=MATLAB_DPICGen.DPICGenInst;
    obj.moduleName=[];
    obj.tbModuleName=[];
    obj.dpig_codeinfo=[];
    obj.buildInfo=[];
    obj.SrcPath=[];
    obj.InputArgs=[];
    obj.GenCodeOnly=[];
    obj.configObj=[];
    obj.testBench=[];
    obj.dllOutputName=[];
    obj.topDir=[];

end




























