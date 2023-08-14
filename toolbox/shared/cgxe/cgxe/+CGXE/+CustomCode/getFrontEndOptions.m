

function feOptions=getFrontEndOptions(lang,usrIncludes,usrDefines,extraFlags,useCached,addMWInc)

    if nargin<6
        addMWInc=true;
    end

    if nargin<5
        useCached=false;
    end

    if nargin<4
        extraFlags={};
    end

    if nargin<3
        usrDefines=[];
    end

    if nargin<2
        usrIncludes=[];
    end

    genCpp=strcmpi(lang,'C++');


    if strcmpi(computer,'pcwin64')
        compilerInfo=cgxeprivate('compilerman','get_compiler_info',genCpp);
        forceLcc64=strcmpi(compilerInfo.compilerName,'lcc');
    else
        forceLcc64=false;
    end

    if useCached&&isempty(extraFlags)&&~forceLcc64


        feOptions=CGXE.CustomCode.CxxFEOptionsManager.instance.getCachedDefaultSelectedMEXCompilerFeOpts(lang,addMWInc,forceLcc64);
    else


        feOptions=internal.cxxfe.util.getFrontEndOptions('lang',lang,...
        'useMexSettings',true,'addMWInc',addMWInc,'forceLcc64',forceLcc64,extraFlags{:});
    end


    feOptions.Preprocessor.Defines{end+1}='MX_COMPAT_64';
    feOptions.Preprocessor.Defines{end+1}='MATLAB_MEXCMD_RELEASE=R2018a';


    if~isempty(usrIncludes)
        feOptions.Preprocessor.IncludeDirs=[feOptions.Preprocessor.IncludeDirs(:);usrIncludes(:)];
    end

    if~isempty(usrDefines)
        usrDefines=CGXE.CustomCode.extractUserDefines(usrDefines);
        feOptions.Preprocessor.Defines=[feOptions.Preprocessor.Defines(:);usrDefines(:)];
    end


