function setWidgetProperties(this,widgetTag)






    index=ismember(this.widgetTagList,widgetTag);
    if sum(index(:))
        widgetNode=this.widgetStructList(index);
    else
        return;
    end

    switch widgetTag
    case 'Tfldesigner_Key'
        if~isempty(this.object.Key)&&~isempty(this.object.ConceptualArgs)&&...
            (isa(this.object,'RTW.TflCOperationEntry')||...
            isa(this.object,'RTW.TflCSemaphoreEntry'))

            widgetNode.Value=this.getEnumString(this.object.Key);
            this.Name=widgetNode.Value;
        elseif~isempty(this.object.Key)&&~isempty(this.object.ConceptualArgs)&&...
            (strcmpi(this.EntryType,'RTW.TflBlasEntryGenerator')||...
            strcmpi(this.EntryType,'RTW.TflCBlasEntryGenerator'))

            value=find(strcmpi(this.getkeyentries,this.getEnumString(this.object.Key)),1)-1;
            if isempty(value)
                widgetNode.Value=0;
                this.object.Key=this.getEnumString(this.getkeyentries{widgetNode.Value+1});
                this.Name=this.getEnumString(this.object.Key);
            else
                widgetNode.Value=value;
            end
        else
            if~isempty(this.object.Key)&&...
                (isa(this.object,'RTW.TflCFunctionEntry')||...
                isa(this.object,'RTW.TflCustomization'))

                value=find(strcmpi(this.getkeyentries,this.getEnumString(this.object.Key)),1)-1;

                if isempty(value)||(value==find(strcmpi(widgetNode.Entries,'Custom'),1)-1)
                    widgetNode.Value='Custom';
                else
                    widgetNode.Value=this.getEnumString(this.object.Key);
                end
            end
        end
    case 'Tfldesigner_CustomFunc'
        keydesc=this.getDialogWidget('Tfldesigner_Key');
        if~isempty(this.object.Key)&&~isempty(this.object.ConceptualArgs)&&...
            (isa(this.object,'RTW.TflCOperationEntry')||...
            isa(this.object,'RTW.TflCSemaphoreEntry'))
            widgetNode.Visible=false;
        elseif~isempty(this.object.Key)&&~isempty(this.object.ConceptualArgs)&&...
            (strcmpi(this.EntryType,'RTW.TflBlasEntryGenerator')||...
            strcmpi(this.EntryType,'RTW.TflCBlasEntryGenerator'))
            widgetNode.Visible=false;
        elseif~isempty(this.object.Key)&&...
            (isa(this.object,'RTW.TflCFunctionEntry')||...
            isa(this.object,'RTW.TflCustomization'))
            value=find(strcmpi(this.getkeyentries,this.getEnumString(this.object.Key)),1)-1;
            if isempty(value)||(value==find(strcmpi(keydesc.Entries,'Custom'),1)-1)
                widgetNode.Visible=true;
                if strcmpi(this.object.Key,'Custom')
                    widgetNode.Value='function_name';
                else
                    widgetNode.Value=this.getEnumString(this.object.Key);
                end
            else
                widgetNode.Visible=false;
            end
        else
            widgetNode.Visible=false;
        end
    case 'Tfldesigner_AlgorithmInfo'
        if~isempty(this.object.Key)
            switch(this.object.Key)
            case{'sin','cos','sincos','atan2'}
                widgetNode.Visible=true;
                widgetNode.Enabled=true;

                widgetNode.Entries=this.getentries('Tfldesigner_AlgorithmInfo');
                widgetNode.Value=this.getEnumString(this.object.EntryInfo.Algorithm);
            case 'rSqrt'
                widgetNode.Visible=true;
                widgetNode.Enabled=true;

                widgetNode.Entries=this.getentries('Tfldesigner_RSQRT_AlgorithmInfo');
                widgetNode.Value=this.getEnumString(this.object.EntryInfo.Algorithm);
            case 'fir2d'
                widgetNode.Visible=true;
                widgetNode.Enabled=true;

                widgetNode.Entries=this.getentries('Tfldesigner_FIR2D_AlgorithmInfo');
                widgetNode.Value=this.getEnumString(this.object.EntryInfo.Algorithm);
            case 'ConvCorr1d'
                widgetNode.Visible=true;
                widgetNode.Enabled=true;

                widgetNode.Entries=this.getentries('Tfldesigner_CONVCORR_AlgorithmInfo');
                widgetNode.Value=this.getEnumString(this.object.EntryInfo.Algorithm);
            case 'reciprocal'
                widgetNode.Visible=true;
                widgetNode.Enabled=true;

                widgetNode.Entries=this.getentries('Tfldesigner_RECIPROCAL_AlgorithmInfo');
                widgetNode.Value=this.getEnumString(this.object.EntryInfo.Algorithm);
            end
        end
    case 'Tfldesigner_AddMinusAlgorithm'
        if~isempty(this.object.Key)&&...
            (strcmp(this.object.Key,'RTW_OP_ADD')||strcmp(this.object.Key,'RTW_OP_MINUS'))

            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Entries=this.getentries('Tfldesigner_AddMinusAlgorithm');
            widgetNode.Value=this.getEnumString(this.object.EntryInfo.Algorithm);
        end
    case 'Tfldesigner_FIR2D_OutputMode'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'fir2d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.getEnumString(this.object.EntryInfo.OutputMode);
            widgetNode.Entries=this.getentries('Tfldesigner_FIR2D_OutputMode');
        end
    case 'Tfldesigner_FIR2D_NumInRows'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'fir2d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumInRows;
        end
    case 'Tfldesigner_FIR2D_NumInCols'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'fir2d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumInCols;
        end
    case 'Tfldesigner_FIR2D_NumOutRows'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'fir2d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumOutRows;
        end
    case 'Tfldesigner_FIR2D_NumOutCols'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'fir2d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumOutCols;
        end
    case 'Tfldesigner_FIR2D_NumMaskRows'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'fir2d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumMaskRows;
        end
    case 'Tfldesigner_FIR2D_NumMaskCols'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'fir2d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumMaskCols;
        end
    case 'Tfldesigner_CONVCORR1D_NumIn1Rows'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'ConvCorr1d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumIn1Rows;
        end
    case 'Tfldesigner_CONVCORR1D_NumIn2Rows'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'ConvCorr1d')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.NumIn2Rows;
        end
    case 'Tfldesigner_LOOKUP_SearchMethod'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'lookup')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.getEnumString(this.object.EntryInfo.SearchMethod);
        end
    case 'Tfldesigner_LOOKUP_IntrpMethod'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'lookup')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.getEnumString(this.object.EntryInfo.IntrpMethod);
        end
    case 'Tfldesigner_LOOKUP_ExtrpMethod'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'lookup')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.getEnumString(this.object.EntryInfo.ExtrpMethod);
        end
    case 'Tfldesigner_TIMER_CountDirection'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'code_profile_read_timer')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.getEnumString(this.object.EntryInfo.CountDirection);
        end
    case 'Tfldesigner_TIMER_Ticks'
        if~isempty(this.object.Key)&&strcmp(this.object.Key,'code_profile_read_timer')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=this.object.EntryInfo.TicksPerSecond;
        end
    case 'Tfldesigner_ActiveConceptArg'
        widgetNode.Entries=this.getconceptualarglist;
        widgetNode.Value=this.activeconceptarg-1;
    case 'Tfldesigner_Addargpushbutton'
        if~isempty(this.object.Key)&&...
            (isempty(find(ismember(this.getkeyentries,this.getEnumString(this.object.Key)),1))||...
            strcmpi(this.object.Key,'custom'))
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
        end

    case 'Tfldesigner_Removeargpushbutton'
        if~isempty(this.object.Key)&&...
            (isempty(find(ismember(this.getkeyentries,this.getEnumString(this.object.Key)),1))||...
            strcmpi(this.object.Key,'custom'))
            widgetNode.Visible=true;
            if~isempty(this.object.ConceptualArgs)
                widgetNode.Enabled=true;
            end
        end
    case 'Tfldesigner_customclassbutton'
        if this.iscustomtype
            widgetNode.Enabled=true;
            widgetNode.Visible=true;
        end
    case 'Tfldesigner_ConceptIOType'
        if~isempty(this.object.Key)&&...
            (isempty(find(ismember(this.getkeyentries,this.getEnumString(this.object.Key)),1))||...
            strcmpi(this.object.Key,'custom'))
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
        end
        if~isempty(this.object.ConceptualArgs)
            widgetNode.Value=this.getEnumString(...
            this.object.ConceptualArgs(this.activeconceptarg).IOType);
        end
    case 'Tfldesigner_Complex'
        index=this.activeconceptarg;
        if~isempty(this.object.ConceptualArgs)
            keydesc=this.getDialogWidget('Tfldesigner_Key');
            if strcmp(keydesc.Value,'code_profile_read_timer')
                widgetNode.Value=false;
                widgetNode.Enabled=false;
            else
                dtype=this.getDialogWidget('Tfldesigner_DataType');

                dtypeval=this.object.ConceptualArgs(index).toString;
                widgetNode.Value=strcmp(dtypeval(1),'c')&&~strcmp(dtypeval(2),'h');
                if~this.concepargerror&&~isempty(dtype.Value)
                    widgetNode.Value=(widgetNode.Value||(dtype.Value(1)=='c'&&...
                    dtype.Value(2)~='h'));
                end
            end
        end
    case 'Tfldesigner_isMatrixPointer'
        entries={'Scalar','Matrix'};
        excludepointer={'memset','memcpy','memcmp','frexp'};
        keydesc=this.getDialogWidget('Tfldesigner_Key');
        if strcmp(keydesc.Value,'code_profile_read_timer')
            widgetNode.Entries={'Scalar'};
            widgetNode.Value=0;
        else
            if~isempty(find(strcmp(excludepointer,this.object.Key),1))
                widgetNode.Entries=[entries,'Pointer'];
            else
                widgetNode.Entries=entries;
            end
            if~isempty(this.object.ConceptualArgs)
                if this.concepargerror
                    widgetNode.Value=this.argtype;
                else
                    if isa(this.object.ConceptualArgs(this.activeconceptarg),'RTW.TflArgPointer')
                        widgetNode.Value=2;
                        if~any(strcmp(widgetNode.Entries,'Pointer'))
                            widgetNode.Entries=[entries,'Pointer'];
                        end
                    elseif isa(this.object.ConceptualArgs(this.activeconceptarg),'RTW.TflArgMatrix')
                        widgetNode.Value=1;
                    else
                        widgetNode.Value=0;
                    end
                    dtype=this.getDialogWidget('Tfldesigner_DataType');
                    if~isempty(dtype.Value)&&...
                        ~isempty(strfind(dtype.Value(end),'*'))
                        widgetNode.Value=2;
                    end
                end
            end
        end
    case 'Tfldesigner_LowerDim'
        if~isempty(this.object.ConceptualArgs)

            if isa(this.object.ConceptualArgs(this.activeconceptarg),'RTW.TflArgMatrix')
                ranges=this.object.ConceptualArgs(this.activeconceptarg).DimRange;
                widgetNode.Value=['[',num2str(ranges(1,:)),']'];
            else
                widgetNode.Value='[2 2]';
            end
            if isa(this.object.ConceptualArgs(this.activeconceptarg),'RTW.TflArgMatrix')
                widgetNode.Visible=true;
            end
        end
    case 'Tfldesigner_UpperDim'
        if~isempty(this.object.ConceptualArgs)

            if isa(this.object.ConceptualArgs(this.activeconceptarg),'RTW.TflArgMatrix')
                ranges=this.object.ConceptualArgs(this.activeconceptarg).DimRange;
                widgetNode.Value=['[',num2str(ranges(2,:)),']'];
            else
                widgetNode.Value='[2 2]';
            end
            if isa(this.object.ConceptualArgs(this.activeconceptarg),'RTW.TflArgMatrix')
                widgetNode.Visible=true;
            end
        end
    case 'Tfldesigner_CopyConcepArgSettings'
        keydesc=this.getDialogWidget('Tfldesigner_Key');
        if isa(this.object,'RTW.TflCustomization')
            widgetNode.Visible=false;
        elseif strcmp(keydesc.Value,'code_profile_read_timer')
            widgetNode.Visible=true;
            widgetNode.Value=true;
            widgetNode.Enabled=false;
        elseif isempty(this.object.Implementation.Return)&&...
            isempty(this.object.Implementation.Arguments)
            widgetNode.Enabled=false;
        end
    case 'Tfldesigner_DWorkAllocatorCheck'
    case 'Tfldesigner_DWorkEntryTag'
    case 'Tfldesigner_ActiveDWorkArg'
    case 'Tfldesigner_DWorkDataType'
    case 'Tfldesigner_DWorkPointerDesc'
    case 'Tfldesigner_DWorkAllocatorEntry'
        widgetNode.Visible=~this.allocatesdwork;
        if~isempty(this.object.DWorkAllocatorEntry)&&widgetNode.Visible
            widgetNode.Value=this.object.DWorkAllocatorEntry.EntryTag;
        end
    case 'Tfldesigner_Implementationname'
    case 'Tfldesigner_namespace'
        if isa(this.object.Implementation,'RTW.CPPImplementation')
            widgetNode.Value=this.object.getNameSpace;
        end
    case 'Tfldesigner_functionreturnvoid'
        if~isempty(this.object.Implementation.Return)
            widgetNode.Value=strcmp(this.object.Implementation.Return.toString,'void');
        end
    case 'Tfldesigner_blaslevel'
        if strcmp(this.EntryType,'RTW.TflBlasEntryGenerator')||...
            strcmp(this.EntryType,'RTW.TflCBlasEntryGenerator')
            widgetNode.Visible=true;
            numargs=length(this.object.Implementation.Arguments);
            if numargs>12
                widgetNode.Value=2;
            elseif numargs>10
                widgetNode.Value=1;
            end
            if~isempty(this.object.ConceptualArgs)
                widgetNode.Enabled=true;
            end
        end
    case 'Tfldesigner_ImplfuncArglist'
        entryList=this.getimplarglist;
        for i=1:length(entryList)
            arg=this.object.Implementation.Arguments(i);
            if isprop(arg,'ArgumentForInPlaceUse')&&~isempty(arg.ArgumentForInPlaceUse)
                entryList{i}=[entryList{i},'  <-->  ',arg.ArgumentForInPlaceUse];
            end
        end
        if isempty(this.object.Implementation.Return)
            widgetNode.Entries=[DAStudio.message('RTW:tfldesigner:NoReturnArgSetText'),...
            entryList];
        else
            returnargentryname=[this.object.Implementation.Return.Name...
            ,DAStudio.message('RTW:tfldesigner:ReturnArgText')];
            widgetNode.Entries=[returnargentryname,entryList];
        end
    case 'Tfldesigner_UpArgbutton'
        if~isempty(this.object.Implementation.Arguments)
            if this.activeimplarg==0
                widgetNode.Enabled=false;
            else
                argtomove=this.object.Implementation.Arguments(this.activeimplarg);
                widgetNode.Enabled=true;
                if this.activeimplarg<2&&~strcmp(argtomove.IOType,'RTW_IO_OUTPUT')
                    widgetNode.Enabled=false;
                end
            end
        end
    case 'Tfldesigner_DownArgbutton'
        if~isempty(this.object.Implementation.Arguments)
            if this.activeimplarg==0
                widgetNode.Enabled=false;
            else
                argtomove=this.object.Implementation.Arguments(this.activeimplarg);
                widgetNode.Enabled=true;
                if~(this.activeimplarg<2&&~strcmp(argtomove.IOType,'RTW_IO_OUTPUT'))...
                    &&(this.activeimplarg==length(this.object.Implementation.Arguments))
                    widgetNode.Enabled=false;
                end
            end
        end
    case 'Tfldesigner_AddargpushbuttonImpl'
        if~isempty(this.object.ConceptualArgs)
            keydesc=this.getDialogWidget('Tfldesigner_Key');
            if strcmp(keydesc.Value,'code_profile_read_timer')
                widgetNode.Enabled=false;
            else
                blaslevel=this.getDialogWidget('Tfldesigner_blaslevel');
                if blaslevel.Value<1
                    widgetNode.Enabled=true;
                else
                    widgetNode.Visible=false;
                end
            end
        end
    case 'Tfldesigner_RemoveargpushbuttonImpl'
        if isempty(this.object.ConceptualArgs)&&...
            (~isempty(this.object.Implementation.Arguments)||...
            ~isempty(this.object.Implementation.Return))
            widgetNode.Enabled=true;
        elseif~isempty(this.object.ConceptualArgs)||...
            ~isempty(this.object.Implementation.Arguments)||...
            ~isempty(this.object.Implementation.Return)
            blaslevel=this.getDialogWidget('Tfldesigner_blaslevel');
            if blaslevel.Value<1
                widgetNode.Enabled=true;
            else
                widgetNode.Visible=false;
            end

            if(isempty(this.object.Implementation.Arguments)...
                &&isempty(this.object.Implementation.Return))||...
                this.activeimplarg==0
                widgetNode.Enabled=false;
            end
            activearg=loc_getactiveImplArg(this);
            if~isempty(activearg)
                concepargs=this.getconceptualarglist;
                isconceptarg=~isempty(find(sum(ismember(concepargs,activearg.Name)),1));
                dworkargs=this.getdworkarglist;
                isdworkarg=~isempty(find(sum(ismember(dworkargs,activearg.Name)),1));
                keydesc=this.getDialogWidget('Tfldesigner_Key');
                iscustom=strcmpi(keydesc.Value,'Custom');
                if((isconceptarg||isdworkarg)&&~iscustom)||...
                    (this.activeimplarg==0&&strcmp(this.returnargname,'unused'))
                    widgetNode.Enabled=false;
                else
                    widgetNode.Enabled=true;
                end
            end
        end
    case 'Tfldesigner_ImplDatatype'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            dtypeval=activearg.toString;
            dtypeval=this.formatFixpointString(dtypeval);
            dtypeval=strrep(dtypeval,'const','');
            dtypeval=strrep(dtypeval,'volatile','');
            dtypeval=strtrim(dtypeval);

            if isa(activearg,'RTW.TflArgDWork')
                widgetNode.Enabled=false;
            else
                if strcmp(dtypeval(1),'c')&&~strcmp(dtypeval(2),'h')
                    dtypeval=dtypeval(2:end);
                end
            end

            len=length(strfind(dtypeval(end-1:end),'*'));
            if len==2
                dtypeval(end-1:end)=[];
            elseif len==1
                dtypeval(end)=[];
            end

            widgetNode.Value=strtrim(dtypeval);
            if this.activeimplarg==0&&strcmp(this.returnargname,'ununsed')
                widgetNode.Enabled=false;
            end
        end
    case 'Tfldesigner_ImplIOType'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            widgetNode.Value=this.getEnumString(activearg.IOType);
        end
    case 'Tfldesigner_Readonly'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)

            if isa(activearg,'RTW.TflArgPointer')
                if isa(activearg.Type.BaseType,'RTW.TflArgPointer')
                    widgetNode.Value=activearg.Type.BaseType.BaseType.ReadOnly;
                else
                    widgetNode.Value=activearg.Type.BaseType.ReadOnly;
                end
            else
                widgetNode.Value=activearg.Type.ReadOnly;
            end
        end
    case 'Tfldesigner_ispointer'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            if strcmpi(class(activearg),'RTW.TflArgPointer')
                widgetNode.Value=true;
            end
            dtypeval=activearg.toString;
            len=length(strfind(dtypeval(end-1:end),'*'));
            if len==1
                widgetNode.Value=true;
            end
            if~isempty(find(strfind(class(activearg),'Constant'),1))
                widgetNode.Enabled=false;
            elseif strcmp(this.implargdtype,'char')
                widgetNode.Value=false;
                widgetNode.Enabled=false;
            end
        end
    case 'Tfldesigner_ispointerpointer'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            if isa(activearg,'RTW.TflArgDWork')
                widgetNode.Visible=true;
                widgetNode.Enabled=true;
                dtypeval=activearg.toString;
                len=length(strfind(dtypeval(end-1:end),'*'));
                if len==2
                    widgetNode.Value=true;
                end
            end
        end
    case 'Tfldesigner_isargcomplex'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            dtypeval=activearg.toString;
            dtypeval=this.formatFixpointString(dtypeval);
            dtypeval=strrep(dtypeval,'const','');
            dtypeval=strrep(dtypeval,'volatile','');
            dtypeval=strtrim(dtypeval);
            if isa(activearg,'RTW.TflArgDWork')
                widgetNode.Visible=false;
            else
                if strcmp(dtypeval(1),'c')&&~strcmp(dtypeval(2),'h')
                    widgetNode.Value=true;
                end
            end
            if strcmp(this.implargdtype,'char')
                widgetNode.Value=false;
                widgetNode.Enabled=false;

            elseif strcmp(this.implargdtype,'void')
                widgetNode.Value=false;
                widgetNode.Enabled=false;
            end
        end
    case 'Tfldesigner_DataAlignment'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            dtypeval=activearg.toString;
            len=length(strfind(dtypeval(end-1:end),'*'));
            if len==1
                widgetNode.Visible=true;
            end
            if~isempty(activearg.Descriptor)&&~this.implargerror
                widgetNode.Value=num2str(activearg.Descriptor.AlignmentBoundary);
            elseif isempty(activearg.Descriptor)&&~this.implargerror
                widgetNode.Value='-1';
            end
        end
    case 'Tfldesigner_makeconstant'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            if this.activeimplarg==0
                widgetNode.Value=false;
                widgetNode.Enabled=false;
                widgetNode.Visible=false;
                this.makeimplargconstant=false;
            else
                concepargs=this.getconceptualarglist;
                isconceptarg=~isempty(find(sum(ismember(concepargs,activearg.Name)),1));
                dworkargs=this.getdworkarglist;
                isdworkarg=~isempty(find(sum(ismember(dworkargs,activearg.Name)),1));
                keydesc=this.getDialogWidget('Tfldesigner_Key');
                iscustom=strcmpi(keydesc.Value,'Custom');
                if((isconceptarg||isdworkarg)&&~iscustom)||...
                    (this.activeimplarg==0&&strcmp(this.returnargname,'unused'))
                    widgetNode.Enabled=false;
                    widgetNode.Visible=false;
                elseif~isempty(find(strfind(class(activearg),'Constant'),1))
                    widgetNode.Value=true;
                    widgetNode.Enabled=true;
                    this.makeimplargconstant=true;
                end
            end
        end
    case 'Tfldesigner_Initialvalue'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            if~isempty(find(strfind(class(activearg),'Constant'),1))
                if~isempty(find(strfind(class(activearg),'Complex'),1))
                    widgetNode.Value=num2str(complex(activearg.ReValue,activearg.ImValue));
                else
                    widgetNode.Value=activearg.Value;
                end
            end
            if~isempty(this.object.ConceptualArgs)
                concepargs=this.getconceptualarglist;
                if~isempty(find(sum(ismember(concepargs,activearg.Name)),1))
                    widgetNode.Value='';
                    widgetNode.Enabled=false;
                else
                    widgetNode.Enabled=true;
                end
            end
        end
    case 'Tfldesigner_Passbytype'
        activearg=loc_getactiveImplArg(this);
        if~isempty(activearg)
            if strcmpi(class(activearg),'RTW.TflArgPointer')
                widgetNode.Value=this.getEnumString(activearg.PassByType);
            end
        end
    case 'Tfldesigner_ImplFcnPreview'
        widgetNode.Name=loc_getPreviewSignature(this);
    case 'Tfldesigner_SaturationMode'
    case 'Tfldesigner_RoundingMode'
    case 'Tfldesigner_ExprInput'
    case 'Tfldesigner_SideEffects'
    case 'Tfldesigner_FLmustbesame'
        if isa(this.object,'RTW.TflCOperationEntryGenerator_NetSlope')||...
            isa(this.object,'RTW.TflCOperationEntryGenerator')
            fxpType=loc_hasFxpTypeArgs(this);
            if isa(this.object,'RTW.TflCOperationEntryGenerator')&&fxpType
                widgetNode.Visible=true;
                widgetNode.Enabled=true;
                widgetNode.Value=this.object.SlopesMustBeTheSame;
            elseif fxpType
                keydesc=this.getDialogWidget('Tfldesigner_Key');
                switch(keydesc.Value)
                case{'Addition','Minus'}
                    widgetNode.Visible=true;
                    widgetNode.Enabled=true;
                    widgetNode.Value=this.object.SlopesMustBeTheSame;
                otherwise
                end
            end
        end
    case 'Tfldesigner_Netslopeadjustfac'
        if isa(this.object,'RTW.TflCOperationEntryGenerator_NetSlope')||...
            isa(this.object,'RTW.TflCOperationEntryGenerator')
            fxpType=loc_hasFxpTypeArgs(this);
            if~isa(this.object,'RTW.TflCOperationEntryGenerator')&&fxpType
                keydesc=this.getDialogWidget('Tfldesigner_Key');
                switch(keydesc.Value)
                case{'Multiply','Divide','Cast','Shift left',...
                    'Element-wise Matrix Multiply',...
                    'Shift Right Arithmetic','Shift Right Logical',...
                    'Hermitian Multiplication','Transpose Multiplication'}
                    widgetNode.Visible=true;
                    widgetNode.Enabled=true;
                    widgetNode.Value=this.object.NetSlopeAdjustmentFactor;
                otherwise
                end
            end
        end
    case 'Tfldesigner_Netfixedexponent'
        if isa(this.object,'RTW.TflCOperationEntryGenerator_NetSlope')||...
            isa(this.object,'RTW.TflCOperationEntryGenerator')
            fxpType=loc_hasFxpTypeArgs(this);
            if~isa(this.object,'RTW.TflCOperationEntryGenerator')&&fxpType
                keydesc=this.getDialogWidget('Tfldesigner_Key');
                switch(keydesc.Value)
                case{'Multiply','Divide','Cast','Shift left',...
                    'Element-wise Matrix Multiply',...
                    'Shift Right Arithmetic','Shift Right Logical',...
                    'Hermitian Multiplication','Transpose Multiplication'}
                    widgetNode.Visible=true;
                    widgetNode.Enabled=true;
                    widgetNode.Value=this.object.NetFixedExponent;
                otherwise
                end
            end
        end
    case 'Tfldesigner_SameSlopeFunction'
        if isa(this.object,'RTW.TflCFunctionEntry')
            fxpType=loc_hasFxpTypeArgs(this);
            if fxpType
                keydesc=this.getDialogWidget('Tfldesigner_Key');
                switch(keydesc.Value)
                case{'abs','min','max','sign','sqrt'}
                    widgetNode.Visible=true;
                    widgetNode.Enabled=true;
                    widgetNode.Value=this.object.SlopesMustBeTheSame;
                otherwise
                end
            end
        end
    case 'Tfldesigner_SameBiasFunction'
        if isa(this.object,'RTW.TflCFunctionEntry')
            fxpType=loc_hasFxpTypeArgs(this);
            if fxpType
                keydesc=this.getDialogWidget('Tfldesigner_Key');
                switch(keydesc.Value)
                case{'abs','min','max','sign','sqrt'}
                    widgetNode.Visible=true;
                    widgetNode.Enabled=true;
                    widgetNode.Value=this.object.BiasMustBeTheSame;
                otherwise
                end
            end
        end
    case 'Tfldesigner_buildinfoHyperlink'
        keydesc=this.getDialogWidget('Tfldesigner_Key');
        if isempty(keydesc.Value)
            widgetNode.Enabled=false;
        end
    case 'Tfldesigner_InlineFcn'
        if strcmpi(this.EntryType,'RTW.TflCustomization')
            widgetNode.Visible=true;
            widgetNode.Value=this.object.InlineFcn;
        end
    case 'Tfldesigner_Precise'
        if strcmpi(this.EntryType,'RTW.TflCustomization')
            widgetNode.Value=this.object.Precise;
        end
    case 'Tfldesigner_SupportNonFinite'
        if strcmpi(this.EntryType,'RTW.TflCustomization')
            widgetNode.Visible=true;
            widgetNode.Value=this.getEnumString(this.object.SupportNonFinite);
        end
    case 'Tfldesigner_EMLCallback'
        if strcmpi(this.EntryType,'RTW.TflCustomization')

            widgetNode.Value=this.object.ImplCallback;
        end
    case 'Tfldesigner_ValidateStatus'
    case 'Tfldesigner_errorLogHyperlink'
        if~this.applyinvalid&&~isempty(this.errLog)
            widgetNode.Visible=true;
        end
    case 'Tfldesigner_ValidateStatusDesc'
        if~this.applyinvalid&&~this.isValid&&isempty(this.errLog)
            widgetNode.Visible=true;
        end
    case 'Tfldesigner_InvalidStatusDesc'
        if this.applyinvalid
            widgetNode.Visible=true;
        elseif~isempty(this.errLog)&&~this.isValid
            widgetNode.Visible=true;
        end
    case 'Tfldesigner_ValidStatusDesc'
        if~this.applyinvalid&&this.isValid&&isempty(this.errLog)
            widgetNode.Visible=true;
        end
    case 'Tfldesigner_WarningStatusDesc'
        if~this.applyinvalid&&this.isValid&&~isempty(this.errLog)
            widgetNode.Visible=true;
        end
    case 'Tfldesigner_Validatepushbutton'
        if~this.applyinvalid&&~this.isValid&&isempty(this.errLog)
            widgetNode.Visible=true;
        end
    case 'Tfldesigner_RemoveProtection'
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D','prelookup'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));

            end

        end
    case 'Tfldesigner_RemoveProtectionIndex'
        switch this.object.Key
        case{'interp1D','interp2D','interp3D','interp4D','interp5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case 'Tfldesigner_RoundMethod'
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D',...
            'prelookup','interp1D','interp2D','interp3D','interp4D','interp5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case 'Tfldesigner_SatMethod'
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D',...
            'interp1D','interp2D','interp3D','interp4D','interp5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case 'Tfldesigner_UseRowMajorAlgorithm'
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D','lookupND_Direct',...
            'interp1D','interp2D','interp3D','interp4D','interp5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case 'Tfldesigner_AngleUnit_AlgoParam'
        widgetNode.Visible=true;
        widgetNode.Enabled=true;
        widgetNode.Value=0;
        propName=this.getBlockPropertyFromTag(widgetTag);
        if isprop(this.apSet,propName)
            widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
        end
    case 'Tfldesigner_ExtrpMethod_AlgoParam'
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        case{'prelookup','interp1D','interp2D','interp3D','interp4D','interp5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case 'Tfldesigner_IntrpMethod_AlgoParam'
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D','sin','cos','sincos','atan2'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        case{'interp1D','interp2D','interp3D','interp4D','interp5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case{'Tfldesigner_IndexSearchMethod','Tfldesigner_BeginIndexSearchUsingPreviousIndexResult'}
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D',...
            'prelookup'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case{'Tfldesigner_SupportTunableTable',...
'Tfldesigner_UseLastTableValue'...
        }
        switch this.object.Key
        case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        otherwise
        end
    case 'Tfldesigner_ValidIndexReachLast'
        switch this.object.Key
        case{'interp1D','interp2D','interp3D','interp4D','interp5D'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        otherwise
        end
    case 'Tfldesigner_UseLastBreakpoint'
        switch this.object.Key
        case{'prelookup'}
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        otherwise
        end
    case 'Tfldesigner_TableDimension'
        if strcmp(this.object.Key,'lookupND_Direct')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=2;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case 'Tfldesigner_InputSelectObjectTable'
        if strcmp(this.object.Key,'lookupND_Direct')
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
            widgetNode.Value=0;
            propName=this.getBlockPropertyFromTag(widgetTag);
            if isprop(this.apSet,propName)
                widgetNode.Value=loc_algoString(this.apSet.(propName).Value);
                widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AlgoOptionsText',...
                loc_algoString(this.apSet.(propName).Options));
            end
        end
    case 'Tfldesigner_InPlaceArg'
        keydesc=this.getDialogWidget('Tfldesigner_Key');
        activearg=loc_getactiveImplArg(this);
        widgetNode.Visible=false;
        if strcmp(keydesc.Value,'Custom')&&this.activeimplarg~=0&&...
            ~isempty(activearg)
            widgetNode.Visible=true;
            widgetNode.Enable=widgetNode.Visible;
            widgetNode.Entries=this.getentries(widgetTag);
            widgetNode.Value=0;
            if isprop(activearg,'ArgumentForInPlaceUse')&&...
                ~isempty(activearg.ArgumentForInPlaceUse)
                widgetNode.Value=activearg.ArgumentForInPlaceUse;
            end
            if strcmp(activearg.IOType,'RTW_IO_OUTPUT')
                widgetNode.Enable=false;
            end
            if widgetNode.Visible
                makeconstant=this.getDialogWidget('Tfldesigner_makeconstant',true);
                makeconstant.Enabled=false;
            end
        end
    case 'Tfldesigner_ArrayLayout'
        containMatrix=getEntryContainMatrix(this);
        if containMatrix
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
        end
        widgetNode.Entries=this.getentries('Tfldesigner_ArrayLayout');
        widgetNode.Value=this.getEnumString(this.object.ArrayLayout);
    case 'Tfldesigner_AllowShapeAgnosticMatch'
        containMatrix=getEntryContainMatrix(this);
        if containMatrix
            widgetNode.Visible=true;
            widgetNode.Enabled=true;
        end
        widgetNode.Value=this.object.AllowShapeAgnosticMatch;
    otherwise
    end
end



function activearg=loc_getactiveImplArg(this)
    activearg=[];
    if this.activeimplarg==0&&~isempty(this.object.Implementation.Return)
        activearg=this.object.Implementation.Return;
    elseif this.activeimplarg~=0&&~isempty(this.object.Implementation.Arguments)
        activearg=this.object.Implementation.Arguments(this.activeimplarg);
    end
end

function fxpType=loc_hasFxpTypeArgs(this)
    dtype=this.getDialogWidget('Tfldesigner_DataType');
    fxpType=~strcmp(dtype.Value,'double')&&...
    ~strcmp(dtype.Value,'single');
    types={'double','single','boolean','logical','void'};
    for idx=1:length(this.object.ConceptualArgs)
        fxpType=fxpType||...
        isempty(strfind(types,this.object.ConceptualArgs(idx).toString));
    end
end

function text=loc_getPreviewSignature(this)

    impl=this.object.Implementation;
    text='no return argument set';
    if~isempty(impl.Return)
        text='';
        type=formatType(impl.Return.toString);
        type=this.formatFixpointString(type);
        text=[text,type,'<i>'];
        if isa(impl,'RTW.CPPImplementation')
            if~isempty(impl.NameSpace)
                text=[text,' ',impl.NameSpace,'::'];
            end
        end
        if~isempty(impl.Name)
            text=[text,' ',impl.Name,'</i> ( '];
        else
            text=[text,' no_name</i>( '];
        end
        linebreak=1;
        if~isempty(impl.Arguments)
            for i=1:length(impl.Arguments)
                if i==1
                    text=[text,' '];%#ok
                else
                    text=[text,', '];%#ok
                end
                if length(text(linebreak:end))>80
                    text=[text,'<br>          '];%#ok
                    linebreak=length(text);
                end
                type=formatType(impl.Arguments(i).toString);
                type=this.formatFixpointString(type);
                if~isempty(find(strfind(class(impl.Arguments(i)),'Constant'),1))
                    if strcmp(impl.Arguments(i).PassByType,'RTW_PASSBY_VOID_POINTER')
                        type='void';
                    end
                    if strcmp(impl.Arguments(i).PassByType,'RTW_PASSBY_BASE_POINTER')
                        if~isempty(find(strfind(class(impl.Arguments(i)),'Complex'),1))
                            type=type(2:end);
                        end
                    end
                    if~strcmp(impl.Arguments(i).PassByType,'RTW_PASSBY_AUTO')
                        type=strcat(type,'*');
                    end
                end
                text=[text,type,' ',impl.Arguments(i).Name];%#ok
            end
        end

        text=[text,' );'];
    end

    function type=formatType(type)
        type=strrep(type,'volatile','');
        if~isempty(strfind(type,'const'))
            type=strrep(type,'const','');
            type=['const ',strrep(type,' ','')];
        end
    end
end


function str=loc_algoString(cellStr)
    str='';
    if~isempty(cellStr)
        str=strcat(str,cellStr{1});
        for i=2:length(cellStr)
            str=strcat(str,', ',cellStr{i});
        end
    end
end


