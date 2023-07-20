function dlgStruct=lookup_nd_ddg(source,h)








    descTxt.Name=h.BlockDescription;
    descTxt.Type='text';
    descTxt.WordWrap=true;

    descGrp.Name='Lookup Table (n-D)';
    descGrp.Type='group';
    descGrp.Items={descTxt};
    descGrp.RowSpan=[1,1];
    descGrp.ColSpan=[1,1];


    paramGrp.Name=DAStudio.message('Simulink:dialog:Parameters');
    paramGrp.Type='tab';
    paramGrp.RowSpan=[2,2];
    paramGrp.ColSpan=[1,1];
    paramGrp.Source=h;

    paramGrp.Tabs={};
    maxNumParameterPorts=3;
    paramGrp.Tabs{end+1}=get_table_and_breakpoints_tab(source,h,maxNumParameterPorts);
    paramGrp.Tabs{end+1}=get_algorithm_tab(source,h);
    paramGrp.Tabs{end+1}=get_data_type_tab(source,h,maxNumParameterPorts);




    dlgStruct.DialogTitle=getString(message('Simulink:dialog:BlockParameters',strrep(h.Name,sprintf('\n'),' ')));
    dlgStruct.DialogTag='LookupND';
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
    dlgStruct.CloseArgs={'%dialog'};


    [~,isLocked]=source.isLibraryBlock(h);
    if isLocked
        dlgStruct.DisableDialog=1;
    else
        dlgStruct.DisableDialog=0;
    end

end


function[numDimPrompt,numDimValue]=get_NumberOfTableDimensions(source,h,layoutRow)

    [numDimPrompt,numDimValue]=create_widget(source,h,'NumberOfTableDimensions',...
    layoutRow,1,1);
    numDimValue.Type='combobox';
    numDimValue.Entries={'1','2','3','4'};
    numDimValue.Editable=1;
    numDimValue.DialogRefresh=true;
    numDimValue.ColSpan=[2,3];

end

function[aPanel,layoutRow]=get_LUTSpecifications(source,h,layoutRow,aPanel)


    layoutRow=layoutRow+1;
    [dataSepcificationPrompt,dataSpecification]=create_widget(source,h,'DataSpecification',layoutRow,1,1);
    dataSepcificationPrompt.Type='text';
    dataSepcificationPrompt.Visible=true;
    dataSepcificationPrompt.Enabled=true;
    dataSpecification.RowSpan=[layoutRow,layoutRow];
    dataSpecification.ColSpan=[2,3];
    dataSpecification.Visible=true;







    dataSpecification.DialogRefresh=true;

    isLookupTableObject=isLookupTableObjectFormat(h);


    [lutObjectPrompt,lutObjectValue]=create_widget(source,h,'LookupTableObject',...
    layoutRow,1,1);
    lutObjectPrompt.Visible=isLookupTableObject;
    lutObjectPrompt.Enabled=isLookupTableObject;
    lutObjectPrompt.RowSpan=[layoutRow,layoutRow];
    lutObjectPrompt.ColSpan=[4,4];
    lutObjectValue.Visible=isLookupTableObject;
    lutObjectValue.Enabled=isEditValueWidgetEnabled(source,h,'LookupTableObject',isLookupTableObject,lutObjectValue.Type);
    lutObjectValue.RowSpan=[layoutRow,layoutRow];
    lutObjectValue.ColSpan=[5,6];
    lutObjectValue.DialogRefresh=true;
    aPanel.Items={aPanel.Items{1:end},dataSepcificationPrompt,dataSpecification,lutObjectValue,lutObjectPrompt};

    layoutRow=layoutRow+1;


    [BpSpecificationPrompt,BpSpecification]=create_widget(source,h,'BreakpointsSpecification',layoutRow,1,2);
    BpSpecificationPrompt.Visible=~isLookupTableObject;
    BpSpecificationPrompt.Enabled=~isLookupTableObject;
    BpSpecification.ColSpan=[2,3];
    BpSpecification.Visible=~isLookupTableObject;








    BpSpecification.Enabled=BpSpecification.Enabled&&~isLookupTableObject;
    BpSpecification.DialogRefresh=true;

    aPanel.Items={aPanel.Items{1:end},BpSpecificationPrompt,BpSpecification};
end


function[aPanel,layoutRow,tableFromDialog]=constructTable(source,h,layoutRow,isLUTObjectFormat,aPanel)

    maxCol=6;

    layoutRow=layoutRow+1;


    valueLabelforTable.Name=DAStudio.message('Simulink:blkprm_prompts:ParamValueLabelId');
    valueLabelforTable.ColSpan=[3,3];





    valueLabelforTable.RowSpan=[layoutRow,layoutRow];
    valueLabelforTable.Type='text';
    valueLabelforTable.Visible=~isLUTObjectFormat;
    valueLabelforTable.Enabled=~isLUTObjectFormat;

    layoutRow=layoutRow+1;


    [tableDataValuePromptLabel,tableValues]=create_widget(source,h,'Table',layoutRow,2,2);


    tableDataValuePromptLabel.Visible=~isLUTObjectFormat;
    tableDataValuePromptLabel.Enabled=~isLUTObjectFormat;


    [tableSrcPrompt,tableSource]=create_widget(source,h,'TableSource',layoutRow,2,2);
    tableSrcPrompt.Name=DAStudio.message('Simulink:blkprm_prompts:ParamSourceLabelId');
    tableSrcPrompt.RowSpan=[layoutRow-1,layoutRow-1];
    tableSrcPrompt.ColSpan=[2,2];
    tableSrcPrompt.Visible=~isLUTObjectFormat;
    tableSrcPrompt.Enabled=~isLUTObjectFormat;

    tableSource.RowSpan=[layoutRow,layoutRow];
    tableSource.ColSpan=[2,2];
    tableSource.DialogRefresh=true;
    tableSource.Visible=~isLUTObjectFormat;
    tableSource.Enabled=tableSource.Enabled&&~isLUTObjectFormat;


    tableFromDialog=isLUTObjectFormat||strcmp(h.TableSource,'Dialog');
    if tableFromDialog
        tableValues.Visible=~isLUTObjectFormat;
        tableValues.Enabled=isEditValueWidgetEnabled(source,h,'Table',~isLUTObjectFormat,tableValues.Type);
    else
        tableValues='';
        tableValues.Type='edit';
        tableValues.Visible=~isLUTObjectFormat;
        tableValues.Enabled=false;
    end

    tableValues.Name='';
    tableValues.RowSpan=[layoutRow,layoutRow];
    tableValues.ColSpan=[3,maxCol];
    tableValues.DialogRefresh=true;

    layoutRow=layoutRow+1;


    aPanel.Items={aPanel.Items{1:end},valueLabelforTable,tableDataValuePromptLabel,tableValues...
    ,tableSrcPrompt,tableSource};

