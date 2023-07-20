function kcell=handleKernelArgs(module,cProto,name)
    ;%#ok undocumented




    entrySpecified=nargin>2;
    cProtoSpecified=nargin>1;

    if~entrySpecified
        name='';
    end


    if~ischar(module)
        error(message('parallel:gpu:kernel:InvalidModuleArg'));
    end
    if~ischar(name)
        error(message('parallel:gpu:kernel:InvalidEntryArg'));
    end
    if cProtoSpecified
        if~ischar(cProto)
            error(message('parallel:gpu:kernel:InvalidPrototypeArg'));
        end
    end

    if exist(module,'file')

        ptx=iReadAsciiFile(module);

        if~cProtoSpecified

            [dirname,fname,~]=fileparts(module);
            cProto=fullfile(dirname,[fname,'.cu']);
            if~exist(cProto,'file')
                error(message('parallel:gpu:kernel:CUFileNotFound',module));
            end
        end
    else
        if~cProtoSpecified
            error(message('parallel:gpu:kernel:PrototypeRequired'));
        end
        ptx=reshape(module,1,numel(module));
    end

    if~iCheckIsValidPTX(ptx)
        error(message('parallel:gpu:kernel:InvalidInputArgument'));
    end


    try
        if entrySpecified


            name=iCheckEntryNameInPTX(name,ptx);
        else
            name=iLoadSingleEntryFromPTX(ptx);
        end
    catch E
        throw(E);
    end



    if exist(cProto,'file')
        cProto=iFindCPrototypeForPTXname(cProto,name);
    else




        [~,~,ext]=fileparts(cProto);
        if strcmpi(ext,'.CU')
            error(message('parallel:gpu:kernel:CouldNotReadCUFile',cProto));
        end
    end

    varsIn=iParseCPrototype(cProto);

    iCheckPTXEntryAgainstCProto(ptx,varsIn,name);


    nrhs=numel(varsIn);
    [lhstypes,nlhs]=iGetOutputTypes(varsIn);

    kcell={ptx,name,uint32(nlhs),uint32(nrhs),...
    logical([varsIn.pointer]),logical([varsIn.const]),...
    uint32(lhstypes),{varsIn.class},...
    logical([varsIn.iscomplex])};
end

function entry=iGetEntriesFromPTX(ptx)


    entryPattern='\.entry\s+(?<name>.*?)\s*\(';
    entry=regexp(ptx,entryPattern,'names');
end

function name=iLoadSingleEntryFromPTX(ptx)

    entry=iGetEntriesFromPTX(ptx);

    if numel(entry)>1
        entryNames=sprintf('%s\n',entry.name);
        error(message('parallel:gpu:kernel:TooManyEntries',entryNames));
    end
    if numel(entry)~=1
        error(message('parallel:gpu:kernel:NoEntries'));
    end
    name=entry.name;
end

function name=iCheckEntryNameInPTX(name,ptx)

    entry=iGetEntriesFromPTX(ptx);

    if numel(entry)==0
        error(message('parallel:gpu:kernel:NoEntries'));
    end

    [names{1:numel(entry)}]=deal(entry.name);

    found=~cellfun(@isempty,regexp(names,name));
    if sum(found)>1


        prefix=num2str(length(name));
        newFound=~cellfun(@isempty,regexp(names,[prefix,name]));

        if sum(newFound)~=1
            matches=sprintf('%s\n',entry(found).name);
            error(message('parallel:gpu:kernel:MultipleMatchingEntries',matches));
        end
        found=newFound;
    end

    if sum(found)==0
        entryNames=sprintf('%s\n',entry.name);
        error(message('parallel:gpu:kernel:NoEntriesFound',name,entryNames));
    end

    name=names{found};
end

function str=iReadAsciiFile(name)

    fid=fopen(name,'r');
    if fid<0
        error(message('parallel:gpu:kernel:InvalidFile',name));
    end

    str=fread(fid,[1,inf],'char=>char');

    fclose(fid);
end

function[types,nlhs]=iGetOutputTypes(vars)


    types=zeros(1,numel(vars));
    nlhs=0;
    for i=1:numel(vars)
        thisVar=vars(i);
        if~thisVar.pointer

            types(i)=0;
        else
            if thisVar.const

                types(i)=1;
            else

                types(i)=2;
                nlhs=nlhs+1;
            end
        end
    end
end

