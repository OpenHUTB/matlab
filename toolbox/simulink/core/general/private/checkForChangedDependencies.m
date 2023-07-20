function[oChangedDep,oChangedType]=checkForChangedDependencies(iMdl,iMdlDeps,prevChecksums,iVerbose,isInternalDeps)




    oChangedDep='';
    oChangedType=[];

    if isInternalDeps&&~isempty(iMdlDeps)
        mdlDeps={iMdlDeps.Dependency};
        mdlTypes=[iMdlDeps.Type];
    else
        mdlDeps=iMdlDeps;
        mdlTypes=repmat(...
        Simulink.ModelReference.internal.ModelDependencyType('MODELDEP_USER'),...
        length(iMdlDeps),1);
    end

    deps=mdlRefParseUserDeps(iMdl,mdlDeps,iVerbose,mdlTypes);


    if(isempty(prevChecksums))
        prevChecksumsKeys={};
    else
        prevChecksumsKeys={prevChecksums.Key};
    end


    for i=1:length(deps)
        depBase=deps(i).Base;
        depActual=deps(i).Actual;
        depType=deps(i).Type;

        match=strcmp(depBase,prevChecksumsKeys);
        if any(match)


            prevChecksum=prevChecksums(match).Checksum;
            currChecksum=file2hash(depActual);

            outOfDate=~isequal(prevChecksum,currChecksum);
        else


            outOfDate=true;
        end

        if(outOfDate)
            oChangedDep=depActual;
            oChangedType=depType;
            return;
        end
    end

    numPrevDeps=length(prevChecksums);
    numCurrDeps=length(deps);

    if(numPrevDeps~=numCurrDeps)



        currDeps={deps.Base};

        [missingDeps,missingDepsIndex]=setdiff(prevChecksumsKeys,currDeps);
        assert(~isempty(missingDeps));

        oChangedDep=missingDeps{1};
        oChangedType=Simulink.ModelReference.internal.ModelDependencyType(...
        prevChecksums(missingDepsIndex(1)).Type);


        if~isempty(regexp(oChangedDep,'^\$MDL','once'))
            mdlDir=get_mdl_dir(iMdl);
            oChangedDep=regexprep(oChangedDep,'^\$MDL','');
            oChangedDep=fullfile(mdlDir,oChangedDep);
        end
    end
end



