function[success,errstring]=restore(filename,keeporiginal)









    if nargin<2
        keeporiginal=false;
    end

    autosaveext=Simulink.autosave.autosaveext;



    [success,errstring]=i_ExpectSuccess(filename,keeporiginal);
    if~success
        if isempty(errstring)
            errstring=DAStudio.message('Simulink:dialog:autosavePermissionsError',filename);
        end
        return;
    end

    [~,model]=fileparts(filename);
    if bdIsLoaded(model)
        visible=strcmp(get_param(model,'Open'),'on');
        if strcmp(get_param(model,'AutoSaveFileCreated'),'on')


            set_param(model,'AutoSaveFileCreated','off')
        end

        close_system(model,0,'SkipCloseFcn',true);
    else
        visible=false;
    end


    renamed_original=[filename,'.original'];
    if exist(filename,'file')&&keeporiginal
        if ispc



            [ok,attribs]=fileattrib(renamed_original);
            if~ok||attribs.UserWrite

                ok=movefile(filename,renamed_original,'f');
            else

                ok=false;
            end
        else
            ok=movefile(filename,renamed_original);
        end
        if~ok
            DAStudio.error('Simulink:dialog:autosaveCopyError',filename);
        end
    end

    try

        Simulink.internal.newSystemFromFile(model,...
        [filename,autosaveext],ExecuteCallbacks=false);



        save_system(model,filename);
    catch E


        if keeporiginal&&exist(renamed_original,'file')
            if ispc
                movefile(renamed_original,filename,'f');
            else
                movefile(renamed_original,filename);
            end
        end
        rethrow(E);
    end

    if(visible)
        open_system(model);
    end

    try
        i_Discard([filename,autosaveext]);
    catch E


        warning(E.identifier,'%s',E.message);
    end

    success=true;
end


function[success,msg]=i_ExpectSuccess(filename,keeporiginal)


    success=false;
    msg='';

    autosaveext=Simulink.autosave.autosaveext;

    try


        [foundmdl,attribmdl]=fileattrib(filename);
        [foundorig,attriborig]=fileattrib([filename,'.original']);
        if keeporiginal&&foundmdl&&foundorig&&~attriborig.UserWrite
            return
        end



        if~exist([filename,autosaveext],'file')
            return
        end


        if foundmdl&&~attribmdl.UserWrite
            return
        end



        if~ispc
            [~,msgfold]=fileattrib(fileparts(filename));
            if~msgfold.UserWrite
                return
            end
        end
    catch errstruct
        msg=errstruct.message;
        return
    end

    success=true;
end


function i_Discard(autosave_filename)

    [exists,attribs]=fileattrib(autosave_filename);
    if~exists
        return
    end
    if~attribs.UserWrite
        DAStudio.error('Simulink:dialog:autosaveDiscardError',...
        autosave_filename);
    end

    try
        delete(autosave_filename);
    catch E
        DAStudio.error('Simulink:dialog:autosaveDiscardError',...
        autosave_filename);
    end
end
