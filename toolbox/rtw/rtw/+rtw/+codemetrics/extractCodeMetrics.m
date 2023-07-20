function[msg,info]=extractCodeMetrics(srcfile,ccm)



    [~,~,filext]=fileparts(srcfile);
    isCppFile=ccm.targetisCPP||strcmpi(filext,'.cpp');
    if isempty(ccm)
        if isCppFile
            opts=i_create_default_frontend_options('cxx');
        else
            opts=i_create_default_frontend_options('c');
        end
        opts.Language.MaxAlignment=1;
        opts.ExtraOptions{end+1}='--extract_code_metrics';
        new4mdlref=false;
    else
        opts=deepCopy(ccm.CodeMetricsOption);
        new4mdlref=ccm.UseNewForMdlRef;
    end

    if isCppFile
        opts.Language.LanguageMode='cxx';



        if any(strcmp(opts.Preprocessor.Defines,'__LCC__'))&&...
            (any(strcmp(opts.Language.LanguageExtra,'--microsoft'))||any(strcmp(opts.ExtraOptions,'--microsoft')))
            opts.Preprocessor.Defines{end+1}='_SIZE_T_DEFINED';
        end
    else
        opts.Language.LanguageMode='c';
    end

    info=struct('fileInfo',[],'fcnInfo',[],'globalVarInfo',[],'globalConstInfo',[],'classMemberInfo',[]);
    temp_folder=tempname;
    mkdir(temp_folder);
    cleanup_temp=onCleanup(@()rmdir(temp_folder,'s'));
    cm_db=fullfile(temp_folder,'cm.db');


    dbObj=internal.cxxfe.util.CodeMetricsExtractor(cm_db);
    [msg,ok]=dbObj.extract(srcfile,opts);

    if ok
        db=dbObj.retrieve();
    else
        return;
    end







    SystemFileIdx=[];

    ecfileInfo=struct('Name',[],...
    'Idx',[],...
    'IncludedIdx',[],...
    'IsIncludedFile',[],...
    'IsSystemFile',[],...
    'NumCommentLines',[],...
    'NumTotalLines',[],...
    'NumCodeLines',[],...
    'IncludedFile',[]);

    info.fileInfo=repmat(ecfileInfo,1,length(db.Files));

    for curr=1:length(db.Files)
        info.fileInfo(curr).Name=db.Files(curr).Path;
        info.fileInfo(curr).Idx=curr;


        for k=1:length(db.Files)
            if db.Files(k).RefParentFile==curr
                info.fileInfo(curr).IncludedIdx=[info.fileInfo(curr).IncludedIdx,k];
                info.fileInfo(curr).IncludedFile=[info.fileInfo(curr).IncludedFile,{db.Files(k).Path}];
            end
        end


        if isempty(db.Files(curr).RefParentFile)
            info.fileInfo(curr).IsIncludedFile=false;
        else
            info.fileInfo(curr).IsIncludedFile=true;
        end



        id=SearchCodeMetrics(db.CodeMetrics,curr,0,0,2);
        info.fileInfo(curr).NumCommentLines=uint32(db.CodeMetrics(id).Value);


        info.fileInfo(curr).NumTotalLines=uint32(db.CodeMetrics(id-1).Value);


        info.fileInfo(curr).NumCodeLines=uint32(db.CodeMetrics(id+1).Value);





        if info.fileInfo(curr).NumTotalLines==0
            SystemFileIdx=[SystemFileIdx,curr];%#ok
        end
    end


    RefName_StackSize=0;
    if length(db.CodeMetricsNames)>25
        if strcmpi(db.CodeMetricsNames(26).Name,'stacksize_locals_worst')
            RefName_StackSize=26;
        else
            RefName_StackSize=27;
        end
    end

    ndef_func=[];
    for curr=1:length(db.Functions)

        if db.Functions(curr).BodyLineNum==0||isInCppSystemDirs(opts,db,db.Functions(curr))
            continue;
        end

        [ecfcnInfos,ndef_function]=getFcnInfo(opts,db,curr,RefName_StackSize);
        info.fcnInfo=[info.fcnInfo,ecfcnInfos];
        ndef_func=[ndef_func,ndef_function];%#ok
    end

    ndef_function_idx=unique(ndef_func);
    for curr=1:length(ndef_function_idx)
        ecfcnInfos=getFcnInfo(opts,db,ndef_function_idx(curr),RefName_StackSize);
        info.fcnInfo=[info.fcnInfo,ecfcnInfos];
    end










    parent2Child=containers.Map('KeyType','double','ValueType','any');
    for dbIdx=1:length(db.Variables)
        refParent=db.Variables(dbIdx).RefParent;
        if~isempty(refParent)
            if isKey(parent2Child,refParent)
                parent2Child(refParent)=[parent2Child(refParent),dbIdx];
            else
                parent2Child(refParent)=dbIdx;
            end
        end
    end


    refVar2UseIdx=containers.Map('KeyType','double','ValueType','any');
    for dbIdx=1:length(db.Uses)
        refVar=db.Uses(dbIdx).RefVar;
        if~isempty(refVar)
            if isKey(refVar2UseIdx,refVar)
                refVar2UseIdx(refVar)=[refVar2UseIdx(refVar),dbIdx];
            else
                refVar2UseIdx(refVar)=dbIdx;
            end
        end
    end

    for curr=1:length(db.Variables)
        if~isempty(db.Variables(curr).RefParent)
            continue;
        end

        db.Variables(curr).RefParent=0;

        if~isempty(find(SystemFileIdx==db.Variables(curr).RefFile,1))
            continue;
        end

        if~db.Variables(curr).isConstant
            ecglobalVarInfo=getGlobalVarInfo(parent2Child,refVar2UseIdx,db,curr,0,0);
            info.globalVarInfo=[info.globalVarInfo,ecglobalVarInfo];
        elseif db.Variables(curr).UseCount>0
            ecglobalConstInfo=...
            struct('Name',db.Variables(curr).Name,...
            'FileIdx',db.Variables(curr).RefFile,...
            'Size',[],...
            'File',[],...
            'IsStatic',logical(db.Variables(curr).isStatic));


            RefIdx=db.Variables(curr).RefType;
            ecglobalConstInfo.Size=uint32(db.Types(RefIdx).Size);


            RefIdx=db.Variables(curr).RefFile;
            ecglobalConstInfo.File={db.Files(RefIdx).Path};

            info.globalConstInfo=[info.globalConstInfo,ecglobalConstInfo];
        end
    end












    if isCppFile
        for curr=1:length(db.Types)
            RefType=db.Types(curr);
            if(strcmpi(RefType.KindName,'tk_class'))
                ClassInfo=...
                struct('Name',db.Types(curr).Name,...
                'FileIdx',db.Types(curr).RefFile,...
                'Size',[],...
                'File',[],...
                'IsStatic',[],...
                'IsBitField',[],...
                'IsExported',[],...
                'UseCount',[],...
                'Members',[],...
                'UseInFunctions',[]);


                ClassInfo.Size=uint32(db.Types(curr).Size);


                FileIdx=db.Types(curr).RefFile;
                ClassInfo.File={db.Files(FileIdx).Path};


                ClassInfo.IsStatic=false;


                ClassInfo.IsBitField=false;


                ClassInfo.IsExported=true;


                ClassInfo.UseCount=uint32(0);
                ClassInfo.UseInFunctions=[];

                ChildIdx=find([db.Fields.RefParentType]==curr);

                class_size=0;
                for c_idx=1:length(ChildIdx)
                    ChildInfo=getClassInfo(db,ChildIdx(c_idx),[],new4mdlref);
                    ClassInfo.Members=[ClassInfo.Members,ChildInfo];
                    class_size=uint32(class_size+ChildInfo.Size);
                end
                if new4mdlref
                    ClassInfo.Size=uint32(class_size);
                end
                info.classMemberInfo=[info.classMemberInfo,ClassInfo];
            end
        end
    end
