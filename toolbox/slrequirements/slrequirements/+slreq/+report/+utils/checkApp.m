function out=checkApp(appType)



    persistent docExist

    if~isempty(docExist)
        out=docExist;
        return;
    end
    out=true;

    if ispc
        switch lower(appType)
        case '.docx'
            try
                docH=actxserver('word.application');
                if isempty(docH)
                    out=false;
                else
                    out=true;
                end
            catch ME %#ok<NASGU>

                out=false;
            end
        end
    else

        out=true;
    end

    docExist=out;
end

