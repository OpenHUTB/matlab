function[result,dataObjectMapStruct]=ec_data_placement(record,modelName,...
    actModelName,dataObjectMapSharednessInMdlRefs)












































    cFileList={};
    hFileList={};
    globalCDefinitionIndex=[];
    globalHDeclarationIndex=[];
    modelCIndex=[];
    modelHIndex=[];
    decFileNoExt='';
    dataOwnerIgnored={};

    dataObjectMapStruct=struct;
    dataObjectMapStruct.ExportedScopeOwnership=containers.Map('KeyType','char','ValueType','any');
    dataObjectMapStruct.AutoAndFileScopeSharedness=containers.Map('KeyType','char','ValueType','any');

    configSetHandle=getActiveConfigSet(modelName);
    ERTFilePackagingFormat=get_param(configSetHandle,'ERTFilePackagingFormat');

    h=coder.internal.ModelCodegenMgr.getInstance(modelName);
    if isempty(h)
        DAStudio.error('RTW:buildProcess:objHandleLoadError',modelName);
    end
    isCompactFormat=~strcmp(h.MdlRefBuildArgs.ModelReferenceTargetType,'SIM')...
    &&(strcmp(ERTFilePackagingFormat,'Compact')||...
    strcmp(ERTFilePackagingFormat,'CompactWithDataFile'));

    result=record;
    result.totalFileList=[];
    CGModel=get_param(modelName,'CGModel');
    modelDotHFile=[CGModel.getFileName('ModelHeaderFile'),'.h'];
    globalDefnFile=get_param(configSetHandle,'DataDefinitionFile');
    globalRefFile=get_param(configSetHandle,'DataReferenceFile');
    globalDataDefinitionStr=get_param(configSetHandle,'GlobalDataDefinition');



    globalDataReferenceStr=get_param(configSetHandle,'GlobalDataReference');




    moduleNamingRule=get_param(configSetHandle,'ModuleNamingRule');




    includeFileDelimiter=get_param(configSetHandle,'IncludeFileDelimiter');

    switch(includeFileDelimiter)
    case 'Auto'
        openDelimiter='';
        closeDelimiter='';
    case 'UseBracket'
        openDelimiter='<';
        closeDelimiter='>';
    case 'UseQuote'
        openDelimiter='"';
        closeDelimiter='"';
    otherwise
        openDelimiter='';
        closeDelimiter='';
    end
    switch(globalDataDefinitionStr)
    case 'Auto'
        globalDataDefinition=0;
    case 'InSeparateSourceFile'
        globalDataDefinition=1;
    case 'InSourceFile'
        globalDataDefinition=2;
    otherwise
        globalDataDefinition=0;
    end

    switch(globalDataReferenceStr)
    case 'Auto'
        globalDataReference=0;
    case 'InSeparateHeaderFile'
        globalDataReference=1;
    case 'InSourceFile'
        globalDataReference=2;
    otherwise
        globalDataReference=0;
    end





    mpt_symbol_mapping=rtwprivate('rtwattic','AtticData','mpt_symbol_mapping');

    sLen=length(mpt_symbol_mapping.symbolList);
    for i=1:sLen
        result.TemplateSymbol(i).Name=mpt_symbol_mapping.symbolList{i};
    end



    result.NumTemplateSymbols=int32(sLen);






    switch(moduleNamingRule)
    case 'Unspecified'
        moduleOwner='';
    case 'UserSpecified'
        moduleOwner=actModelName;
        assert(false,'Module Naming cannot be Userspecified');
    case 'SameAsModel'
        moduleOwner=actModelName;
    otherwise
        moduleOwner='';
    end

    totalFileList=cell(1,length(record.File));
    for i=1:length(record.File)
        switch(record.File(i).Type)
        case 'source'
            if strcmp(record.File(i).Name,CGModel.getFileName('ModelSourceFile'))
                modelCIndex=int32(i-1);
            end
            cFileList{end+1}=record.File(i).Name;%#ok
            totalFileList{i}=[record.File(i).Name,'.c'];
        case 'header'
            if strcmp(record.File(i).Name,CGModel.getFileName('ModelHeaderFile'))
                modelHIndex=int32(i-1);
            end
            hFileList{end+1}=record.File(i).Name;%#ok
            totalFileList{i}=[record.File(i).Name,'.h'];
        otherwise
            totalFileList{i}=record.File(i).Name;
        end
    end


    if globalDataDefinition==1
        [~,globalDefnFileNoExt]=checkExt(globalDefnFile,'.c');
        info.totalFileList=totalFileList;
        [result,info]=add_file(result,info,globalDefnFileNoExt,'source','yes');
        totalFileList=info.totalFileList;
        globalCDefinitionIndex=info.index;

    end

    if globalDataReference==1

        [globalRefFile,globalRefFileNoExt]=checkExt(globalRefFile,'.h');
        info.totalFileList=totalFileList;
        [result,info]=add_file(result,info,globalRefFileNoExt,'header','yes');
        totalFileList=info.totalFileList;
        globalHDeclarationIndex=info.index;

    end
    info.totalFileList=totalFileList;
    modelPrivateFile=CGModel.getFileName('ModelPrivateFile');
    [result,info]=add_file(result,info,modelPrivateFile,'header','no');
    totalFileList=info.totalFileList;
    private_index=info.index;

    info.totalFileList=totalFileList;
    modelHeaderFile=CGModel.getFileName('ModelHeaderFile');
    [result,info]=add_file(result,info,modelHeaderFile,'header','no');
    totalFileList=info.totalFileList;
    model_index=info.index;

    mpt_symbol_mapping=rtwprivate('rtwattic','AtticData','mpt_symbol_mapping');
    for i=1:double(record.NumDataObjects)
        try



            useIncludeFileFlag=false;
            genDefnFileFlag=false;
            referenceIndex=[];
            definitionIndex=[];
            filesWithIncl=[];
            readWriteDefineFlag=false;
            extraRefFlag=true;
            name=record.DataObject(i).Name;
            hPort=record.DataObject(i).PortHandle;
            hBlock=record.DataObject(i).BlockHandle;
            identifier=record.DataObject(i).Identifier;

            assert((hPort==0.0)||(hBlock==0.0));
            obj=[];

            cgModel=get_param(modelName,'CGModel');
            isDefaultMapped=false;

            if record.DataObject(i).IsDefaultMapped

                isDefaultMapped=true;
                obj=cgModel.getDataObjectForElement(identifier);
            else
                obj=record.DataObject(i).Object;
            end

            if isa(obj,'Simulink.Data')||isa(obj,'Simulink.LookupTable')||isa(obj,'Simulink.Breakpoint')

                switch obj.CoderInfo.StorageClass
                case 'Custom'

                    if isempty(obj.CoderInfo.CustomAttributes)
                        continue;
                    end
                case 'ExportedGlobal'
                    if isDefaultMapped

                        assert(strcmp(obj.CoderInfo.CustomStorageClass,'Default'));
                    else

                        continue;
                    end
                otherwise

                    continue;
                end






                thisRecord=struct;
                thisRecord.RootIOSignal=false;
                thisRecord.DataStore=false;
                thisRecord.IsDefaultMapped=isDefaultMapped;
                thisRecord.DataObjectName=name;
                if(i>=record.FirstSignalObjectIdx+1&&i<=record.FirstSignalObjectIdx+record.NumSignalObjects)
                    thisRecord.Type=1;
                    thisRecord.RootIOSignal=record.DataObject(i).RootIOSignal;
                elseif(i>=record.FirstParameterObjectIdx+1&&i<=record.FirstParameterObjectIdx+record.NumParameterObjects)
                    thisRecord.Type=2;
                elseif(i>=record.FirstStateObjectIdx+1&&i<=record.FirstStateObjectIdx+record.NumStateObjects)
                    thisRecord.Type=3;
                    thisRecord.DataStore=record.DataObject(i).DataStore;
                else
                    assert(false,'inconsistent data object usage indexing');
                end

                attri=obj.CoderInfo.CustomAttributes.get;
                packageCSCDef=rtwprivate('rtwattic','AtticData','packageCSCDef');
                cscdef=ec_get_cscdef(obj,packageCSCDef);
                [originalScope,initializationMode]=locGetDataScopeAndDataInitPropertiesFromDataObject(obj,name);

                if~isempty(originalScope)
                    desiredScope=originalScope;
                    if strcmp(originalScope,'Auto')||strcmp(originalScope,'File')
                        thisRecord.DataScope=originalScope;












                        if dataObjectMapSharednessInMdlRefs.isKey(name)
                            isSharedInMdlRefs=dataObjectMapSharednessInMdlRefs(name).Shared;
                        else

                            isSharedInMdlRefs=false;
                        end

                        if isSharedInMdlRefs
                            thisRecord.Shared=true;
                        elseif thisRecord.Type==1
                            if thisRecord.RootIOSignal

                                thisRecord.Shared=true;
                            else

                                thisRecord.Shared=locDetermineSharednessByReadWrite(record.DataObject(i));
                            end
                        elseif thisRecord.Type==3&&~thisRecord.DataStore

                            thisRecord.Shared=locDetermineSharednessByReadWrite(record.DataObject(i));
                        else
                            mdlRefTargetType=get_param(modelName,'ModelReferenceTargetType');
                            if~strcmp(mdlRefTargetType,'NONE')



                                mwks=get_param(modelName,'ModelWorkspace');
                                if(mwks.hasVariable(name))
                                    thisRecord.Shared=locDetermineSharednessByReadWrite(record.DataObject(i));
                                else
                                    thisRecord.Shared=true;
                                end
                            else

                                thisRecord.Shared=locDetermineSharednessByReadWrite(record.DataObject(i));
                            end
                        end


                        nameToCheck=name;
                        if(cgModel.isDataElementDefaultMapped(identifier))
                            nameToCheck=identifier;
                        end
                        assert(~dataObjectMapStruct.AutoAndFileScopeSharedness.isKey(nameToCheck),...
                        'No more than once for the same model');
                        dataObjectMapStruct.AutoAndFileScopeSharedness(nameToCheck)=thisRecord;


                        if strcmp(originalScope,'Auto')
                            if thisRecord.Shared
                                result.DataObject(i).HasMPTAttributes=true;
                                desiredScope='Exported';
                                result.DataObject(i).Scope=desiredScope;
                            else


                                result.DataObject(i).HasMPTAttributes=false;
                                desiredScope='File';
                                result.DataObject(i).Scope=desiredScope;
                            end
                        end
                    end
                    placementRule=ec_get_placement_rules(obj,attri,packageCSCDef,desiredScope);
                else
                    placementRule=ec_get_placement_rules(obj,attri,packageCSCDef);
                end







                if~strcmp(placementRule.mode,'None')
                    csc=obj.CoderInfo.CustomStorageClass;
                    if isfield(attri,'MemorySection')
                        memorySection=attri.MemorySection;
                    else
                        memorySection=[];
                    end
                    if isa(obj,'Simulink.Signal')
                        classIndex=1;
                    else
                        classIndex=2;
                    end
                    symbolInfo=ec_get_datasym('mpt',classIndex,csc,memorySection,mpt_symbol_mapping);

                    result.DataObject(i).FilePackaging.HeaderFile='';
                    result.DataObject(i).FilePackaging.DefineFile=[];
                    result.DataObject(i).FilePackaging.DeclareSymbol=[];
                    result.DataObject(i).FilePackaging.DefineSymbol=[];
                    result.DataObject(i).FilePackaging.FilesWithDecl=[];
                    result.DataObject(i).FilePackaging.FilesWithIncl=[];



                    [isowned_status,dataOwnerIneffect,isDataOwnerIgnored]=isowned(name,obj,cscdef,moduleOwner);
                    if isDataOwnerIgnored
                        dataOwnerIgnored{end+1}=name;%#ok
                    end



                    if~isempty(dataOwnerIneffect)
                        assert(~strcmp(originalScope,'Auto')&&...
                        ~strcmp(originalScope,'File'),...
                        'Auto/File Scoped data cannot specify owner');

                        thisRecord.Owner=dataOwnerIneffect;
                        if isowned_status>0
                            thisRecord.OwnerFound=true;
                        else
                            thisRecord.OwnerFound=false;
                        end
                        thisRecord.DataInit=initializationMode;
                        thisRecord.PropagatedSignalLevel=0;



                        nameToCheck=name;
                        if(cgModel.isDataElementDefaultMapped(identifier))
                            nameToCheck=identifier;
                        end
                        assert(~dataObjectMapStruct.ExportedScopeOwnership.isKey(nameToCheck),...
                        'No more than once for the same model');
                        dataObjectMapStruct.ExportedScopeOwnership(nameToCheck)=thisRecord;
                    end

                    if~isempty(obj)
                        if strcmp(placementRule.mode,'Include')
                            header=placementRule.HeaderFile;


                            [header,headerOverride]=removeDelimiters(header);













                            if isCompactFormat

                                referenceIndex=int32(model_index);
                            else
                                referenceIndex=int32(private_index);
                            end

                            result.DataObject(i).HasMPTAttributes=true;

                            result.DataObject(i).Scope='Imported';



                            result.DataObject(i).FilePackaging.DeclareSymbol=int32(symbolInfo.globalDecSymIndex-1);
                            result.DataObject(i).FilePackaging.DefineSymbol=int32(symbolInfo.globalDefSymIndex-1);

                            if~isempty(header)





                                result.DataObject(i).FilePackaging.HeaderFile=...
                                header_str(header,openDelimiter,closeDelimiter,headerOverride);

                                result.DataObject(i).FilePackaging.FilesWithIncl=int32(referenceIndex);
                                if(~isempty(result.DataObject(i).DependentParams))
                                    result=locSetReadersInParamExpression(result,info,i);
                                end
                            elseif strcmp(initializationMode,'Macro')


                            else
                                result.DataObject(i).FilePackaging.FilesWithDecl=int32(referenceIndex);
                            end

                        else
                            desiredScope='Exported';


                            header=placementRule.HeaderFile;


                            [header,headerOverride]=removeDelimiters(header);

                            if~isempty(header)






                                [header,headerNoExt]=checkExt(header,'.h');

                                info.totalFileList=totalFileList;
                                [result,info]=add_file(result,info,headerNoExt,'header','yes');
                                referenceIndex=info.index;
                                totalFileList=info.totalFileList;


                                filesWithIncl(end+1)=modelHIndex;%#ok


                                extraRefFlag=false;
                                useIncludeFileFlag=true;

                                result.DataObject(i).FilePackaging.HeaderFile=...
                                header_str(header,openDelimiter,closeDelimiter,headerOverride);
                            end






                            defnFile=ec_get_ungroupedcsc_prop_value(attri,cscdef,'DefinitionFile');

                            if~isempty(defnFile)
                                placeType='definitionFile';

                                [~,defnFileNoExt]=checkExt(defnFile,'.c');
                            else
                                if~strcmp(placementRule.mode,'#Define')
                                    placeType='read-write-global';
                                else
                                    if~isempty(header)
                                        placeType='definitionFile';

                                        defnFileNoExt=headerNoExt;
                                    else
                                        placeType='read-write-global';
                                    end
                                end
                            end


                            switch(placeType)
                            case 'definitionFile'



                                if isempty(header)

                                    switch(globalDataReference)
                                    case 0



                                        decRefFile=modelDotHFile;

                                        useIncludeFileFlag=true;

                                        result.DataObject(i).FilePackaging.HeaderFile=...
                                        header_str(decRefFile,openDelimiter,closeDelimiter,headerOverride);
                                        referenceIndex(end+1)=modelHIndex;%#ok
                                    case 1



                                        decRefFile=globalRefFile;

                                        useIncludeFileFlag=true;

                                        result.DataObject(i).FilePackaging.HeaderFile=...
                                        header_str(decRefFile,openDelimiter,closeDelimiter,headerOverride);
                                        referenceIndex(end+1)=globalHDeclarationIndex;%#ok
                                        header=globalRefFileNoExt;%#ok
                                        filesWithIncl(end+1)=modelHIndex;%#ok


                                        extraRefFlag=false;
                                    case 2





                                        useIncludeFileFlag=false;
                                    otherwise
                                    end
                                    genDefnFileFlag=true;
                                else

                                    decFileNoExt=headerNoExt;
                                    info.totalFileList=totalFileList;
                                    [result,info]=add_file(result,info,decFileNoExt,'header','yes');
                                    totalFileList=info.totalFileList;


                                    decFile=[decFileNoExt,'.h'];
                                    result.DataObject(i).FilePackaging.HeaderFile=...
                                    header_str(decFile,openDelimiter,closeDelimiter,headerOverride);
                                    if~strcmp(placementRule.mode,'#Define')
                                        referenceIndex=info.index;
                                        genDefnFileFlag=true;
                                    else
                                        definitionIndex=info.index;
                                        genDefnFileFlag=false;
                                    end
                                    useIncludeFileFlag=true;
                                end

                            case 'read-write-global'




                                genDefnFileFlag=false;
                                if strcmp(placementRule.mode,'#Define')
                                    definitionIndex=modelHIndex;
                                else

                                    modelRefMode=get_param(modelName,'ModelReferenceTargetType');
                                    assert(~strcmp(modelRefMode,'SIM'));
                                    if((globalDataReference==2)&&strcmp(modelRefMode,'RTW'))
                                        switch(thisRecord.Type)
                                        case 1




                                            skipDef=thisRecord.RootIOSignal;
                                        case 2

                                            skipDef=true;
                                        case 3

                                            skipDef=thisRecord.DataStore;
                                        end
                                    else
                                        skipDef=false;
                                    end

                                    if~skipDef
                                        switch(globalDataDefinition)
                                        case 0

                                            definitionIndex=modelCIndex;
                                        case 1

                                            definitionIndex=globalCDefinitionIndex;
                                        case 2




                                            readWriteDefineFlag=true;
                                            if~isempty(result.DataObject(i).WrittenInFile)
                                                definitionIndex=result.DataObject(i).WrittenInFile(1);
                                            elseif~isempty(result.DataObject(i).ReadFromFile)
                                                definitionIndex=result.DataObject(i).ReadFromFile(1);
                                            else
                                                definitionIndex=modelCIndex;
                                            end
                                        end
                                    end
                                end


                                if~isempty(definitionIndex)
                                    decFileNoExt=result.File(definitionIndex+1).Name;
                                end






                                if isempty(header)
                                    if strcmp(placementRule.mode,'#Define')&&globalDataReference==1






                                        definitionIndex=globalHDeclarationIndex;

                                        decRefFile=globalRefFile;

                                        useIncludeFileFlag=true;

                                        result.DataObject(i).FilePackaging.HeaderFile=...
                                        header_str(decRefFile,openDelimiter,closeDelimiter,headerOverride);
                                        referenceIndex(end+1)=globalHDeclarationIndex;%#ok
                                        header=globalRefFileNoExt;%#ok
                                        filesWithIncl(end+1)=modelHIndex;%#ok


                                        extraRefFlag=false;

                                    elseif strcmp(placementRule.mode,'#Define')||globalDataReference==0




                                        decRefFile=modelDotHFile;

                                        useIncludeFileFlag=true;

                                        result.DataObject(i).FilePackaging.HeaderFile=...
                                        header_str(decRefFile,openDelimiter,closeDelimiter,headerOverride);
                                        referenceIndex(end+1)=modelHIndex;%#ok
                                    else


                                        switch(globalDataReference)
                                        case 1



                                            decRefFile=globalRefFile;

                                            useIncludeFileFlag=true;

                                            result.DataObject(i).FilePackaging.HeaderFile=...
                                            header_str(decRefFile,openDelimiter,closeDelimiter,headerOverride);
                                            referenceIndex(end+1)=globalHDeclarationIndex;%#ok
                                            header=globalRefFileNoExt;%#ok
                                            filesWithIncl(end+1)=modelHIndex;%#ok


                                            extraRefFlag=false;

                                        case 2





                                            useIncludeFileFlag=false;
                                        otherwise
                                        end
                                    end
                                end
                            otherwise
                            end













                            if genDefnFileFlag
                                info.totalFileList=totalFileList;
                                [result,info]=add_file(result,info,defnFileNoExt,'source','yes');
                                definitionIndex=info.index;
                                totalFileList=info.totalFileList;
                            end

                            result.DataObject(i).HasMPTAttributes=true;

                            result.DataObject(i).Scope=desiredScope;







                            if extraRefFlag
                                if useIncludeFileFlag

                                    for j=1:length(result.DataObject(i).ReadFromFile)
                                        if~strcmp(decFileNoExt,result.File(result.DataObject(i).ReadFromFile(j)+1).Name)
                                            filesWithIncl(end+1)=int32(result.DataObject(i).ReadFromFile(j));%#ok
                                        end
                                    end

                                    for j=1:length(result.DataObject(i).WrittenInFile)
                                        if~strcmp(decFileNoExt,result.File(result.DataObject(i).WrittenInFile(j)+1).Name)
                                            filesWithIncl(end+1)=result.DataObject(i).WrittenInFile(j);%#ok
                                        end
                                    end
                                else






                                    if~isempty(definitionIndex)
                                        if(~genDefnFileFlag)&&(readWriteDefineFlag)
                                            defIndx=definitionIndex;
                                        else
                                            defIndx=-1;
                                        end
                                    else
                                        defIndx=-1;
                                    end




                                    for j=1:length(result.DataObject(i).ReadFromFile)
                                        if defIndx~=result.DataObject(i).ReadFromFile(j)
                                            referenceIndex(end+1)=int32(result.DataObject(i).ReadFromFile(j));%#ok
                                        end
                                    end




                                    for j=1:length(result.DataObject(i).WrittenInFile)
                                        if defIndx~=result.DataObject(i).WrittenInFile(j)
                                            referenceIndex(end+1)=result.DataObject(i).WrittenInFile(j);%#ok
                                        end
                                    end

                                end
                            end

                            if(~isempty(result.DataObject(i).DependentParams))
                                result=locSetReadersInParamExpression(result,info,i);

                                for j=1:length(result.DataObject(i).ReadFromFile)
                                    if~strcmp(decFileNoExt,result.File(result.DataObject(i).ReadFromFile(j)+1).Name)
                                        filesWithIncl(end+1)=int32(result.DataObject(i).ReadFromFile(j));%#ok
                                    end
                                end
                            end


                            result.DataObject(i).FilePackaging.DefineFile=int32(definitionIndex);



                            result.DataObject(i).FilePackaging.DeclareSymbol=int32(symbolInfo.globalDecSymIndex-1);
                            if~strcmp(placementRule.mode,'#Define')
                                result.DataObject(i).FilePackaging.DefineSymbol=int32(symbolInfo.globalDefSymIndex-1);
                            else
                                result.DataObject(i).FilePackaging.DefineSymbol=int32(symbolInfo.defineIndex-1);
                            end



                            if~strcmp(placementRule.mode,'#Define')
                                result.DataObject(i).FilePackaging.FilesWithDecl=int32(referenceIndex);
                            else
                                result.DataObject(i).FilePackaging.FilesWithDecl=[];
                            end

                            result.DataObject(i).FilePackaging.FilesWithIncl=[int32(result.DataObject(i).FilePackaging.FilesWithIncl),int32(filesWithIncl)];

                        end

                        result.DataObject(i).FilePackaging.DefineFile=...
                        unique(result.DataObject(i).FilePackaging.DefineFile);
                        result.DataObject(i).FilePackaging.DeclareSymbol=...
                        unique(result.DataObject(i).FilePackaging.DeclareSymbol);
                        result.DataObject(i).FilePackaging.DefineSymbol=...
                        unique(result.DataObject(i).FilePackaging.DefineSymbol);
                        result.DataObject(i).FilePackaging.FilesWithDecl=...
                        unique(result.DataObject(i).FilePackaging.FilesWithDecl);
                        result.DataObject(i).FilePackaging.FilesWithIncl=...
                        unique(result.DataObject(i).FilePackaging.FilesWithIncl);
                        result.DataObject(i).FilePackaging.FilesWithDecl=...
                        setdiff(result.DataObject(i).FilePackaging.FilesWithDecl,...
                        result.DataObject(i).FilePackaging.DefineFile);

                    else
                        disp(DAStudio.message('RTW:mpt:DataPlaceNoWS',name));
                    end
                end
            end

        catch merr

            DAStudio.error('RTW:mpt:DataPlaceInvalidObj',name,merr.message);
        end
    end

    if~isempty(dataOwnerIgnored)
        len=min(length(dataOwnerIgnored),5);
        namestr='';
        if len==1
            namestr=dataOwnerIgnored{1};
        else
            for k=1:len-1
                namestr=[namestr,dataOwnerIgnored{k},', '];%#ok
            end
            namestr=[namestr,dataOwnerIgnored{len}];
        end
        if length(dataOwnerIgnored)>len
            namestr=[namestr,', ... etc,'];
        end
        MSLDiagnostic('RTW:mpt:DataOwnerBeingIgnoredByModel',actModelName,namestr,...
        DAStudio.message('RTW:configSet:dataPlacementEnableDataOwnership'),...
        [DAStudio.message('RTW:configSet:configSetCodeGen'),'|',...
        DAStudio.message('RTW:configSet:RTWDataPlacementTabName')]).reportAsWarning;
    end