end




function isSystemFile=isInCppSystemDirs(aOpts,aDB,aFcn)
    isSystemFile=false;
    if~strcmpi(aOpts.Language.LanguageMode,'cxx')
        return;
    end
    fileFullName=aDB.Files(aFcn.RefFile).Path;
    for fIdx=1:length(aOpts.Preprocessor.SystemIncludeDirs)
        findPath=strfind(fileFullName,aOpts.Preprocessor.SystemIncludeDirs{fIdx});
        if~isempty(findPath)&&findPath==1
            isSystemFile=true;
            return;
        end
    end
end





function index=SearchCodeMetrics(CM_Table,TrgFile,TrgFunc,TrgVar,TrgName)
    upb=length(CM_Table);
    lwb=1;
    index=floor((upb+lwb)/2);
    while(CM_Table(index).RefFile~=TrgFile||...
        CM_Table(index).RefFunc~=TrgFunc||...
        CM_Table(index).RefVar~=TrgVar||...
        CM_Table(index).RefName~=TrgName)
        if CM_Table(index).RefFile>TrgFile
            upb=index;
        elseif CM_Table(index).RefFile<TrgFile
            lwb=index;
        else
            if CM_Table(index).RefFunc>TrgFunc
                upb=index;
            elseif CM_Table(index).RefFunc<TrgFunc
                lwb=index;
            else
                if CM_Table(index).RefVar>TrgVar
                    upb=index;
                elseif CM_Table(index).RefVar<TrgVar
                    lwb=index;
                else
                    if CM_Table(index).RefName>TrgName
                        upb=index;
                    else
                        lwb=index;
                    end
                end
            end
        end
        index=floor((upb+lwb)/2);
    end
