function shrdCodeInfo=add2FileMap(...
    model,...
    sharedutils,...
    objInfoArr,...
    emitCode,...
    useFileRepository,...
    varargin)











































































    shrdCodeInfo.status=1;
    shrdCodeInfo.errorMessage='';
    shrdCodeInfo.numGeneratedFiles=0;
    shrdCodeInfo.generatedFileList={};
    shrdCodeInfo.numNotGeneratedFiles=0;
    shrdCodeInfo.notGeneratedFileList={};

    persistent fileMap;
    persistent oldModel;
    persistent oldSlprj;
    persistent fileMapDirty;





    if isempty(fileMapDirty)
        fileMapDirty=false;
    end


    reset=false;
    traperror=false;
    if emitCode==3
        checkDataDeclContentsConflict=true;
    else
        checkDataDeclContentsConflict=false;
    end

    if emitCode==4
        checkAutoDataTypeConflict=true;
    else
        checkAutoDataTypeConflict=false;
    end




    if emitCode==5
        fileMapDirty=true;
        return;
    end

    nVargs=length(varargin);
    if(nVargs>=1)
        if nVargs>1
            assert(false,'Only one optional argument is supported now');
        end
        if ischar(varargin{1})
            switch varargin{1}
            case 'reset'
                reset=true;
            case 'traperror'
                traperror=true;
            otherwise
                assert(false,'Unsupported optional argument');
            end
        else
            assert(false,'Unsupported optional argument');
        end
    end



    fileName=fullfile(sharedutils,'filemap.mat');
    if reset||emitCode==2
        fileMap=containers.Map('KeyType','char','ValueType','any');
    elseif isempty(fileMap)||isempty(oldModel)||~strcmp(model,oldModel)||...
        isempty(oldSlprj)||~strcmp(sharedutils,oldSlprj)||fileMapDirty
        oldModel=model;
        oldSlprj=sharedutils;

        if exist(fileName,'file')==2



            load(fileName,'fileMap');
        else

            fileMap=containers.Map('KeyType','char','ValueType','any');
        end
    else

        if exist(fileName,'file')~=2
            fileMap=containers.Map('KeyType','char','ValueType','any');
        end
    end


    fileMapDirty=false;

    try


        invalidObjects=...
        struct('Kind',{{}},'Destination',{{}},...
        'AliasType',{{}},'MissingType',{{}},...
        'Content',{{}},'CSCMemSec',{{}},'Pragmas',{{}},...
        'DataScope',{{}});

        anyChangeToFileMap=false;
        for idx=1:objInfoArr.NumInfo
            if~iscell(objInfoArr.objInfo)
                thisObjInfo=objInfoArr.objInfo;
            else
                thisObjInfo=objInfoArr.objInfo{idx};
            end
            thisObjName=thisObjInfo.name;

            if strcmp(thisObjInfo.kind,'constpdef')
                continue;
            end




            thisObjInfo.doUpdate=false;





            if~iscell(thisObjInfo.dependencies)
                depObjNames=regexp(thisObjInfo.dependencies,',','split');
                depIsBI=regexp(thisObjInfo.builtin,',','split');
                thisObjInfo.dependencies=depObjNames;
                thisObjInfo.builtin=depIsBI;
                depIsComplex=regexp(thisObjInfo.isComplex,',','split');
                thisObjInfo.isComplex=depIsComplex;
                depIsMultiword=regexp(thisObjInfo.isMultiword,',','split');
                thisObjInfo.isMultiword=depIsMultiword;
                depIsNonfiniteLiteral=regexp(thisObjInfo.isNonfiniteLiteral,',','split');
                thisObjInfo.isNonfiniteLiteral=depIsNonfiniteLiteral;
            end


            if fileMap.isKey(thisObjName)
                oldObj=fileMap(thisObjName);

                if~strcmp(oldObj.kind,thisObjInfo.kind)
                    invalidObjects.Kind{end+1}={thisObjInfo.name,...
                    thisObjInfo.kind,...
                    oldObj.kind,...
                    oldObj.file};
                elseif checkAutoDataTypeConflict
                    invalidObjects.DataScope{end+1}={thisObjInfo.name,...
                    thisObjInfo.file,...
                    oldObj.file};

                elseif~checkDataDeclContentsConflict&&~strcmp(oldObj.file,thisObjInfo.file)



                    invalidObjects.Destination{end+1}={thisObjInfo.kind,...
                    thisObjInfo.name,...
                    oldObj.file,...
                    thisObjInfo.file};
                else
                    if strcmp(thisObjInfo.kind,'type')

                        if~strcmp(oldObj.checksum,thisObjInfo.checksum)
                            invalidObjects.Content{end+1}={thisObjInfo.name,...
                            thisObjInfo.definition,...
                            oldObj.definition,...
                            oldObj.file};
                        end




                        if(thisObjInfo.genComplexTypedef&&~oldObj.genComplexTypedef)
                            thisObjInfo.doUpdate=true;
                            fileMap(thisObjName)=thisObjInfo;
                            anyChangeToFileMap=true;
                        end
                    elseif strcmp(thisObjInfo.kind,'datadecl')||...
                        strcmp(thisObjInfo.kind,'datamacro')


                        siblingAliasTypes=locGetInconsistentlyUsedAliasTypes(oldObj,thisObjInfo);
                        if~isempty(siblingAliasTypes)
                            invalidObjects.AliasType{end+1}=siblingAliasTypes;
                        end

                        if(~checkDataDeclContentsConflict&&...
                            ~locIsDependentDataTypeShared(thisObjInfo,fileMap,model))
                            invalidObjects.MissingType{end+1}={thisObjInfo.name,...
                            thisObjInfo.dependencies{1}};
                        end





                        dataChecksumStr=locComputeMD5Checksum(thisObjInfo.definition);






                        areSigMutuallyExclusive=thisObjInfo.isExclusive&&oldObj.isExclusive;
                        if~strcmp(oldObj.checksum,dataChecksumStr)&&~areSigMutuallyExclusive
                            invalidObjects.Content{end+1}={thisObjInfo.name,...
                            thisObjInfo.definition,...
                            oldObj.definition,...
                            oldObj.file};
                        end

                        if locIsMemSecChanged(oldObj.cscmemsec,thisObjInfo.cscmemsec)
                            invalidObjects.CSCMemSec{end+1}={thisObjInfo.name,...
                            thisObjInfo.cscmemsec,...
                            oldObj.cscmemsec};
                        end

                        if locIsPragmasChanged(oldObj.cscmemsec,thisObjInfo.cscmemsec)
                            invalidObjects.Pragmas{end+1}={thisObjInfo.name,...
                            thisObjInfo.cscmemsec,...
                            oldObj.cscmemsec};
                        end
                    else
                        assert(false,'Unsupported shared kind');
                    end
                end
            elseif~checkDataDeclContentsConflict

                if strcmp(thisObjInfo.kind,'datadecl')||strcmp(thisObjInfo.kind,'datamacro')
                    if~locIsDependentDataTypeShared(thisObjInfo,fileMap,model)
                        invalidObjects.MissingType{end+1}={thisObjInfo.name,...
                        thisObjInfo.dependencies{1}};

                    end
                end

                if strcmp(thisObjInfo.kind,'datadecl')||strcmp(thisObjInfo.kind,'datamacro')
                    thisObjInfo.checksum=locComputeMD5Checksum(thisObjInfo.definition);
                end
                if~checkAutoDataTypeConflict



                    if loc_isUserProvidedType(thisObjInfo)
                        thisObjInfo.doUpdate=false;
                    else
                        thisObjInfo.doUpdate=true;
                    end
                    fileMap(thisObjName)=thisObjInfo;
                    anyChangeToFileMap=true;
                end
            end

        end


        locObjectInfoChanged(invalidObjects);

        if(emitCode==1)||(emitCode==2)
            [outFileMap,updateNames,dontUpdateFiles]=locSortBasedOnFile(fileMap);
            locTestForCircularity(fileMap,outFileMap);
        end

        if emitCode==1


            locTestForMixedDataKindInFile(outFileMap);

            clonedfileMap=locCloneFileMap(fileMap);

            locDumpSharedCode(model,sharedutils,clonedfileMap,outFileMap,...
            updateNames,useFileRepository);
            resetChangedFlags=locResetDoUpdateFlag(fileMap);

            if resetChangedFlags
                anyChangeToFileMap=true;
            end

            shrdCodeInfo.numGeneratedFiles=length(updateNames);
            for idx=1:shrdCodeInfo.numGeneratedFiles
                shrdCodeInfo.generatedFileList{idx}=...
                regexprep(updateNames{idx},'(\.h$|\.c$|\.cpp$)','');
            end

            shrdCodeInfo.numNotGeneratedFiles=length(dontUpdateFiles);
            for idx=1:shrdCodeInfo.numNotGeneratedFiles
                notGeneratedFileRecord.Name=strrep(dontUpdateFiles{idx}.Name,'.h','');
                notGeneratedFileRecord.Kind=dontUpdateFiles{idx}.Kind;
                notGeneratedFileRecord.UserProvidedType=...
                dontUpdateFiles{idx}.UserProvidedType;
                shrdCodeInfo.notGeneratedFileList{idx}=notGeneratedFileRecord;
            end
        end


        if~reset&&(emitCode==0||emitCode==1)&&anyChangeToFileMap
            save(fileName,'fileMap');
        elseif emitCode==2
            fileMap=containers.Map('KeyType','char','ValueType','any');
        end

    catch e
        shrdCodeInfo.status=0;
        shrdCodeInfo.errorMessage=e.message;
        if~traperror
            e.throw;
        end
    end








    function siblingAliasTypes=locGetInconsistentlyUsedAliasTypes(oldObjInfo,thisObjInfo)

        assert(length(oldObjInfo.dependencies)==1&&length(thisObjInfo.dependencies)==1);
        assert(strcmp(thisObjInfo.kind,'datadecl')||strcmp(thisObjInfo.kind,'datamacro'));

        siblingAliasTypes={};

        oldDataType=oldObjInfo.dependencies{1};
        thisDataType=thisObjInfo.dependencies{1};
        oldAliasedType=oldObjInfo.aliasedType;
        thisAliasedType=thisObjInfo.aliasedType;

        if(isempty(oldAliasedType)&&isempty(thisAliasedType))...
            ||strcmp(oldDataType,thisDataType)...

            return;
        end


        if~isempty(oldAliasedType)
            oldDataType=oldAliasedType;
        end
        if~isempty(thisAliasedType)
            thisDataType=thisAliasedType;
        end

        if strcmp(oldDataType,thisDataType)

            siblingAliasTypes={thisObjInfo.name,...
            thisObjInfo.dependencies{1},...
            oldObjInfo.dependencies{1},...
            oldObjInfo.file};
        end


        function r=locTypeIsReplacementType(dataTypeName,model)
            r=false;

            replacementTypesOn=rtwprivate('rtwattic','AtticData','isReplacementOn');
            if isempty(replacementTypesOn)||~replacementTypesOn
                return;
            end

            replacementTypes=get_param(model,'ReplacementTypes');
            builtinTypes=fieldnames(replacementTypes);

            for i=1:length(builtinTypes)
                rep=replacementTypes.(builtinTypes{i});
                if strcmp(rep,dataTypeName)
                    r=true;
                    return;
                end
            end



            function r=locIsDependentDataTypeShared(thisObjInfo,fileMap,model)

                assert(length(thisObjInfo.dependencies)==1);
                assert(strcmp(thisObjInfo.kind,'datadecl')||strcmp(thisObjInfo.kind,'datamacro'));

                r=true;

                if strcmp(thisObjInfo.builtin,'1'),return;end

                objDataType=thisObjInfo.dependencies{1};
                if~fileMap.isKey(objDataType)
                    if~locTypeIsReplacementType(objDataType,model)
                        r=false;
                    end
                else
                    dtObjInfo=fileMap(objDataType);
                    assert(strcmp(dtObjInfo.kind,'type'));
                end



                function r=locIsMemSecChanged(oldMemSec,newMemSec)
                    r=false;
                    if~strcmp(oldMemSec.PackageName,newMemSec.PackageName)||...
                        ~strcmp(oldMemSec.MemSecName,newMemSec.MemSecName)||...
                        ~strcmp(oldMemSec.CSCName,newMemSec.CSCName)
                        r=true;
                    end



                    function r=locIsPragmasChanged(oldMemSec,newMemSec)
                        r=false;

                        if oldMemSec.MemSecAddPragma~=newMemSec.MemSecAddPragma
                            r=true;
                        elseif oldMemSec.MemSecAddPragma
                            if~strcmp(strtrim(oldMemSec.MemSecPrepragma),strtrim(newMemSec.MemSecPrepragma))||...
                                ~strcmp(strtrim(oldMemSec.MemSecPostpragma),strtrim(newMemSec.MemSecPostpragma))
                                r=true;
                            end
                        end


                        function locObjectInfoChanged(invalidObjects)
                            assert(isstruct(invalidObjects));
                            invalidTypes=fieldnames(invalidObjects);
                            for k=1:length(invalidTypes)
                                funcname=['loc',invalidTypes{k},'Changed'];
                                errorInfo=invalidObjects.(invalidTypes{k});

                                if~isempty(errorInfo)
                                    feval(funcname,errorInfo);
                                end
                            end



                            function clonedfileMap=locCloneFileMap(fileMap)

                                clonedfileMap=containers.Map('KeyType','char','ValueType','any');
                                names=fileMap.keys;
                                for k=1:length(names)
                                    clonedfileMap(names{k})=fileMap(names{k});
                                end


                                function locDumpSharedCode(modelName,sharedutils,objMap,outFileMap,...
                                    updateNames,useFileRepository)


                                    if~isempty(objMap)&&~isempty(updateNames)
                                        ofKeys=outFileMap.keys;
                                        ofVals=outFileMap.values;


                                        for idx=1:length(ofKeys)

                                            if~ismember(ofKeys{idx},updateNames)
                                                continue;
                                            end

                                            [typeVals,dataMacroVals,dataDeclVals]=locSortObjKind(ofVals{idx});

                                            sortedTypeNames=locDoSortOnType(typeVals,objMap);



                                            sortedDataMacroNames=locDoSortOnDataDeclMacro(dataMacroVals,objMap);
                                            sortedDataDeclNames=locDoSortOnDataDeclMacro(dataDeclVals,objMap);

                                            sortedNames=[sortedTypeNames,...
                                            sortedDataMacroNames{:},...
                                            sortedDataDeclNames{:}];

                                            if useFileRepository
                                                fileRep=get_param(modelName,'SLCGFileRepository');
                                                fileName=ofKeys{idx};
                                                newFile=fileRep.findFileByName(fileName);

                                                if isempty(newFile)
                                                    newFile=fileRep.createGenericFile(fileName);
                                                    newFile.Type='SystemHeader';
                                                    newFile.Indent=true;
                                                    newFile.OutputDirectory=sharedutils;
                                                    newFile.Creator='TFL callback';
                                                    newFile.Group='utility';
                                                else




                                                    DAStudio.error('RTW:tlc:ErrWhenCheckingUpdatedSharedHeaderFileName',...
                                                    fileName,modelName);
                                                end
                                            else
                                                fileName=fullfile(sharedutils,ofKeys{idx});
                                                newFile=fopen(fileName,'w+');
                                                assert(newFile~=-1);
                                            end

                                            includedHdrs={};
                                            if~useFileRepository
                                                locDumpHeaderGuardBegin(newFile,ofKeys{idx});
                                            end


                                            for idy=1:length(sortedNames)
                                                aObj=objMap(sortedNames{idy});
                                                depObjNames=aObj.dependencies;
                                                depIsBI=aObj.builtin;
                                                depIsMultiword=aObj.isMultiword;
                                                depIsNonfiniteLiteral=aObj.isNonfiniteLiteral;
                                                isSharedData=(strcmp(aObj.kind,'datadecl')||...
                                                strcmp(aObj.kind,'datamacro'));

                                                for idz=1:length(depObjNames)
                                                    depObjName=depObjNames{idz};
                                                    if objMap.isKey(depObjName)
                                                        depObj=objMap(depObjName);

                                                        if~strcmp(depObj.file,ofKeys{idx})
                                                            includedHdrs=locDumpInclude(newFile,depObj.file,...
                                                            includedHdrs,useFileRepository);
                                                        end
                                                    else



                                                        if strcmp(depIsBI{idz},'1')||isSharedData
                                                            includedHdrs=locDumpInclude(newFile,'rtwtypes.h',...
                                                            includedHdrs,useFileRepository);
                                                        end

                                                        if strcmp(depIsMultiword{idz},'1')
                                                            includedHdrs=locDumpInclude(newFile,'multiword_types.h',...
                                                            includedHdrs,useFileRepository);
                                                        end

                                                        if strcmp(depIsNonfiniteLiteral{idz},'1')
                                                            includedHdrs=locDumpInclude(newFile,'math.h',...
                                                            includedHdrs,useFileRepository);
                                                        end
                                                    end
                                                end
                                            end


                                            for idy=1:length(sortedNames)
                                                aObj=objMap(sortedNames{idy});
                                                if useFileRepository
                                                    if(strcmp(aObj.kind,'datamacro'))
                                                        newFile.getDefinesSection().addContent(aObj.definition);
                                                    elseif(strcmp(aObj.kind,'datadecl'))
                                                        newFile.getDeclarationsSection().addContent(aObj.definition);
                                                    elseif(strcmp(aObj.kind,'type'))
                                                        if~(newFile.SharedType)
                                                            newFile.SharedType=true;
                                                        end
                                                        newFile.getTypedefsSection().addContent(aObj.definition);
                                                    end
                                                else
                                                    fprintf(newFile,'%s\n\n',aObj.definition);
                                                end
                                            end

                                            if~useFileRepository
                                                locDumpHeaderGuardEnd(newFile,ofKeys{idx});
                                                fclose(newFile);

                                                cBeautifierWithOptions(fileName,modelName);
                                            end
                                        end
                                    end


                                    function[outFileMap,updateNames,dontUpdateFiles]=locSortBasedOnFile(objMap)

                                        outFileMap=containers.Map;
                                        vals=objMap.values;
                                        updateNames={};
                                        dontUpdateNames={};
                                        dontUpdateFiles={};
                                        dontUpdateFileRecord=struct('Name',[],'Kind',[],'UserProvidedType',false);
                                        for idx=1:length(vals)
                                            aFileName=vals{idx}.file;
                                            aFileKind=vals{idx}.kind;

                                            if(strcmp(aFileKind,'constpdef'))
                                                continue;
                                            end

                                            if vals{idx}.doUpdate
                                                updateNames{end+1}=aFileName;
                                            else
                                                dontUpdateNames{end+1}=aFileName;
                                                dontUpdateFileRecord.Name=aFileName;
                                                dontUpdateFileRecord.Kind=aFileKind;

                                                if(loc_isUserProvidedType(vals{idx}))
                                                    dontUpdateFileRecord.UserProvidedType=true;
                                                end

                                                dontUpdateFiles{end+1}=dontUpdateFileRecord;
                                            end
                                            if outFileMap.isKey(aFileName)
                                                oldObjs=outFileMap(aFileName);
                                                oldObjs{end+1}=vals{idx};%#ok<*AGROW>
                                                outFileMap(aFileName)=oldObjs;
                                            else
                                                outFileMap(aFileName)=vals(idx);
                                            end
                                        end
                                        updateNames=unique(updateNames);

                                        if~isempty(dontUpdateNames)
                                            [dontUpdateNames,indices]=unique(dontUpdateNames);
                                            dontUpdateFiles=dontUpdateFiles(indices);
                                        end

                                        [~,indices]=setdiff(dontUpdateNames,updateNames);
                                        if~isempty(indices)
                                            dontUpdateFiles=dontUpdateFiles(indices);
                                        else
                                            dontUpdateFiles={};
                                        end


                                        function locDumpHeaderGuardBegin(fid,fileName)
                                            guardStr=regexprep(fileName,'\.','_');
                                            fprintf(fid,'#ifndef SIMULINK_CODER_%s\n',guardStr);
                                            fprintf(fid,'#define SIMULINK_CODER_%s\n',guardStr);


                                            function locDumpHeaderGuardEnd(fid,fileName)
                                                guardStr=regexprep(fileName,'\.','_');
                                                fprintf(fid,'#endif /*SIMULINK_CODER_%s*/\n',guardStr);


                                                function includedHdrs=locDumpInclude(newFile,aFile,includedHdrs,useFileRepository)
                                                    if isempty(includedHdrs)||~ismember(aFile,includedHdrs)
                                                        if useFileRepository
                                                            newFile.getIncludesSection().addContent(['#include "',aFile,'"',char(10)]);
                                                        else
                                                            fprintf(newFile,'#include "%s"\n',aFile);
                                                        end
                                                        includedHdrs{end+1}=aFile;
                                                    end


                                                    function locTestForCircularity(objMap,outFileMap)








                                                        objKeys=outFileMap.keys;
                                                        objVals=outFileMap.values;

                                                        fileVec={};
                                                        fileVecSize=0;%#ok<*NASGU>
                                                        for idx=1:length(objKeys)

                                                            fileVecSize=1;
                                                            fileVec{fileVecSize}=objKeys{idx};
                                                            for idy=1:length(objVals{idx})
                                                                thisObj=objVals{idx}{idy};

                                                                locCheckObjForCircularity(thisObj,objMap,fileVec,fileVecSize);
                                                            end
                                                        end


                                                        function[fileVec,fileVecSize]=locCheckObjForCircularity(...
                                                            aObj,objMap,fileVec,fileVecSize)

                                                            currFile=fileVec{fileVecSize};
                                                            errMsg='';

                                                            depObjNames=aObj.dependencies;
                                                            depIsBI=aObj.builtin;
                                                            for idy=1:length(depObjNames)
                                                                if strcmp(depIsBI{idy},'0')
                                                                    if objMap.isKey(depObjNames{idy})
                                                                        aDepObj=objMap(depObjNames{idy});

                                                                        aDepFile=aDepObj.file;
                                                                        if~strcmp(aDepFile,currFile)&&ismember(aDepFile,fileVec)

                                                                            errMsg=locBuildCircuarityErrorMsg(aDepFile,...
                                                                            fileVec,fileVecSize);
                                                                            DAStudio.error('RTW:buildProcess:sharedTypeCircularityDetected',errMsg);

                                                                        else

                                                                            fileVecSize=fileVecSize+1;
                                                                            fileVec{fileVecSize}=aDepFile;


                                                                            [fileVec,fileVecSize]=...
                                                                            locCheckObjForCircularity(aDepObj,objMap,fileVec,fileVecSize);


                                                                            fileVec{fileVecSize}='';
                                                                            fileVecSize=fileVecSize-1;
                                                                        end
                                                                    end
                                                                end
                                                            end


                                                            function errMsg=locBuildCircuarityErrorMsg(aDepFile,fileVec,fileVecSize)

                                                                assert(fileVecSize>1);
                                                                errMsg=fileVec{1};

                                                                for idx=2:fileVecSize
                                                                    errMsg=strcat(errMsg,'->',fileVec{idx});
                                                                end

                                                                errMsg=strcat(errMsg,'->',aDepFile);


                                                                function[typeVals,dataMacroVals,dataDeclVals]=locSortObjKind(vals)

                                                                    typeVals={};
                                                                    dataDeclVals={};
                                                                    dataMacroVals={};

                                                                    for k=1:length(vals)
                                                                        objKind=vals{k}.kind;
                                                                        if strcmp(objKind,'type')
                                                                            typeVals{end+1}=vals{k};
                                                                        elseif strcmp(objKind,'datadecl')
                                                                            dataDeclVals{end+1}=vals{k};
                                                                        elseif strcmp(objKind,'datamacro')
                                                                            dataMacroVals{end+1}=vals{k};
                                                                        elseif strcmp(objKind,'constpdef')

                                                                        else
                                                                            assert(false,'unrecognized object kind');
                                                                        end
                                                                    end




                                                                    function sortedNames=locDoSortOnType(aList,aObjMap)

                                                                        sortedNames={};

                                                                        if isempty(aList)
                                                                            return;
                                                                        end

                                                                        names={};
                                                                        depNamesMasterList={};
                                                                        objNamesMasterList=cell(1,length(aList));



                                                                        for idx=1:length(aList)
                                                                            thisName=aList{idx}.name;
                                                                            objNamesMasterList{idx}=thisName;
                                                                            depObjs=aList{idx}.dependencies;
                                                                            depIsBI=aList{idx}.builtin;
                                                                            for idy=1:length(depObjs)
                                                                                if strcmp(depIsBI(idy),'0')
                                                                                    depNamesMasterList{end+1}=depObjs{idy};
                                                                                end
                                                                            end
                                                                        end
                                                                        depNamesMasterList=unique(depNamesMasterList);
                                                                        names=setdiff(objNamesMasterList,depNamesMasterList);
                                                                        names=sort(names);

                                                                        for idx=1:length(names)


                                                                            depList={};
                                                                            thisObj=aObjMap(names{idx});
                                                                            depObjNames=thisObj.dependencies;
                                                                            for idy=1:length(depObjNames)
                                                                                if aObjMap.isKey(depObjNames{idy})
                                                                                    testObj=aObjMap(depObjNames{idy});
                                                                                    if strcmp(thisObj.file,testObj.file)
                                                                                        depList{end+1}=testObj;
                                                                                    end
                                                                                end
                                                                            end

                                                                            subNameSort=locDoSortOnType(depList,aObjMap);




                                                                            subNameSort=setdiff(subNameSort,sortedNames,'stable');
                                                                            sortedNames=[sortedNames,subNameSort,names{idx}];
                                                                        end






                                                                        function sortedNames=locDoSortOnDataDeclMacro(aList,aObjMap)
                                                                            sortedNames={};

                                                                            sortedList=struct;
                                                                            for k=1:length(aList)
                                                                                memsec=aList{k}.cscmemsec;


                                                                                pkgName=['A',memsec.PackageName];
                                                                                msName=['A',memsec.MemSecName];
                                                                                cscName=['A',memsec.CSCName];
                                                                                objName=['A',aList{k}.name];
                                                                                sortedList.(pkgName).(msName).(cscName).(objName)=aList{k};
                                                                            end

                                                                            pkgNames=sort(fieldnames(sortedList));
                                                                            for pkg_idx=1:length(pkgNames)
                                                                                aPkgName=pkgNames{pkg_idx};
                                                                                msNames=sort(fieldnames(sortedList.(aPkgName)));
                                                                                for ms_idx=1:length(msNames)
                                                                                    aMsName=msNames{ms_idx};
                                                                                    cscNames=sort(fieldnames(sortedList.(aPkgName).(aMsName)));
                                                                                    for csc_idx=1:length(cscNames)
                                                                                        aCscName=cscNames{csc_idx};
                                                                                        objNames=sort(fieldnames(sortedList.(aPkgName).(aMsName).(aCscName)));
                                                                                        for obj_idx=1:length(objNames)
                                                                                            aObjName=objNames{obj_idx};

                                                                                            aEleValue=sortedList.(aPkgName).(aMsName).(aCscName).(aObjName);
                                                                                            objName=aEleValue.name;
                                                                                            value=aObjMap(objName);

                                                                                            aMemSec=aEleValue.cscmemsec;

                                                                                            valueChanged=false;
                                                                                            if obj_idx==1&&~isempty(aMemSec.CSCComment)

                                                                                                value.definition=[aMemSec.CSCComment,char(10),...
                                                                                                value.definition];
                                                                                                valueChanged=true;
                                                                                            end


                                                                                            if csc_idx==1&&obj_idx==1
                                                                                                if pkg_idx==1&&ms_idx==1

                                                                                                    if strcmp(value.kind,'datadecl')
                                                                                                        value.definition=['/* Exported data declaration */',...
                                                                                                        char(10),value.definition];
                                                                                                        valueChanged=true;
                                                                                                    elseif strcmp(value.kind,'datamacro')
                                                                                                        value.definition=['/* Exported data define */',...
                                                                                                        char(10),value.definition];
                                                                                                        valueChanged=true;
                                                                                                    end
                                                                                                end



                                                                                                if aMemSec.MemSecAddPragma
                                                                                                    if~isempty(aMemSec.MemSecPrepragma)
                                                                                                        value.definition=[aMemSec.MemSecPrepragma,char(10),...
                                                                                                        value.definition];
                                                                                                        valueChanged=true;
                                                                                                    end

                                                                                                    if~isempty(aMemSec.MemSecComment)
                                                                                                        value.definition=[aMemSec.MemSecComment,char(10),...
                                                                                                        value.definition];
                                                                                                        valueChanged=true;
                                                                                                    end
                                                                                                end
                                                                                            end


                                                                                            if csc_idx==length(cscNames)&&obj_idx==length(objNames)


                                                                                                if aMemSec.MemSecAddPragma&&~isempty(aMemSec.MemSecPostpragma)
                                                                                                    value.definition=[value.definition,char(10),...
                                                                                                    aMemSec.MemSecPostpragma];
                                                                                                    valueChanged=true;
                                                                                                end
                                                                                            end

                                                                                            if valueChanged



                                                                                                aObjMap(objName)=value;
                                                                                            end

                                                                                            sortedNames{end+1}=objName;
                                                                                        end
                                                                                    end
                                                                                end
                                                                            end



                                                                            function anyChange=locResetDoUpdateFlag(objMap)

                                                                                anyChange=false;

                                                                                keys=objMap.keys;
                                                                                for idx=1:length(keys)
                                                                                    thisObj=objMap(keys{idx});

                                                                                    if(thisObj.doUpdate)
                                                                                        anyChange=true;
                                                                                    end
                                                                                    thisObj.doUpdate=false;
                                                                                    objMap(keys{idx})=thisObj;
                                                                                end



                                                                                function oChecksumStr=locComputeMD5Checksum(value)
                                                                                    assert(ischar(value));
                                                                                    oChecksum=CGXE.Utils.md5(value);
                                                                                    oChecksumStr=num2str(oChecksum');



                                                                                    function kindName=locGetKindName(kind)
                                                                                        switch kind
                                                                                        case{'type'}
                                                                                            kindName='data type';
                                                                                        case{'datamacro'}
                                                                                            kindName='macro';
                                                                                        otherwise
                                                                                            kindName='variable';
                                                                                        end



                                                                                        function locKindChanged(invalidObjectsForKind)%#ok
                                                                                            assert(~isempty(invalidObjectsForKind));
                                                                                            invalidInfo='';
                                                                                            for k=1:length(invalidObjectsForKind)
                                                                                                newKindName=locGetKindName(invalidObjectsForKind{k}{2});
                                                                                                oldKindName=locGetKindName(invalidObjectsForKind{k}{3});

                                                                                                invalidInfo=[invalidInfo,char(10),...
                                                                                                DAStudio.message('RTW:buildProcess:sharedKindChangeEntry',...
                                                                                                invalidObjectsForKind{k}{1},...
                                                                                                newKindName,...
                                                                                                oldKindName,...
                                                                                                invalidObjectsForKind{k}{4})];
                                                                                            end
                                                                                            DAStudio.error('RTW:buildProcess:sharedKindChangeCmdLine',...
                                                                                            invalidInfo);




                                                                                            function locDestinationChanged(invalidObjectsForDestination)%#ok
                                                                                                assert(~isempty(invalidObjectsForDestination));

                                                                                                invalidInfoForDataType='';
                                                                                                invalidInfoForDataDecl='';
                                                                                                for k=1:length(invalidObjectsForDestination)
                                                                                                    if strcmp(invalidObjectsForDestination{k}{1},'type')
                                                                                                        invalidInfoForDataType=[invalidInfoForDataType,char(10),...
                                                                                                        DAStudio.message('RTW:buildProcess:sharedTypeDestChangeEntry',...
                                                                                                        invalidObjectsForDestination{k}{2},...
                                                                                                        invalidObjectsForDestination{k}{4},...
                                                                                                        invalidObjectsForDestination{k}{3})];
                                                                                                    else
                                                                                                        invalidInfoForDataDecl=[invalidInfoForDataDecl,char(10),...
                                                                                                        DAStudio.message('RTW:buildProcess:sharedDataDeclDestChangeEntry',...
                                                                                                        invalidObjectsForDestination{k}{2},...
                                                                                                        invalidObjectsForDestination{k}{4},...
                                                                                                        invalidObjectsForDestination{k}{3})];
                                                                                                    end
                                                                                                end

                                                                                                if~isempty(invalidInfoForDataType)
                                                                                                    DAStudio.error('RTW:buildProcess:sharedTypeDestChangeCmdLine',...
                                                                                                    invalidInfoForDataType);
                                                                                                end
                                                                                                if~isempty(invalidInfoForDataDecl)
                                                                                                    DAStudio.error('RTW:buildProcess:sharedDataDeclDestChangeCmdLine',...
                                                                                                    invalidInfoForDataDecl);
                                                                                                end




                                                                                                function locAliasTypeChanged(invalidObjectsForAliasType)%#ok
                                                                                                    assert(~isempty(invalidObjectsForAliasType));
                                                                                                    invalidInfo='';
                                                                                                    for k=1:length(invalidObjectsForAliasType)
                                                                                                        invalidInfo=[invalidInfo,char(10),...
                                                                                                        DAStudio.message('RTW:buildProcess:sharedAliasTypeChangeEntry',...
                                                                                                        invalidObjectsForAliasType{k}{1},...
                                                                                                        invalidObjectsForAliasType{k}{2},...
                                                                                                        invalidObjectsForAliasType{k}{3},...
                                                                                                        invalidObjectsForAliasType{k}{4})];
                                                                                                    end
                                                                                                    DAStudio.error('RTW:buildProcess:sharedAliasTypeChangeCmdLine',...
                                                                                                    invalidInfo);




                                                                                                    function locMissingTypeChanged(invalidObjectsForSharedType)%#ok
                                                                                                        assert(~isempty(invalidObjectsForSharedType));
                                                                                                        invalidInfo='';
                                                                                                        uniqueDTNames=cell(2,0);

                                                                                                        for k=1:length(invalidObjectsForSharedType)
                                                                                                            datatypeName=invalidObjectsForSharedType{k}{2};
                                                                                                            dataName=invalidObjectsForSharedType{k}{1};
                                                                                                            [~,idx]=intersect(uniqueDTNames(1,:),datatypeName);
                                                                                                            if isempty(idx)
                                                                                                                uniqueDTNames{1,end+1}=datatypeName;
                                                                                                                uniqueDTNames{2,end}=dataName;
                                                                                                            else
                                                                                                                if length(uniqueDTNames{2,idx})<20

                                                                                                                    uniqueDTNames{2,idx}=[uniqueDTNames{2,idx},', ',dataName];
                                                                                                                else
                                                                                                                    uniqueDTNames{2,idx}=[uniqueDTNames{2,idx},', ... etc.,'];
                                                                                                                end
                                                                                                            end
                                                                                                        end

                                                                                                        for k=1:length(uniqueDTNames(1,:))
                                                                                                            invalidInfo=[invalidInfo,char(10),...
                                                                                                            DAStudio.message('RTW:buildProcess:sharedMissingSharedTypeChangeEntry',...
                                                                                                            uniqueDTNames{1,k},...
                                                                                                            uniqueDTNames{2,k})];
                                                                                                        end
                                                                                                        DAStudio.error('RTW:buildProcess:sharedMissingSharedTypeChangeCmdLine',...
                                                                                                        invalidInfo,uniqueDTNames{1,k});





                                                                                                        function line=locConvertToOneLine(str)
                                                                                                            line='';
                                                                                                            idx=strfind(str,char(10));
                                                                                                            if isempty(idx)
                                                                                                                line=strtrim(str);
                                                                                                                return;
                                                                                                            end

                                                                                                            startIdx=1;
                                                                                                            for k=1:length(idx)
                                                                                                                line=[line,strtrim(str(startIdx:idx(k))),' '];
                                                                                                                startIdx=idx(k);
                                                                                                            end
                                                                                                            line=strtrim([line,strtrim(str(startIdx:end))]);



                                                                                                            function locContentChanged(invalidObjectsForContent)%#ok 
                                                                                                                assert(~isempty(invalidObjectsForContent));
                                                                                                                invalidInfo='';
                                                                                                                for k=1:length(invalidObjectsForContent)
                                                                                                                    newContent=locConvertToOneLine(invalidObjectsForContent{k}{2});
                                                                                                                    oldContent=locConvertToOneLine(invalidObjectsForContent{k}{3});


                                                                                                                    newContent=strtrim(removeTempInlineTraceComments(newContent));
                                                                                                                    oldContent=strtrim(removeTempInlineTraceComments(oldContent));
                                                                                                                    if(isempty(newContent)&&isempty(oldContent))
                                                                                                                        invalidInfo=[invalidInfo,char(10),...
                                                                                                                        DAStudio.message('RTW:buildProcess:sharedDataContentChangeEntryGeneric',...
                                                                                                                        invalidObjectsForContent{k}{1},...
                                                                                                                        invalidObjectsForContent{k}{4})];
                                                                                                                    else
                                                                                                                        invalidInfo=[invalidInfo,char(10),...
                                                                                                                        DAStudio.message('RTW:buildProcess:sharedDataContentChangeEntry',...
                                                                                                                        invalidObjectsForContent{k}{1},...
                                                                                                                        newContent,...
                                                                                                                        oldContent,...
                                                                                                                        invalidObjectsForContent{k}{4})];
                                                                                                                    end
                                                                                                                end
                                                                                                                DAStudio.error('RTW:buildProcess:sharedTypeContentChangeCmdLine',...
                                                                                                                invalidInfo);




                                                                                                                function locCSCMemSecChanged(invalidObjectsForCSCMemSec)%#ok
                                                                                                                    assert(~isempty(invalidObjectsForCSCMemSec));
                                                                                                                    invalidInfo='';
                                                                                                                    for k=1:length(invalidObjectsForCSCMemSec)
                                                                                                                        newMemSec=invalidObjectsForCSCMemSec{k}{2};
                                                                                                                        oldMemSec=invalidObjectsForCSCMemSec{k}{3};
                                                                                                                        invalidInfo=[invalidInfo,char(10),...
                                                                                                                        DAStudio.message('RTW:buildProcess:sharedDataCSCMemSecChangeEntry',...
                                                                                                                        invalidObjectsForCSCMemSec{k}{1},...
                                                                                                                        newMemSec.CSCName,...
                                                                                                                        newMemSec.MemSecName,...
                                                                                                                        newMemSec.PackageName,...
                                                                                                                        oldMemSec.CSCName,...
                                                                                                                        oldMemSec.MemSecName,...
                                                                                                                        oldMemSec.PackageName)];
                                                                                                                    end
                                                                                                                    DAStudio.error('RTW:buildProcess:sharedDataCSCMemSecChangeCmdLine',...
                                                                                                                    invalidInfo);




                                                                                                                    function locPragmasChanged(invalidObjectsForPragmas)%#ok
                                                                                                                        assert(~isempty(invalidObjectsForPragmas));
                                                                                                                        invalidInfo='';
                                                                                                                        for k=1:length(invalidObjectsForPragmas)
                                                                                                                            newMemSec=invalidObjectsForPragmas{k}{2};
                                                                                                                            oldMemSec=invalidObjectsForPragmas{k}{3};
                                                                                                                            invalidInfo=[invalidInfo,char(10),...
                                                                                                                            DAStudio.message('RTW:buildProcess:sharedPragmasChangeEntry',...
                                                                                                                            invalidObjectsForPragmas{k}{1},...
                                                                                                                            newMemSec.CSCName,...
                                                                                                                            newMemSec.MemSecName,...
                                                                                                                            newMemSec.PackageName)];
                                                                                                                        end
                                                                                                                        DAStudio.error('RTW:buildProcess:sharedPragmasChangeCmdLine',...
                                                                                                                        invalidInfo);



                                                                                                                        function locDataScopeChanged(invalidObjectForDataScope)%#ok
                                                                                                                            assert(~isempty(invalidObjectForDataScope));
                                                                                                                            invalidInfo='';
                                                                                                                            for k=1:length(invalidObjectForDataScope)
                                                                                                                                invalidInfo=[invalidInfo,char(10),...
                                                                                                                                DAStudio.message('RTW:buildProcess:sharedDataTypeScopeChangedEntry',...
                                                                                                                                invalidObjectForDataScope{k}{1},...
                                                                                                                                invalidObjectForDataScope{k}{3})];
                                                                                                                            end
                                                                                                                            DAStudio.error('RTW:buildProcess:sharedDataTypeScopeChangedCmdLine',...
                                                                                                                            invalidInfo);


                                                                                                                            function locTestForMixedDataKindInFile(outFileMap)


                                                                                                                                objKeys=outFileMap.keys;
                                                                                                                                objVals=outFileMap.values;
                                                                                                                                invalidInfo='';
                                                                                                                                anyError=false;
                                                                                                                                for idx=1:length(objKeys)
                                                                                                                                    isType=0;
                                                                                                                                    isData=0;
                                                                                                                                    for idy=1:length(objVals{idx})
                                                                                                                                        thisObj=objVals{idx}{idy};
                                                                                                                                        switch thisObj.kind
                                                                                                                                        case 'type'
                                                                                                                                            isType=1;
                                                                                                                                        case{'datadecl','datamacro'}
                                                                                                                                            isData=1;
                                                                                                                                        otherwise
                                                                                                                                            assert(false,'only type, datadecl, datamacro, constpdef are supported currently');
                                                                                                                                        end
                                                                                                                                    end
                                                                                                                                    if isType+isData>1
                                                                                                                                        anyError=true;
                                                                                                                                        invalidInfo=[invalidInfo,char(10),...
                                                                                                                                        DAStudio.message('RTW:buildProcess:sharedMixedDataKindEntry',objKeys{idx});];
                                                                                                                                    end
                                                                                                                                end

                                                                                                                                if anyError
                                                                                                                                    DAStudio.error('RTW:buildProcess:sharedMixedDataKindCmdLine',...
                                                                                                                                    invalidInfo);
                                                                                                                                end

                                                                                                                                function retVal=loc_isUserProvidedType(objInfo)
                                                                                                                                    retVal=false;
                                                                                                                                    if(strcmp(objInfo.kind,'type')&&...
                                                                                                                                        objInfo.typeUserProvided)
                                                                                                                                        retVal=true;
                                                                                                                                    end







