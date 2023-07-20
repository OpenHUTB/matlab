
function runBuildProcessChecks(iMdl,protectedOrderedMdlRefs,orderedMdlRefsWithIMdl,runningForExternalMode,simMode,iBuildArgs)






    if~isempty(protectedOrderedMdlRefs)



        locCheckForCodeGenSupport(protectedOrderedMdlRefs,iBuildArgs);

        locCheckForClashingNames(orderedMdlRefsWithIMdl,iBuildArgs);
    end


    isExternalMode=~isempty(protectedOrderedMdlRefs)&&(runningForExternalMode);

    if isExternalMode
        DAStudio.error('Simulink:protectedModel:ExternalModeAndProtectedModel');
    end


    for i=1:length(protectedOrderedMdlRefs)
        protectedOrderedMdlRef=protectedOrderedMdlRefs(i);
        protectedModelName=protectedOrderedMdlRef.modelName;
        protectedModelSimMode=protectedOrderedMdlRef.mdlRefSimMode;
        opts=Simulink.ModelReference.ProtectedModel.getOptions(protectedModelName);

        if(shouldCheckForProtectedClashingName(iMdl,iBuildArgs,simMode))
            subModels=opts.subModels;

            for j=i+1:length(protectedOrderedMdlRefs)

                otherProtectedOrderedMdlRef=protectedOrderedMdlRefs(j);
                otherProtectedModelName=otherProtectedOrderedMdlRef.modelName;
                otherOpt=Simulink.ModelReference.ProtectedModel.getOptions(otherProtectedModelName);
                otherSubModels=otherOpt.subModels;

                clashingProtectedNames=intersect(subModels,otherSubModels);
                if~isempty(clashingProtectedNames)
errorOutIfClashingNameWithDifferentChecksum...
                    (protectedModelName,otherProtectedModelName,clashingProtectedNames);

                end
            end
        end






        if strcmp(opts.codeInterface,'Top model')
            needToThrowError=false;
            if loc_needsCodeGenCheck(iBuildArgs)
                needToThrowError=true;
            end

            if~needToThrowError&&...
                (iBuildArgs.XilInfo.IsModelBlockXil||...
                iBuildArgs.XilInfo.IsModelBlockXilTopModel)&&...
                any(strcmp(protectedModelSimMode,...
                {'Software-in-the-loop (SIL)','Processor-in-the-loop (PIL)'}))
                parentModelsSimModes=getEffectiveSimModesOfParentsOfProtectedModel(...
                iMdl,protectedOrderedMdlRef,orderedMdlRefsWithIMdl);
                if~isempty(parentModelsSimModes)
                    needToThrowError=~all(strcmp(parentModelsSimModes,'Normal'));
                end
            end

            if needToThrowError
                DAStudio.error('Simulink:protectedModel:protectedModelCodeInterfaceNotSupportedForRTW',...
                protectedModelName);
            end
        end
    end
end

function locCheckForCodeGenSupport(protectedOrderedMdlRefs,iBuildArgs)

    if(slfeature('NoSimTargetForBuild')==0)
        return;
    end



    isCodeGen=(iBuildArgs.TopModelStandalone&&~strcmp(iBuildArgs.ModelReferenceTargetType,'SIM'))||...
    iBuildArgs.ModelReferenceRTWTargetOnly||...
    strcmp(iBuildArgs.ModelReferenceTargetType,'RTW');
    if(~isCodeGen)
        return
    end


    for i=1:length(protectedOrderedMdlRefs)
        protectedModelFile=protectedOrderedMdlRefs(i).modelName;
        opts=Simulink.ModelReference.ProtectedModel.getOptions(protectedModelFile);

        if~Simulink.ModelReference.ProtectedModel.supportsCodeGen(opts)

            DAStudio.error('Simulink:protectedModel:ProtectedModelUnsupportedModeRTW',...
            opts.modelName);
        end
    end
end

