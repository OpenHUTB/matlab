function errmsg=getErrorMessage(E)

    if strcmp(E.identifier,'MATLAB:MException:MultipleErrors')||...
        (isa(E,'MSLException')&&~isempty(E.cause))
        errmsg=recursive_popup_exception_msg(E);
    else
        errmsg=loc_ExceptionMessageFilter(E);
    end
end

function errmsgs=recursive_popup_exception_msg(E)
    errmsgs={};
    for errIdx=1:numel(E.cause)

        if~strcmp(E.cause{errIdx}.identifier,'Simulink:Engine:EI_CannotCompleteEI')
            if~strcmp(E.cause{errIdx}.identifier,'MATLAB:MException:MultipleErrors')
                errmsgs{end+1}=[loc_ExceptionMessageFilter(E.cause{errIdx}),'<br />'];%#ok<AGROW>
            end
            errmsgs=[errmsgs,recursive_popup_exception_msg(E.cause{errIdx})];%#ok<AGROW>
        end
    end

    if length(errmsgs)>1
        errmsgs=sprintf('%s<br />\n',errmsgs{:});

    elseif length(errmsgs)==1
        errmsgs=regexprep(errmsgs{1},'<br />$','');
    else
        errmsgs='';
    end
end

function errmsg=loc_ExceptionMessageFilter(E)
...
...
...
...
...
...
...
...
...
...

    errmsg=E.message;
end