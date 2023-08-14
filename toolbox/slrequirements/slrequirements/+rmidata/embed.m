function embed(model)




    if ischar(model)
        modelH=get_param(model,'Handle');
    else
        modelH=model;
    end

    embedInSLX(modelH);
end

function embedInSLX(modelH)
    modelFile=get_param(modelH,'FileName');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(modelFile);
    if~isempty(linkSet)
        oldFile=linkSet.filepath;
        success=linkSet.embed();
        if success

            if isModelFileWriteable(modelH)
                save_system(modelH);
                if exist(oldFile,'file')==2
                    backupFile=regexprep(oldFile,'.slmx$','.slmx.bak');
                    try
                        movefile(oldFile,backupFile,'f');
                    catch ME %#ok<NASGU>

                    end
                end
            end
        end
    end
end

function tf=isModelFileWriteable(modelH)
    mdlFile=get_param(modelH,'FileName');
    if exist(mdlFile,'file')==4
        [~,fattr]=fileattrib(mdlFile);
        tf=fattr.UserWrite;
    else
        tf=true;
    end
end

