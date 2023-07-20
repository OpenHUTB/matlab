function success=removeStaleCGContext(sharedFileDMRLocation,...
    cgCtxName,...
    systemName)










    success=false;%#ok




    if~strcmp(systemName(1:7),'<Root>/')
        success=true;
        return;
    end


    assert(strcmp(systemName(1:7),'<Root>/'));


    systemName=systemName(8:end);

    libIntf=SharedCodeManager.LibrarySubsystemInterface(fullfile(sharedFileDMRLocation,'shared_file.dmr'));


    targetCGCtxIdenIdentifier=[systemName,'_',cgCtxName];


    allCGCtxIdens=libIntf.retrieveAllIdentities('SCM_CODEGEN_CONTEXT');
    targetCGCtxIden=[];
    for i=1:length(allCGCtxIdens)
        thisCgCtxIden=allCGCtxIdens{i};
        if strcmp(thisCgCtxIden.Identifier,targetCGCtxIdenIdentifier)

            targetCGCtxIden=thisCgCtxIden;
            break;
        end
    end
    assert(~isempty(targetCGCtxIden));


    libIntf.removeIdentityAndData(targetCGCtxIden);



    allLibSSIdens=libIntf.retrieveAllIdentities('SCM_LIBRARY_SUBSYSTEM');
    targetLibSSIden=[];
    for i=1:length(allLibSSIdens)
        thisLibSSIden=allLibSSIdens{i};
        if strcmp(thisLibSSIden.SubsystemName,systemName)

            targetLibSSIden=thisLibSSIden;
            break;
        end
    end

    assert(~isempty(targetLibSSIden))
    oldLibSSData=libIntf.retrieveData(targetLibSSIden);


    numOldCodeGenContexts=oldLibSSData.NumCodeGenerationContexts;
    libIntf.removeIdentityAndData(targetLibSSIden);


    targetCtxToRemove=[systemName,'_',cgCtxName];





    newLibSSData=SharedCodeManager.LibrarySubsystemData(systemName);

    cgCtxList=oldLibSSData.CodegenContexts;
    for i=1:length(oldLibSSData.NumCodeGenerationContexts)
        thisCGCtx=cgCtxList(i);
        if strcmp(thisCGCtx,targetCtxToRemove)

            continue;
        end
        newLibSSData.addCodeGenerationContext(thisCGCtx);
    end


    libIntf.registerData(targetLibSSIden,newLibSSData);
    libIntf.finalize();


    assert(newLibSSData.NumCodeGenerationContexts==numOldCodeGenContexts-1)

    success=true;