end

function[aPanel,layoutRow,allBpFromDialog]=constructBreakpoints(source,h,numberOfTableRows,...
    maxNumParameterPorts,layoutRow,isLUTObjectFormat,isEvenlySpacingFormat,maxCol,aPanel)



    allBpFromDialog=true;


    if~isEvenlySpacingFormat

        [aPanel,layoutRow,allBpFromDialog]=constructExplictFormatBreakpoints(source,h,numberOfTableRows,...
        maxNumParameterPorts,layoutRow,isLUTObjectFormat,isEvenlySpacingFormat,maxCol,allBpFromDialog,aPanel);

    else

        [aPanel,layoutRow]=constructEvenSpaingFormatBreakpoints(source,h,numberOfTableRows,...
        layoutRow,isLUTObjectFormat,isEvenlySpacingFormat,aPanel);

    end

    layoutRow=layoutRow+2;

end

function[aPanel,layoutRow,allBpFromDialog]=constructExplictFormatBreakpoints(source,h,numberOfTableRows,...
    maxNumParameterPorts,layoutRow,isLUTObjectFormat,isEvenlySpacingFormat,maxCol,allBpFromDialog,aPanel)

    layoutRow=layoutRow+1;

    for i=1:numberOfTableRows

        if i<=maxNumParameterPorts

            bpParam=['BreakpointsForDimension',num2str(i)];
            [bpPrompt,bpValues]=create_widget(source,h,bpParam,layoutRow,2,2);


            bpPrompt.Name=DAStudio.message('Simulink:dialog:BreakPointsTypePrompt',i);
            bpPrompt.Visible=~isLUTObjectFormat;
            bpPrompt.Enabled=~isLUTObjectFormat;



            bpSourceParam=['BreakpointsForDimension',num2str(i),'Source'];
            [BpSourcePrompt,BpSource]=create_widget(source,h,bpSourceParam,layoutRow,2,2);
            BpSourcePrompt.Name=DAStudio.message('Simulink:blkprm_prompts:ParamSourceLabelId');
            BpSourcePrompt.RowSpan=[layoutRow-1,layoutRow-1];
            BpSourcePrompt.ColSpan=[2,2];


            BpSourcePrompt.Visible=false;
            BpSourcePrompt.Enabled=false;

            BpSource.RowSpan=[layoutRow,layoutRow];
            BpSource.ColSpan=[2,2];
            BpSource.Visible=~isLUTObjectFormat&&~isEvenlySpacingFormat;
            BpSource.Enabled=BpSource.Enabled&&~isLUTObjectFormat&&~isEvenlySpacingFormat;
            BpSource.DialogRefresh=true;


            bpFromDialog=isLUTObjectFormat||isEvenlySpacingFormat||strcmp(h.get(bpSourceParam),'Dialog');
            if bpFromDialog
                bpValues.Enabled=isEditValueWidgetEnabled(source,h,bpParam,~isLUTObjectFormat&&~isEvenlySpacingFormat,bpValues.Type);
                bpValues.Visible=~isLUTObjectFormat&&~isEvenlySpacingFormat;
            else
                bpValues='';
                bpValues.Type='edit';
                bpValues.Enabled=false;
                bpValues.Visible=~isLUTObjectFormat&&~isEvenlySpacingFormat;
            end

            bpValues.Name='';
            bpValues.RowSpan=[layoutRow,layoutRow];
            bpValues.ColSpan=[3,maxCol];
            bpValues.DialogRefresh=true;

            aPanel.Items={aPanel.Items{1:end},bpPrompt,bpValues,BpSource,BpSourcePrompt};
        else
            bpParam=['BreakpointsForDimension',num2str(i)];
            [bpPrompt,bpValues]=create_widget(source,h,bpParam,layoutRow,1,maxCol-1);
            bpPrompt.Name=DAStudio.message('Simulink:dialog:BreakPointsTypePrompt',i);
            bpPrompt.Enabled=~isLUTObjectFormat;
            bpPrompt.Visible=~isLUTObjectFormat;
            bpValues.Enabled=isEditValueWidgetEnabled(source,h,bpParam,~isLUTObjectFormat&&~isEvenlySpacingFormat,bpValues.Type);
            bpValues.Visible=~isLUTObjectFormat&&~isEvenlySpacingFormat;
            bpValues.DialogRefresh=true;

            aPanel.Items={aPanel.Items{1:end},bpPrompt,bpValues};
        end
        layoutRow=layoutRow+1;
        allBpFromDialog=allBpFromDialog&&bpFromDialog;
    end

end

