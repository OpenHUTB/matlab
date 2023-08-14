
function lookForRapidAccelNonInlinedSFunctionFiles(lBuildInfo,modelName,sfcns)

    tmpSourcePaths=lBuildInfo.getSourcePaths(true);
    for i=1:length(sfcns)
        sfcn=sfcns{i};
        [sfcnPath,sfcnName]=fileparts(which(sfcn));
        if(isempty(sfcnName))
            continue;
        end
        foundCFile=false;
        if(exist([sfcnPath,filesep,sfcnName,'.c'],'file')==2)
            foundCFile=true;
        end
        if(exist([sfcnPath,filesep,sfcnName,'.cpp'],'file')==2)
            foundCFile=true;
        end
        if(~foundCFile)
            for j=1:length(tmpSourcePaths)
                sfcnPath=tmpSourcePaths{j};
                if(exist([sfcnPath,filesep,sfcnName,'.c'],'file')==2)
                    foundCFile=true;
                    break;
                end
                if(exist([sfcnPath,filesep,sfcnName,'.cpp'],'file')==2)
                    foundCFile=true;
                    break;
                end
            end
        end
        if(~foundCFile)
            DAStudio.error('Simulink:tools:rapidAccelBuildFailedCSFunctionSourceNotFound',...
            modelName,sfcnName);
        end
    end