end





function value=SearchCodeMetrics2(CM_Table,TrgFile,TrgFunc,TrgVar,TrgName)
    index=[CM_Table.RefFile]==TrgFile&...
    [CM_Table.RefFunc]==TrgFunc&...
    [CM_Table.RefVar]==TrgVar&...
    [CM_Table.RefName]==TrgName;
    value=CM_Table(index).Value;
end





function[DataCopys,DataCopyDetails]=getDataCopyDetails(DataBase,index)
    DataCopyIdx=find([DataBase.CopyInfos.RefFunc]==index);
    DataCopys=uint32(0);
    len=length(DataCopyIdx);

    DataCopyDetails=struct(...
    'Location',cell(1,len),...
    'TypeName',cell(1,len),...
    'TypeClass',cell(1,len),...
    'Locality',cell(1,len),...
    'Complete',cell(1,len),...
    'Size',cell(1,len));

    for copyidx=1:len
        CopyInfoEntry=DataBase.CopyInfos(DataCopyIdx(copyidx));

        if CopyInfoEntry.Repetition>0
            size=CopyInfoEntry.Size*CopyInfoEntry.Repetition;
        else
            size=CopyInfoEntry.Size;
        end

        DataCopys=uint32(DataCopys+size);

        DataCopyDetails(copyidx).Location=struct('LineNumber',uint32(CopyInfoEntry.LineNum),'ColumnNumber',uint32(CopyInfoEntry.ColNum));
        DataCopyDetails(copyidx).TypeName=CopyInfoEntry.TypeName;
        DataCopyDetails(copyidx).TypeClass=CopyInfoEntry.TypeClass;
        DataCopyDetails(copyidx).Locality=CopyInfoEntry.Locality;
        DataCopyDetails(copyidx).Complete=logical(CopyInfoEntry.isComplete);
        DataCopyDetails(copyidx).Size=uint32(CopyInfoEntry.Size);
    end

    memcpy=strcmp({DataCopyDetails.Locality},'memcpy');
    DataCopyDetails=DataCopyDetails(~memcpy);

