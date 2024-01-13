function feOpts=extractFEOptsFromSnifferOutput(psOutputDumpFile,psDefaultOptions)

    feOpts=containers.Map('KeyType','char','ValueType','any');
    if~exist(psOutputDumpFile,'file')
        return;
    end
    fine(polyspace.internal.logging.Logger.getLogger('CompilerCmd'),...
    'Extracting the front-end options from the ''polyspace-configure'' output dump file...\n');
    fid=fopen(psOutputDumpFile,'rt');
    closeOutputDumpFile=onCleanup(@()fclose(fid));

    dialect='';
    includes=containers.Map('KeyType','char','ValueType','any');
    system_includes=containers.Map('KeyType','char','ValueType','any');
    implicit_includes=containers.Map('KeyType','char','ValueType','any');
    preincludes=containers.Map('KeyType','char','ValueType','any');
    defines=containers.Map('KeyType','char','ValueType','any');
    implicit_defines=containers.Map('KeyType','char','ValueType','any');
    undefines=containers.Map('KeyType','char','ValueType','any');
    target_options=containers.Map('KeyType','char','ValueType','any');
    compiler_semantic_options=containers.Map('KeyType','char','ValueType','any');
    compilation_units={};

    while true
        tline=fgets(fid);
        if~ischar(tline)
            break
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

                [~,f,e]=fileparts(tmp{2});
                fileName=[f,e];
                compilation_units{end+1}=fileName;%#ok
                includes(fileName)={};
                system_includes(fileName)={};
                implicit_includes(fileName)={};
                preincludes(fileName)={};
                defines(fileName)={};
                implicit_defines(fileName)={};
                undefines(fileName)={};
                compiler_semantic_options(fileName)={};
                target_options(fileName)=containers.Map('KeyType','char','ValueType','any');
                continue
            case 'include'
                includes_l=includes(compilation_units{end});
                includes_l(end+1)=tmp(2);%#ok<AGROW>
                includes(compilation_units{end})=includes_l;
                continue
            case 'system_include'
                system_includes_l=system_includes(compilation_units{end});
                system_includes_l(end+1)=tmp(2);%#ok<AGROW>
                system_includes(compilation_units{end})=system_includes_l;
                continue
            case 'implicit_include'
                implicit_includes_l=implicit_includes(compilation_units{end});
                implicit_includes_l(end+1)=tmp(2);%#ok<AGROW>
                implicit_includes(compilation_units{end})=implicit_includes_l;
                continue
            case 'preinclude'
                preincludes_l=preincludes(compilation_units{end});
                preincludes_l(end+1)=tmp(2);%#ok<AGROW>
                preincludes(compilation_units{end})=preincludes_l;
                continue
            case 'define'
                defines_l=defines(compilation_units{end});
                defines_l(end+1)=tmp(2);%#ok<AGROW>
                defines(compilation_units{end})=defines_l;
                continue
            case 'implicit_define'
                implicit_defines_l=implicit_defines(compilation_units{end});
                implicit_defines_l(end+1)=tmp(2);%#ok<AGROW>
                implicit_defines(compilation_units{end})=implicit_defines_l;
                continue
            case 'undefine'
                undefines_l=undefines(compilation_units{end});
                undefines_l(end+1)=tmp(2);%#ok<AGROW>
                undefines(compilation_units{end})=undefines_l;
                continue
            case 'compiler_semantic_option'
                compiler_semantic_option_l=compiler_semantic_options(compilation_units{end});
                compiler_semantic_option_l(end+1)=tmp(2);%#ok<AGROW>
                compiler_semantic_options(compilation_units{end})=compiler_semantic_option_l;
                continue
            end
        end

        tmp=regexp(tline,'cu[0-9]+\s+target: (.*?): (.*?)\s*$','tokens');
        if~isempty(tmp)
            tmp=tmp{1};
            if strcmp(tmp{2},'-1')
                continue
            end
            target_options_l=target_options(compilation_units{end});
            target_options_l(tmp{1})=tmp{2};
            target_options(compilation_units{end})=target_options_l;
            continue
        end

    end

    clear closeOutputDumpFile;

    for i=1:length(compilation_units)
        compilation_unit=compilation_units{i};

        compInfo=struct('targetSettings',struct(),...
        'sysHeaderDirs',{[system_includes(compilation_unit),implicit_includes(compilation_unit)]},...
        'mwHeaderDirs',{includes(compilation_unit)},...
        'sysCompDefines',{implicit_defines(compilation_unit)},...
        'mwCompDefines',{defines(compilation_unit)},...
        'unDefines',{undefines(compilation_unit)},...
        'preIncludes',{preincludes(compilation_unit)},...
        'languageExtra',{{}},...
        'compilerFlags',{compiler_semantic_options(compilation_unit)});
        target_options_l=target_options(compilation_unit);
        if target_options_l.isKey('endianness')&&~strcmpi(target_options_l('endianness'),'unknown')
            compInfo.targetSettings.Endianness=target_options_l('endianness');
        end
        compInfo.targetSettings.CharNumBits=psGetNumericOption('char_number_of_bits',...
        target_options_l,...
        psDefaultOptions);
        compInfo.targetSettings.ShortNumBits=psGetNumericOption('sizeof_short',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);
        compInfo.targetSettings.IntNumBits=psGetNumericOption('sizeof_int',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);
        compInfo.targetSettings.LongNumBits=psGetNumericOption('sizeof_long',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);
        if target_options_l.isKey('sizeof_long_long')
            compInfo.targetSettings.LongLongNumBits=sscanf(target_options_l('sizeof_long_long'),'%d')*compInfo.targetSettings.CharNumBits;
        end
        if target_options_l.isKey('sizeof_short_long')
            compInfo.targetSettings.ShortLongNumBits=sscanf(target_options_l('sizeof_short_long'),'%d')*compInfo.targetSettings.CharNumBits;
        end
        compInfo.targetSettings.FloatNumBits=psGetNumericOption('sizeof_float',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);
        compInfo.targetSettings.DoubleNumBits=psGetNumericOption('sizeof_double',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);
        if target_options_l.isKey('sizeof_long_double')
            compInfo.targetSettings.LongDoubleNumBits=sscanf(target_options_l('sizeof_long_double'),'%d')*compInfo.targetSettings.CharNumBits;
        end
        compInfo.targetSettings.PointerNumBits=psGetNumericOption('sizeof_pointer',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);
        compInfo.targetSettings.SizeTNumBits=psGetNumericOption('sizeof_size_t',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);
        compInfo.targetSettings.PtrDiffTNumBits=psGetNumericOption('sizeof_ptrdiff_t',...
        target_options_l,...
        psDefaultOptions,...
        compInfo.targetSettings.CharNumBits);


        if strncmp(target_options_l('language'),'C++',3)
            lang='cxx';
            if strncmp(target_options_l('language'),'C++1',4)
                idx=strncmp(compInfo.sysCompDefines,'__cplusplus=',12);
                if~any(idx)
                    compInfo.sysCompDefines{end+1}='__cplusplus=201103L';
                end
            end
        else
            lang='c';
        end
        compInfo.targetSettings.AllowShortLong=target_options_l.isKey('sizeof_short_long');
        compInfo.targetSettings.AllowLongLong=target_options_l.isKey('sizeof_long_long');
        compInfo.targetSettings.MinStructAlignment=psGetNumericOption('alignof_struct',...
        target_options_l,...
        psDefaultOptions);
        compInfo.targetSettings.MaxAlignment=sscanf(target_options_l('max_alignment'),'%d');
        if~strcmp(target_options_l('integral_type_for_ptrdiff_t'),'unknown')
            compInfo.targetSettings.PtrDiffTypeKind=psConfigureTypeToFEOptsTypeKind(target_options_l('integral_type_for_ptrdiff_t'));
            checkTypeKindAndSize(target_options_l,'ptrdiff_t',compInfo.targetSettings.PtrDiffTypeKind,target_options_l('sizeof_ptrdiff_t'));
        end
        if~strcmp(target_options_l('integral_type_for_size_t'),'unknown')
            compInfo.targetSettings.SizeTypeKind=psConfigureTypeToFEOptsTypeKind(target_options_l('integral_type_for_size_t'));
            checkTypeKindAndSize(target_options_l,'size_t',compInfo.targetSettings.SizeTypeKind,target_options_l('sizeof_size_t'));
        end
        if~strcmp(target_options_l('integral_type_for_wchar_t'),'unknown')
            compInfo.targetSettings.WcharTypeKind=psConfigureTypeToFEOptsTypeKind(target_options_l('integral_type_for_wchar_t'));
            if strcmp(compInfo.targetSettings.WcharTypeKind(1),'u')~=~strcmp(target_options_l('signed_wchar_t'),'1')
                error(message('polyspace:pscore:invalidWcharType'));
            end
            if target_options_l.isKey('sizeof_wchar_t')
                checkTypeKindAndSize(target_options_l,'wchar_t',compInfo.targetSettings.WcharTypeKind,target_options_l('sizeof_wchar_t'));
            end
        end
        compInfo.targetSettings.AllowMultibyteChars=true;
        compInfo.targetSettings.PlainCharsAreSigned=strcmp(target_options_l('signed_char'),'1');

        compInfo.targetSettings.PlainBitFieldsAreSigned=true;

        if any(strncmp(compInfo.sysCompDefines,'__GNUC__=',9))
            declspecIdx=strcmp(compInfo.sysCompDefines,'__declspec=__declspec');
            if any(declspecIdx)
                compInfo.sysCompDefines{declspecIdx}='__declspec(x)=__attribute__((x))';
            elseif ispc

                compInfo.sysCompDefines{end+1}='__declspec(x)=__attribute__((x))';
            end
        end

        if strncmp(dialect,'gnu',3)
            gnu_version=sscanf(dialect,'gnu%d.%d');
            gnucMajorIdx=strncmp(compInfo.sysCompDefines,'__GNUC__=',9);
            if~any(gnucMajorIdx)&&(numel(gnu_version)>=1)
                compInfo.sysCompDefines{end+1}=sprintf('__GNUC__=%d',gnu_version(1));
            end
            gnucMinorIdx=strncmp(compInfo.sysCompDefines,'__GNUC_MINOR__=',15);
            if~any(gnucMinorIdx)&&(numel(gnu_version)>=2)
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
                case 'visual12.0'
                    mVer='1800';
                case 'visual14.0'
                    mVer='1902';
                case 'visual15.x'
                    mVer='1914';
                case 'visual16.x'
                    mVer='1920';
                otherwise
                    mVer='';
                end
                if~isempty(mVer)
                    compInfo.sysCompDefines{end+1}=sprintf('_MSC_VER=%s',mVer);
                end
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
            otherwise




            end
        end







        cuFEOpts=...
        internal.cxxfe.util.getMexFrontEndOptions(...
        'lang',lang,...
        'compInfoFromPsConfigure',compInfo);
        feOpts(compilation_unit)=cuFEOpts;

    end
