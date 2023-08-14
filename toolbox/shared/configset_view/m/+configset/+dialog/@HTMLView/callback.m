function callback(obj,msg)





    if islogical(msg)


        if msg&&~isempty(obj.pending)
            msg=obj.pending;
            obj.pending=[];
        else

            obj.pending=[];
            return;
        end
    elseif isfield(msg,'pending')&&msg.pending



        obj.pending=msg;



        obj.enableApplyButton(true);
        return;
    end


    adp=obj.Source;
    cs=adp.getCS;

    msg.from='web';
    msg.dialog=obj.Dlg;


    if strcmp(msg.type,'toggle')
        cb=msg.callback;
        fn=str2func(cb);
        fn('web',cs,msg);
        return;
    elseif~strcmp(msg.type,'button')&&~strcmp(msg.type,'hyperlink')




        obj.enableApplyButton(true);
    end

    obj.isWebPageReady=false;
    if isfield(msg,'parameter')&&strcmp(msg.parameter,'CoderTargetData')

        cb=msg.callback_literal;
        fn=str2func(cb);


        hObj=cs.getComponent('Coder Target');
        if isempty(hObj)


            hObj=cs.getComponent('Run on Hardware');
        end
        hDlg=ConfigSet.DDGWrapper(obj.Dlg,msg);
        tag=hDlg.tag;
        desc='web';




        dirtyDialog=true;



        try


            n=nargout(fn);
        catch



            n=nargout(cb);
        end

        try
            if n>0
                dirtyDialog=fn(hObj,hDlg,tag,desc);
            else
                fn(hObj,hDlg,tag,desc);
            end
        catch e
            errordlg(e.message);
        end

        if~isequal(msg.userData.Storage,'ESB.ProcessingUnit')

            coderTargetData=configset.layout.custom.getTargetHardwareDialogSchema(cs,'web');
            obj.publish('coderTarget/update',coderTargetData);
        end


        dlg=cs.getDialogHandle;
        if~isempty(dlg)&&dirtyDialog
            obj.enableApplyButton(true);
        end

    elseif strcmp(msg.type,'button')&&isfield(msg,'callback_literal')
        [hObj,hSrc,hDlg,model]=configset.internal.util.populateTLCFunctionArguments(cs,msg.dialog);%#ok<ASGLU>
        cb=msg.callback_literal;
        eval(cb);
    else

        if isfield(msg,'parameter')
            data=adp.getWidgetData(msg.name);
        else
            data=adp.getParamData(msg.name);
        end

        msg.dialog=obj.Dlg;
        msg.data=data;
        isTable=strcmp(msg.type,'table');

        try
            if isTable

                cb=msg.callback;
                fn=str2func(cb);




                fn(adp.Source,msg.row,msg.col,msg.value);
            else

                adp.dialogCallback(msg);
                obj.removeError([],msg.name);
            end
        catch ME
            if isTable
                err=struct('name',msg.name,'data',data,...
                'error',struct('val',msg.value,'msg',ME.message,'row',msg.row,'col',msg.col),...
                'me',ME);
            elseif strcmp(msg.type,'button')
                if isa(ME,'configset.internal.util.MSLValueException')
                    value=ME.getValue;
                else
                    value='';
                end


                err=struct('name',data.Parameter.Name,'data',data.Parameter,...
                'error',struct('val',value,'msg',ME.message),...
                'me',ME);
            else
                err=struct('name',msg.name,'data',data,...
                'error',struct('val',msg.value,'msg',ME.message),...
                'me',ME);
            end

            obj.addError(err);
        end
    end

    adp.flush();
    obj.pageReady();