end





function ret=isClassMemberFunction(DataBase,fcnIdx)
    ret=false;
    parentIdx=DataBase.Functions(fcnIdx).RefClassOrNS;
    if~isempty(parentIdx)&&parentIdx>0
        ret=~isempty(DataBase.ClassOrNSes(parentIdx).RefType);
    end
end





function[Calleeer,ndef_func]=getCalleeer(opts,DataBase,index,sel)
    ndef_func=[];
    Calleeer=struct('Name',{},'Weight',{});

    if sel==0
        RefCallIdx=find([DataBase.Calls.RefCaller]==index);
    else
        RefCallIdx=find([DataBase.Calls.RefCallee]==index);
    end

    while~isempty(RefCallIdx)
        ecfcnCall=struct('Name',[],'Weight',[]);
        if sel==0
            refcalleeer=DataBase.Calls(RefCallIdx(1)).RefCallee;
            same_calleeer=find([DataBase.Calls.RefCaller]==index&...
            [DataBase.Calls.RefCallee]==refcalleeer);
        else
            refcalleeer=DataBase.Calls(RefCallIdx(1)).RefCaller;
            same_calleeer=find([DataBase.Calls.RefCallee]==index&...
            [DataBase.Calls.RefCaller]==refcalleeer);
        end

        RefCallIdx=setdiff(RefCallIdx,same_calleeer);

        if isInCppSystemDirs(opts,DataBase,DataBase.Functions(refcalleeer))
            continue;
        end

        ecfcnCall.Name=DataBase.Functions(refcalleeer).Name;
        if DataBase.Functions(refcalleeer).isStatic&&~isClassMemberFunction(DataBase,refcalleeer)
            [~,name,ext]=fileparts(DataBase.Files(DataBase.Functions(refcalleeer).RefFile).Path);
            ecfcnCall.Name=[name,ext,':',ecfcnCall.Name];
        end
        ecfcnCall.Name=attach_ClassOrNS(DataBase,refcalleeer,ecfcnCall.Name);

        if DataBase.Functions(refcalleeer).BodyLineNum==0
            ndef_func=[ndef_func,refcalleeer];%#ok
        end
        ecfcnCall.Weight=uint32(length(same_calleeer));
        Calleeer=[Calleeer,ecfcnCall];%#ok
    end
end





function ClassInfo=getClassInfo(DBase,Index,trvd_types,accu_size)
    ClassInfo=...
    struct('Name',DBase.Fields(Index).Name,...
    'FileIdx',DBase.Fields(Index).RefFile,...
    'Size',[],...
    'File',[],...
    'IsStatic',[],...
    'IsBitField',logical(DBase.Fields(Index).isBitfield),...
    'IsExported',[],...
    'UseCount',[],...
    'Members',[],...
    'UseInFunctions',[]);


    if DBase.Fields(Index).isBitfield
        ClassInfo.Size=uint32(DBase.Fields(Index).BitSize);
    else
        TypeIdx=DBase.Fields(Index).RefType;
        ClassInfo.Size=uint32(DBase.Types(TypeIdx).Size);
    end


    FileIdx=DBase.Fields(Index).RefFile;
    ClassInfo.File={DBase.Files(FileIdx).Path};


    ClassInfo.IsStatic=false;


    ClassInfo.IsExported=false;


    ClassInfo.UseCount=uint32(0);


    ClassInfo.UseInFunctions=[];


    ClassInfo.Members=struct('Name',{},'File',{},'Size',{},'IsStatic',{},'IsBitField',{},'IsExported',{},'UseCount',{},'Members',{},'UseInFunctions',{});

    TypeIdx=DBase.Fields(Index).RefType;
    while~isempty(DBase.Types(TypeIdx).RefBaseType)
        TypeIdx=DBase.Types(TypeIdx).RefBaseType;
    end

    if(strcmpi(DBase.Types(TypeIdx).KindName,'tk_struct')||...
        strcmpi(DBase.Types(TypeIdx).KindName,'tk_class'))&&...
        isempty(find(trvd_types==TypeIdx,1))
        ChildIdx=find([DBase.Fields.RefParentType]==TypeIdx);
        class_size=0;
        for c_idx=1:length(ChildIdx)
            ChildInfo=getClassInfo(DBase,ChildIdx(c_idx),[trvd_types,TypeIdx],accu_size);
            Member=CopyToMember(ChildInfo);
            ClassInfo.Members=[ClassInfo.Members,Member];
            class_size=class_size+ChildInfo.Size;
        end
        if accu_size==1
            ClassInfo.Size=uint32(class_size);
        end
    else
        ClassInfo.Members=[];
    end
