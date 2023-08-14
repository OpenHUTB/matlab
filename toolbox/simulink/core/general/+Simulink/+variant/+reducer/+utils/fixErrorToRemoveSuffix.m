function modifiedExcep=fixErrorToRemoveSuffix(red2orig,inExcep)








    function recursivelyUpdateCause(causeExcep)
        updatedCauseExcep=Simulink.variant.reducer.utils.fixErrorToRemoveSuffix(red2orig,causeExcep);
        modifiedExcep=addCause(modifiedExcep,updatedCauseExcep);
    end

    modifiedExcep=inExcep;

    try
        modifiedExcep=removeReducerSuffix(red2orig,inExcep);
        if isempty(inExcep.cause)
            return;
        end
        cellfun(@recursivelyUpdateCause,inExcep.cause);
    catch excep %#ok<NASGU>
    end
end

function modifiedExcep=removeReducerSuffix(red2orig,excep)
    if isa(excep,'MSLException')
        modifiedExcep=removeReducerSuffixForMSLException(red2orig,excep);


    elseif isa(excep,'MException')
        modifiedExcep=removeReducerSuffixForMException(red2orig,excep);
    end
end

function modifiedArgs=getModifiedArguments(red2orig,inputArgs)
    modifiedArgs=inputArgs;
    for i=1:numel(modifiedArgs)


        if~ischar(modifiedArgs{i})
            continue;
        end

        paths=Simulink.variant.utils.splitPathInHierarchy(...
        modifiedArgs{i});

        if isempty(paths)
            continue;
        end


        if red2orig.isKey(paths{1})
            paths{1}=red2orig(paths{1});
        end




        modifiedArgs{i}=strjoin(paths,'/');
    end
end

function modifiedExcep=removeReducerSuffixForMException(red2orig,excep)


    if isequal(excep.identifier,'MATLAB:MException:MultipleErrors')
        errid='SL_SERVICES:utils:MultipleErrorsMessagePreamble';
        modifiedExcep=MException(message(errid));
        return;
    end

    modifiedArgs=excep.arguments;



    if isempty(modifiedArgs)
        modifiedExcep=MException(excep.identifier,excep.message);
        return;
    end

    modifiedArgs=getModifiedArguments(red2orig,excep.arguments);

    modifiedExcep=MException(excep.identifier,message(...
    excep.identifier,...
    modifiedArgs{:}));
end

function modifiedExcep=removeReducerSuffixForMSLException(red2orig,excep)


    if isequal(excep.identifier,'MATLAB:MException:MultipleErrors')
        errid='SL_SERVICES:utils:MultipleErrorsMessagePreamble';
        modifiedExcep=MSLException(message(errid));
        return;
    end






    if isempty(excep.arguments)
        modifiedExcep=MSLException([],excep.identifier,excep.message);
    else
        modifiedExcep=MSLException(excep.identifier,excep.arguments{:});
    end



    allHandles=[excep.handles{:}];
    if isempty(allHandles)
        return;
    end

    modifiedArguments=getModifiedArguments(red2orig,excep.arguments);
    modifiedExcep=MSLException(excep.identifier,modifiedArguments{:});
end