end


function checkTypeKindAndSize(target_options_l,typeName,typeKind,typeSize)
    switch typeKind
    case{'char','uchar'}
        if~strcmp('1',typeSize)
            error(message('polyspace:pscore:invalidTypeSize',typeName,'sizeof_char'));
        end
    case{'short','ushort'}
        if~strcmp(target_options_l('sizeof_short'),typeSize)
            error(message('polyspace:pscore:invalidTypeSize',typeName,'sizeof_short'));
        end
    case{'int','uint'}
        if~strcmp(target_options_l('sizeof_int'),typeSize)
            error(message('polyspace:pscore:invalidTypeSize',typeName,'sizeof_int'));
        end
    case{'long','ulong'}
        if~strcmp(target_options_l('sizeof_long'),typeSize)
            error(message('polyspace:pscore:invalidTypeSize',typeName,'sizeof_long'));
        end
    case{'longlong','ulonglong'}
        if~strcmp(target_options_l('sizeof_long_long'),typeSize)
            error(message('polyspace:pscore:invalidTypeSize',typeName,'sizeof_long_long'));
        end
    case{'shortlong','ushortlong'}
        if~strcmp(target_options_l('sizeof_short_long'),typeSize)
            error(message('polyspace:pscore:invalidTypeSize',typeName,'sizeof_short_long'));
        end
    otherwise
        error(message('polyspace:pscore:unknownTypeKind',typeKind,typeName));
    end
end

function res=psConfigureTypeToFEOptsTypeKind(t)



    res=regexprep(t,{'^unsigned_','_'},{'u',''});
end













function res=psGetNumericOption(lFieldName,lTargetOptions,lDefaultOptions,lBitsInByte)
    if lTargetOptions.isKey(lFieldName)
        res=sscanf(lTargetOptions(lFieldName),'%d');
        if nargin>3
            res=res*lBitsInByte;
        end
    elseif~isempty(lDefaultOptions)&&lDefaultOptions.isKey(lFieldName)
        res=lDefaultOptions(lFieldName);
    else
        error(message('polyspace:pscore:unknownOption',lFieldName));
    end
end





