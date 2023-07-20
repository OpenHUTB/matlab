function[mexVerboseText,errorOccurred,mexCommand]=sfuncSourceCompile(isEval,sfunctionName,addLibsStr,...
    addIncPaths,preProcDefList,outdir,enableUsePublishedOnly,isDebug)

    mexVerboseText='';
    mexCommand='';
    errorOccurred=0;
    addLibsStr=strrep(addLibsStr,'$MATLABROOT',matlabroot);

    addIncludePathStr='';
    addIncludePaths={};
    if~isempty(addIncPaths)
        numAddIncPaths=0;
        if iscell(addIncPaths)
            numAddIncPaths=length(addIncPaths);
            addIncludePaths=addIncPaths;
        elseif ischar(addIncPaths)
            numAddIncPaths=1;
            addIncludePaths=addIncPaths;
        end
        for addIncIdx=1:numAddIncPaths
            if isempty(addIncludePaths{addIncIdx})
                continue;
            end
            if isEval
                addIncludePathStr=[addIncludePathStr,',''-I',addIncludePaths{addIncIdx},''''];
            else
                addIncludePathStr=[addIncludePathStr,',','[''-I''',' ',addIncludePaths{addIncIdx},']'];
            end
        end
    end


    addPreprocDefsStr='';
    addPreprocDefs={};
    if~isempty(preProcDefList)
        numPreprocDefs=0;
        if iscell(preProcDefList)
            numPreprocDefs=length(preProcDefList);
            addPreprocDefs=preProcDefList;
        elseif ischar(preProcDefList)
            numPreprocDefs=1;
            addPreprocDefs={preProcDefList};
        end
        for addPreprocIdx=1:numPreprocDefs
            if isempty(addPreprocDefs{addPreprocIdx})
                continue;
            end
            addPreprocDefsStr=[addPreprocDefsStr,',''-D',addPreprocDefs{addPreprocIdx},''''];
        end
    end


    if isEval

        mexCommand='mex(';
        mexCommand=[mexCommand,'''-v'','];
        mexCommand=[mexCommand,'''CFLAGS=$CFLAGS -Wall'','];
        mexCommand=[mexCommand,'''-outdir'',','outdir,'];
        if enableUsePublishedOnly
            mexCommand=[mexCommand,'''-DUSE_PUBLISHED_ONLY'','];
        end
        if isequal(isDebug,'yes')
            mexCommand=[mexCommand,'''-g'','];
        end
        mexCommand=[mexCommand,'sfunctionName,',addLibsStr];



        if~isempty(strtrim(addIncludePathStr))
            mexCommand=[mexCommand,addIncludePathStr];
        end


        if~isempty(strtrim(addPreprocDefsStr))
            mexCommand=[mexCommand,addPreprocDefsStr];
        end

        mexCommand=[mexCommand,')'];
        [mexVerboseText,errorOccurred]=evalc(mexCommand);

    else
        mexCommand='mex(';
        mexCommand=[mexCommand,'''-outdir'',',outdir,' ,'];
        if enableUsePublishedOnly
            mexCommand=[mexCommand,'''-DUSE_PUBLISHED_ONLY'','];
        end
        if isequal(isDebug,'yes')
            mexCommand=[mexCommand,'''-g'','];
        end
        if~isempty(addLibsStr)
            mexCommand=[mexCommand,sfunctionName,',',addLibsStr];
        else
            mexCommand=[mexCommand,sfunctionName];
        end


        if~isempty(strtrim(addIncludePathStr))
            mexCommand=[mexCommand,addIncludePathStr];
        end


        if~isempty(strtrim(addPreprocDefsStr))
            mexCommand=[mexCommand,addPreprocDefsStr];
        end

        mexCommand=[mexCommand,')'];
    end

end