end


function[result,info]=add_file(result,info,fileName,fileType,isCustom)
    switch(fileType)
    case 'header'
        str='.h';
    case 'source'
        str='.c';
    otherwise
        str='.c';
    end
    match=ismember(info.totalFileList,[fileName,str]);
    index=find(match);
    if isempty(index)
        file.Name=fileName;
        file.Type=fileType;
        file.IsCustom=isCustom;

        result.File(end+1)=file;
        info.index=result.NumFiles;
        result.NumFiles=result.NumFiles+1;
        info.totalFileList{end+1}=[file.Name,str];
    else
        info.index=index-1;
    end

end

function headerFile=header_str(header,openDelimiter,closeDelimiter,headerOverride)




    switch(headerOverride)
    case 0
        headerFile=[openDelimiter,header,closeDelimiter];
    case 1
        headerFile=['<',header,'>'];
    case 2
        headerFile=['"',header,'"'];
    otherwise
        headerFile=[openDelimiter,header,closeDelimiter];
    end

end

function[header,headerOverride]=removeDelimiters(header)










    headerOverride=0;
    if~isempty(header)

        if(header(1)=='<')&&(header(end)=='>')
            headerOverride=1;
        elseif(header(1)=='"')&&(header(end)=='"')
            headerOverride=2;
        end


        if(headerOverride~=0)
            header=header(2:end-1);
        end
    end

