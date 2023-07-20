function[success,error]=applyconceptargchanges(this,dlghandle)






    success=true;
    error='';

    dtype=dlghandle.getWidgetValue('Tfldesigner_DataType');

    complex=false;


    if strcmp(dtype(1),'c')&&~strcmp(dtype(2),'h')
        dtype=dtype(2:end);
        complex=true;
    end


    index=this.activeconceptarg;
    originalargs=this.object.ConceptualArgs(1:end);

    name=this.object.ConceptualArgs(index).Name;
    iotype=this.object.ConceptualArgs(index).IOType;
    oldIOType=iotype;

    if dlghandle.isEnabled('Tfldesigner_ConceptIOType')
        entries=this.getentries('Tfldesigner_IOType');
        iotype=this.getEnumString(...
        entries{dlghandle.getWidgetValue('Tfldesigner_ConceptIOType')+1});
    end

    [fdt,isfix]=formatFixdtString(dtype);

    if isfix
        evaluatedType=eval(fdt);
        if evaluatedType.isscaleddouble
            error=DAStudio.message('RTW:tfldesigner:ScaledDoubleTypeNotSupported');
            this.object.ConceptualArgs=originalargs;
            success=false;
            this.concepargerror=true;
            this.applyerrorlog=error;
        end

        dtype=strrep(fdt,'numerictype','fixdt');
    end

    complex=logical(dlghandle.getWidgetValue('Tfldesigner_Complex'))||complex;
    if complex&&~(strcmp(dtype(1:2),'ch'))
        dtype=['c',dtype];
    end

    if success&&this.object.ConceptualArgs(this.activeconceptarg).CheckType
        if this.isStructSpecEnabled&&this.isDataTypeStruct(dtype)
            try
                newarg=createStructConceptualArg(this,dlghandle,name);
                newarg.IOType=iotype;
                this.object.ConceptualArgs(index)=newarg;
            catch ME
                error=ME.message;
                this.object.ConceptualArgs=originalargs;
                success=false;
                this.concepargerror=true;
                this.applyerrorlog=ME.message;
            end
        else
            switch dlghandle.getWidgetValue('Tfldesigner_isMatrixPointer')

            case 0
                try
                    newarg=this.parentnode.object.getTflArgFromString(name,dtype);
                    newarg.IOType=iotype;
                    this.object.ConceptualArgs(index)=newarg;
                catch ME
                    error=ME.message;
                    this.object.ConceptualArgs=originalargs;

                    this.argtype=0;
                    success=false;
                    this.concepargerror=true;
                    this.applyerrorlog=ME.message;
                end

            case 1
                try
                    if isempty(dlghandle.getWidgetValue('Tfldesigner_LowerDim'))||...
                        isempty(dlghandle.getWidgetValue('Tfldesigner_UpperDim'))

                        exception=MException(DAStudio.message('RTW:tfldesigner:DimRangeMissingException'),...
                        DAStudio.message('RTW:tfldesigner:DimRangeMissingExceptionMsg'));
                        throw(exception);
                    end
                    remainingargs=this.object.ConceptualArgs(index:end);
                    this.object.ConceptualArgs(index:end)=[];

                    lowerdim=dlghandle.getWidgetValue('Tfldesigner_LowerDim');
                    upperdim=dlghandle.getWidgetValue('Tfldesigner_UpperDim');

                    dimRange=[eval(lowerdim);eval(upperdim)];
                    this.object.createAndAddConceptualArg('RTW.TflArgMatrix',...
                    'Name',name,...
                    'IOType',iotype,...
                    'BaseType',dtype,...
                    'DimRange',dimRange);

                    this.object.ConceptualArgs=[this.object.ConceptualArgs;remainingargs(2:end)];
                catch ME
                    error=ME.message;
                    this.object.ConceptualArgs=originalargs;

                    this.argtype=1;
                    success=false;
                    this.concepargerror=true;
                    this.applyerrorlog=ME.message;
                end

            case 2
                try
                    if isempty(strfind(dtype,'*'))
                        dtype=[dtype,'*'];
                    end

                    newarg=this.parentnode.object.getTflArgFromString(name,dtype);
                    newarg.IOType=iotype;
                    this.object.ConceptualArgs(index)=newarg;

                catch ME
                    error=ME.message;
                    this.object.ConceptualArgs=originalargs;

                    this.argtype=2;
                    success=false;
                    this.concepargerror=true;
                    this.applyerrorlog=ME.message;
                end
            end
        end
    elseif success&&~this.object.ConceptualArgs(this.activeconceptarg).CheckType
        newarg=this.parentnode.object.getTflArgFromString(name,'int32');
        newarg.IOType=iotype;
        newarg.CheckType=false;
        this.object.ConceptualArgs(index)=newarg;
    end




    if success


        if~strcmp(oldIOType,iotype)
            renameConceptualAndImplementationArgs(this);
        end

        if isa(this.object,'RTW.TflCOperationEntryGenerator_NetSlope')||...
            isa(this.object,'RTW.TflCOperationEntryGenerator')
            for i=1:length(this.object.ConceptualArgs)
                arg=this.object.ConceptualArgs(i);
                if isa(arg,'RTW.TflArgNumeric')||...
                    isa(arg,'RTW.TflArgMatrix')||...
                    isa(arg,'RTW.TflArgComplex')
                    arg.CheckSlope=false;
                    arg.CheckBias=false;
                end
            end
        end

        if isa(this.object,'RTW.TflCFunctionEntry')
            sameSlope=this.object.SlopesMustBeTheSame;
            sameBias=this.object.BiasMustBeTheSame;
            for i=1:length(this.object.ConceptualArgs)
                arg=this.object.ConceptualArgs(i);
                if isa(arg,'RTW.TflArgNumeric')||...
                    isa(arg,'RTW.TflArgMatrix')||...
                    isa(arg,'RTW.TflArgComplex')
                    arg.CheckSlope=~sameSlope;
                end
            end

            for i=1:length(this.object.ConceptualArgs)
                arg=this.object.ConceptualArgs(i);
                if isa(arg,'RTW.TflArgNumeric')||...
                    isa(arg,'RTW.TflArgMatrix')||...
                    isa(arg,'RTW.TflArgComplex')
                    arg.CheckBias=~sameBias;
                end
            end
        end

        newindex=dlghandle.getWidgetValue('Tfldesigner_ActiveConceptArg');

        if~isempty(newindex)
            this.activeconceptarg=newindex+1;
        end

        classtype=class(this.object.ConceptualArgs(this.activeconceptarg));

        if strcmpi(classtype,'RTW.TflArgPointer')
            this.argtype=2;
        elseif strcmpi(classtype,'RTW.TflArgMatrix')
            this.argtype=1;
        else
            this.argtype=0;
        end

        this.concepargerror=false;
        this.applyerrorlog='';

        this.firepropertychanged;

        this.cargstructfields={};
    end


    function[fdt,isfix]=formatFixdtString(dt)
        fdt=strrep(dt,' ','');
        isfix=false;
        isFix=strfind(fdt,'fix');
        if~isempty(isFix)
            ind=strfind(fdt,'*');
            commaInd=strfind(fdt,',');
            if~isempty(ind)&&length(commaInd)==2

                fdt(ind:end)=[];
                fdt=[fdt,'0)'];
            elseif~isempty(ind)&&length(commaInd)==3
                if strcmp(fdt(commaInd(2)+1),'*')
                    fdt(commaInd(2)+1)='1';
                end
                if strcmp(fdt(commaInd(3)+1),'*')
                    fdt(commaInd(3)+1)='0';
                end
            end
        end
        if~isempty(strfind(fdt,'fixdt'))
            fdt=strrep(fdt,'fixdt','numerictype');
            isfix=true;
        end
        if(~isempty(strfind(fdt,'fix'))||~isempty(strfind(fdt,'flt')))...
            &&isempty(strfind(fdt,'numerictype'))
            fdt=['numerictype(''',fdt,''')'];
            isfix=true;
        end
        if~isempty(strfind(fdt,'numerictype'))
            isfix=true;
        end
        fdt=strrep(fdt,' ','');


        function renameConceptualAndImplementationArgs(this)

            args=this.object.ConceptualArgs;
            numInput=0;
            numOutput=0;

            newArgs=[];
            for i=1:length(args)
                if strcmp(args(i).IOType,'RTW_IO_OUTPUT')
                    numOutput=numOutput+1;
                    args(i).Name=strcat('y',num2str(numOutput));
                    newArgs=[newArgs(1:numOutput-1);args(i);newArgs(numOutput:end)];
                else
                    if strcmp(args(i).IOType,'RTW_IO_INPUT')
                        numInput=numInput+1;
                        args(i).Name=strcat('u',num2str(numInput));
                        newArgs=[newArgs(1:numOutput+numInput-1);args(i);newArgs(numOutput+numInput:end)];
                    end
                end
            end
            this.object.ConceptualArgs=newArgs;
            if~isa(this.object,'RTW.TflCustomization')
                this.object.Implementation.Return=[];
                this.object.Implementation.Arguments=[];
            end


            function structarg=createStructConceptualArg(this,dlghandle,argname)
                structname=dlghandle.getWidgetValue('Tfldesigner_StructName');
                if isempty(structname)
                    errorMsg=DAStudio.message('RTW:tfldesigner:ErrorNoStructName');
                    ME=MException('ConceptualStruct:nostructname',errorMsg);
                    throw(ME);
                end


                [nrows,ncols]=size(this.cargstructfields);

                assert(ncols==2);
                if nrows~=2
                    errorMsg=DAStudio.message('RTW:tfldesigner:ErrorStructFieldNumber');
                    ME=MException('ConceptualStruct:structfields',errorMsg);
                    throw(ME);
                end

                structElements=[];
                for rowIdx=1:nrows
                    fieldNameStr=this.cargstructfields{rowIdx,1};
                    fieldTypeStr=this.cargstructfields{rowIdx,2};

                    [fdt,isfix]=formatFixdtString(fieldTypeStr);

                    if isfix
                        evaluatedType=eval(fdt);
                        if evaluatedType.isscaleddouble
                            errorMsg=DAStudio.message('RTW:tfldesigner:ScaledDoubleTypeNotSupported');
                            ME=MException('ConceptualStruct:wrongtype',errorMsg);
                            throw(ME);
                        end
                    else
                        try
                            tmpArg=this.parentnode.object.getTflArgFromString('unused',fieldTypeStr);
                            evaluatedType=tmpArg.Type;
                        catch
                            errorMsg=DAStudio.message('RTW:tfldesigner:ErrorStructFieldTypeInvalid');
                            ME=MException('ConceptualStruct:wrongtype',errorMsg);
                            throw(ME);
                        end
                    end

                    if isempty(fieldNameStr)
                        errorMsg=DAStudio.message('RTW:tfldesigner:ErrorNoStructFieldName');
                        ME=MException('ConceptualStruct:emptyname',errorMsg);
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

                structarg=RTW.TflArgStruct;
                structarg.Name=argname;
                structarg.Type=structType;



