function CleanWorkspace(obj)



    if isempty(obj.data.currentdirectory)
        rmdir(obj.data.workdirectory,'s');
    else
        UnfoldingVerbose(obj,true,getString(message('dsp:dspunfold:CleanWorkspaceLog',obj.data.workdirectory)));
        warning('off','MATLAB:mpath:nameNonexistentOrNotADirectory');
        path(obj.data.origpath);
        chdir(obj.data.currentdirectory);
        if~obj.Debugging



            [~,~,~]=rmdir(obj.data.workdirectory,'s');
        end
        warning(obj.data.orig_warning_state);
    end
end