end





function GlobalVarInfo=getGlobalVarInfo(parent2ChildMap,var2UseIdxMap,DBase,Index,RefFileIdx,accu_size)
    GlobalVarInfo=...
    struct('Name',DBase.Variables(Index).Name,...
    'FileIdx',DBase.Variables(Index).RefFile,...
    'Size',[],...
    'File',[],...
    'IsStatic',logical(DBase.Variables(Index).isStatic),...
    'IsBitField',[],...
    'IsExported',logical(DBase.Variables(Index).isExported),...
    'UseCount',uint32(DBase.Variables(Index).UseCount),...
    'Members',[],...
    'UseInFunctions',[]);


    RefFieldIdx=DBase.Variables(Index).RefField;
    if isempty(RefFieldIdx)||~DBase.Fields(RefFieldIdx).isBitfield
        RefIdx=DBase.Variables(Index).RefType;
        GlobalVarInfo.Size=uint32(DBase.Types(RefIdx).Size);
    else
        GlobalVarInfo.Size=uint32(DBase.Fields(RefFieldIdx).BitSize);
    end


    if isempty(RefFieldIdx)
        RefFIdx=GlobalVarInfo.FileIdx;
    else
        RefFIdx=DBase.Fields(RefFieldIdx).RefFile;
    end
    if RefFIdx==0
        if RefFileIdx==0
            return;
        end
        RefFIdx=RefFileIdx;
    end
    GlobalVarInfo.File={DBase.Files(RefFIdx).Path};
    GlobalVarInfo.FileIdx=RefFIdx;

    RefClassOrNS=DBase.Variables(Index).RefClassOrNS;
    while RefClassOrNS~=0
        RefType=DBase.ClassOrNSes(RefClassOrNS).RefType;
        RefNamespace=DBase.ClassOrNSes(RefClassOrNS).RefNamespace;
        if RefNamespace==0
            GlobalVarInfo.Name=[DBase.Types(RefType).Name,'::',GlobalVarInfo.Name];
            RefClassOrNS=DBase.Types(RefType).RefClassOrNS;
        else
            GlobalVarInfo.Name=[DBase.Namespaces(RefNamespace).Name,'::',GlobalVarInfo.Name];
            RefClassOrNS=DBase.Namespaces(RefNamespace).RefParentNS;
        end
    end



    if isempty(RefFieldIdx)
        GlobalVarInfo.IsBitField=false;
    else
        FieldIdx=RefFieldIdx;
        GlobalVarInfo.IsBitField=logical(DBase.Fields(FieldIdx).isBitfield);
    end


    GlobalVarInfo.Members=struct('Name',{},'File',{},'Size',{},'IsStatic',{},'IsBitField',{},'IsExported',{},'UseCount',{},'Members',{},'UseInFunctions',{});

    ChildIdx=[];
    if(isKey(parent2ChildMap,Index))
        ChildIdx=parent2ChildMap(Index);
    end

    if~isempty(ChildIdx)
        var_size=0;
        GlobalVarInfo.UseInFunctions=[];
        for c_idx=1:length(ChildIdx)
            ChildInfo=getGlobalVarInfo(parent2ChildMap,var2UseIdxMap,DBase,ChildIdx(c_idx),RefFIdx,accu_size);
            var_size=var_size+ChildInfo.Size;
            Member=CopyToMember(ChildInfo);
            GlobalVarInfo.Members=[GlobalVarInfo.Members,Member];
        end
        if(accu_size)
            GlobalVarInfo.Size=uint32(var_size);
        end
    else
        GlobalVarInfo.Members=[];
    end

    GlobalVarInfo.UseInFunctions=getUseInFunctions(var2UseIdxMap,DBase,Index);
