function removelistentry(this,dlghandle,tag,pressedkey)






    pressedkey;%#ok

    switch tag

    case 'Tfldesigner_RemoveHeadPaths'

        lenheadfiles=length(this.object.AdditionalHeaderFiles);
        index=dlghandle.getWidgetValue('Tfldesigner_AdditionalHeadFiles')+1;

        if index<=lenheadfiles
            this.object.AdditionalHeaderFiles(index)=[];
        else
            index=index-lenheadfiles;
            this.object.AdditionalIncludePaths(index)=[];
        end


    case 'Tfldesigner_RemoveSourcePaths'
        lensourcefiles=length(this.object.AdditionalSourceFiles);
        index=dlghandle.getWidgetValue('Tfldesigner_AdditionalSourceFiles')+1;

        if index<=lensourcefiles
            this.object.AdditionalSourceFiles(index)=[];
        else
            index=index-lensourcefiles;
            this.object.AdditionalSourcePaths(index)=[];
        end

    case 'Tfldesigner_RemoveLinkPath'
        lenlinkfiles=length(this.object.AdditionalLinkObjs);
        index=dlghandle.getWidgetValue('Tfldesigner_AdditionalLinkFiles')+1;

        if index<=lenlinkfiles
            this.object.AdditionalLinkObjs(index)=[];
        else
            index=index-lenlinkfiles;
            this.object.AdditionalLinkObjsPaths(index)=[];
        end
    end
    wasDirty=this.parentnode.isDirty;
    this.isValid=false;
    this.parentnode.isDirty=true;
    this.isDirty=true;

    if~wasDirty
        this.parentnode.firehierarchychanged;
    end