end


function[fileName,fNameNoExt]=checkExt(fileName,reqExt)







    [~,~,fExt]=fileparts(fileName);

    if isempty(fExt)
        fNameNoExt=fileName;
    elseif strcmp(fExt,reqExt)

        fNameNoExt=fileName(1:(end-length(reqExt)));
    else

        DAStudio.error('RTW:mpt:DataPlaceInvalidFileExt',fExt,reqExt);
    end

    fileName=[fNameNoExt,reqExt];

end


function isShared=locDetermineSharednessByReadWrite(dataObject)



















    dataReaders=dataObject.ReadFromFile;
    dataWriters=dataObject.WrittenInFile;
    numReaders=length(dataReaders);
    numWriters=length(dataWriters);

    if(numReaders==0&&numWriters==0)||(numReaders>1||numWriters>1)


        isShared=true;
        return;
    end

    if(numReaders==1&&numWriters==1)
        if dataReaders(1)==dataWriters(1)

            isShared=false;
        else
            isShared=true;
        end
    else
        assert(numReaders+numWriters==1);
        isShared=false;
    end

end

function[dataScope,dataInit]=locGetDataScopeAndDataInitPropertiesFromDataObject(obj,symbol)
    attri=obj.CoderInfo.CustomAttributes.get;
    packageCSCDef=rtwprivate('rtwattic','AtticData','packageCSCDef');
    cscdef=ec_get_cscdef(obj,packageCSCDef);
    assert(~isempty(cscdef),['CSC definition for object ',...
    symbol,' cannot be found']);

    dataScope=ec_get_ungroupedcsc_prop_value(attri,cscdef,'DataScope');
    dataInit=ec_get_ungroupedcsc_prop_value(attri,cscdef,'DataInit');
    if(strcmp(dataInit,'Macro'))
        assert(~cscdef.IsGrouped);
    end
