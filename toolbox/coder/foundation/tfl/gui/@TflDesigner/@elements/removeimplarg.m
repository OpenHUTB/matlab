function removeimplarg(this)







    me=TflDesigner.getexplorer;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:RemoveImplementationArgStatusMsg'));
    me.getRoot.iseditorbusy=true;

    index=this.activeimplarg;

    if index==0
        if~isempty(this.object.Implementation.Return)
            this.object.Implementation.Return=[];
        end

    elseif~isempty(this.object.Implementation.Arguments)

        this.object.Implementation.Arguments(index)=[];

        if index>length(this.object.Implementation.Arguments)
            this.activeimplarg=index-1;
        end
    else
        me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
        me.getRoot.iseditorbusy=false;
        errormsg=DAStudio.message('RTW:tfldesigner:ErrorCannotRemoveImplArg');
        dp=DAStudio.DialogProvider;
        dp.errordlg(errormsg,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
    end

    this.isValid=false;
    wasDirty=this.parentnode.isDirty;
    this.parentnode.isDirty=true;
    this.isDirty=true;

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    me.getRoot.iseditorbusy=false;
    this.firepropertychanged;
    if~wasDirty
        this.parentnode.firehierarchychanged;
    end