function[whichResult,whichResultType]=resolveSymbols(callerFilePath,callSites,useEMLWhich)










































































    import coderapp.internal.screener.WhichResultType;

    numSites=numel(callSites);
    whichResult=repmat(string(missing),[1,numSites]);
    whichResultType=repmat(WhichResultType.MATLABPath,[1,numSites]);
    for idx=1:numSites
        [whichResult(idx),whichResultType(idx)]=resolveSymbolImpl(callerFilePath,callSites(idx).Symbol,callSites(idx).Imports,useEMLWhich);
    end
end

function[whichResult,whichResultType]=resolveSymbolImpl(callerFilePath,symbol,imports,useEMLWhich)
    import coderapp.internal.screener.resolver.getCachedBestWhichResult;

    if~isempty(imports)
        [explicitImports,implicitImports]=partitionImports(imports);

        for explicitImport=explicitImports
            importedIdentifier=extractLastIdentifier(explicitImport);
            if~isDotQualified(symbol)
                if strcmp(importedIdentifier,symbol)
                    [whichResult,whichResultType]=getCachedBestWhichResult(explicitImport,useEMLWhich);
                    if~ismissing(whichResult)
                        return;
                    end
                end
            elseif isSingleDotQualified(symbol)
                staticMethodCallOrEnumMemberConstProperty=extractLastIdentifier(symbol);
                className=extractFirstIdentifier(symbol);
                if strcmp(className,importedIdentifier)
                    fullyQualifiedCall=strcat(explicitImport,".",staticMethodCallOrEnumMemberConstProperty);
                    [whichResult,whichResultType]=getCachedBestWhichResult(fullyQualifiedCall,useEMLWhich);
                    if~ismissing(whichResult)
                        return;
                    end


                    [whichResult,whichResultType]=getCachedBestWhichResult(explicitImport,useEMLWhich);
                    if~ismissing(whichResult)
                        return;
                    end
                end
            end
        end

        for implicitImport=implicitImports
            implicitImportPrefix=getImplicitImportPrefix(implicitImport);
            importedIdentifier=strcat(implicitImportPrefix,symbol);
            [whichResult,whichResultType]=getCachedBestWhichResult(importedIdentifier,useEMLWhich);
            if~ismissing(whichResult)
                return;
            end

            if isDotQualified(symbol)
                nonEnumMemberConstPropertyPrefix=extractAllButLastIdentifier(symbol);
                importedIdentifier=strcat(implicitImportPrefix,nonEnumMemberConstPropertyPrefix);
                [whichResult,whichResultType]=getCachedBestWhichResult(importedIdentifier,useEMLWhich);
                if~ismissing(whichResult)
                    return;
                end
            end
        end
    end

    if~isDotQualified(symbol)
        privateDir=getPrivateDirectoryOfFile(callerFilePath);
        privateDirFunction=append(privateDir,filesep,symbol);
        [whichResult,whichResultType]=getCachedBestWhichResult(privateDirFunction,useEMLWhich);
        if~ismissing(whichResult)
            return;
        end
    end

    [whichResult,whichResultType]=getCachedBestWhichResult(symbol,useEMLWhich);
    if~ismissing(whichResult)
        return;
    end

    if isDotQualified(symbol)
        identifier=extractAllButLastIdentifier(symbol);
        [whichResult,whichResultType]=getCachedBestWhichResult(identifier,useEMLWhich);
        if~ismissing(whichResult)
            return;
        end
    end

    import coderapp.internal.screener.WhichResultType;

    whichResult=string(missing);
    whichResultType=WhichResultType.MATLABPath;
end




function result=isSingleDotQualified(symbol)
    result=(count(symbol,".")==1);
end

function result=extractFirstIdentifier(symbol)
    identifiers=split(symbol,".");
    result=identifiers(1);
end

function result=getPrivateDirectoryOfFile(filePath)
    parentDir=fileparts(filePath);
    result=append(parentDir,filesep,"private");
end

function result=getImplicitImportPrefix(implicitImport)

    result=extractBefore(implicitImport,strlength(implicitImport));
end

function result=isDotQualified(symbol)
    result=contains(symbol,".");
end

function result=extractLastIdentifier(symbol)
    identifiers=split(symbol,".");
    result=identifiers(end);
end

function result=extractAllButLastIdentifier(symbol)
    identifiers=split(symbol,".");
    result=join(identifiers(1:end-1),".");
end

function[explicitImports,implicitImports]=partitionImports(imports)
    explicitImports=string.empty;
    implicitImports=string.empty;
    for import=imports
        if isImplicitImport(import)
            implicitImports(end+1)=import;%#ok<AGROW>
        else
            explicitImports(end+1)=import;%#ok<AGROW>
        end
    end
end

function result=isImplicitImport(import)
    if strlength(import)<1
        result=false;
    else
        lastChar=extract(import,strlength(import));
        result=strcmp(lastChar,"*");
    end
end
