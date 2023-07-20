function addimplarg(this)





    me=TflDesigner.getexplorer;
    dlghandle=TflDesigner.getdialoghandle;
    if~isempty(dlghandle)
        dlghandle.apply;
    end

    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:AddArgumentInProgressStatusMsg'));
    me.getRoot.iseditorbusy=true;

    numOutput=0;
    cargs=this.object.ConceptualArgs;
    var=[];
    if~isempty(cargs)
        for k=1:length(cargs)
            if strcmp(cargs(k).IOType,'RTW_IO_OUTPUT')
                var(k).name=cargs(k).Name;%#ok
                numOutput=numOutput+1;
            end
        end
    end

    if isempty(this.object.Implementation.Return)
        arg=this.parentnode.object.getTflArgFromString(['y',num2str(1)],'double');
        arg.IOType='RTW_IO_OUTPUT';

        this.object.Implementation.setReturn(arg);
    else
        outputAdded=false;
        for k=1:length(var)
            notfound=true;
            if~isempty(this.object.Implementation.Return)
                if~strcmp(this.object.Implementation.Return.Name,var(k).name)
                    notfound=true;
                else
                    notfound=false;
                end
            end
            if notfound
                for m=1:length(this.object.Implementation.Arguments)
                    if strcmp(this.object.Implementation.Arguments(m).Name,var(k).name)
                        notfound=false;
                        break;
                    end
                end
            end
            if notfound
                arg=this.parentnode.object.getTflArgFromString(var(k).name,'double*');
                arg.IOType='RTW_IO_OUTPUT';
                outputAdded=true;
                break;
            end
        end

        if~outputAdded
            concepargs=this.getconceptualarglist;
            implargs=this.getimplarglist;
            returnArgName=[];
            if~isempty(this.object.Implementation.Return)
                returnArgName=this.object.Implementation.Return.Name;
            end

            isNew=false;
            numImplInput=1;
            while(~isNew)
                newArgName=['u',num2str(numImplInput)];
                if~any(strcmp(implargs,newArgName))&&...
                    ~strcmp(newArgName,returnArgName)&&...
                    ~concepArgIsVoid(cargs,newArgName)
                    isNew=true;
                end
                numImplInput=numImplInput+1;
            end

            if any(strcmp(concepargs,newArgName))
                arg=this.parentnode.object.getTflArgFromString(newArgName,'double');
            else
                arg=this.parentnode.object.getTflArgFromString(newArgName,'double',0);
            end
            arg.IOType='RTW_IO_INPUT';
        end

        this.object.Implementation.addArgument(arg);
    end

    this.activeimplarg=length(this.object.Implementation.Arguments);
    dlghandle.setWidgetValue('Tfldesigner_ImplfuncArglist',this.activeimplarg)
    this.isValid=false;
    wasDirty=this.parentnode.isDirty;
    this.parentnode.isDirty=true;
    this.isDirty=true;
    this.addedimplarg=true;

    if this.copyconcepargsettings
        this.copyConceptualArgsSettings;
    end
    me.getRoot.iseditorbusy=false;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    this.firepropertychanged;
    if~wasDirty
        this.parentnode.firehierarchychanged;
    end



    function isVoid=concepArgIsVoid(cargs,newArgName)

        isVoid=false;
        for i=1:length(cargs)
            if strcmp(cargs(i).Name,newArgName)
                isVoid=strcmp(cargs(i).toString,'void');
            end
        end
