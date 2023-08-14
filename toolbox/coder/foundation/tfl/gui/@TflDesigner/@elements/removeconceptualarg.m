function removeconceptualarg(this)








    me=TflDesigner.getexplorer;
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:RemoveConceptualArgStatusMsg'));
    me.getRoot.iseditorbusy=true;
    wasDirty=this.parentnode.isDirty;
    index=this.activeconceptarg;

    if~isempty(this.object.ConceptualArgs)
        this.object.ConceptualArgs(index)=[];

        if index>length(this.object.ConceptualArgs)&&...
            index~=1
            this.activeconceptarg=index-1;
        elseif index<=length(this.object.ConceptualArgs)&&index~=1

            for argid=index:length(this.object.ConceptualArgs)
                if strcmpi(this.object.ConceptualArgs(argid).IOType,'RTW_IO_INPUT')
                    this.object.ConceptualArgs(argid).Name=['u',num2str(argid-1)];
                else
                    this.object.ConceptualArgs(argid).Name=['y',num2str(argid)];
                end
            end
        elseif index==1&&index<=length(this.object.ConceptualArgs)
            for argid=index:length(this.object.ConceptualArgs)
                if strcmpi(this.object.ConceptualArgs(argid).IOType,'RTW_IO_OUTPUT')
                    this.object.ConceptualArgs(argid).Name=['y',num2str(argid)];
                end
            end
        end

        this.isValid=false;
        this.parentnode.isDirty=true;
        this.isDirty=true;

    end
    me.setStatusMessage(DAStudio.message('RTW:tfldesigner:ReadyStatus'));
    me.getRoot.iseditorbusy=false;
    this.firepropertychanged;
    if~wasDirty&&this.parentnode.isDirty
        this.parentnode.firehierarchychanged;
    end

