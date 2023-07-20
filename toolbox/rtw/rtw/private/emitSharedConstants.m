function sharedHdrInfo=emitSharedConstants(model,sharedutils,sharedFile,...
    constPFileBase,hasSharedConstants,appendToFile,varargin)






    persistent p;
    if isempty(p)
        p=inputParser;
        addParameter(p,'ExistingIncludes',{});
        addParameter(p,'ExistingParameters',{});
    end
    parse(p,varargin{:});

    sharedHdrInfo.numGeneratedFiles=0;
    sharedHdrInfo.generatedFileList={};


    fileName=fullfile(sharedutils,'filemap.mat');


    if exist(fileName,'file')==2



        load(fileName,'fileMap');
    else
        return;
    end



    aKeys=fileMap.keys;

    if~hasSharedConstants
        for idx=1:length(aKeys)
            thisKey=aKeys{idx};

            objKind=fileMap(thisKey).kind;
            if(strcmp(objKind,'constpdef'))
                hasSharedConstants=true;
                continue;
            end
        end
    end

    if~hasSharedConstants
        return;
    end

    [~,langExtension]=rtwprivate('rtw_is_cpp_build',model);
    langExtension=['.',langExtension];

    includedHdrs={};

    sharedTypesInIR=slfeature('SharedTypesInIR');

    if(sharedTypesInIR==1)
        sharedTypesInterface=SharedCodeManager.SharedTypesInterface(sharedFile);
    end

    for idx=1:length(aKeys)
        thisKey=aKeys{idx};

        objKind=fileMap(thisKey).kind;


        if(~strcmp(objKind,'constpdef'))
            continue;
        end

        thisFile=fileMap(thisKey);

        depObjName=thisFile.dependencies;

        depIsMultiword=isfield(thisFile,'isMultiword')&&thisFile.isMultiword;
        depIsNonfiniteLiteral=isfield(thisFile,'isNonfiniteLiteral')&&thisFile.isNonfiniteLiteral;
        depIsStdString=isfield(thisFile,'isStdString')&&thisFile.isStdString;
        depIsStdArray=isfield(thisFile,'isStdArray')&&thisFile.isStdArray;
        depIsStdVector=isfield(thisFile,'isStdVector')&&thisFile.isStdVector;
        depIsHalfType=isfield(thisFile,'isHalfPrecision')&&thisFile.isHalfPrecision;
        depIsImageType=isfield(thisFile,'isImage')&&thisFile.isImage;
        includedHdrs=locCollectIncludes(thisFile.standardTypesHeaders,includedHdrs);


        if(sharedTypesInIR==1)
            if(sharedTypesInterface.isValidSharedType(depObjName))
                depObj=sharedTypesInterface.retrieveDataForName('SCM_SHARED_TYPES',depObjName);
                includedHdrs=locCollectIncludes(depObj.FileName,includedHdrs);
            else
                if depIsStdString
                    includedHdrs=locCollectIncludes('<string>',includedHdrs);
                end
                if depIsMultiword
                    includedHdrs=locCollectIncludes('multiword_types.h',includedHdrs);
                end
                if depIsNonfiniteLiteral
                    includedHdrs=locCollectIncludes('<math.h>',includedHdrs);
                    includedHdrs=locCollectIncludes('rt_nonfinite.h',includedHdrs);
                end
                if depIsStdArray
                    includedHdrs=locCollectIncludes('<array>',includedHdrs);
                end
                if depIsStdVector
                    includedHdrs=locCollectIncludes('<vector>',includedHdrs);
                end
                if depIsHalfType
                    includedHdrs=locCollectIncludes('half_type.h',includedHdrs);
                end
                if depIsImageType
                    includedHdrs=locCollectIncludes('image_type.h',includedHdrs);
                end
            end
        elseif fileMap.isKey(depObjName)
            depObj=fileMap(depObjName);
            includedHdrs=locCollectIncludes(depObj.file,includedHdrs);
        else
            if depIsStdString
                includedHdrs=locCollectIncludes('<string>',includedHdrs);
            end
            if depIsMultiword
                includedHdrs=locCollectIncludes('multiword_types.h',includedHdrs);
            end
            if depIsNonfiniteLiteral
                includedHdrs=locCollectIncludes('<math.h>',includedHdrs);
            end
            if depIsStdArray
                includedHdrs=locCollectIncludes('<array>',includedHdrs);
            end
            if depIsStdVector
                includedHdrs=locCollectIncludes('<vector>',includedHdrs);
            end
            if depIsHalfType
                includedHdrs=locCollectIncludes('half_type.h',includedHdrs);
            end
        end
    end



    isConstPDefIdx=false(size(aKeys));
    aObjs=values(fileMap);
    for i=length(aObjs):-1:1
        if strcmp(aObjs{i}.kind,'constpdef')
            constPDefItems(i)=aObjs{i};
            isConstPDefIdx(i)=true;
        end
    end
    constPDefNames=aKeys(isConstPDefIdx);
    constPDefItems=constPDefItems(isConstPDefIdx);


    hasExistingParams=~isempty(p.Results.ExistingParameters);
    if hasExistingParams
        keepIdx=true(size(constPDefNames));
        for i=1:length(constPDefNames)
            paramName=[constPDefItems(i).ParamPrefix,constPDefNames{i}];
            keepIdx(i)=~any(strcmp(paramName,p.Results.ExistingParameters));
        end
        constPDefNames=constPDefNames(keepIdx);
        constPDefItems=constPDefItems(keepIdx);
    end

    if~isempty(constPDefNames)

        newHeaders=setdiff(includedHdrs,p.Results.ExistingIncludes,'stable');


        outFileName=fullfile(sharedutils,[constPFileBase,langExtension]);

        locWriteContent(model,outFileName,appendToFile,newHeaders,...
        hasExistingParams,constPDefNames,constPDefItems);

    end

    sharedHdrInfo.numGeneratedFiles=1;
    sharedHdrInfo.generatedFileList{1}=constPFileBase;
