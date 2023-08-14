function compilerInfo=compilerman(isRTW,targetLangIsC,~)




    if nargin<2
        targetLangIsC=true;
    end

    if nargin<3

        emcGetMexCompiler();
    end

    if ispc
        if~isRTW&&targetLangIsC&&exist('sfpref.m','file')&&sfpref('UseLCC64ForEMC')
            compilerInfo=default_compiler_info('lcc64');
        else
            compilerInfo=getMEXInfo(isRTW,targetLangIsC);
        end
    else
        cc=callMexGetCompilerConfigurations(targetLangIsC);
        if(isempty(cc))
            coder.internal.throwUnsupportedCompilerError();
        end
        compilerInfo=unknown_compiler(cc(1).Name);
        compilerInfo.mexOptsFile=cc(1).Details.SetEnv;
    end

    compilerInfo.codingMicrosoftMakefile=false;
    compilerInfo.codingMinGWMakefile=false;
    compilerInfo.codingLcc64Makefile=false;
    compilerInfo.codingUnixMakefile=false;
    compilerInfo.codingIntelMakefile=false;

    if~isempty(regexp(compilerInfo.compilerName,'^msvc[p]{0,2}','once'))
        compilerInfo.codingMicrosoftMakefile=true;
    else
        if~isempty(regexpi(compilerInfo.compilerName,'^intelc[p]{0,2}[0-9]{2}ms','once'))
            compilerInfo.codingIntelMakefile=true;
        else
            switch compilerInfo.compilerName
            case{'mingw64','mingw64-g++','mingw64sdk10+'}
                compilerInfo.codingMinGWMakefile=true;

                expr='-Wl,"[^"]*mexFunction.def"';
                replace='';
                compilerInfo.compilerName='mingw64';
                compilerInfo.mexOptsFile=regexprep(compilerInfo.mexOptsFile,expr,replace,'once');
            case 'lcc64'
                compilerInfo.codingLcc64Makefile=true;
            case{'','unix','GNU C','HNU C++','gcc','g++'}
                compilerInfo.compilerName='gcc';
                compilerInfo.codingUnixMakefile=true;
            case{'Clang','Xcode with Clang','Xcode Clang++','Clang++'}
                compilerInfo.compilerName='clang';
                compilerInfo.codingUnixMakefile=true;
            otherwise
                href='<a href="matlab: mex -setup">mex -setup</a>';
                error(message('Coder:buildProcess:unknownMexCompiler',href));
            end
        end
    end
end


function mexCompilerInfo=getMEXInfo(isRTW,targetLangIsC)
    cc=callMexGetCompilerConfigurations(targetLangIsC);
    if isempty(cc)
        if(~isRTW&&targetLangIsC&&strcmp(computer,'PCWIN64'))
            mexCompilerInfo=default_compiler_info('lcc64');
            return;
        else
            href='<a href="matlab: mex -setup">mex -setup</a>';
            error(message('Coder:buildProcess:unknownMexCompiler',href));
        end
    end
    shortName=lower(strtrim(cc.ShortName));

    if~isempty(regexp(shortName,'^msvc[p]{0,2}1[4567]','once'))
        mexCompilerInfo.compilerName=shortName;
        success=true;
    else
        if any(strcmp(shortName,{'mingw64','mingw64sdk10+','mingw64-g++'}))
            mexCompilerInfo.compilerName=shortName;
            mexCompilerInfo.OpenMPLib=fullfile(cc.Location,'bin','libgomp-1.dll');
            success=true;
        else
            if strcmp(shortName,'lcc64')
                mexCompilerInfo.compilerName=shortName;
                success=true;
            else
                if~isempty(regexp(shortName,'intelc[p]{0,2}[0-9]{2}ms','once'))
                    if isRTW
                        error(message('Coder:reportGen:rtwCompilerNotSupported',cc.Name));
                    end
                    mexCompilerInfo.compilerName=shortName;
                    success=true;
                else
                    success=false;
                end
            end
        end
    end
    if~success
        error(message('Coder:reportGen:mexCompilerNotSupported',cc.Name));
    end
    mexCompilerInfo.mexOptsFile=cc.Details.SetEnv;
    mexCompilerInfo.isRTW=isRTW;
end


function compilerInfo=unknown_compiler(compilerName)
    compilerInfo.compilerName=compilerName;
    compilerInfo.mexOptsFile='';
    compilerInfo.isRTW=false;
    compilerInfo.optsFileTimeStamp=0.0;
end


function compilerInfo=default_compiler_info(compilerName)
    compilerInfo.compilerName=compilerName;
    compilerInfo.mexOptsFile='';
    compilerInfo.optsFileTimeStamp=0.0;
    compilerInfo.ignoreMexOptsFile=0;
    compilerInfo.mexOptsIgnored=true;
    compilerInfo.mexOptsNotFound=true;
end


function cc=callMexGetCompilerConfigurations(targetLangIsC)
    if targetLangIsC
        langName='C';
    else
        langName='C++';
    end
    try
        cc=emcGetMexCompiler(langName);
    catch ME %#ok<NASGU>
        cc=[];
    end
end
