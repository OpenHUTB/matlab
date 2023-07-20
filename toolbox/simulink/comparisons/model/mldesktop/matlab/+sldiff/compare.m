function out=compare(leftFile,rightFile)




    try
        if nargout==0
            app=sldiff.internal.diff(leftFile,rightFile);
            comparisons.internal.appstore.register(app);
        else
            mcosView=sldiff.internal.mcos(leftFile,rightFile);
            if mcosView.getForest.roots.Size==uint64(0)
                out=[];
                return;
            end
            out=xmlcomp.Edits(comparisons.internal.MF0Edits(mcosView));
        end

    catch ex
        ex.throwAsCaller();
    end
end
