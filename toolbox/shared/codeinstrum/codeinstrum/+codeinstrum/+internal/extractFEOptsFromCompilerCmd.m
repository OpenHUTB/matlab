



function[compilation_units,frontEndOptions]=extractFEOptsFromCompilerCmd(cwd,argv,env,sendOutputFn)
    fine(polyspace.internal.logging.Logger.getLogger('CompilerCmd'),...
    'Extracting front-end options for compiler command %s\n',strjoin(argv,' '));

    if nargin<4
        sendOutputFn=@(outStr)fprintf(1,'%s',outStr);
    end

    if ispc()
        psConfigureCmd=fullfile(matlabroot,'bin',computer('arch'),'ps_configure.exe');
    else
        psConfigureCmd=fullfile(matlabroot,'polyspace','bin','polyspace-configure');
    end


    psConfigureOutDir=tempname();
    if~exist(psConfigureOutDir,'dir')
        mkdir(psConfigureOutDir);
    end
    removePsConfigureOutDir=onCleanup(@()rmdir(psConfigureOutDir,'s'));

    psConfigureTmpPath=fullfile(psConfigureOutDir,'tmp_path');
    psConfigureBuildTraceFile=fullfile(psConfigureOutDir,'trace_file.txt');
    psConfigureOutputDumpFile=fullfile(psConfigureOutDir,'dump_file.txt');


    fine(polyspace.internal.logging.Logger.getLogger('CompilerCmd'),...
    'Calling ''polyspace-configure'' to perform and trace the build...\n');
    if nargin<3
        cenv={};
    else
        cenv={env};
    end
    if polyspace.internal.logging.Logger.getLogger('CompilerCmd').Level>polyspace.internal.logging.Level.FINER
        silentOpt={'-silent'};
    else
        silentOpt={};
    end
    hPsConfigureProc=polyspace.internal.Process('-working-directory',cwd,...
    '-capture-stdout','-merge-stderr-with-stdout',...
    psConfigureCmd,...
    '-tmp-path',psConfigureTmpPath,...
    '-build-trace',psConfigureBuildTraceFile,...
    '-no-project',...
    '-no-cache',...
    silentOpt{:},argv{:},cenv{:});
    [exitStatus,outStr]=hPsConfigureProc.getExitStatus();
    sendOutputFn(outStr);
    if exitStatus~=0

        error(message('cxxfe_mi:utils:compilerCommandFailed',strjoin(argv,' ')));
    end


    fine(polyspace.internal.logging.Logger.getLogger('CompilerCmd'),...
    'Calling ''polyspace-configure'' to analyze the build trace...\n');
    hPsConfigureProc=polyspace.internal.Process('-discard-stdout','-discard-stderr',...
    psConfigureCmd,...
    '-tmp-path',psConfigureTmpPath,...
    '-build-trace',psConfigureBuildTraceFile,...
    '-no-project',...
    '-no-cache',...
    '-output-dump-file',psConfigureOutputDumpFile,...
    '-no-build',...
    silentOpt{:});

    compilation_units={};
    if(hPsConfigureProc.getExitStatus()~=0)||~exist(psConfigureOutputDumpFile,'file')

        frontEndOptions=[];
        return
    end

    language='';
    dialect='';
    includes={};
    system_includes={};
    implicit_includes={};
    preincludes={};
    defines={};
    implicit_defines={};
    undefines={};
    target_options=containers.Map('KeyType','char','ValueType','any');


    fine(polyspace.internal.logging.Logger.getLogger('CompilerCmd'),...
    'Extracting the front-end options from the ''polyspace-configure'' output dump file...\n');
    fid=fopen(psConfigureOutputDumpFile,'rt','n',matlab.internal.i18n.locale.default.Encoding);
    closeOutputDumpFile=onCleanup(@()fclose(fid));
    while true
        tline=fgets(fid);
        if~ischar(tline)
            break
        end


        tmp=regexp(tline,'cmd[0-9]+\s+language: (.*?)\s*$','tokens');
        if~isempty(tmp)
            tmp=tmp{1};
            language=tmp{1};
            continue
        end


        tmp=regexp(tline,'cc[0-9]+\s+dialect: (.*?)\s*$','tokens');
        if~isempty(tmp)
            tmp=tmp{1};
            dialect=tmp{1};
            continue
        end


        tmp=regexp(tline,'cu[0-9]+\s+([\w_ ]+): (.*?)\s*$','tokens');
        if~isempty(tmp)
            tmp=tmp{1};
            switch tmp{1}
            case 'compilation unit'
                compilation_units(end+1)=tmp(2);%#ok<AGROW>
                continue
            case 'include'
                includes(end+1)=tmp(2);%#ok<AGROW>
                continue
            case 'system_include'
                system_includes(end+1)=tmp(2);%#ok<AGROW>
                continue
            case 'implicit_include'
                implicit_includes(end+1)=tmp(2);%#ok<AGROW>
                continue
            case 'preinclude'
                preincludes(end+1)=tmp(2);%#ok<AGROW>
                continue
            case 'define'
                defines(end+1)=tmp(2);%#ok<AGROW>
                continue
            case 'implicit_define'
                implicit_defines(end+1)=tmp(2);%#ok<AGROW>
                continue
            case 'undefine'
                undefines(end+1)=tmp(2);%#ok<AGROW>
                continue
            end
        end


        tmp=regexp(tline,'cu[0-9]+\s+target: (.*?): (.*?)\s*$','tokens');
        if~isempty(tmp)
            tmp=tmp{1};
            if strcmp(tmp{2},'-1')
                continue
            end
            target_options(tmp{1})=tmp{2};
            continue
        end
    end
    clear closeOutputDumpFile;
    clear removePsConfigureOutDir;




    compInfo=struct('targetSettings',struct(),...
    'sysHeaderDirs',{[system_includes,implicit_includes]},...
    'mwHeaderDirs',{includes},...
    'sysCompDefines',{implicit_defines},...
    'mwCompDefines',{defines},...
    'unDefines',{undefines},...
    'preIncludes',{preincludes},...
    'languageExtra',{{}});


    compInfo.targetSettings.Endianness=target_options('endianness');
    compInfo.targetSettings.CharNumBits=sscanf(target_options('char_number_of_bits'),'%d');
    compInfo.targetSettings.ShortNumBits=sscanf(target_options('sizeof_short'),'%d')*compInfo.targetSettings.CharNumBits;
    compInfo.targetSettings.IntNumBits=sscanf(target_options('sizeof_int'),'%d')*compInfo.targetSettings.CharNumBits;
    compInfo.targetSettings.LongNumBits=sscanf(target_options('sizeof_long'),'%d')*compInfo.targetSettings.CharNumBits;
    compInfo.targetSettings.LongLongNumBits=sscanf(target_options('sizeof_long_long'),'%d')*compInfo.targetSettings.CharNumBits;
    compInfo.targetSettings.FloatNumBits=sscanf(target_options('sizeof_float'),'%d')*compInfo.targetSettings.CharNumBits;
    compInfo.targetSettings.DoubleNumBits=sscanf(target_options('sizeof_double'),'%d')*compInfo.targetSettings.CharNumBits;
    compInfo.targetSettings.LongDoubleNumBits=sscanf(target_options('sizeof_long_double'),'%d')*compInfo.targetSettings.CharNumBits;
    compInfo.targetSettings.PointerNumBits=sscanf(target_options('sizeof_pointer'),'%d')*compInfo.targetSettings.CharNumBits;


    switch language
    case 'C++11'
        lang='cxx';
        idx=strncmp(compInfo.sysCompDefines,'__cplusplus=',12);
        if~any(idx)
            compInfo.sysCompDefines{end+1}='__cplusplus=201103L';
        end
    case 'C++'
        lang='cxx';
    otherwise
        lang='c';
    end
    compInfo.targetSettings.AllowLongLong=~strcmp(target_options('sizeof_long_long'),'-1');
    compInfo.targetSettings.MinStructAlignment=sscanf(target_options('alignof_struct'),'%d');
    compInfo.targetSettings.MaxAlignment=sscanf(target_options('max_alignment'),'%d');
    compInfo.targetSettings.PtrDiffTypeKind=psConfigureTypeToFEOptsTypeKind(target_options('integral_type_for_ptrdiff_t'));
    checkTypeKindAndSize('ptrdiff_t',compInfo.targetSettings.PtrDiffTypeKind,target_options('sizeof_ptrdiff_t'));
    compInfo.targetSettings.SizeTypeKind=psConfigureTypeToFEOptsTypeKind(target_options('integral_type_for_size_t'));
    checkTypeKindAndSize('size_t',compInfo.targetSettings.SizeTypeKind,target_options('sizeof_size_t'));
    compInfo.targetSettings.WcharTypeKind=psConfigureTypeToFEOptsTypeKind(target_options('integral_type_for_wchar_t'));
    assert(strcmp(compInfo.targetSettings.WcharTypeKind(1),'u')==~strcmp(target_options('signed_wchar_t'),'1'),...
    'The ''wchar_t'' type kind should match the ''signed_wchar_t'' value');
    checkTypeKindAndSize('wchar_t',compInfo.targetSettings.WcharTypeKind,target_options('sizeof_wchar_t'));

    compInfo.targetSettings.AllowMultibyteChars=true;
    compInfo.targetSettings.PlainCharsAreSigned=strcmp(target_options('signed_char'),'1');

    compInfo.targetSettings.PlainBitFieldsAreSigned=true;
    if strncmp(dialect,'gnu',3)


        gnu_version=sscanf(dialect,'gnu%d.%d');
        gnucMajorIdx=strncmp(compInfo.sysCompDefines,'__GNUC__=',9);
        if~any(gnucMajorIdx)
            compInfo.sysCompDefines{end+1}=sprintf('__GNUC__=%d',gnu_version(1));
        end
        gnucMinorIdx=strncmp(compInfo.sysCompDefines,'__GNUC_MINOR__=',15);
        if~any(gnucMinorIdx)
            compInfo.sysCompDefines{end+1}=sprintf('__GNUC_MINOR__=%d',gnu_version(2));
        end
    elseif strncmp(dialect,'visual',6)


        mscVerIdx=strncmp(compInfo.sysCompDefines,'_MSC_VER=',9);
        if~any(mscVerIdx)
            switch dialect
            case 'visual6'
                mVer='1200';
            case 'visual7.0'
                mVer='1300';
            case{'visual','visual7.1'}
                mVer='1310';
            case 'visual8'
                mVer='1400';
            case 'visual9.0'
                mVer='1500';
            case 'visual10'
                mVer='1600';
            case 'visual11.0'
                mVer='1700';
            otherwise

                assert(false);
            end
            compInfo.sysCompDefines{end+1}=sprintf('_MSC_VER=%s',mVer);
        end
    else
        switch dialect
        case 'iso'
            compInfo.languageExtra=[compInfo.LanguageExtra...
            ,{'--strict','--dep_name',...
            '--implicit_extern_c_type_conversion',...
            '--distinct_template_signatures'}];
        case 'cfront2'
            compInfo.languageExtra{end+1}='--cfront_2.1';
        case 'cfront3'
            compInfo.languageExtra{end+1}='--cfront_3.0';
        case 'keil'
            compInfo.languageExtra{end+1}='--keil';
        case 'iar'
            compInfo.languageExtra{end+1}='--iar';
        case{'default','none'}
        otherwise

            assert(false,'The dialect ''%s'' is unknown',dialect);
        end
    end







    frontEndOptions=internal.cxxfe.util.getMexFrontEndOptions('lang',lang,...
    'compInfoFromPsConfigure',compInfo);


    function checkTypeKindAndSize(typeName,typeKind,typeSize)
        switch typeKind
        case{'short','ushort'}
            assert(strcmp(target_options('sizeof_short'),typeSize),...
            'The ''%s'' type size should match the ''sizeof_short'' value',typeName);
        case{'int','uint'}
            assert(strcmp(target_options('sizeof_int'),typeSize),...
            'The ''%s'' type size should match the ''sizeof_int'' value',typeName);
        case{'long','ulong'}
            assert(strcmp(target_options('sizeof_long'),typeSize),...
            'The ''%s'' type size should match the ''sizeof_long'' value',typeName);
        case{'longlong','ulonglong'}
            assert(strcmp(target_options('sizeof_long_long'),typeSize),...
            'The ''%s'' type size should match the ''sizeof_long_long'' value',typeName);
        otherwise
            assert(false,...
            'The ''%s'' type kind (associated to the ''%s'' type) is unknown',typeKind,typeName);
        end
    end
end

function res=psConfigureTypeToFEOptsTypeKind(t)



    res=regexprep(t,{'^unsigned_','_'},{'u',''});
end



