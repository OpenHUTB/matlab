function dlgStruct=CallerBlock_ddg(source,h)






    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    myFunctions.List=getAutoCompleteFunctionsList(h.Handle);


    rowIdx=1;
    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[rowIdx,rowIdx];
    descGrp.ColSpan=[1,1];


    rowIdx=rowIdx+1;
    protoTypePrompt.Name=DAStudio.message('Simulink:blkprm_prompts:FcnCallerFunctionPrototype');
    protoTypePrompt.Type='text';
    protoTypePrompt.RowSpan=[rowIdx,rowIdx];
    protoTypePrompt.ColSpan=[1,1];
    protoTypePrompt.Buddy='FunctionPrototype';

    if(slfeature('EditTimeCrossModelSLFunctionSelection')>0)
        crossMdlfcnProtList=Simulink.internal.slid.DictionaryInterface.getListOfAvailableSLFunctions();
    else
        crossMdlfcnProtList={};
    end

    if(slfeature('SLDDBroker')>0)

        ddSpec=get_param(bdroot(h.Handle),'DataDictionary');
        if~isempty(ddSpec)
            crossMdlfcnProtList=...
            Simulink.internal.slid.DictionaryInterface.getFunctionPrototypesFromDictionary(which(ddSpec));
        end
    end


    protoptyList=(myFunctions.List(:))';
    numberOfProt=length(protoptyList);
    autocompleteData=cell(2,numberOfProt);
    autocompleteData(1,:)=protoptyList;
    autocompleteData(2,:)={DAStudio.message('Simulink:blkprm_prompts:FcnCallerThisModel')};


    if~isempty(crossMdlfcnProtList)
        crossMdlfcnProtList=crossMdlfcnProtList(:);
        currentMdlName=get(bdroot(h.Handle),'Name');

        crossMdlfcnProtList=crossMdlfcnProtList(...
        cellfun(@(x)isempty(regexp(x,[':',currentMdlName,'\.slx$'],'once'))...
        ,crossMdlfcnProtList));
        crNumberOfProt=length(crossMdlfcnProtList);
        splitRes=split(crossMdlfcnProtList,':',2);
        additionalProtList=splitRes(:,1)';
        additionalSrcList=splitRes(:,2)';
        crossMdlData=cell(2,crNumberOfProt);
        crossMdlData(1,:)=additionalProtList;
        crossMdlData(2,:)=additionalSrcList;
        autocompleteData(1:2,end+1:end+crNumberOfProt)=crossMdlData;
    end

    rowIdx=rowIdx+1;
    protoType.Name='';
    protoType.Type='edit';
    protoType.RowSpan=[rowIdx,rowIdx];
    protoType.ColSpan=[1,2];
    protoType.Source=h;
    protoType.ObjectProperty='FunctionPrototype';
    protoType.Tag=protoType.ObjectProperty;
    protoType.AutoCompleteType='Custom';
    protoType.AutoCompleteViewColumn={'Function','Source'};
    protoType.AutoCompleteViewData=autocompleteData;
    protoType.AutoCompleteMatchOption='contains';
    protoType.Enabled=true;


    rowIdx=rowIdx+1;
    inputArgSpecPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:FcnCallerInputArgSpec');
    inputArgSpecPrompt.Type='text';
    inputArgSpecPrompt.RowSpan=[rowIdx,rowIdx];
    inputArgSpecPrompt.ColSpan=[1,1];
    inputArgSpecPrompt.Buddy='InputArgumentSpecifications';

    rowIdx=rowIdx+1;
    inputArgSpec.Name='';
    inputArgSpec.Type='edit';
    inputArgSpec.RowSpan=[rowIdx,rowIdx];
    inputArgSpec.ColSpan=[1,1];
    inputArgSpec.Source=h;
    inputArgSpec.ObjectProperty='InputArgumentSpecifications';

    inputArgSpec.Tag=inputArgSpec.ObjectProperty;


    rowIdx=rowIdx+1;
    outputArgSpecPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:FcnCallerOutputArgSpec');
    outputArgSpecPrompt.Type='text';
    outputArgSpecPrompt.ColSpan=[1,1];
    outputArgSpecPrompt.RowSpan=[rowIdx,rowIdx];
    outputArgSpecPrompt.ColSpan=[1,1];
    outputArgSpecPrompt.Buddy='OutputArgumentSpecifications';

    rowIdx=rowIdx+1;
    outputArgSpec.Name='';
    outputArgSpec.Type='edit';
    outputArgSpec.RowSpan=[rowIdx,rowIdx];
    outputArgSpec.ColSpan=[1,1];
    outputArgSpec.Source=h;
    outputArgSpec.ObjectProperty='OutputArgumentSpecifications';
    outputArgSpec.Tag=outputArgSpec.ObjectProperty;


    rowIdx=rowIdx+1;
    sampleTimePrompt.Name=DAStudio.message('Simulink:blkprm_prompts:AllBlksSampleTime');
    sampleTimePrompt.Type='text';
    sampleTimePrompt.ColSpan=[1,1];
    sampleTimePrompt.RowSpan=[rowIdx,rowIdx];
    sampleTimePrompt.ColSpan=[1,1];
    sampleTimePrompt.Buddy='SampleTime';

    rowIdx=rowIdx+1;
    sampleTime.Name='';
    sampleTime.Type='edit';
    sampleTime.RowSpan=[rowIdx,rowIdx];
    sampleTime.ColSpan=[1,1];
    sampleTime.Source=h;
    sampleTime.ObjectProperty='SampleTime';
    sampleTime.Tag=sampleTime.ObjectProperty;
    sampleTime.Enabled=true;

    if(slfeature('CompositeFunctionElements')&&...
        slfeature('AsyncClientServer'))
        rowIdx=rowIdx+1;
        runOnMessage.Name=DAStudio.message('Simulink:blkprm_prompts:AllowAsynchronousExecution');
        runOnMessage.Type='checkbox';
        runOnMessage.RowSpan=[1,1];
        runOnMessage.Source=h;
        runOnMessage.ObjectProperty='AsynchronousCaller';
        runOnMessage.Tag=runOnMessage.ObjectProperty;
        runOnMessage.Enabled=true;
    end


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='group';
    paramGrp.RowSpan=[rowIdx,rowIdx];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;
    paramGrp.Items={protoTypePrompt,protoType,...
    inputArgSpecPrompt,inputArgSpec,...
    outputArgSpecPrompt,outputArgSpec,...
    sampleTimePrompt,sampleTime...
    };
    if(slfeature('CompositeFunctionElements')&&...
        slfeature('AsyncClientServer'))
        paramGrp.Items{end+1}=runOnMessage;
    end




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,newline,' ')));
    dlgStruct.DialogTag='FunctionCallerParameter';
    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[rowIdx,1];
    dlgStruct.RowStretch=[zeros(1,(rowIdx-1)),1];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};


    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked||source.isHierarchySimulating
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end


