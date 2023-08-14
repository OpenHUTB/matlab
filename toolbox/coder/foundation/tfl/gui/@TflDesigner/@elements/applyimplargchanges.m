function[success,error]=applyimplargchanges(this,dlghandle)






    success=true;
    error='';

    index=this.activeimplarg;

    namespace=dlghandle.getWidgetValue('Tfldesigner_namespace');
    if~isempty(namespace)
        this.object.enableCPP();
        this.object.Implementation.NameSpace=strtrim(namespace);
    elseif isa(this.object.Implementation,'RTW.CPPImplementation')
        cimpl=RTW.CImplementation;
        cppimpl=this.object.Implementation;
        cimpl.HeaderFile=cppimpl.HeaderFile;
        cimpl.SourceFile=cppimpl.SourceFile;
        cimpl.HeaderPath=cppimpl.HeaderPath;
        cimpl.SourcePath=cppimpl.SourcePath;
        cimpl.Return=cppimpl.Return;
        cimpl.Name=cppimpl.Name;
        cimpl.Arguments=cppimpl.Arguments;
        this.object.Implementation=cimpl;
    end

    if index==0&&isempty(this.object.Implementation.Return)
        value=dlghandle.getWidgetValue('Tfldesigner_ImplfuncArglist');
        if~isempty(value)
            this.activeimplarg=value;
        end
        return;
    end

    if index~=0&&isempty(this.object.Implementation.Arguments)
        value=dlghandle.getWidgetValue('Tfldesigner_ImplfuncArglist');
        if~isempty(value)
            this.activeimplarg=value;
        end
        return;
    end

    if index==0
        oldarg=this.object.Implementation.Return;
    else
        oldarg=this.object.Implementation.Arguments(index);
    end

    complex=logical(dlghandle.getWidgetValue('Tfldesigner_isargcomplex'));
    pointer=logical(dlghandle.getWidgetValue('Tfldesigner_ispointer'));
    pointerpointer=false;
    if dlghandle.isEnabled('Tfldesigner_ispointerpointer')
        pointerpointer=logical(dlghandle.getWidgetValue('Tfldesigner_ispointerpointer'));
    end

    if isa(oldarg,'RTW.TflArgDWork')
        datatype='void';
    else
        dtypeentries=this.getentries('Tfldesigner_ImplDatatype');
        datatype=dtypeentries{dlghandle.getWidgetValue('Tfldesigner_ImplDatatype')+1};
    end


    readonly=logical(dlghandle.getWidgetValue('Tfldesigner_Readonly'));

    if logical(dlghandle.getWidgetValue('Tfldesigner_makeconstant'))
        initialval=dlghandle.getWidgetValue('Tfldesigner_Initialvalue');
    else
        initialval=[];
    end

    if pointer&&dlghandle.isEnabled('Tfldesigner_DataAlignment')
        dataalign=dlghandle.getWidgetValue('Tfldesigner_DataAlignment');
        dataalign=str2double(dataalign);
    else
        dataalign=-1;
    end



    if imag(str2double(initialval))~=0
        complex=true;
    end


    if dlghandle.isEnabled('Tfldesigner_ImplIOType')
        if index==0
            iotype='RTW_IO_OUTPUT';
        else
            ioentries=this.getentries('Tfldesigner_IOType');
            iotype=this.getEnumString(ioentries{dlghandle.getWidgetValue('Tfldesigner_ImplIOType')+1});
        end
    else
        if index==0
            iotype=this.object.Implementation.Return.IOType;
        else
            iotype=this.object.Implementation.Arguments(index).IOType;
        end
    end

    dtype=datatype;
    if complex
        dtype=strcat('c',dtype);
    end

    if dlghandle.isEnabled('Tfldesigner_ImplArgName')
        name=dlghandle.getWidgetValue('Tfldesigner_ImplArgName');
    else
        if index==0
            name=this.object.Implementation.Return.Name;
        else
            name=this.object.Implementation.Arguments(index).Name;
        end
    end

    if~isempty(initialval)

        try
            passtypeentries=this.getentries('Tfldesigner_PassbyType');
            passtype=this.getEnumString(...
            passtypeentries{dlghandle.getWidgetValue('Tfldesigner_Passbytype')+1});

            if strcmp(datatype,'char')

                newarg=this.parentnode.object.getTflArgFromString(name,...
                datatype,str2double(initialval));
            elseif complex
                compreal=real(str2double(initialval));
                compimag=imag(str2double(initialval));
                newarg=this.parentnode.object.getTflArgFromString(name,...
                dtype,compreal,compimag);
            else
                newarg=this.parentnode.object.getTflArgFromString(name,...
                dtype,str2double(initialval));
            end
            newarg.IOType=iotype;
            if isa(newarg,'RTW.TflArgPointer')||isa(newarg,'RTW.TflArgComplex')
                if isa(newarg.Type.BaseType,'RTW.TflArgPointer')||isa(newarg.Type.BaseType,'RTW.TflArgComplex')
                    newarg.Type.BaseType.BaseType.ReadOnly=readonly;
                else
                    newarg.Type.BaseType.ReadOnly=readonly;
                end
            else
                newarg.Type.ReadOnly=readonly;
            end
            newarg.PassByType=passtype;

            if dataalign~=-1
                des=RTW.ArgumentDescriptor;
                des.AlignmentBoundary=dataalign;
                newarg.Descriptor=des;
            end

            if index==0
                this.object.Implementation.Return=newarg;
            else
                this.object.Implementation.Arguments(index)=newarg;
            end

        catch ME
            error=ME.message;
            this.applyerrorlog=ME.message;
            success=false;
            this.implargerror=true;
        end
    else
        try


            if any(strcmp(datatype,{'char','void'}))
                dtype=datatype;

            end

            if pointer
                dtype=strcat(dtype,'*');
            elseif pointerpointer
                dtype=strcat(dtype,'**');
            end

            if isa(oldarg,'RTW.TflArgDWork')
                newarg=this.parentnode.object.getTflDWorkFromString(name,dtype);
            else
                if this.isStructSpecEnabled&&this.isDataTypeStruct(dtype)
                    newarg=createStructImplArg(this,dlghandle,name);
                else
                    newarg=this.parentnode.object.getTflArgFromString(name,dtype);
                end
            end

            newarg.IOType=iotype;
            if isa(newarg,'RTW.TflArgPointer')
                if isa(newarg.Type.BaseType,'RTW.TflArgPointer')
                    newarg.Type.BaseType.BaseType.ReadOnly=readonly;
                else
                    newarg.Type.BaseType.ReadOnly=readonly;
                end
            else
                newarg.Type.ReadOnly=readonly;
            end

            if dlghandle.isEnabled('Tfldesigner_InPlaceArg')
                if index~=0&&isa(newarg,'RTW.TflArgPointer')&&...
                    isprop(this.object.Implementation.Arguments(index),'ArgumentForInPlaceUse')
                    newarg.ArgumentForInPlaceUse=...
                    this.object.Implementation.Arguments(index).ArgumentForInPlaceUse;
                end
            end

            if index==0
                this.object.Implementation.Return=newarg;
            else
                this.object.Implementation.Arguments(index)=newarg;
            end

            if dataalign~=-1
                des=RTW.ArgumentDescriptor;
                des.AlignmentBoundary=dataalign;
                newarg.Descriptor=des;
            end
            this.showdataalign=false;
        catch ME
            error=ME.message;
            this.applyerrorlog=ME.message;
            success=false;
            this.implargerror=true;
        end

    end
    update(this,dlghandle,success);

    if success
        this.iargstructfields={};
    end



    function update(this,dlghandle,success)

        if success
            hasSideEffects=dlghandle.getWidgetValue('Tfldesigner_SideEffects');
            if~hasSideEffects&&~isempty(this.object.Implementation.Return)&&...
                strcmpi(this.object.Implementation.Return.toString,'void')
                if isempty(this.object.Implementation.Arguments)
                    hasSideEffects=1;
                else
                    for id=1:length(this.object.Implementation.Arguments)
                        arg=this.object.Implementation.Arguments(id);
                        if isa(arg,'RTW.TflArgPointer')&&...
                            strcmp(arg.IOType,'RTW_IO_INPUT')
                            hasSideEffects=1;
                            break;
                        end
                    end
                end
            end
            this.setPropValue('SideEffects',num2str(hasSideEffects));

            newimplargindex=dlghandle.getWidgetValue('Tfldesigner_ImplfuncArglist');
            if~isempty(newimplargindex)
                this.activeimplarg=newimplargindex;
            end

            this.applyerrorlog='';
            this.firepropertychanged;
            this.implargerror=false;
        else
            dlghandle.enableApplyButton(true,false);
        end


        function implarg=createStructImplArg(this,dlghandle,name)
            structname=dlghandle.getWidgetValue('Tfldesigner_ImplStructName');
            if isempty(structname)
                errorMsg=DAStudio.message('RTW:tfldesigner:ErrorNoStructName');
                ME=MException('ImplStruct:nostructname',errorMsg);
                throw(ME);
            end


            [nrows,ncols]=size(this.iargstructfields);

            assert(ncols==2);
            if nrows~=2
                errorMsg=DAStudio.message('RTW:tfldesigner:ErrorStructFieldNumber');
                ME=MException('ImplStruct:structfields',errorMsg);
                throw(ME);
            end

            structElements=[];
            for rowIdx=1:nrows
                fieldNameStr=this.iargstructfields{rowIdx,1};
                fieldTypeStr=this.iargstructfields{rowIdx,2};

                try
                    tmpArg=this.parentnode.object.getTflArgFromString('unused',fieldTypeStr);
                    evaluatedType=tmpArg.Type;
                catch
                    errorMsg=DAStudio.message('RTW:tfldesigner:ErrorStructFieldTypeInvalid');
                    ME=MException('ImplStruct:wrongtype',errorMsg);
                    throw(ME);
                end

                if isempty(fieldNameStr)
                    errorMsg=DAStudio.message('RTW:tfldesigner:ErrorNoStructFieldName');
                    ME=MException('ImplStruct:emptyname',errorMsg);
                    throw(ME)
                end

                structElement=embedded.structelement;
                structElement.Identifier=fieldNameStr;
                structElement.Type=evaluatedType;
                structElements=[structElements,structElement];%#ok<AGROW>
            end

            structType=embedded.structtype;
            structType.Identifier=structname;
            structType.Elements=structElements;

            ispointer=logical(dlghandle.getWidgetValue('Tfldesigner_ispointer'));
            if ispointer
                ptrType=embedded.pointertype;
                ptrType.BaseType=structType;

                implarg=RTW.TflArgPointer;
                implarg.Name=name;
                implarg.Type=ptrType;
            else
                implarg=RTW.TflArgStruct;
                implarg.Name=name;
                implarg.Type=structType;
            end