end



function includedHdrs=locCollectIncludes(additionalHdrs,includedHdrs)
    if~iscell(additionalHdrs)





        additionalHdrs=cellstr(additionalHdrs);
    end
    additionalHdrs=setdiff(additionalHdrs,includedHdrs,'stable');
    includedHdrs=[includedHdrs,additionalHdrs];
end



function locWriteContent(model,outFileName,appendToFile,includedHdrs,...
    hasExistingParams,constPDefNames,constPDefItems)


    if appendToFile
        fid=fopen(outFileName,'a+');
    else
        fid=fopen(outFileName,'w+');
    end

    assert(fid~=-1);




    if hasExistingParams
        fprintf(fid,[newline,newline]);
    end


    if~isempty(includedHdrs)
        for i=1:length(includedHdrs)

            if~isempty(regexp(includedHdrs{i},'<*>','once'))
                fprintf(fid,'#include %s\n',includedHdrs{i});
            else
                fprintf(fid,'#include "%s"\n',includedHdrs{i});
            end
        end
    end


    for i=1:length(constPDefNames)
        paramData=constPDefItems(i);
        dataType=paramData.dataType;
        width=paramData.Width;
        initStr=paramData.InitStr;
        paramName=[paramData.ParamPrefix,constPDefNames{i}];

        fprintf(fid,'\nextern const %s %s%s;\n',dataType,paramName,width);
        if(getUsesCppBracedInit(model))
            if initStr(find(~isspace(initStr),1))=='{'
                fprintf(fid,'const %s %s%s%s;\n',dataType,paramName,width,initStr);
            else
                fprintf(fid,'const %s %s%s{ %s };\n',dataType,paramName,width,initStr);
            end
        else
            fprintf(fid,'const %s %s%s = %s;\n',dataType,paramName,width,initStr);
        end
    end


    fclose(fid);

end