function[aPanel,layoutRow]=constructEvenSpaingFormatBreakpoints(source,h,numberOfTableRows,...
    layoutRow,isLUTObjectFormat,isEvenlySpacingFormat,aPanel)








    evenSpacingFormatPanel.Type='panel';
    evenSpacingFormatPanel.RowSpan=[layoutRow,layoutRow+numberOfTableRows+1];

    maxCol=4;
    evenSpacingFormatPanel.ColSpan=[1,maxCol];
    evenSpacingFormatPanel.LayoutGrid=[numberOfTableRows+1,maxCol];
    evenSpacingFormatPanel.RowStretch=[0,ones(1,maxCol-1)];
    evenSpacingFormatPanel.ColStretch=[0,0,0,0];

    layoutRow=layoutRow+1;

    bp0Label.Name=DAStudio.message('Simulink:blkprm_prompts:BreakpointsFirstPoint');
    bp0Label.RowSpan=[layoutRow,layoutRow];
    bp0Label.ColSpan=[2,2];
    bp0Label.Type='text';
    bp0Label.Visible=~isLUTObjectFormat&&isEvenlySpacingFormat;
    bp0Label.Buddy='BreakpointsForDimension1FirstPoint';


    evenSpaceLabel1.Name=DAStudio.message('Simulink:blkprm_prompts:BreakpointsSpacing');
    evenSpaceLabel.Name=evenSpaceLabel1.Name;
    evenSpaceLabel.RowSpan=[layoutRow,layoutRow];
    evenSpaceLabel.ColSpan=[3,3];
    evenSpaceLabel.Type='text';
    evenSpaceLabel.Visible=~isLUTObjectFormat&&isEvenlySpacingFormat;
    evenSpaceLabel.Buddy='BreakpointsForDimension1Spacing';



    evenSpacingFormatPanel.Items={bp0Label,evenSpaceLabel};

    layoutRow=layoutRow+1;

    for i=1:numberOfTableRows


        bpParam=['BreakpointsForDimension',num2str(i)];
        [bpPrompt,~]=create_widget(source,h,bpParam,layoutRow,1,maxCol-1);
        bpPrompt.Name=DAStudio.message('Simulink:dialog:BreakPointsTypePrompt',i);
        bpPrompt.Enabled=~isLUTObjectFormat;
        bpPrompt.Visible=~isLUTObjectFormat;





        bpPrompt.MinimumSize=[172,10];



        bpZeroParam=['BreakpointsForDimension',num2str(i),'FirstPoint'];
        [bpZeroLabel,bpZeroValue]=create_widget(source,h,bpZeroParam,layoutRow,2,2);
        bpZeroValue.Enabled=isEditValueWidgetEnabled(source,h,bpZeroParam,~isLUTObjectFormat&&isEvenlySpacingFormat,bpZeroValue.Type);
        bpZeroValue.Visible=~isLUTObjectFormat&&isEvenlySpacingFormat;
        bpZeroValue.DialogRefresh=true;
        bpZeroValue.ColSpan=[2,2];




        bpZeroLabel.Visible=false;


        bpSpaceParam=['BreakpointsForDimension',num2str(i),'Spacing'];
        [bpSpaceLabel,bpSpaceValue]=create_widget(source,h,bpSpaceParam,layoutRow,3,3);
        bpSpaceValue.Enabled=isEditValueWidgetEnabled(source,h,bpSpaceParam,~isLUTObjectFormat&&isEvenlySpacingFormat,bpSpaceValue.Type);
        bpSpaceValue.Visible=~isLUTObjectFormat&&isEvenlySpacingFormat;
        bpSpaceValue.DialogRefresh=true;
        bpSpaceValue.ColSpan=[3,3];




        bpSpaceLabel.Visible=false;

        layoutRow=layoutRow+1;

        evenSpacingFormatPanel.Items={evenSpacingFormatPanel.Items{1:end},bpPrompt,bpZeroValue,bpSpaceValue};

    end

    aPanel.Items={aPanel.Items{1:end},evenSpacingFormatPanel};

end


function thisTab=get_table_and_breakpoints_tab(source,h,maxNumParameterPorts)


    numTabDims=get_num_dims(h);


    layoutRow=1;
    layoutPrompt=1;
    layoutValue=3;
    layoutCols=layoutPrompt+layoutValue;
    maxCol=6;


    aPanel.Type='panel';
    aPanel.RowSpan=[layoutRow,layoutRow+numTabDims+2+2+2];
    aPanel.ColSpan=[1,maxCol];
    aPanel.LayoutGrid=[numTabDims+1+2,maxCol];
    aPanel.RowStretch=[0,ones(1,maxCol-1)];


    [numDimPrompt,numDimValue]=get_NumberOfTableDimensions(source,h,layoutRow);
    aPanel.Items={numDimPrompt,numDimValue};


    [aPanel,layoutRow]=get_LUTSpecifications(source,h,layoutRow,aPanel);


    isLookupTableObject=isLookupTableObjectFormat(h);
    [aPanel,layoutRow,tableFromDialog]=constructTable(source,h,layoutRow,isLookupTableObject,aPanel);


    isEvenlySpacingFormat=(strcmp(h.BreakpointsSpecification,'Even spacing'));
    [aPanel,layoutRow,allBpFromDialog]=constructBreakpoints(source,h,numTabDims,maxNumParameterPorts,...
    layoutRow,isLookupTableObject,isEvenlySpacingFormat,maxCol,aPanel);

    if(~isLookupTableObject)
        aPanel.ColStretch=[0,0,0,1,0,0];
    else
        aPanel.ColStretch=[0,0,0,0,1,0];
    end


    layoutRow=layoutRow+2;
    lutEditorEditButton.Name=DAStudio.message('Simulink:dialog:EditButton');
    lutEditorEditButton.Type='pushbutton';
    lutEditorEditButton.RowSpan=[layoutRow,layoutRow];
    lutEditorEditButton.ColSpan=[1,1];
    lutEditorEditButton.MatlabMethod='luteditorddg_cb';
    lutEditorEditButton.MatlabArgs={'%dialog',h};
    lutEditorEditButton.ToolTip=DAStudio.message('Simulink:dialog:EditButtonTip');
    lutEditorEditButton.Enabled=tableFromDialog&&allBpFromDialog;
    lutEditorEditButton.Visible=tableFromDialog&&allBpFromDialog;

    layoutRow=layoutRow+1;


    if slfeature('HideSampleTimeWidgetWithDefaultValue')>0
        ts=Simulink.SampleTimeWidget.getSampleTimeWidget('SampleTime',-1,h.SampleTime,...
        '','',source);
        ts.RowSpan=[layoutRow,layoutRow];
        ts.ColSpan=[1,3];
    else
        [tsPrompt,tsValue]=create_widget(source,h,'SampleTime',layoutRow,layoutPrompt,1);
    end


    layoutRow=layoutRow+1;
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[layoutRow,layoutRow];
    spacer.ColSpan=[1,layoutCols];


    thisTab.Name=DAStudio.message('Simulink:dialog:TableAndBreakpointsTab');
    if slfeature('HideSampleTimeWidgetWithDefaultValue')>0
        thisTab.Items={aPanel,lutEditorEditButton,ts,spacer};
    else
        thisTab.Items={aPanel,lutEditorEditButton,tsPrompt,tsValue,spacer};
    end


    thisTab.LayoutGrid=[layoutRow,layoutCols];
    thisTab.ColStretch=[0,1,1,1,0];
    thisTab.RowStretch=[zeros(1,(layoutRow-1)),1];


