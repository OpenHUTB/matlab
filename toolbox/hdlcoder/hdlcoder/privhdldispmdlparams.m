function privhdldispmdlparams(mdlName,allParams)


    [mdlName,allParams]=convertStringsToChars(mdlName,allParams);

    nonDefaults=~strcmpi(allParams,'all');
    obj=mdlName;
    if~contains(obj,'/')

        mdlName=obj;

        openSystems=find_system('flat');
        if isempty(openSystems)||~any(contains(openSystems,mdlName))
            error(message('hdlcoder:makehdl:noopenmodels',mdlName));
        end

    else

        blkName=obj;
        mdlName=bdroot(blkName);
    end

    try
        dispHDLCodeGenParams(mdlName,nonDefaults);
    catch me
        disp(['Error occurred reading when reading parameters from the model ',mdlName]);
        rethrow(me);
    end
end


function dispHDLCodeGenParams(mdlName,nonDefaults)

    cli=hdlcoderprops.CLI;

    mdlProps=get_param(mdlName,'HDLParams');

    if isempty(mdlProps)
        mdlProps=slprops.hdlmdlprops;
    end

    currProps=mdlProps.getCurrentMdlProps;

    for k=1:2:length(currProps)
        try
            cli.set(currProps{k},currProps{k+1});
        catch me %#ok<NASGU>

        end
    end

    cli.displayProps(mdlName,nonDefaults);
end
