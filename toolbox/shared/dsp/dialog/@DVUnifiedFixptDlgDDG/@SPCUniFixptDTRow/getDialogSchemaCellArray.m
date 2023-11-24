function[promptWidgets,comboxWidgets,shwBtnWidgets,hdeBtnWidgets,desMinWidgets,desMaxWidgets,dtaGUIWidgets]=getDialogSchemaCellArray(this)

    totNumDTypeRows=length(this);
    allUDTSpecs=cell(1,totNumDTypeRows);

    for ind=1:totNumDTypeRows
        dtRowStruct=this(ind);
        udtPrmStr=strcat(udtGetPrmPrefixFromFixptDTRowStruct(dtRowStruct),'DataTypeStr');
        udtString=dtRowStruct.Block.(udtPrmStr);
        allUDTSpecs{ind}=udtCreateUDTSpecStruct(dtRowStruct,udtString);
    end
    [promptWidgets,comboxWidgets,shwBtnWidgets,hdeBtnWidgets,dtaGUIWidgets]=...
    Simulink.DataTypePrmWidget.getSPCDataTypeWidgets(...
    this(1).Block.getDialogSource,allUDTSpecs,-1,'');

    dtaPrmColIdx=1;
    dtaUDTColIdx=2;
    dtaBtnColIdx=3;
    desMinColIdx=4;
    desMaxColIdx=5;
    desMinWidgets=cell(1,totNumDTypeRows);
    desMaxWidgets=cell(1,totNumDTypeRows);

    for ind=1:totNumDTypeRows

        uDTypeRowIdx=(2*this(ind).Row)-2;
        dtaGUIRowIdx=uDTypeRowIdx+1;

        widgetVisible=this(ind).Visible;

        promptWidgets{ind}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        promptWidgets{ind}.ColSpan=[dtaPrmColIdx,dtaPrmColIdx];
        promptWidgets{ind}.Visible=widgetVisible;


        comboxWidgets{ind}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        comboxWidgets{ind}.ColSpan=[dtaUDTColIdx,dtaUDTColIdx];
        comboxWidgets{ind}.Visible=widgetVisible;


        shwBtnWidgets{ind}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        shwBtnWidgets{ind}.ColSpan=[dtaBtnColIdx,dtaBtnColIdx];
        shwBtnWidgets{ind}.Visible=widgetVisible;
        hdeBtnWidgets{ind}.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
        hdeBtnWidgets{ind}.ColSpan=[dtaBtnColIdx,dtaBtnColIdx];



        prmPromptStr=this(ind).Name;
        prmPrefixStr=this(ind).Prefix;

        if this(ind).HasDesignMin
            desMin.Source=this(ind).Block;
            desMin.Type='edit';
            desMin.Tag=strcat(prmPrefixStr,'Min');
            desMin.ObjectProperty=strcat(prmPrefixStr,'Min');
            desMin.Name=sprintf('%s %s',prmPromptStr,'minimum:');
            desMin.HideName=true;
            desMin.Value=this(ind).DesignMin;
            desMin.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
            desMin.ColSpan=[desMinColIdx,desMinColIdx];
            desMinWidgets{ind}=desMin;
            desMinWidgets{ind}.Visible=widgetVisible;
        end

        if this(ind).HasDesignMax
            desMax.Source=this(ind).Block;
            desMax.Type='edit';
            desMax.Tag=strcat(prmPrefixStr,'Max');
            desMax.ObjectProperty=strcat(prmPrefixStr,'Max');
            desMax.Name=sprintf('%s %s',prmPromptStr,'maximum:');
            desMax.HideName=true;
            desMax.Value=this(ind).DesignMax;
            desMax.RowSpan=[uDTypeRowIdx,uDTypeRowIdx];
            desMax.ColSpan=[desMaxColIdx,desMaxColIdx];
            desMaxWidgets{ind}=desMax;
            desMaxWidgets{ind}.Visible=widgetVisible;
        end


        dtaGUIWidgets{ind}.RowSpan=[dtaGUIRowIdx,dtaGUIRowIdx];
        dtaGUIWidgets{ind}.ColSpan=[1,dtaBtnColIdx];

    end