end


function thisTab=get_data_type_tab(source,h,maxNumParameterPorts)

    numTabDims=get_num_dims(h);

    extraDTStr=3;
    if(strcmp(h.InterpMethod,'Flat')||...
        strcmp(h.InterpMethod,'Nearest')||...
        strcmp(h.InterpMethod,'Above')||...
        strcmp(h.InterpMethod,'Akima spline'))

        extraDTStr=1;
    end

    if strcmp(h.InterpMethod,'Linear Lagrange')

        extraDTStr=2;
    end


    isLookupTableObject=isLookupTableObjectFormat(h);


    tableDTStr=getNumTableUDTs(h,isLookupTableObject);


    [bpDTStr,bpPrmIdxRequiringUDT]=getNumBreakpointsUDTs(h,isLookupTableObject,numTabDims,maxNumParameterPorts);

    numDataTypeStrs=tableDTStr+bpDTStr+extraDTStr;


    udtSpecs=cell(1,numDataTypeStrs);


    idx=1;
    for paramIdx=1:tableDTStr
        udtSpecs{idx}=get_data_type_specs(source,h,idx-1);
        idx=idx+1;
    end


    for paramIdx=1:numTabDims
        if(bpPrmIdxRequiringUDT(paramIdx))
            udtSpecs{idx}=get_data_type_specs(source,h,bpPrmIdxRequiringUDT(paramIdx));
            idx=idx+1;
        end
    end


    if(extraDTStr==3)

        udtSpecs{end-2}=get_data_type_specs(source,h,-1);

        udtSpecs{end-1}=get_data_type_specs(source,h,-2);
    elseif(extraDTStr==2)

        udtSpecs{end-1}=get_data_type_specs(source,h,-1);
    end


    udtSpecs{end}=get_data_type_specs(source,h,-3);

    [orderedWidgets,maxRows,maxCols]=lut_create_data_type_widgets(source,h,udtSpecs);


    layoutPrompt=1;
    layoutValue=1;

    rowIdx=maxRows+1;

    [irPriority_Prompt,irPriority_Value]=create_widget(source,h,'InternalRulePriority',rowIdx,2,2);
    irPriority_Prompt.RowSpan=[rowIdx,rowIdx];
    irPriority_Prompt.ColSpan=[1,1];

    irPriority_Value.RowSpan=[rowIdx,rowIdx];
    irPriority_Value.ColSpan=[2,2];





    showIrPriority=true;
    if strcmp(h.InterpMethod,'Linear Lagrange')||strcmp(h.InterpMethod,'Akima spline')||strcmp(h.InterpMethod,'Cubic spline')
        showIrPriority=false;
    end

    irPriority_Prompt.Visible=showIrPriority;
    irPriority_Prompt.Enabled=showIrPriority;
    irPriority_Value.Visible=showIrPriority;


    irPriority_Value.Enabled=irPriority_Value.Enabled&&showIrPriority;

    rowIdx=rowIdx+1;

    dtInputSameDT=create_widget(source,h,'InputSameDT',...
    rowIdx,layoutPrompt,layoutValue);
    dtInputSameDT.Visible=isNeitherCubicNorAlima(h);
    dtInputSameDT.Enabled=dtInputSameDT.Enabled&&isNeitherCubicNorAlima(h);

    rowIdx=rowIdx+1;
    lockOutScaleValue=create_widget(source,h,'LockScale',...
    rowIdx,layoutPrompt,layoutValue+1);
    lockOutScaleValue.Visible=~strcmp(h.InterpMethod,'Akima spline')&&~strcmp(h.InterpMethod,'Cubic spline');
    lockOutScaleValue.Enabled=lockOutScaleValue.Enabled&&isNeitherCubicNorAlima(h);

    rowIdx=rowIdx+1;
    [roundPrompt,roundValue]=create_widget(source,h,'RndMeth',...
    rowIdx,layoutPrompt,layoutValue);
    roundPrompt.Visible=isNeitherCubicNorAlima(h);
    roundPrompt.Enabled=isNeitherCubicNorAlima(h);

    roundValue.Visible=isNeitherCubicNorAlima(h);
    roundValue.Enabled=roundValue.Enabled&&isNeitherCubicNorAlima(h);

    rowIdx=rowIdx+1;
    saturate=create_widget(source,h,'SaturateOnIntegerOverflow',...
    rowIdx,layoutPrompt,layoutValue);
    saturate.Visible=isNeitherCubicNorAlima(h);
    saturate.Enabled=saturate.Enabled&&isNeitherCubicNorAlima(h);

    rowIdx=rowIdx+1;
    spacer.Name='';

    spacer.Type='text';
    spacer.RowSpan=[rowIdx,rowIdx];
    spacer.ColSpan=[1,1];

    thisTab.Items=[...
orderedWidgets...
    ,{irPriority_Prompt...
    ,irPriority_Value...
    ,dtInputSameDT...
    ,lockOutScaleValue...
    ,roundPrompt,roundValue...
    ,saturate...
    ,spacer...
    }];

    thisTab.Name=DAStudio.message('Simulink:dialog:DataTypesTab');

    thisTab.LayoutGrid=[rowIdx,maxCols+1];
    thisTab.ColStretch=[0,1,1,1,1,0];
    thisTab.RowStretch=[zeros(1,(rowIdx-1)),1];