end





function member=CopyToMember(childinfo)
    member=struct('Name',[],'File',[],'Size',[],'IsStatic',[],'IsBitField',[],'IsExported',[],'UseCount',[],'Members',[],'UseInFunctions',[]);
    member.Name=childinfo.Name;
    member.File=uint32(childinfo.FileIdx);
    member.Size=childinfo.Size;
    member.IsStatic=childinfo.IsStatic;
    member.IsBitField=childinfo.IsBitField;
    member.IsExported=childinfo.IsExported;
    member.UseCount=childinfo.UseCount;
    member.Members=childinfo.Members;
    member.UseInFunctions=childinfo.UseInFunctions;
end







function UseInFunctions=getUseInFunctions(var2UseIdxMap,DBase,Index)
    UseInFunctions=struct('FunctionName',{},'UseCount',{});
    UseIdx=[];
    if isKey(var2UseIdxMap,Index)
        UseIdx=var2UseIdxMap(Index);
    end
    RefFuncs=struct('idx',{},'count',{});
    funcIdx2structIdx=containers.Map('KeyType','double','ValueType','double');
    for ii=1:length(UseIdx)
        RefFuncIdx=DBase.Uses(UseIdx(ii)).RefFunc;
        if(isKey(funcIdx2structIdx,RefFuncIdx))
            strIdx=funcIdx2structIdx(RefFuncIdx);
            RefFuncs(strIdx).count=RefFuncs(strIdx).count+DBase.Uses(UseIdx(ii)).Count;
        else
            RefFunc=struct('idx',RefFuncIdx,'count',DBase.Uses(UseIdx(ii)).Count);
            RefFuncs=[RefFuncs,RefFunc];%#ok
            funcIdx2structIdx(RefFuncIdx)=length(RefFuncs);
        end
    end

    for ii=1:length(RefFuncs)
        UseInFunction=struct('FunctionName',[],'UseCount',[]);
        UseInFunction.FunctionName=DBase.Functions(RefFuncs(ii).idx).Name;
        UseInFunction.UseCount=uint32(RefFuncs(ii).count);
        UseInFunctions=[UseInFunctions,UseInFunction];%#ok
    end
    if isempty(UseInFunctions)
        UseInFunctions=[];
    end
end





