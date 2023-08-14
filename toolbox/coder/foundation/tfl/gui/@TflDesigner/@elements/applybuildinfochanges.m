function[success,error]=applybuildinfochanges(this,dlghandle)







    success=true;
    error='';

    try
        [path,name,ext]=fileparts(dlghandle.getWidgetValue('Tfldesigner_HeaderFile'));
        this.object.Implementation.HeaderFile=strcat(name,ext);
        this.object.Implementation.HeaderPath=path;

        [path,name,ext]=fileparts(dlghandle.getWidgetValue('Tfldesigner_SourceFile'));
        this.object.Implementation.SourceFile=strcat(name,ext);
        this.object.Implementation.SourcePath=path;

        addLinkFlags=dlghandle.getWidgetValue('Tfldesigner_LinkFlags');
        addLinkFlags=strtrim(addLinkFlags);
        if isempty(addLinkFlags)
            this.object.AdditionalLinkFlags={};
        else
            this.object.AdditionalLinkFlags={addLinkFlags};
        end

        addCompileFlags=dlghandle.getWidgetValue('Tfldesigner_CompileFlags');
        addCompileFlags=strtrim(addCompileFlags);
        if isempty(addCompileFlags)
            this.object.AdditionalCompileFlags={};
        else
            this.object.AdditionalCompileFlags={addCompileFlags};
        end

        if dlghandle.getWidgetValue('Tfldesigner_CopyFilestoBuildDir')
            this.object.GenCallback='RTW.copyFileToBuildDir';
        else
            this.object.GenCallback='';
        end
    catch ME
        error=ME.message;
    end

