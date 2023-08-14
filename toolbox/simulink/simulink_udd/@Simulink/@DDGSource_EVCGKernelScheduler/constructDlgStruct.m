function dlgStruct=constructDlgStruct(this,items,numRows)




    block=this.getBlock;
    rowspan=0;


    descText.Name=block.BlockDescription;
    descText.Type='text';
    descText.WordWrap=true;
    descText.RowSpan=[1,1];
    descText.ColSpan=[1,3];

    rowspan=rowspan+1;
    descGroup.Name=block.BlockType;
    descGroup.Type='group';
    descGroup.Items={descText};
    descGroup.RowSpan=[rowspan,rowspan];
    descGroup.ColSpan=[1,1];
    descGroup.LayoutGrid=[2,3];
    descGroup.RowStretch=[0,0];
    descGroup.ColStretch=[0,0,1];


    rowspan=rowspan+1;
    inputGroup.Type='group';
    inputGroup.Items=items([2,1]);
    inputGroup.LayoutGrid=[numRows(1),3];
    inputGroup.RowStretch=[zeros(1,numRows(1)-1),1];
    inputGroup.ColStretch=[0,0,1];
    inputGroup.RowSpan=[rowspan,rowspan];
    inputGroup.ColSpan=[1,1];
    inputGroup.Source=block;

    rowspan=rowspan+1;
    neighborhoodSize=this.initWidget("NeighborhoodSize",false);
    neighborhoodSize.Tag='_EVCG_Neighborhood_Dimension_';
    neighborhoodSize.RowSpan=[rowspan,rowspan];
    neighborhoodSize.ColSpan=[1,1];

    if slfeature('EVCGNPSSSupportStrideAndProcessingRegion')
        rowspan=rowspan+1;
        stride=this.initWidget("Stride",false);
        stride.Tag='_EVCG_Stride_';
        stride.RowSpan=[rowspan,rowspan];
        stride.ColSpan=[1,1];

        rowspan=rowspan+1;
        processRegionL=this.initWidget("ProcessingOffset",false);
        processRegionL.Tag='_EVCG_Processing_Offset_';
        processRegionL.RowSpan=[rowspan,rowspan];
        processRegionL.ColSpan=[1,1];

        rowspan=rowspan+1;
        processRegionU=this.initWidget("ProcessingWidth",false);
        processRegionU.Tag='_EVCG_Processing_Width_';
        processRegionU.RowSpan=[rowspan,rowspan];
        processRegionU.ColSpan=[1,1];
    end

    rowspan=rowspan+1;
    subsection=this.initWidget("OutputSize",false);
    subsection.Tag='_EVCG_Output_Subsection_';
    subsection.RowSpan=[rowspan,rowspan];
    subsection.ColSpan=[1,1];

    if(subsection.Value~=2)
        rowspan=rowspan+1;
        boundaryMethodsCombobox=this.initWidget('PaddingOption',false);
        boundaryMethodsCombobox.Tag='_Show_Padding_Method_';
        boundaryMethodsCombobox.RowSpan=[rowspan,rowspan];
        boundaryMethodsCombobox.ColSpan=[1,1];

        if(boundaryMethodsCombobox.Value==0)
            rowspan=rowspan+1;
            boundaryConstnatValueEdit=this.initWidget('PaddingConstant',false);
            boundaryConstnatValueEdit.Tag='_EVCG_Padding_Value_';
            boundaryConstnatValueEdit.RowSpan=[rowspan,rowspan];
            boundaryConstnatValueEdit.ColSpan=[1,1];
        end
    end

    rowspan=rowspan+1;
    neighborhoodParamGroup.Type='panel';

    neighborhoodParamGroup.Items={neighborhoodSize};
    if slfeature('EVCGNPSSSupportStrideAndProcessingRegion')
        neighborhoodParamGroup.Items=[neighborhoodParamGroup.Items,stride,processRegionL,processRegionU];
    end
    neighborhoodParamGroup.Items=[neighborhoodParamGroup.Items,subsection];
    if(subsection.Value~=2)
        neighborhoodParamGroup.Items=[neighborhoodParamGroup.Items,boundaryMethodsCombobox];
        if(boundaryMethodsCombobox.Value==0)
            neighborhoodParamGroup.Items=[neighborhoodParamGroup.Items,boundaryConstnatValueEdit];
        end
    end

    neighborhoodParamGroup.RowSpan=[rowspan,rowspan];
    neighborhoodParamGroup.ColSpan=[1,1];
    neighborhoodParamGroup.LayoutGrid=[5,1];




    dlgStruct.DialogTitle=DAStudio.message('Simulink:dialog:ForEachDlgTitle',strrep(block.Name,sprintf('\n'),' '));
    dlgStruct.DialogTag='evcg_ddg';

    if slfeature('EVCGNPSSSupportNonIterSpaceInputs')
        dlgStruct.Items={descGroup,inputGroup,neighborhoodParamGroup};
    else
        dlgStruct.Items={descGroup,neighborhoodParamGroup};
    end

    dlgStruct.LayoutGrid=[rowspan,1];
    dlgStruct.RowStretch=[0,1,zeros(1,rowspan-2)];
    dlgStruct.ColStretch=[1];
    dlgStruct.ShowGrid=false;
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={block.Handle};

    dlgStruct.PreApplyMethod='PreApplyCallback';
    dlgStruct.PreApplyArgs={'%dialog'};
    dlgStruct.PreApplyArgsDT={'handle'};

    dlgStruct.CloseMethod='CloseCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};

    [~,isLocked]=this.isLibraryBlock(block);
    isLibraryLink=any(strcmp(get_param(block.Handle,'LinkStatus'),{'implicit','resolved'}));
    if isLocked||isLibraryLink
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end