end

function tableDTStr=getNumTableUDTs(h,isLookupTableObject)
    tableDTStr=0;
    if~isLookupTableObject&&strcmp(h.TableSource,'Dialog')
        tableDTStr=1;
    end
end

function[bpDTStr,bpPrmIdxRequiringUDT]=getNumBreakpointsUDTs(h,isLookupTableObject,numTabDims,maxNumParameterPorts)


    bpDTStr=0;

    bpPrmIdxRequiringUDT=zeros(1,numTabDims);

    if~isLookupTableObject
        isEvenlySpacingFormat=(strcmp(h.BreakpointsSpecification,'Even spacing'));
        if~isEvenlySpacingFormat


            for bpDim=1:numTabDims


                if bpDim<=maxNumParameterPorts
                    bpSourceParam=['BreakpointsForDimension',num2str(bpDim),'Source'];
                    if strcmp(h.get(bpSourceParam),'Dialog')
                        bpPrmIdxRequiringUDT(bpDim)=bpDim;
                        bpDTStr=bpDTStr+1;
                    end
                else
                    bpPrmIdxRequiringUDT(bpDim)=bpDim;
                    bpDTStr=bpDTStr+1;
                end
            end
        else

            bpDTStr=numTabDims;
            bpPrmIdxRequiringUDT=1:numTabDims;
        end
    end

end

function notAkimaOrCubic=isNeitherCubicNorAlima(h)

    notAkimaOrCubic=~strcmp(h.InterpMethod,'Akima spline')&&...
    ~strcmp(h.InterpMethod,'Cubic spline');
end


