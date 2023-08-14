


classdef Propagation<handle
    properties
TopModel
CS
Time
SaveName
Number
IsPropagated
Map
        Mode=0;
        Index=1;
    end

    properties(Transient=true)
Dialog
GUI
        Dirty=false;

        IsConvertedChecked=true;
        IsRestoredChecked=true;
        IsSkippedChecked=true;
        IsFailedChecked=true;
        SearchStr='';
    end

    methods
        function h=Propagation(mdl,varargin)
            try
                gui=true;
                if nargin>1
                    if strcmp(varargin{1},'nogui')
                        gui=false;
                    end
                end

                if gui
                    p=showProgressbar();
                end

                load_system(mdl);
                backupFile=setupBackupFile(mdl);

                if isBackupValid(backupFile)
                    h=loadBackup(backupFile,mdl,gui);
                else
                    h.init(mdl,backupFile,gui);
                end

                h.Mode=0;
                h.Number=h.Map.length;
                h.Index=1;

                if gui
                    if h.Map.size(1)>0
                        h.showDialog();
                        h.setDlg();
                        p=[];
                    else
                        msgbox(DAStudio.message('Simulink:tools:NoReferencedModel',h.TopModel),...
                        DAStudio.message('configset:util:Error'),'warn');
                        p=[];
                    end
                end
            catch e
                if gui
                    errordlg(configset.util.message(e));
                    p=[];
                else
                    throw(e);
                end


            end
        end

        schema=getDialogSchema(h)
        dlg=showDialog(h)

        showCS(h)
        showTopModel(h)
        selectAll(h,val)
        checkon(h)
        checkoff(h)
        checktri(h)

        selectModel(h,tag,val)
        showModel(h,tag)
        showDetail(h,tag)
        showError(h,tag)
        undoModel(h,tag)
        redoModel(h,tag)


        propagate(h)
        sl_propagate(h)
        restore(h)
        closeAll(h)
        saveAndClose(h)

        save(h)

        search(h)
        searchByStatus(h,str)
        searchClear(h)

        statusFilter(h)
        showByStatus(h,str)

        propagateCallback(h)
        restoreCallback(h)
        helpCallback(h)

        pause(h)
        conti(h)
        stop(h)
        stopProcess(h)

        changeStatusToWait(h)
        changeStatus(h,ori,des)
    end

    methods(Access=public)
        str=setBackupStr(h,name,i)
        str=setTitle(h)
        str=setBackupInfo(h)
        out=setTopModelInfo(h)
        out=setToggle(h,str)
        setDlg(h)
        init(h,mdl,backup,gui)
        setFileStatus(h)
        st=stats(h)
        schema=getBottomPanSchema(h,a,b)
    end

    methods(Hidden=true)



        function dataType=getPropDataType(~,propName)
            dataType='invalid';

            boolTypeProps={'IsSkippedChecked','IsFailedChecked'...
            ,'IsConvertedChecked','IsRestoredChecked'};

            if any(strcmp(propName,boolTypeProps))
                dataType='bool';
            end
        end
    end

end


