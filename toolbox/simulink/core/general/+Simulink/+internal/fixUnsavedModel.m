function out=fixUnsavedModel(sys)







    sysType=get_param(sys,'BlockDiagramType');
    isModel=strcmp(sysType,'model');

    cs=getActiveConfigSet(sys);
    dlg=cs.getDialogHandle;
    csHasUnappliedChanges=isa(dlg,'DAStudio.Dialog')&&dlg.hasUnappliedChanges;

    if isModel
        wks=get_param(sys,'ModelWorkspace');
        successMessage=message('Simulink:slbuild:unsavedMdlRefsSaved',sys).getString;


        if~strcmp(get_param(sys,'Dirty'),'on')&&~csHasUnappliedChanges&&...
            ~wks.isDirty

            out=successMessage;
            return
        end
    else
        successMessage=message('Simulink:slbuild:unsavedMdlRefsSaved',sys).getString;


        if~strcmp(get_param(sys,'Dirty'),'on')&&~csHasUnappliedChanges

            out=successMessage;
            return
        end
    end




    file=get_param(sys,'FileName');
    if~isWritable(file)
        promptMakeWritable(file);
    else
        promptSave(sys);
    end


    if isModel
        saveDataFile=any(strcmp(wks.DataSource,{'MAT-File','MATLAB File'}))&&wks.isDirty;
        if saveDataFile
            if~isWritable(wks.FileName)


                promptMakeWritable(wks.FileName);
            end
        end
    else
        saveDataFile=false;
    end




    makeWritable(file);
    if saveDataFile
        makeWritable(wks.FileName);
        args={'AllowPrompt',true,'SaveModelWorkspace',true};
    elseif isModel&&wks.isDirty&&strcmp(wks.DataSource,'MATLAB Code')



        args={'SaveModelWorkspace',true};
    else









        args={'AllowPrompt',true};
    end


    if isModel&&csHasUnappliedChanges
        dlg.apply;
    end


    save_system(sys,file,args{:});


    out=successMessage;

    function out=isWritable(file)

        if exist(file,'file')
            [success,attrib]=fileattrib(file);
            out=success&&attrib.UserWrite;
        else
            out=true;
        end

        function makeWritable(file)

            [stat,struc]=fileattrib(file);
            if stat&&~struc.UserWrite
                if isnan(struc.OtherWrite)
                    fileattrib(file,'+w');
                else
                    fileattrib(file,'+w','u');
                end
            end

            function promptMakeWritable(file)

                ok=message('Simulink:Commands:MakeWritableAndSave').getString;
                cancel=message('Simulink:editor:DialogCancel').getString;
                response=questdlg(...
                message('Simulink:Commands:FileNotWritable',file).getString,...
                message('Simulink:editor:DialogMessage').getString,...
                ok,cancel,cancel);
                if strcmp(response,cancel)
                    throw(MSLException([],message('Simulink:modelReference:MdlRefSaveCanceled')));
                end

                function promptSave(model)

                    ok=message('Simulink:editor:DialogOK').getString;
                    cancel=message('Simulink:editor:DialogCancel').getString;
                    response=questdlg(...
                    message('Simulink:Commands:SaveModelPrompt',model).getString,...
                    message('Simulink:editor:DialogMessage').getString,...
                    ok,cancel,cancel);
                    if strcmp(response,cancel)
                        throw(MSLException([],message('Simulink:modelReference:MdlRefSaveCanceled')));
                    end