end

function headerFile=locGetHeaderFile(obj,symbol)
    attri=obj.CoderInfo.CustomAttributes.get;
    packageCSCDef=rtwprivate('rtwattic','AtticData','packageCSCDef');
    cscdef=ec_get_cscdef(obj,packageCSCDef);
    assert(~isempty(cscdef),['CSC definition for object ',...
    symbol,' cannot be found']);
    headerFile=ec_get_ungroupedcsc_prop_value(attri,cscdef,'HeaderFile');
end

function defnFile=locGetDefinitionFile(obj,symbol)
    attri=obj.CoderInfo.CustomAttributes.get;
    packageCSCDef=rtwprivate('rtwattic','AtticData','packageCSCDef');
    cscdef=ec_get_cscdef(obj,packageCSCDef);
    assert(~isempty(cscdef),['CSC definition for object ',...
    symbol,' cannot be found']);
    defnFile=ec_get_ungroupedcsc_prop_value(attri,cscdef,'DefinitionFile');
end



function result=locSetReadersInParamExpression(result,info,i)

    for j=1:length(result.DataObject(i).DependentParams)
        param=result.DataObject(i).DependentParams{j};
        symbol=result.DataObject(i).DependentParamNames{j};

        [dataScopeLHS,dataInitLHS]=locGetDataScopeAndDataInitPropertiesFromDataObject(param,symbol);




        if(~strcmp(dataScopeLHS,'Imported'))
            if(strcmp(dataInitLHS,'Macro'))
                headerFile=locGetHeaderFile(param,symbol);
                if(~isempty(headerFile))
                    [~,fileNoExt]=checkExt(headerFile,'.h');
                    [result,info]=add_file(result,info,fileNoExt,'header','yes');
                    result.DataObject(i).ReadFromFile(end+1)=info.index;
                    result.DataObject(i).FilePackaging.FilesWithIncl(end+1)=info.index;
                else
                    for index=1:double(result.NumDataObjects)
                        if(~strcmp(result.DataObject(index).Name,symbol))
                            continue;
                        end
                        [~,fileNoExt]=checkExt(result.DataObject(index).FilePackaging.HeaderFile,'.h');
                        [result,info]=add_file(result,info,fileNoExt,'header','no');
                        result.DataObject(i).ReadFromFile(end+1)=info.index;
                        result.DataObject(i).FilePackaging.FilesWithIncl(end+1)=info.index;
                        break;
                    end
                end
            else
                defnFile=locGetDefinitionFile(param,symbol);
                if(~isempty(defnFile))
                    [~,fileNoExt]=checkExt(defnFile,'.c');
                    [result,info]=add_file(result,info,fileNoExt,'source','yes');
                    result.DataObject(i).ReadFromFile(end+1)=info.index;
                    result.DataObject(i).FilePackaging.FilesWithIncl(end+1)=info.index;
                else
                    for jindex=1:double(result.NumDataObjects)
                        if(~strcmp(result.DataObject(jindex).Name,symbol))
                            continue;
                        end
                        if(~isempty(result.DataObject(jindex).FilePackaging))
                            result.DataObject(i).ReadFromFile(end+1)=result.DataObject(jindex).FilePackaging.DefineFile;
                            result.DataObject(i).FilePackaging.FilesWithIncl(end+1)=result.DataObject(jindex).FilePackaging.DefineFile;
                            break;
                        end
                    end
                end
            end
        end

    end
end