function locCheckForClashingNames(orderedMdlRefsWithIMdl,iBuildArgs)

    import Simulink.ModelReference.ProtectedModel.*;

    mdlRefNames={orderedMdlRefsWithIMdl.modelName};
    protectedOrderedMdlRefNames={};
    for i=1:length(orderedMdlRefsWithIMdl)
        currentMdlRef=orderedMdlRefsWithIMdl(i);
        parentSimMode=currentMdlRef.mdlRefSimMode;
        for j=1:length(currentMdlRef.protectedChildren)
            protectedMdlRef=currentMdlRef.protectedChildren{j};
            protectedMdlRefSimMode=currentMdlRef.protectedChildSimMode{j};



            needsRTWArtifacts=buildNeedsRTWArtifacts(iBuildArgs.IsUpdatingSimForRTW,...
            iBuildArgs.ModelReferenceTargetType,...
            protectedMdlRefSimMode);

            if~strcmp(parentSimMode,'normal')||needsRTWArtifacts
                protectedOrderedMdlRefNames{end+1}=protectedMdlRef;%#ok<AGROW>
            end
        end
    end

    protectedModelsSupportingCodegenOrAccelerator=...
    getModelsSupportingCodegenOrAccelerator(protectedOrderedMdlRefNames);

    if~isempty(protectedModelsSupportingCodegenOrAccelerator)

        clashingNames=intersect(mdlRefNames,protectedModelsSupportingCodegenOrAccelerator);


        if~isempty(clashingNames)


            listOfClashingNames=locGetListOfClashingNames(clashingNames);

            DAStudio.error('Simulink:protectedModel:ModelRefAndProtectedModelNameClash',...
            listOfClashingNames);
        end
    end
end

function simModes=getEffectiveSimModesOfParentsOfProtectedModel(...
    iMdl,protectedOrderedMdlRef,orderedMdlRefsWithIMdl)
    simModes={};
    directParentsOfProtectedModel=protectedOrderedMdlRef.directParents;
    for parentIdx=1:length(directParentsOfProtectedModel)
        directParentOfProtectedModel=directParentsOfProtectedModel{parentIdx};

        if strcmp(directParentOfProtectedModel,iMdl)
            continue
        end
        parentsInOrderedList=orderedMdlRefsWithIMdl(...
        strcmp({orderedMdlRefsWithIMdl.modelName},...
        directParentOfProtectedModel));
        if~isempty(parentsInOrderedList)
            simModes=[simModes,{parentsInOrderedList.mdlRefSimMode}];%#ok<AGROW>
        end
    end
end

function out=locGetListOfClashingNames(clashingNames)
    listOfClashingNames=clashingNames{1};
    for clashingNamesIterator=2:length(clashingNames)
        listOfClashingNames=sprintf('%s, %s',listOfClashingNames,clashingNames{clashingNamesIterator});
    end
    out=listOfClashingNames;
end

function errorOutIfClashingNameWithDifferentChecksum...
    (protectedModelName,otherProtectedModelName,clashingProtectedNames)

    for i=1:length(clashingProtectedNames)
        checksum1=slInternal('getModelStructuralChecksumFromXMLFileInsideProtectedModel',...
        which(slInternal('getPackageNameForModel',protectedModelName)),...
        clashingProtectedNames{i});
        checksum2=slInternal('getModelStructuralChecksumFromXMLFileInsideProtectedModel',...
        which(slInternal('getPackageNameForModel',otherProtectedModelName)),...
        clashingProtectedNames{i});

        if(~isequal(checksum1,checksum2)||isempty(checksum1))
            DAStudio.error('Simulink:protectedModel:SubProtectedModelNameClash',...
            protectedModelName,otherProtectedModelName,clashingProtectedNames{i});
        end
    end

end

function needCheck=shouldCheckForProtectedClashingName(iMdl,iBuildArgs,simMode)





    needCodeGenCheck=loc_needsCodeGenCheck(iBuildArgs);

    needCheck=(~strcmp(simMode,'normal')&&~strcmp(simMode,'accelerator'))||...
    Simulink.ModelReference.ProtectedModel.protectingModel(iMdl)||...
    needCodeGenCheck;
end


function needsCodeGenCheck=loc_needsCodeGenCheck(iBuildArgs)
    isSimForRTW=iBuildArgs.IsUpdatingSimForRTW;
    isBuildWithNoSimTarget=(slfeature('NoSimTargetForBuild')>0)&&...
    (iBuildArgs.TopModelStandalone||...
    strcmp(iBuildArgs.ModelReferenceTargetType,'RTW'));

    needsCodeGenCheck=isSimForRTW||isBuildWithNoSimTarget;
end
