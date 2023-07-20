function[result,compspec]=getComposeSpec(testcomp)



    compspec=struct([]);
    result=true;
    options=testcomp.activeSettings;
    if isequal(options.EnableObjComposition,'on')
        file=options.ObjectiveComposeSpecFileName;
        [dir,name]=fileparts(file);
        if~isempty(dir)

            oldPath=addpath(dir);
        end
        try
            compspec=feval(name);
        catch Mex
            modelH=testcomp.analysisInfo.designModelH;
            msg=getString(message('Sldv:private:objComposition:unableToProcessComposeSpec',file,Mex.message));
            sldvshareprivate('avtcgirunsupcollect','push',modelH,'sldv',...
            msg,'Sldv:private:objComposition:unableToProcessComposeSpec');
            result=false;
        end
        if~isempty(dir)

            path(oldPath);
        end
    end
end



