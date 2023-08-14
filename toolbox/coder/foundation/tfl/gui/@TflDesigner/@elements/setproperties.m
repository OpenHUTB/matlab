function[success,errorid]=setproperties(h,dlghandle,propNames)







    success=true;
    errorid='';
    wasDirty=h.parentnode.isDirty;
    needupdate=false;
    h.activeconceptargIsMatrix=false;

    try
        for idx=1:length(propNames)

            switch propNames{idx}

            case 'Tfldesigner_Key'

                index=dlghandle.getWidgetValue('Tfldesigner_Key');
                names=h.getkeyentries;
                h.activeconceptarg=1;
                h.activeimplarg=0;
                if isprop(h.object,'AlgorithmParams')
                    h.object.AlgorithmParams=[];
                end
                if strcmpi(names{index+1},'Custom')
                    h.object.ConceptualArgs=[];
                    if~isa(h.object,'RTW.TflCustomization')
                        h.object.Implementation.Arguments=[];
                        h.object.Implementation.Return=[];
                    end
                    h.object.Key=names{index+1};
                    dlghandle.setFocus('Tfldesigner_CustomFunc');
                else
                    h.object.Key=h.getEnumString(names{index+1});
                    h.Name=h.getEnumString(h.object.Key);

                    h.createConceptualArgs;

                    if~isa(h.object,'RTW.TflCustomization')
                        h.createImplementationArgs;
                        if h.copyconcepargsettings
                            h.copyConceptualArgsSettings;
                        end
                        if isa(h.object,'RTW.TflCSemaphoreEntry')
                            h.createDWorkArgs;
                        elseif isa(h.object,'RTW.TflCFunctionEntry')
                            h.apSet=h.object.getAlgorithmParameters;
                        end
                    end
                end
                needupdate=true;
            case 'Tfldesigner_CustomFunc'
                if isprop(h.object,'AlgorithmParams')
                    h.object.AlgorithmParams=[];
                end
                names=h.getkeyentries;
                propVal=dlghandle.getWidgetValue('Tfldesigner_CustomFunc');
                if strcmp(h.Name,propVal)
                    return;
                end
                index=find(strcmpi(propVal,names)==1);
                if~isempty(index)
                    dlghandle.setWidgetValue('Tfldesigner_Key',index-1);
                    h.object.Key=h.getEnumString(names{index});
                    h.Name=h.getEnumString(h.object.Key);

                    h.createConceptualArgs;

                    if~isa(h.object,'RTW.TflCustomization')
                        h.createImplementationArgs;
                        if isa(h.object,'RTW.TflCSemaphoreEntry')
                            h.createDWorkArgs;
                        end
                    end
                else
                    h.object.Key=propVal;
                    h.Name=h.object.Key;
                end
                if isa(h.object,'RTW.TflCFunctionEntry')
                    h.apSet=h.object.getAlgorithmParameters;
                end
                needupdate=true;
            case{'Tfldesigner_ActiveConceptArg'}

                if dlghandle.hasUnappliedChanges&&h.copyconcepargsettings~=1&&...
                    h.copyconcepargsettings~=2
                    dlghandle.apply;
                    if h.concepargerror
                        dlghandle.setWidgetValue('Tfldesigner_ActiveConceptArg',h.activeconceptarg-1);
                    end
                else
                    if h.copyconcepargsettings==2
                        h.copyconcepargsettings=1;
                    end
                    h.activeconceptarg=dlghandle.getWidgetValue('Tfldesigner_ActiveConceptArg')+1;
                end
                classtype=class(h.object.ConceptualArgs(h.activeconceptarg));

                if strcmpi(classtype,'RTW.TflArgPointer')
                    h.argtype=2;
                elseif strcmpi(classtype,'RTW.TflArgMatrix')
                    h.argtype=1;
                else
                    h.argtype=0;
                end
                h.cargstructfields={};
                ismatrix=(h.argtype==1);
                h.activeconceptargIsMatrix=ismatrix;
                needupdate=true;
            case{'Tfldesigner_ImplfuncArglist'}
                if dlghandle.hasUnappliedChanges&&h.copyconcepargsettings~=1&&...
                    h.copyconcepargsettings~=2
                    dlghandle.apply;
                    if h.implargerror
                        dlghandle.setWidgetValue('Tfldesigner_ImplfuncArglist',h.activeimplarg)
                    end
                else
                    if h.copyconcepargsettings==2
                        h.copyconcepargsettings=1;
                    end
                    if h.addedimplarg
                        h.addedimplarg=false;
                        dlghandle.setWidgetValue('Tfldesigner_ImplfuncArglist',h.activeimplarg)
                    else
                        index=dlghandle.getWidgetValue('Tfldesigner_ImplfuncArglist');
                        if isempty(index)
                            index=0;
                        end
                        h.activeimplarg=index;
                    end
                end
                h.iargstructfields={};
            case 'Tfldesigner_SaturationMode'
                entries=h.getentries('Tfldesigner_SaturationMode');
                propValue=dlghandle.getWidgetValue('Tfldesigner_SaturationMode');
                h.object.SaturationMode=h.getEnumString(entries{propValue+1});
                needupdate=true;
            case 'Tfldesigner_RoundingMode'
                propValue=dlghandle.getWidgetValue('Tfldesigner_RoundingMode');
                entries=h.getentries('Tfldesigner_RoundingMode');
                h.object.RoundingMode=h.getEnumString(entries{propValue+1});
                needupdate=true;
            case 'Tfldesigner_DataType'
                if h.isStructSpecEnabled


                    h.updateStructFieldTypes;
                    needupdate=true;
                end
            case 'Tfldesigner_isMatrixPointer'
                h.argtype=dlghandle.getWidgetValue('Tfldesigner_isMatrixPointer');
                ismatrix=h.argtype==1;
                dlghandle.setVisible('Tfldesigner_LowerDim',ismatrix);
                dlghandle.setVisible('Tfldesigner_UpperDim',ismatrix);
                h.activeconceptargIsMatrix=ismatrix;
                needupdate=true;
            case 'Tfldesigner_DWorkAllocatorCheck'
                h.allocatesdwork=dlghandle.getWidgetValue('Tfldesigner_DWorkAllocatorCheck');
                if h.allocatesdwork
                    h.allocateDWork;
                else
                    h.clearDWork;
                end
            case 'Tfldesigner_DWorkAllocatorEntry'
                entries=h.getdworkallocatorentries;
                tag=entries{dlghandle.getWidgetValue('Tfldesigner_DWorkAllocatorEntry')+1};
                for i=1:length(h.parentnode.children)
                    if h.parentnode.children(i).allocatesdwork
                        if strcmp(tag,h.parentnode.children(i).object.EntryTag)
                            h.object.DWorkAllocatorEntry=h.parentnode.children(i).object;
                        end
                    end
                end
                dlghandle.apply;
            case 'Tfldesigner_Returnarg'
                returnArgList=h.getentries('Tfldesigner_Returnarg');
                returnArgIndex=dlghandle.getWidgetValue('Tfldesigner_Returnarg');

                h.returnargname=returnArgList{returnArgIndex+1};
                setReturnArg(h,dlghandle);

            case 'Tfldesigner_ImplDatatype'
                dtypeentries=h.getentries('Tfldesigner_ImplDatatype');
                h.implargdtype=dtypeentries{dlghandle.getWidgetValue('Tfldesigner_ImplDatatype')+1};

                setCopyConceptArgSettings(h);
                if h.isStructSpecEnabled
                    needupdate=true;
                end
            case 'Tfldesigner_IgnoreCheckType'
                h.object.ConceptualArgs(h.activeconceptarg).CheckType=...
                ~dlghandle.getWidgetValue('Tfldesigner_IgnoreCheckType');
                needupdate=true;
            case 'Tfldesigner_blaslevel'
                h.object.Implementation.Arguments=[];
                h.object.Implementation.Return=[];
                h.makeimplargconstant=false;
                h.activeimplarg=0;
                index=dlghandle.getWidgetValue('Tfldesigner_blaslevel');
                if index==1
                    if strcmp(h.EntryType,'RTW.TflBlasEntryGenerator')
                        h.createBlasImplementationArgsLevel2;
                    else
                        h.createCBlasImplementationArgsLevel2;
                    end
                elseif index==2
                    if strcmp(h.EntryType,'RTW.TflBlasEntryGenerator')
                        h.createBlasImplementationArgsLevel3;
                    else
                        h.createCBlasImplementationArgsLevel3;
                    end
                else
                    h.createImplementationArgs;
                end
                needupdate=true;
            case 'Tfldesigner_makeconstant'
                h.makeimplargconstant=dlghandle.getWidgetValue('Tfldesigner_makeconstant');
                if~h.makeimplargconstant
                    if~isempty(dlghandle.getWidgetValue('Tfldesigner_Initialvalue'))
                        dlghandle.setWidgetValue('Tfldesigner_Initialvalue','');
                    end
                end
            case 'Tfldesigner_errorLogHyperlink'
                h.showErrLogTab=true;
            case 'Tfldesigner_buildinfoHyperlink'
                h.showBuildInfoTab=true;
            case 'Tfldesigner_functionreturnvoid'
                returnvoid=dlghandle.getWidgetValue('Tfldesigner_functionreturnvoid');
                if returnvoid
                    h.returnargname='unused';
                    setReturnArg(h,dlghandle);
                else
                    h.returnargname='y1';
                    setReturnArg(h,dlghandle);
                end
                needupdate=true;
            case 'Tfldesigner_ispointer'
                if h.activeimplarg==0
                    iname=h.object.Implementation.Return.Name;
                else
                    iname=h.object.Implementation.Arguments(h.activeimplarg).Name;
                end

                for i=1:length(h.object.ConceptualArgs)
                    if strcmp(h.object.ConceptualArgs(i).Name,iname)
                        if~isa(h.object.ConceptualArgs(i),'RTW.TflArgMatrix')
                            h.copyconcepargsettings=0;
                            break;
                        end
                    end
                end

                value=dlghandle.getWidgetValue('Tfldesigner_ispointer');
                if dlghandle.isEnabled('Tfldesigner_ispointerpointer')
                    dlghandle.setWidgetValue('Tfldesigner_ispointerpointer',~value);
                end
                h.showdataalign=value;
            case 'Tfldesigner_isargcomplex'
                setCopyConceptArgSettings(h);
            case 'Tfldesigner_ispointerpointer'
                value=dlghandle.getWidgetValue('Tfldesigner_ispointerpointer');
                dlghandle.setWidgetValue('Tfldesigner_ispointer',~value);

                impldatatypeentries=h.getentries('Tfldesigner_ImplDatatype');
                ind=find(strcmp(impldatatypeentries,'void'),1)-1;
                dlghandle.setWidgetValue('Tfldesigner_ImplDatatype',ind);
            case 'Tfldesigner_ConceptIOType'
                entries=h.getentries('Tfldesigner_IOType');
                iotype=h.getEnumString(...
                entries{dlghandle.getWidgetValue('Tfldesigner_ConceptIOType')+1});
                if~strcmp(iotype,h.object.ConceptualArgs(h.activeconceptarg).IOType)
                    if~isa(h.object,'RTW.TflCustomization')&&...
                        (~isempty(h.object.Implementation.Return)||...
                        ~isempty(h.object.Implementation.Arguments))
                        msg=DAStudio.message('RTW:tfldesigner:IOTypeChangeWarningMsg');
                        warndlg(msg,DAStudio.message('RTW:tfldesigner:WarningText'));
                    end
                end
            case 'Tfldesigner_CopyConcepArgSettings'
                input=dlghandle.getWidgetValue('Tfldesigner_CopyConcepArgSettings');



                if input
                    h.copyconcepargsettings=1;
                end
            case 'Tfldesigner_InPlaceArg'
                entries=h.getentries('Tfldesigner_InPlaceArg');
                input=entries{dlghandle.getWidgetValue('Tfldesigner_InPlaceArg')+1};
                if strcmp(input,'None')
                    input='';
                end
                activearg=h.object.Implementation.Arguments(h.activeimplarg);
                if isprop(activearg,'ArgumentForInPlaceUse')&&...
                    ~strcmp(activearg.ArgumentForInPlaceUse,input)
                    resetArgumentInPlace(h,input);
                    resetArgumentInPlace(h,activearg.Name);
                end
                if h.activeimplarg~=0&&~isempty(h.object.Implementation.Arguments)
                    newactivearg=manageArgPointerType(h,activearg,'add');
                    newactivearg.ArgumentForInPlaceUse=input;
                    h.object.Implementation.Arguments(h.activeimplarg)=newactivearg;
                    if strcmp(input,h.object.Implementation.Return.Name)

                        h.returnargname='unused';
                        currimplarg=h.activeimplarg;
                        setReturnArg(h,dlghandle);
                        h.activeimplarg=currimplarg;
                        needupdate=true;
                    end
                    names={h.object.Implementation.Arguments.Name};
                    index=find(ismember(names,input),1);
                    if~isempty(index)
                        arg=manageArgPointerType(h,h.object.Implementation.Arguments(index),'add');
                        arg.ArgumentForInPlaceUse=activearg.Name;
                        h.object.Implementation.Arguments(index)=arg;
                    end
                end
            case 'Tfldesigner_ArrayLayout'
                propValue=dlghandle.getWidgetValue('Tfldesigner_ArrayLayout');
                entries=h.getentries('Tfldesigner_ArrayLayout');
                h.object.ArrayLayout=h.getEnumString(entries{propValue+1});
                needupdate=true;
            otherwise
                dlghandle.refresh;
            end
        end

    catch ME
        errorid=ME.message;
        success=false;
    end

    h.firepropertychanged;
    if~wasDirty&&needupdate
        h.isValid=false;
        h.parentnode.isDirty=true;
        h.parentnode.firehierarchychanged;
    end


    function setReturnArg(h,dlghandle)

        return_arg=h.object.Implementation.Return;
        if~isempty(return_arg)&&...
            strcmp(return_arg.Name,h.returnargname)
            dlghandle.apply;
        else
            matchfound=false;
            for len=1:length(h.object.Implementation.Arguments)
                if strcmp(h.object.Implementation.Arguments(len).Name,h.returnargname)
                    resetArgumentInPlace(h,h.object.Implementation.Arguments(len).Name);
                    newarg=manageArgPointerType(h,h.object.Implementation.Arguments(len),'remove');
                    h.object.Implementation.setReturn(newarg);
                    h.object.Implementation.Arguments(len)=[];
                    if~isa(return_arg,'RTW.TflArgVoid')
                        h.object.Implementation.Arguments=[h.object.Implementation.Arguments;...
                        return_arg];
                    end
                    matchfound=true;
                    break;
                end
            end

            if~matchfound
                if~isempty(return_arg)
                    for len=1:length(h.object.ConceptualArgs)
                        if strcmp(return_arg.Name,h.object.ConceptualArgs(len).Name)
                            return_arg=manageArgPointerType(h,return_arg,'add');
                            if isempty(h.object.Implementation.Arguments)
                                h.object.Implementation.Arguments=return_arg;
                            else
                                h.object.Implementation.Arguments=[h.object.Implementation.Arguments;...
                                return_arg];
                            end
                            matchfound=true;
                            break;
                        end
                    end
                else
                    matchfound=true;
                end

                if isempty(h.returnargname)
                    h.object.Implementation.Return=[];
                elseif matchfound
                    arg=h.parentnode.object.getTflArgFromString(h.returnargname,'void');
                    arg.IOType='RTW_IO_OUTPUT';
                    h.object.Implementation.setReturn(arg);
                else
                    h.object.Implementation.Return.Name=h.returnargname;
                end
            end
        end

        h.activeimplarg=0;


        function setCopyConceptArgSettings(h)
            concepargs=h.getconceptualarglist;
            if h.activeimplarg==0
                iname=h.object.Implementation.Return.Name;
            else
                iname=h.object.Implementation.Arguments(h.activeimplarg).Name;
            end
            if~isempty(find(strcmp(concepargs,iname),1))
                h.copyconcepargsettings=0;
            end