function vars=iParseCPrototype(proto)

    proto=regexprep(proto,'\*',' * ');


    proto=regexprep(proto,'\s*',' ');

    tokens=regexp(proto,'\s*(?<varDecl>.*?)\s*(,|$)','names');
    vars=cell(1,numel(tokens));
    for i=1:numel(tokens)
        vars{i}=iParseToken(tokens(i).varDecl);
    end

    vars=[vars{:}];
end

function var=iParseToken(declaration)


    declaration=regexprep(declaration,'(.+)\s+(.+)\s*\[\s*\w*\s*\]','$1 * $2');

    tokens=regexp(declaration,'\S+','match');

    if numel(tokens)==0
        error(message('parallel:gpu:kernel:InvalidVariableDeclaration'));
    end

    [isConst,tokens]=iTokensBeginWith(tokens,'const');

    signedTypes={'unsigned','signed'};
    [signedIndex,tokens]=iTokensBeginWith(tokens,signedTypes);

    realTypes={'double','float','double2','float2'};
    [realIndex,tokens]=iTokensBeginWith(tokens,realTypes);
    if realIndex>0

        if signedIndex~=0
            error(message('parallel:gpu:kernel:NoUnsignedFloatTypes'));
        end

        switch realIndex
        case{1,3}
            class='double';
        case{2,4}
            class='single';
        end

        complexFlag=(realIndex>=3);

        type=sprintf('%s',realTypes{realIndex});
    else

        isUnsigned=signedIndex==1;
        complexFlag=false;




        unsignedTypes={'size_t'};
        logicalTypes={'bool'};
        realTypes={'ptrdiff_t','char','short','int','long'};
        cplxTypes={'uchar2','char2','ushort2','short2',...
        'int2','uint2','long2','ulong2',...
        'longlong2','ulonglong2'};


        realTypes=[realTypes,{'int8_T','int16_T','int32_T','int64_T'}];
        unsignedTypes=[unsignedTypes,{'uint8_T','uint16_T','uint32_T','uint64_T'}];

        types=[unsignedTypes,logicalTypes,realTypes,cplxTypes];

        i=1;
        typeIndex=zeros(4,1);

        while true
            [thisTypeIndex,tokens]=iTokensBeginWith(tokens,types);
            isUnsigned=isUnsigned||(thisTypeIndex>0&&thisTypeIndex<=length(unsignedTypes));
            typeIndex(i)=thisTypeIndex;

            if thisTypeIndex==0
                break
            end
            i=i+1;
        end

        type=sprintf('%s ',types{typeIndex(typeIndex~=0)});

        type=type(1:end-1);

        if isempty(type)

            error(message('parallel:gpu:kernel:UnsupportedType',declaration));
        end

        if ismember(type,logicalTypes)
            if isUnsigned
                error(message('parallel:gpu:kernel:BadBoolPrototype'));
            end
        end


        mlLen=8*parallel.internal.gpu.getCTypeSize(type);

        if ismember(type,cplxTypes)

            mlLen=mlLen/2;
            complexFlag=true;

            isUnsigned=isequal(type(1),'u');
        end



        if mlLen<8
            error(message('parallel:gpu:kernel:UnknownType',declaration));
        end
        if ismember(type,logicalTypes)

            class='logical';
            type='bool';
        else

            suffix=sprintf('%d',mlLen);
            if isUnsigned
                prefix='u';
            else
                prefix='';
            end
            class=sprintf('%sint%s',prefix,suffix);
            if signedIndex>0
                type=sprintf('%s %s',signedTypes{signedIndex},type);
            end
        end
    end

    [tmpIsConst,tokens]=iTokensBeginWith(tokens,'const');
    isConst=isConst||tmpIsConst;

    [isPointer,tokens]=iTokensBeginWith(tokens,'*');
    if isPointer

        [~,tokens]=iTokensBeginWith(tokens,'__restrict__');

        [~,tokens]=iTokensBeginWith(tokens,'const');
        [~,tokens]=iTokensBeginWith(tokens,'__restrict__');
    end

    if numel(tokens)>1
        error(message('parallel:gpu:kernel:CannotParseDeclaration',declaration));
    end
    if isempty(tokens)
        name='';
    else
        name=tokens{1};
    end
    var=struct('const',isConst,...
    'cdecl',declaration,...
    'ctype',type,...
    'class',class,...
    'iscomplex',complexFlag,...
    'castFcn',str2func(class),...
    'pointer',isPointer,...
    'name',name);