function[fcnInfos,ndef_func]=getFcnInfo(opts,db,curr,RefName_StackSize)



    ndef_func=[];
    fcnInfos=[];
    ecfcnInfo=struct('Name',db.Functions(curr).Name,...
    'UniqueKey',[db.Functions(curr).Signature,'$',db.Functions(curr).Name],...
    'Idx',curr,...
    'FileIdx',db.Functions(curr).RefFile,...
    'Position',[],...
    'NumCommentLines',[],...
    'NumTotalLines',[],...
    'NumCodeLines',[],...
    'Callee',[],...
    'Caller',[],...
    'DataCopy',[],...
    'Stack',[],...
    'HasDefinition',[],...
    'File',[],...
    'IsStatic',[],...
    'DataCopyDetails',[],...
    'Complexity',[]);


    if isInCppSystemDirs(opts,db,db.Functions(curr))
        return;
    end

    if db.Functions(curr).isStatic&&~isClassMemberFunction(db,curr)
        [~,name,ext]=fileparts(db.Files(db.Functions(curr).RefFile).Path);
        ecfcnInfo.Name=[name,ext,':',ecfcnInfo.Name];
        ecfcnInfo.UniqueKey=[db.Functions(curr).Signature,'$',ecfcnInfo.Name];
    end

    ecfcnInfo.Name=attach_ClassOrNS(db,curr,ecfcnInfo.Name);


    if db.Functions(curr).ColNum>0
        ecfcnInfo.Position=uint32([db.Functions(curr).LineNum,db.Functions(curr).ColNum]);
    else
        ecfcnInfo.Position=uint32([0,0]);
    end


    id=SearchCodeMetrics(db.CodeMetrics,...
    db.Functions(curr).RefFile,...
    curr,...
    0,...
    22);
    ecfcnInfo.NumCommentLines=uint32(db.CodeMetrics(id).Value);


    ecfcnInfo.NumTotalLines=uint32(db.Functions(curr).BodyEndLineNum-db.Functions(curr).LineNum+1);


    ecfcnInfo.NumCodeLines=uint32(db.CodeMetrics(id-2).Value);


    [ecfcnInfo.Callee,no_def_function]=getCalleeer(opts,db,curr,0);
    ndef_func=[ndef_func,no_def_function];

    [ecfcnInfo.Caller,no_def_function]=getCalleeer(opts,db,curr,1);
    ndef_func=[ndef_func,no_def_function];


    [ecfcnInfo.DataCopy,ecfcnInfo.DataCopyDetails]=getDataCopyDetails(db,curr);


    if db.Functions(curr).BodyLineNum>0

        ecfcnInfo.HasDefinition=uint32(1);
        ecfcnInfo.Stack=uint32(SearchCodeMetrics2(db.CodeMetrics,...
        db.Functions(curr).RefFile,...
        curr,...
        0,...
        RefName_StackSize));
    else
        ecfcnInfo.HasDefinition=uint32(0);
        ecfcnInfo.Stack=uint32(0);
    end

    FileIdx=db.Functions(curr).RefFile;
    ecfcnInfo.File={db.Files(FileIdx).Path};


    ecfcnInfo.IsStatic=uint32(db.Functions(curr).isStatic);


    ecfcnInfo.Complexity=uint32(db.CodeMetrics(id-11).Value);


    fcnInfos=[fcnInfos,ecfcnInfo];
end





function name_classOrNS=attach_ClassOrNS(db,fcn_idx,name)
    name_classOrNS=name;
    RefClassOrNS=db.Functions(fcn_idx).RefClassOrNS;
    while RefClassOrNS~=0
        RefType=db.ClassOrNSes(RefClassOrNS).RefType;
        RefNamespace=db.ClassOrNSes(RefClassOrNS).RefNamespace;
        if RefNamespace==0
            name_classOrNS=[db.Types(RefType).Name,'::',name_classOrNS];%#ok
            RefClassOrNS=db.Types(RefType).RefClassOrNS;
        else
            name_classOrNS=[db.Namespaces(RefNamespace).Name,'::',name_classOrNS];%#ok
            RefParentNS=db.Namespaces(RefNamespace).RefParentNS;
            if RefParentNS==0
                RefClassOrNS=0;
            else
                RefClassOrNS=find([db.ClassOrNSes.RefNamespace]==RefParentNS);
            end
        end
    end
end





function opts=i_create_default_frontend_options(lang)
    opts=internal.cxxfe.util.getFrontEndOptions('lang',lang);
    opts.Target.Endianness='little';
    opts.Target.CharNumBits=8;
    opts.Target.ShortNumBits=16;
    opts.Target.IntNumBits=32;
    opts.Target.LongNumBits=64;
    opts.Target.LongLongNumBits=64;
    opts.Target.FloatNumBits=32;
    opts.Target.DoubleNumBits=64;
    opts.Target.LongDoubleNumBits=64;
    opts.Target.PointerNumBits=32;
    opts.RemoveUnneededEntities=false;
    opts.DoIlLowering=false;
end