function thisTab=get_algorithm_tab(source,h)



    layoutRow=0;
    layoutPrompt=3;
    layoutValue=2;
    layoutCols=layoutPrompt+layoutValue;









    layoutRow=layoutRow+1;
    [interpPrompt,interp_popup]=create_widget(source,h,'InterpMethod',...
    layoutRow,layoutPrompt,layoutValue);

    interp_popup.DialogRefresh=true;

    interpPrompt.RowSpan=[layoutRow,layoutRow];
    interpPrompt.ColSpan=[1,2];
    interp_popup.RowSpan=[layoutRow,layoutRow];
    interp_popup.ColSpan=[3,4];


    applyFullPrecision=create_widget(source,h,'ApplyFullPrecisionForLinearInterpolation',...
    layoutRow,layoutPrompt,layoutValue);
    applyFullPrecision.DialogRefresh=true;

    applyFullPrecision.RowSpan=[layoutRow,layoutRow];
    applyFullPrecision.ColSpan=[5,5];

    isLinearPointSlope=strcmp(h.InterpMethod,'Linear point-slope');
    isTable1D=isequal(get_num_dims(h),1);
    isEvenSpacingBp=strcmp(h.BreakpointsSpecification,'Even spacing');
    isClipExtrapolation=strcmp(h.ExtrapMethod,'Clip');

    if(isLinearPointSlope&&isTable1D&&isClipExtrapolation&&~isEvenSpacingBp)
        applyFullPrecision.Visible=true;
    else
        applyFullPrecision.Visible=false;
        applyFullPrecision.Enabled=false;
    end

    layoutRow=layoutRow+1;
    [extrapPrompt,extrap_popup]=create_widget(source,h,'ExtrapMethod',...
    layoutRow,layoutPrompt,layoutValue);

    extrap_popup.DialogRefresh=true;



    interp_popup_entries=h.getPropAllowedValues('InterpMethod',false);
    if~any(strcmpi(h.InterpMethod,interp_popup_entries))
        if(strcmpi(h.InterpMethod,'Above'))
            interp_popup.Entries{end+1}=DAStudio.message('SimulinkBlocks:LookupNd:Above_CB');
            interp_popup_entries{end+1}='Above';



        end
    end

    indexes=7:length(interp_popup_entries);
    isLinearInterp=strcmp(h.InterpMethod,'Linear point-slope')||strcmp(h.InterpMethod,'Linear Lagrange');
    isLinearOrCubicInterp=(isLinearInterp||strcmp(h.InterpMethod,'Cubic spline'));
    isLinearOrCubicOrAkimaInterp=(isLinearInterp||strcmp(h.InterpMethod,'Cubic spline')||strcmp(h.InterpMethod,'Akima spline'));
    if~any(strcmp(h.InterpMethod,interp_popup_entries(indexes)))
        extrapPrompt.Visible=true;
        extrapPrompt.Enabled=true;
        if(isLinearOrCubicInterp)
            extrap_popup.Visible=true;


        else
            extrap_popup.Visible=false;
            extrap_popup.Enabled=false;
        end
    else
        extrapPrompt.Visible=false;
        extrapPrompt.Enabled=false;
        extrap_popup.Visible=false;
        extrap_popup.Enabled=false;
    end

    extrapPrompt.RowSpan=[layoutRow,layoutRow];
    extrapPrompt.ColSpan=[1,2];
    extrap_popup.RowSpan=[layoutRow,layoutRow];
    extrap_popup.ColSpan=[3,4];


    if strcmp(h.InterpMethod,'Akima spline')
        extrap_box.Name=DAStudio.message('SimulinkBlocks:dialog:Akima_CB');
    else
        extrap_box.Name=DAStudio.message('SimulinkBlocks:dialog:Clip_CB');
    end
    extrap_box.Type='text';
    extrap_box.RowSpan=[layoutRow,layoutRow];
    extrap_box.ColSpan=[3,4];
    extrap_box.Enabled=~isLinearOrCubicInterp;
    extrap_box.Visible=~isLinearOrCubicInterp;

    useLastValue=create_widget(source,h,'UseLastTableValue',...
    layoutRow,layoutPrompt,layoutValue);
    useLastValue.DialogRefresh=true;
    useLastValue_dummy.Name=DAStudio.message('Simulink:blkprm_prompts:LookupNdIndexOORInput');
    useLastValue_dummy.Type='checkbox';
    useLastValue_dummy.Tag='UseLastTableValue_Dummy';
    useLastValue_dummy.Value=true;
    useLastValue_dummy.RowSpan=[layoutRow,layoutRow];
    useLastValue_dummy.ColSpan=[5,5];
    useLastValue_dummy.DialogRefresh=true;
    useLastValue_dummy.Enabled=false;
    useLastValue_dummy.Visible=false;



    if(isLinearInterp&&strcmp(h.ExtrapMethod,'Clip'))
        useLastValue.Visible=true;


    elseif(~isLinearOrCubicOrAkimaInterp)
        useLastValue.Visible=false;
        useLastValue.Enabled=false;
        useLastValue_dummy.Visible=true;
    else
        useLastValue.Visible=false;
        useLastValue.Enabled=false;
        useLastValue_dummy.Visible=false;
    end
    useLastValue.RowSpan=[layoutRow,layoutRow];
    useLastValue.ColSpan=[5,5];





    isEvenlySpacingFormat=strcmp(h.BreakpointsSpecification,'Even spacing')&&~isLookupTableObjectFormat(h);


    layoutRow=layoutRow+1;
    [indexSearchPrompt,indexSearchValue]=create_widget(source,h,'IndexSearchMethod',...
    layoutRow,layoutPrompt,layoutValue);

    indexSearchValue.DialogRefresh=true;
    indexSearchPrompt.RowSpan=[layoutRow,layoutRow];
    indexSearchPrompt.ColSpan=[1,2];



    indexSearchValue.RowSpan=[layoutRow,layoutRow];
    indexSearchValue.ColSpan=[3,4];
    indexSearchValue.Visible=~isEvenlySpacingFormat&&~strcmp(h.InterpMethod,'Akima spline');
    indexSearchValue.Enabled=indexSearchValue.Enabled&&~isEvenlySpacingFormat&&~strcmp(h.InterpMethod,'Akima spline');

    evenlySpacedEditBox.Name=DAStudio.message('SimulinkBlocks:dialog:Evenly_spaced_points_CB');
    evenlySpacedEditBox.Type='text';
    evenlySpacedEditBox.RowSpan=[layoutRow,layoutRow];
    evenlySpacedEditBox.ColSpan=[3,4];
    evenlySpacedEditBox.Visible=isEvenlySpacingFormat&&~strcmp(h.InterpMethod,'Akima spline');
    evenlySpacedEditBox.Enabled=isEvenlySpacingFormat&&~strcmp(h.InterpMethod,'Akima spline');


    akimaEditBox.Name=DAStudio.message('SimulinkBlocks:dialog:Linear_search_CB');
    akimaEditBox.Type='text';
    akimaEditBox.RowSpan=[layoutRow,layoutRow];
    akimaEditBox.ColSpan=[3,4];
    akimaEditBox.Visible=strcmp(h.InterpMethod,'Akima spline');
    akimaEditBox.Enabled=strcmp(h.InterpMethod,'Akima spline');

    prevIndexValue=create_widget(source,h,'BeginIndexSearchUsingPreviousIndexResult',...
    layoutRow,layoutPrompt,layoutValue);
    prevIndexValue.RowSpan=[layoutRow,layoutRow];
    prevIndexValue.ColSpan=[5,5];
    if(~strcmp(h.IndexSearchMethod,'Evenly spaced points')&&~isEvenlySpacingFormat&&~strcmp(h.InterpMethod,'Akima spline'))
        prevIndexValue.Visible=true;


    else
        prevIndexValue.Visible=false;
        prevIndexValue.Enabled=false;
    end



    layoutRow=layoutRow+1;
    [rangeErrPrompt,rangeErr_popup]=create_widget(source,h,'DiagnosticForOutOfRangeInput',...
    layoutRow,layoutPrompt,layoutValue);

    rangeErrPrompt.RowSpan=[layoutRow,layoutRow];
    rangeErrPrompt.ColSpan=[1,2];


    rangeErr_popup.RowSpan=[layoutRow,layoutRow];
    rangeErr_popup.ColSpan=[3,4];




    layoutRow=layoutRow+1;
    useOneInputValue=create_widget(source,h,'UseOneInputPortForAllInputData',...
    layoutRow,layoutPrompt,layoutValue);

    isSpline=strcmp(h.InterpMethod,'Cubic spline')||strcmp(h.InterpMethod,'Akima spline');


    layoutRow=layoutRow+1;
    checkRangeInCode=create_widget(source,h,'RemoveProtectionInput',...
    layoutRow,layoutPrompt,layoutValue);

    checkRangeInCode_dummy.Name=DAStudio.message('Simulink:blkprm_prompts:RemoveRangeInCode');
    checkRangeInCode_dummy.Type='checkbox';
    checkRangeInCode_dummy.Value=false;
    checkRangeInCode_dummy.RowSpan=[layoutRow,layoutRow];
    checkRangeInCode_dummy.ColSpan=[1,4];
    checkRangeInCode_dummy.DialogRefresh=true;
    checkRangeInCode_dummy.Enabled=false;
    checkRangeInCode_dummy.Visible=false;



    layoutRow=layoutRow+1;
    tunableTableSize=create_widget(source,h,'SupportTunableTableSize',...
    layoutRow,layoutPrompt,layoutValue);
    tunableTableSize.DialogRefresh=true;

    tunableTableSize_dummy.Name=DAStudio.message('Simulink:blkprm_prompts:LookupNdTunableTableSize');
    tunableTableSize_dummy.Type='checkbox';
    tunableTableSize_dummy.Value=false;
    tunableTableSize_dummy.RowSpan=[layoutRow,layoutRow];
    tunableTableSize_dummy.ColSpan=[1,4];
    tunableTableSize_dummy.DialogRefresh=true;
    tunableTableSize_dummy.Enabled=false;
    tunableTableSize_dummy.Visible=false;


    if(isSpline)
        checkRangeInCode.Enabled=false;
        checkRangeInCode.Visible=false;
        checkRangeInCode_dummy.Visible=true;

        tunableTableSize.Enabled=false;
        tunableTableSize.Visible=false;
        tunableTableSize_dummy.Visible=true;
    else
        checkRangeInCode.Visible=true;


        checkRangeInCode_dummy.Visible=false;
        tunableTableSize_dummy.Visible=false;
    end

    tunableTableSize.Visible=~isSpline&&~isLookupTableObjectFormat(h);
    tunableTableSize.Enabled=tunableTableSize.Enabled&&~isSpline&&~isLookupTableObjectFormat(h);

    layoutRow=layoutRow+1;

    supportTunableTable=~isSpline&&strcmp(h.SupportTunableTableSize,'on');

    maxIndex=create_widget(source,h,'MaximumIndicesForEachDimension',...
    layoutRow,layoutPrompt,layoutValue);
    maxIndex.Visible=supportTunableTable&&~isLookupTableObjectFormat(h);
    maxIndex.Enabled=isEditValueWidgetEnabled(source,h,'MaximumIndicesForEachDimension',supportTunableTable&&~isLookupTableObjectFormat(h),maxIndex.Type);

    layoutRow=layoutRow+1;
    spacer.Name='';
    spacer.Type='text';
    spacer.RowSpan=[layoutRow,layoutRow];
    spacer.ColSpan=[1,layoutCols];



    lastRow=rangeErrPrompt.RowSpan(2);
    lmGroup.Name=DAStudio.message('Simulink:dialog:GroupLookupMethod');
    lmGroup.Type='group';
    lmGroup.RowSpan=[interpPrompt.RowSpan,lastRow];
    lmGroup.ColSpan=[1,layoutCols+1];
    lmGroup.LayoutGrid=[
    lmGroup.RowSpan(2)-lmGroup.RowSpan(1)+1...
    ,lmGroup.ColSpan(2)-lmGroup.ColSpan(1)+2];
    lmGroup.ColStretch=[ones(1,lmGroup.LayoutGrid(2)-1),6];
    rowOffset=interpPrompt.RowSpan(1)-1;
    interp_popup.RowSpan=interp_popup.RowSpan-rowOffset;
    applyFullPrecision.RowSpan=applyFullPrecision.RowSpan-rowOffset;
    extrapPrompt.RowSpan=extrapPrompt.RowSpan-rowOffset;
    extrap_popup.RowSpan=extrap_popup.RowSpan-rowOffset;
    useLastValue.RowSpan=useLastValue.RowSpan-rowOffset;
    extrap_box.RowSpan=extrap_box.RowSpan-rowOffset;
    useLastValue_dummy.RowSpan=useLastValue_dummy.RowSpan-rowOffset;
    indexSearchPrompt.RowSpan=indexSearchPrompt.RowSpan-rowOffset;
    indexSearchValue.RowSpan=indexSearchValue.RowSpan-rowOffset;
    evenlySpacedEditBox.RowSpan=evenlySpacedEditBox.RowSpan-rowOffset;
    akimaEditBox.RowSpan=akimaEditBox.RowSpan-rowOffset;
    prevIndexValue.RowSpan=prevIndexValue.RowSpan-rowOffset;
    rangeErrPrompt.RowSpan=rangeErrPrompt.RowSpan-rowOffset;
    rangeErr_popup.RowSpan=rangeErr_popup.RowSpan-rowOffset;
    lmGroup.Items={interpPrompt,interp_popup,applyFullPrecision...
    ,extrapPrompt,extrap_box,extrap_popup,useLastValue,useLastValue_dummy,indexSearchPrompt,indexSearchValue,evenlySpacedEditBox...
    ,akimaEditBox,prevIndexValue,rangeErrPrompt,rangeErr_popup};
    inGroup.Name=DAStudio.message('Simulink:dialog:GroupInputSettings');
    inGroup.Type='group';
    inGroup.RowSpan=[useOneInputValue.RowSpan(1),useOneInputValue.RowSpan(2)];
    inGroup.ColSpan=[1,layoutCols+1];
    inGroup.LayoutGrid=[
    inGroup.RowSpan(2)-inGroup.RowSpan(1)+1...
    ,inGroup.ColSpan(2)-inGroup.ColSpan(1)+2];
    inGroup.ColStretch=[ones(1,inGroup.LayoutGrid(2)-1),6];
    rowOffset=useOneInputValue.RowSpan(1)-1;
    useOneInputValue.RowSpan=useOneInputValue.RowSpan-rowOffset;
    inGroup.Items={useOneInputValue};
    inGroup.Visible=~strcmp(h.InterpMethod,'Akima spline');
    inGroup.Enabled=~strcmp(h.InterpMethod,'Akima spline');
    cgGroup.Name=DAStudio.message('Simulink:dialog:GroupCodeGeneration');
    cgGroup.Type='group';
    cgGroup.RowSpan=[checkRangeInCode.RowSpan(1),maxIndex.RowSpan(2)];
    cgGroup.ColSpan=[1,layoutCols+1];
    cgGroup.LayoutGrid=[
    cgGroup.RowSpan(2)-cgGroup.RowSpan(1)+1...
    ,cgGroup.ColSpan(2)-cgGroup.ColSpan(1)+2];
    cgGroup.ColStretch=[ones(1,cgGroup.LayoutGrid(2)-1),6];
    rowOffset=checkRangeInCode.RowSpan(1)-1;
    checkRangeInCode_dummy.RowSpan=checkRangeInCode_dummy.RowSpan-rowOffset;
    checkRangeInCode.RowSpan=checkRangeInCode.RowSpan-rowOffset;
    tunableTableSize_dummy.RowSpan=tunableTableSize_dummy.RowSpan-rowOffset;
    tunableTableSize.RowSpan=tunableTableSize.RowSpan-rowOffset;
    maxIndex.RowSpan=maxIndex.RowSpan-rowOffset;
    cgGroup.Items={checkRangeInCode,checkRangeInCode_dummy,tunableTableSize,tunableTableSize_dummy,maxIndex};
    cgGroup.Visible=~isSpline&&~strcmp(h.InterpMethod,'Akima spline');
    cgGroup.Enabled=~isSpline&&~strcmp(h.InterpMethod,'Akima spline');
    thisTab.Items={lmGroup...
    ,inGroup...
    ,cgGroup...
    ,spacer};




    thisTab.Name=DAStudio.message('Simulink:dialog:AlgorithmTab');
    thisTab=apply_grid_and_stretch(thisTab,layoutRow,layoutCols+1);
    thisTab.ColStretch=1-thisTab.ColStretch;
