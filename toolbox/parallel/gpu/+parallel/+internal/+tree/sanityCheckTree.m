function sanityCheckTree(ftree,context,ftype,errorMechanism)




    if isempty(ftree)
        me=MException(message('parallel:gpu:compiler:EmptyFile',context));
        throwAsCaller(me);
    end

    rootftree=root(ftree);
    setCurrentContextForErrorMechanism(errorMechanism,context);
    setNodeForErrorMechanism(errorMechanism,rootftree);

    if iskind(rootftree,'ERR')
        lineNumberColonMessage=string(rootftree);
        indxOfColonAndMessage=regexp(lineNumberColonMessage,':(.*)','start');
        messageOnly=lineNumberColonMessage(indxOfColonAndMessage+1:end);
        encounteredError(errorMechanism,...
        message('parallel:gpu:compiler:Syntax',messageOnly));
    end


    if iskind(rootftree,'CLASSDEF')
        encounteredError(errorMechanism,...
        message('parallel:gpu:compiler:LanguageMCOS',...
        'MCOS',upper(kind(rootftree))));
    end



    if strcmp(ftype,'simple')&&~iskind(rootftree,'FUNCTION')
        encounteredError(errorMechanism,...
        message('parallel:gpu:compiler:LanguageScript'));
    end




    if strcmp(ftype,'simple')&&iskind(rootftree,'FUNCTION')
        mtreefname=string(Fname(rootftree));




        rootfname=regexp(context,iGetFilesepAsRegexpPattern(),'split');
        rootfname=rootfname{end};




        rootfname=regexprep(rootfname,'\..*','');


        if~strcmp(mtreefname,rootfname)
            parallel.internal.gpu.errorFcnFileNameMismatch(context,...
            full(rootftree),...
            errorMechanism);
        end
    end
end





function delimiter=iGetFilesepAsRegexpPattern()
    persistent pattern;

    if isempty(pattern)
        pattern=filesep;
        if strcmp(pattern,'/')
            pattern='\/';
        end
    end

    delimiter=pattern;
end
