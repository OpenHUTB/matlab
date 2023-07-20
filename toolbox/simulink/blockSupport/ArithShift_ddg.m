function dlgStruct=ArithShift_ddg(source,h)






    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name=h.BlockType;
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    paramGrp.Name='Parameters';
    paramGrp.Type='tab';
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;


    paramGrp.Tabs={};
    paramGrp.Tabs{end+1}=get_data_and_algorithm_tab(source,h);




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag='ArithShift';

    dlgStruct.Items={descGrp,paramGrp};
    dlgStruct.LayoutGrid=[2,1];
    dlgStruct.RowStretch=[0,1];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={h.Handle,'parameter'};


    dlgStruct.PreApplyMethod='preApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};


    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};


    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end




    function thisTab=get_data_and_algorithm_tab(source,h)


        dlFromDlg=strcmp(h.BitShiftNumberSource,'Dialog');

        titleRowIdx=1;
        BitShiftRowIdx=2;
        BinPtRowIdx=3;
        DiagnosticRowIdx=4;
        CheckRowIdx=5;

        c1=1;
        c2=1;
        c3=1;








        dataCurCol=1;

        sP.Name='';
        sP.Type='text';
        sP.RowSpan=[titleRowIdx,titleRowIdx];
        sP.ColSpan=[dataCurCol,dataCurCol+c1-1];


        BitShiftPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:Shift_Bit');
        BitShiftPrompt.Type='text';
        BitShiftPrompt.RowSpan=[BitShiftRowIdx,BitShiftRowIdx];
        BitShiftPrompt.ColSpan=[dataCurCol,dataCurCol+c1-1];


        BinPtPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:Shift_Bnp');
        BinPtPrompt.Type='text';
        BinPtPrompt.RowSpan=[BinPtRowIdx,BinPtRowIdx];
        BinPtPrompt.ColSpan=[dataCurCol,dataCurCol+c1+1];









        dataCurCol=dataCurCol+c1;


        srcPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:ParamSourceLabelId');
        srcPrompt.Type='text';
        srcPrompt.RowSpan=[titleRowIdx,titleRowIdx];
        srcPrompt.ColSpan=[dataCurCol,dataCurCol+c2-1];



        BitShiftSource=create_widget(source,h,'BitShiftNumberSource',BitShiftRowIdx,2,2);
        BitShiftSource.Name='';
        BitShiftSource.RowSpan=[BitShiftRowIdx,BitShiftRowIdx];
        BitShiftSource.ColSpan=[dataCurCol,dataCurCol+c2-1];
        BitShiftSource.DialogRefresh=true;


        dataCurCol=dataCurCol+c2;


        DirectionPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:BitShiftDirection');
        DirectionPrompt.Type='text';
        DirectionPrompt.RowSpan=[titleRowIdx,titleRowIdx];
        DirectionPrompt.ColSpan=[dataCurCol,dataCurCol+c2-1];


        DirectionValue=create_widget(source,h,'BitShiftDirection',BitShiftRowIdx,2,2);
        DirectionValue.Name='';
        DirectionValue.RowSpan=[BitShiftRowIdx,BitShiftRowIdx];
        DirectionValue.ColSpan=[dataCurCol,dataCurCol+c2-1];
        DirectionValue.DialogRefresh=true;
        DirectionValue.Visible=true;
        DirectionValue.Enabled=true;


        dataCurCol=dataCurCol+c3;




        BitShiftValuePrompt.Name=DAStudio.message('Simulink:blkprm_prompts:BitShiftNumber');
        BitShiftValuePrompt.Type='text';
        BitShiftValuePrompt.RowSpan=[titleRowIdx,titleRowIdx];
        BitShiftValuePrompt.ColSpan=[dataCurCol,dataCurCol+c3-1];

        BitShiftValue=create_widget(source,h,'BitShiftNumber',BitShiftRowIdx,2,2);
        BitShiftValue.Name='';
        BitShiftValue.RowSpan=[BitShiftRowIdx,BitShiftRowIdx];
        BitShiftValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
        if dlFromDlg
            BitShiftValue.Enabled=true;
            BitShiftValue.Visible=true;
        else
            BitShiftValue.Enabled=false;
            BitShiftValue.Visible=false;
        end


        BinPtValue=create_widget(source,h,'BinPtShiftNumber',BinPtRowIdx,2,2);
        BinPtValue.Name='';
        BinPtValue.RowSpan=[BinPtRowIdx,BinPtRowIdx];
        BinPtValue.ColSpan=[dataCurCol,dataCurCol+c3-1];
        BinPtValue.Enabled=true;
        BinPtValue.Visible=true;

        DiagnosticOORShift=create_widget(source,h,'DiagnosticForOORShift',DiagnosticRowIdx,2,2);

        DiagnosticOORShift.RowSpan=[DiagnosticRowIdx,DiagnosticRowIdx];
        DiagnosticOORShift.ColSpan=[1,dataCurCol-1];

        CheckOORShift=create_widget(source,h,'CheckOORBitShift',CheckRowIdx,2,2);
        CheckOORShift.RowSpan=[CheckRowIdx,CheckRowIdx];
        CheckOORShift.ColSpan=[1,dataCurCol];
        if dlFromDlg
            CheckOORShift.Enabled=false;
            CheckOORShift.Visible=false;
        else
            CheckOORShift.Enabled=true;
            CheckOORShift.Visible=true;
        end


        dataMaxCol=dataCurCol;


        rowIdx=CheckRowIdx+1;

        rowIdx=rowIdx+1;



        dataGroup.Name='';
        dataGroup.Type='group';
        dataGroup.RowSpan=[titleRowIdx,BinPtRowIdx];
        dataGroup.ColSpan=[1,dataMaxCol];
        dataGroup.LayoutGrid=[...
        dataGroup.RowSpan(2)-dataGroup.RowSpan(1)+1...
        ,dataGroup.ColSpan(2)-dataGroup.ColSpan(1)+1];
        dataGroup.ColStretch=[zeros(1,(dataMaxCol-1)),1];

        dataGroup.Items={sP...
        ,BitShiftPrompt...
        ,BinPtPrompt...
        ,srcPrompt...
        ,BitShiftValuePrompt...
        ,BitShiftSource...
        ,DirectionPrompt...
        ,DirectionValue...
        ,BitShiftValue...
        ,BinPtValue...
        };


        algGroup.Name='';
        algGroup.Type='group';
        algGroup.RowSpan=[DiagnosticRowIdx,CheckRowIdx];
        algGroup.ColSpan=[1,dataMaxCol];
        algGroup.LayoutGrid=[...
        algGroup.RowSpan(2)-algGroup.RowSpan(1)+1...
        ,algGroup.ColSpan(2)-algGroup.ColSpan(1)+1];
        algGroup.ColStretch=ones(1,dataMaxCol);

        algGroup.Items={...
DiagnosticOORShift...
        ,CheckOORShift...
        };



        spacer.Name='';
        spacer.Type='text';
        spacer.RowSpan=[rowIdx,rowIdx];
        spacer.ColSpan=[1,dataMaxCol];

        thisTab.Items={dataGroup...
        ,algGroup...
        ,spacer};

        thisTab.Name=DAStudio.message('Simulink:dialog:DataAlgorithm');
        thisTab.LayoutGrid=[rowIdx,dataMaxCol];
        thisTab.ColStretch=ones(1,dataMaxCol);
        thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];