end


function[idx,tokens]=iTokensBeginWith(tokens,aToken)




    if numel(tokens)<1
        idx=0;
        return
    end
    idx=strcmp(tokens{1},aToken);
    if numel(idx)>1
        idx=find(idx,1,'first');
        if isempty(idx)
            idx=false;
        end
    end
    if idx>0
        tokens=tokens(2:end);
    end
end


function iCheckPTXEntryAgainstCProto(ptx,vars,entryName)

    ptxVersion=regexp(ptx,'(?<=.version\s+)[\d\.]+','match','once');

    if str2double(ptxVersion)<1.4
        warning(message('parallel:gpu:kernel:IncorrectPTXVersion',ptxVersion));
        return
    end


    entryPattern=['\.entry\s+',entryName,'\s*\([^\)]+\)'];
    entry=regexp(ptx,entryPattern,'match','once');

    paramTypePattern='(?<=\.param\s*(.align\s*[0-9]*\s*)?)\.([ubs](8|16|32|64)|f(32|64))(?=\s+)';
    paramTypes=regexp(entry,paramTypePattern,'match');

    if numel(paramTypes)~=numel(vars)
        error(message('parallel:gpu:kernel:ArgMismatch',numel(paramTypes),numel(vars)));
    end
    is64bit=iComputerIs64bit;
    if is64bit
        ptxPointerType='.u64';
    else
        ptxPointerType='.u32';
    end
    mappings={...
    'logical .s8';...
    'uint8 .u8';...
    'uint16 .u16';...
    'uint32 .u32';...
    'uint64 .u64';...
    'int8 .s8';...
    'int16 .s16';...
    'int32 .s32';...
    'int64 .s64';...
    'single .f32';...
    'double .f64';...
    };




    mappings=[
    mappings;...
    'logical .u8';...
    'int8 .u8';...
    'int16 .u16';...
    'int32 .u32';...
    'int64 .u64';...
    'uint8 .s8';...
    'uint16 .s16';...
    'uint32 .s32';...
    'uint64 .s64';...
    ];

    for i=1:numel(vars)
        if vars(i).pointer
            if~strcmp(paramTypes{i},ptxPointerType)
                warning(message('parallel:gpu:kernel:PrototypeMismatchExpectedPointer',i,paramTypes{i}));
            end
        else

            if~vars(i).iscomplex
                if~any(strcmp([vars(i).class,' ',paramTypes{i}],mappings))
                    warning(message('parallel:gpu:kernel:PrototypeMismatchInvalidMapping',i,vars(i).class,paramTypes{i}));
                end
            end
        end
    end
end

function[OK,cName,ptxProto]=iParsePTXEntryName(entryName)
    OK=false;
    cName='';
    ptxProto='';

    p=regexp(entryName,'(?<prefix>_Z)(?<numChars>\d+)(?<suffix>.*)','names');

    if numel(p)==1&&~isempty(p.prefix)&&~isempty(p.numChars)&&~isempty(p.suffix)
        cNameLen=str2double(p.numChars);
        if cNameLen<numel(p.suffix)
            cName=p.suffix(1:cNameLen);
            ptxProto=p.suffix(cNameLen+1:end);
            OK=true;
        end
    end
end

function cProto=iFindCPrototypeForPTXname(cuFilename,ptxEntryName)

    cCode=iReadAsciiFile(cuFilename);

    [OK,cName]=iParsePTXEntryName(ptxEntryName);
    if~OK
        error(message('parallel:gpu:kernel:UnableToParsePtxEntryName'));
    end

    protoPattern=['(?<=__global__\s+\w+\s+',cName,'\s*\()[^)]+(?=\))'];
    cProto=regexp(cCode,protoPattern,'match','once');

    if isempty(cProto)
        protoPattern=['(?<=\w+\s+__global__\s+',cName,'\s*\()[^)]+(?=\))'];
        cProto=regexp(cCode,protoPattern,'match','once');
    end
end

function is64bit=iComputerIs64bit
    is64bit=contains(computer,'64');
end


function OK=iCheckIsValidPTX(ptx)

    isPtxPattern='\.version.*\.entry.*\.([us](8|16|32|64)|f(32|64))';
    OK=~isempty(regexp(ptx,isPtxPattern,'once'));
end
