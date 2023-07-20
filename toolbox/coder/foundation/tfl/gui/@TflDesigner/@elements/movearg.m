function movearg(this,dlghandle,direction)




    me=TflDesigner.getexplorer;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReorderingArgStatusMsg'));
    me.getRoot.iseditorbusy=true;

    switch direction
    case 'Tfldesigner_UpArgbutton'
        if this.activeimplarg>1
            argtomove=this.object.Implementation.Arguments(this.activeimplarg);
            rearrangedargs=...
            [this.object.Implementation.Arguments(1:this.activeimplarg-2);...
            argtomove;
            this.object.Implementation.Arguments(this.activeimplarg-1);
            this.object.Implementation.Arguments(this.activeimplarg+1:end)];
            this.object.Implementation.Arguments=rearrangedargs;
            this.activeimplarg=this.activeimplarg-1;
        else
            argtomove=this.object.Implementation.Arguments(this.activeimplarg);
            if strcmp(argtomove.IOType,'RTW_IO_OUTPUT')
                resetArgumentInPlace(this,argtomove.Name);
                returnarg=this.object.Implementation.Return;
                argtomove=manageArgPointerType(this,argtomove,'remove');
                if isempty(returnarg)
                    this.object.Implementation.setReturn(argtomove);
                    this.object.Implementation.Arguments(this.activeimplarg)=[];
                else
                    this.object.Implementation.setReturn(argtomove);
                    if~strcmp(returnarg.Name,'unused')
                        this.object.Implementation.Arguments(this.activeimplarg)=returnarg;
                    else
                        this.object.Implementation.Arguments(this.activeimplarg)=[];
                    end
                end
                this.returnargname=argtomove.Name;
            end
            this.activeimplarg=0;
        end
    case 'Tfldesigner_DownArgbutton'
        if this.activeimplarg~=length(this.object.Implementation.Arguments)
            argtomove=this.object.Implementation.Arguments(this.activeimplarg);
            rearrangedargs=...
            [this.object.Implementation.Arguments(1:this.activeimplarg-1);
            this.object.Implementation.Arguments(this.activeimplarg+1);
            argtomove;
            this.object.Implementation.Arguments(this.activeimplarg+2:end)];
            this.object.Implementation.Arguments=rearrangedargs;
            this.activeimplarg=this.activeimplarg+1;
        end
    end

    this.isValid=false;
    this.parentnode.isDirty=true;
    this.isDirty=true;

    dlghandle.setFocus('Tfldesigner_ImplfuncArglist');
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    me.getRoot.iseditorbusy=false;
    this.firepropertychanged;

