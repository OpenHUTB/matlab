function addconceptualarg(this)









    me=TflDesigner.getexplorer;
    dlghandle=TflDesigner.getdialoghandle;
    if~isempty(dlghandle)
        dlghandle.apply;
    end
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:AddArgumentInProgressStatusMsg'));
    me.getRoot.iseditorbusy=true;


    if isempty(this.object.ConceptualArgs)
        this.object.ConceptualArgs=this.parentnode.object.getTflArgFromString('y1','double');
        this.object.ConceptualArgs.IOType='RTW_IO_OUTPUT';
        this.activeconceptarg=1;
    else
        currentindex=length(this.object.ConceptualArgs);
        for id=1:currentindex
            hasoutput=~isempty(strfind(this.object.ConceptualArgs(id).Name,'y'));
            if hasoutput
                break;
            end
        end

        if~hasoutput
            outputarg=this.parentnode.object.getTflArgFromString('y1','double');
            outputarg.IOType='RTW_IO_OUTPUT';
            this.object.ConceptualArgs=[outputarg;this.object.ConceptualArgs];
            this.activeconceptarg=1;
        else
            concepargs=this.getconceptualarglist;
            isNew=false;
            numImplInput=1;
            while(~isNew)
                newArgName=['u',num2str(numImplInput)];
                if~any(strcmp(concepargs,newArgName))
                    isNew=true;
                end
                numImplInput=numImplInput+1;
            end

            this.object.ConceptualArgs(currentindex+1)=this.parentnode.object.getTflArgFromString(newArgName,'double');
            this.object.ConceptualArgs(currentindex+1).IOType='RTW_IO_INPUT';
            this.activeconceptarg=currentindex+1;
        end
    end

    this.argtype=0;
    this.isValid=false;
    wasDirty=this.parentnode.isDirty;
    this.parentnode.isDirty=true;
    this.isDirty=true;

    me.getRoot.iseditorbusy=false;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    this.firepropertychanged;
    if~wasDirty
        this.parentnode.firehierarchychanged;
    end
