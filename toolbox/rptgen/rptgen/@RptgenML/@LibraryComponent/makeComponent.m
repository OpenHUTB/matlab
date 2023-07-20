function c=makeComponent(libC,isSafe)




    try
        c=feval(libC.ClassName);
    catch
        if nargin<2||isSafe
            c=rptgen.crg_comment('CommentText',sprintf(getString(message('rptgen:RptgenML_LibraryComponent:couldNotCreateLabel')),libC.ClassName));
        else
            c=[];
        end
    end
