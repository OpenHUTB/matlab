function applyMakeOptionsToBuildInfo(lBuildArgs,lBuildInfo)



    optsGroup='OPTS';
    optOptsGroup='OPT_OPTS';


    i_addFlagsAndDefinesToBuildInfo(lBuildInfo,lBuildArgs,optsGroup);
    i_addFlagsAndDefinesToBuildInfo(lBuildInfo,lBuildArgs,optOptsGroup);



    lBuildInfo.MakeArgs=lBuildArgs;
end


function[defs,cflags]=i_separateDefinesAndFlags(opts_str)


    opts=regexp(opts_str,'\S+','match');


    isDefine=regexp(opts,'(^-D.*)','once');
    definesIdx=cellfun(@(x)(~isempty(x)),isDefine);
    defs=opts(definesIdx);


    cflags=opts(~definesIdx);
end


function i_addFlagsAndDefinesToBuildInfo(lBuildInfo,lBuildArgs,group)


    optsString=coder.make.internal.parsestrforvar(lBuildArgs,group);

    if~isempty(optsString)

        [defs,cflags]=i_separateDefinesAndFlags(optsString);

        lBuildInfo.addDefines(defs,group);


        existingCompileFlags=getCompileFlags(lBuildInfo,group);
        newCompileFlags=setdiff(cflags,existingCompileFlags,'stable');
        if~isempty(newCompileFlags)
            lBuildInfo.addCompileFlags(newCompileFlags,group);
        end

    end
end