end


function dataTypeSpec=get_data_type_specs(source,h,paramNumber)


    scalingValues='';

    if paramNumber==0
        paramPrefix='Table';
        promptString=h.IntrinsicDialogParameters.Table.Prompt;
        scalingModesSelect='BPt_SB_Best';
        inheritRulesSelect='Out_TD';
        builtinSelect='NumHalf';
        useMinMax=true;
    elseif paramNumber>0&&paramNumber<=30
        paramPrefix=['BreakpointsForDimension',num2str(paramNumber)];
        promptString=DAStudio.message('Simulink:dialog:BreakPointsTypePrompt',paramNumber);
        scalingModesSelect='BPt_SB_Best';
        inheritRulesSelect='CorrIn_IR';
        builtinSelect='NumHalf';
        dataTypeItems.supportsEnumType=true;
        useMinMax=true;
    elseif paramNumber==-3
        paramPrefix='Out';
        promptString=DAStudio.message('Simulink:dialog:OutputTypePrompt');
        scalingModesSelect='BPt_SB_Best';
        inheritRulesSelect='BP_TD_In2';
        builtinSelect='NumHalf';
        useMinMax=true;
        scalingValues='Table';
    elseif paramNumber==-1
        paramPrefix='Fraction';
        promptString=DAStudio.message('Simulink:dialog:FractionTypePrompt');
        scalingModesSelect='BPt';
        inheritRulesSelect='IR';
        builtinSelect='Float';
        useMinMax=false;
        scalingValues='*';
    elseif paramNumber==-2
        paramPrefix='IntermediateResults';
        promptString=DAStudio.message('Simulink:dialog:IntermediateTypePrompt');
        scalingModesSelect='BPt_SB';
        inheritRulesSelect='IR_Out_TDT';
        builtinSelect='Num';
        useMinMax=false;
        scalingValues='*';
    end

    paramName=[paramPrefix,'DataTypeStr'];

    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList(scalingModesSelect);
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    dataTypeItems.inheritRules=Simulink.DataTypePrmWidget.getInheritList(inheritRulesSelect);
    dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinList(builtinSelect);
    if useMinMax
        dataTypeItems.scalingMinTag={[paramPrefix,'Min']};
        dataTypeItems.scalingMaxTag={[paramPrefix,'Max']};
    else
        dataTypeItems.scalingMinTag={};
        dataTypeItems.scalingMaxTag={};
    end
    if isempty(scalingValues)
        dataTypeItems.scalingValueTags={paramPrefix};
    elseif scalingValues(1)~='*'
        dataTypeItems.scalingValueTags={scalingValues};
    else
        dataTypeItems.scalingValueTags={};
    end

    dataTypeSpec.hDlgSource=source;
    dataTypeSpec.dtName=paramName;
    dataTypeSpec.dtPrompt=promptString;
    dataTypeSpec.dtTag=paramName;
    dataTypeSpec.dtVal=h.(paramName);
    dataTypeSpec.customAsstName=false;
    dataTypeSpec.dtaItems=dataTypeItems;

end

function widgetEnabled=isEditValueWidgetEnabled(source,h,propName,widgetEnabled,widgetType)














    assert(strcmp(widgetType,'edit'));




    if~h.isTunableProperty(propName)
        widgetEnabled=widgetEnabled&&~source.isHierarchySimulating;
    end

end


function container=apply_grid_and_stretch(container,layoutRow,layoutCols)

    container.LayoutGrid=[layoutRow,layoutCols];
    container.ColStretch=[ones(1,container.LayoutGrid(2)-1),0];
    container.RowStretch=[zeros(1,container.LayoutGrid(1)-1),1];
end


function numTabDims=get_num_dims(h)
    try
        numTabDims=eval(h.NumberOfTableDimensions);
    catch %#ok<CTCH>



        numTabDims=0;
    end



    if~isscalar(numTabDims)||...
        ~isnumeric(numTabDims)||...
        ~isreal(numTabDims)||...
        numTabDims~=floor(numTabDims)||...
        numTabDims<1||numTabDims>30















        ports=get_param(gcbh,'Ports');
        numTabDims=ports(1);
    end

end


function isLUTObj=isLookupTableObjectFormat(h)
    isLUTObj=strcmp(h.DataSpecification,'Lookup table object');
end



