function algorithmparamgroup=getAlgorithmParamsDialogSchema(this)




    if isempty(this.object.Key)||~isprop(this.object,'AlgorithmParams')||...
        isempty(find(strcmp(this.object.Key,{'lookup1D','lookup2D',...
        'lookup3D','lookup4D','lookup5D','lookupND_Direct','prelookup',...
        'interp1D','interp2D','interp3D','interp4D','interp5D','sin','cos','sincos','cexp','atan2'}),1))
        algorithmparamgroup=getEmptyAlgorithmParamGroup();
        return;
    end

    if isTrigAlgorithmNotLookup(this)

        algorithmparamgroup=getEmptyAlgorithmParamGroup();
        return;
    end


    switch this.object.Key

    case{'sin','cos','sincos','cexp','atan2'}

        angleUnit=this.getDialogWidget('Tfldesigner_AngleUnit_AlgoParam');
        angleUnit.RowSpan=[1,1];
        angleUnit.ColSpan=[1,2];



        lookupintrpmodeLbl.Name=DAStudio.message('RTW:tfldesigner:InterpolationText');
        lookupintrpmodeLbl.Type='text';
        lookupintrpmodeLbl.RowSpan=[1,1];
        lookupintrpmodeLbl.ColSpan=[3,3];

        lookupintrpmode=this.getDialogWidget('Tfldesigner_IntrpMethod_AlgoParam');
        lookupintrpmode.RowSpan=[1,1];
        lookupintrpmode.ColSpan=[4,4];
        lookupintrpmodeLbl.Buddy=lookupintrpmode.Tag;
        lookupintrpmodeLbl.Visible=lookupintrpmode.Visible;
        lookupintrpmodeLbl.ToolTip=lookupintrpmode.ToolTip;


        algorithmparampanel.Type='panel';
        algorithmparampanel.LayoutGrid=[5,15];
        algorithmparampanel.RowSpan=[1,4];
        algorithmparampanel.ColSpan=[1,15];
        algorithmparampanel.RowStretch=ones(1,2);
        algorithmparampanel.ColStretch=[zeros(1,14),1];
        algorithmparampanel.Items={angleUnit,lookupintrpmodeLbl,lookupintrpmode};
        algorithmparamgroup.Items={algorithmparampanel};

    case 'prelookup'


        lookupextrpmodeLbl.Name=DAStudio.message('RTW:tfldesigner:ExtrapolationText');
        lookupextrpmodeLbl.Type='text';
        lookupextrpmodeLbl.RowSpan=[1,1];
        lookupextrpmodeLbl.ColSpan=[1,2];

        lookupextrpmode=this.getDialogWidget('Tfldesigner_ExtrpMethod_AlgoParam');
        lookupextrpmode.RowSpan=[1,1];
        lookupextrpmode.ColSpan=[3,4];
        lookupextrpmodeLbl.Buddy=lookupextrpmode.Tag;
        lookupextrpmodeLbl.Visible=lookupextrpmode.Visible;
        lookupextrpmodeLbl.ToolTip=lookupextrpmode.ToolTip;


        lookupintrpmodeLbl.Name=DAStudio.message('RTW:tfldesigner:InterpolationText');
        lookupintrpmodeLbl.Type='text';
        lookupintrpmodeLbl.RowSpan=[1,1];
        lookupintrpmodeLbl.ColSpan=[6,8];

        lookupintrpmode=this.getDialogWidget('Tfldesigner_IntrpMethod_AlgoParam');
        lookupintrpmode.RowSpan=[1,1];
        lookupintrpmode.ColSpan=[9,9];
        lookupintrpmodeLbl.Buddy=lookupintrpmode.Tag;
        lookupintrpmodeLbl.Visible=lookupintrpmode.Visible;
        lookupintrpmodeLbl.ToolTip=lookupintrpmode.ToolTip;


        roundmethodLbl.Name=DAStudio.message('RTW:tfldesigner:RoundMethodText');
        roundmethodLbl.Type='text';
        roundmethodLbl.RowSpan=[2,2];
        roundmethodLbl.ColSpan=[1,2];

        roundmethod=this.getDialogWidget('Tfldesigner_RoundMethod');
        roundmethod.RowSpan=[2,2];
        roundmethod.ColSpan=[3,4];
        roundmethodLbl.Buddy=roundmethod.Tag;
        roundmethodLbl.Visible=roundmethod.Visible;
        roundmethodLbl.ToolTip=roundmethod.ToolTip;


        satMethodLbl.Name=DAStudio.message('RTW:tfldesigner:SatMethodText');
        satMethodLbl.Type='text';
        satMethodLbl.RowSpan=[2,2];
        satMethodLbl.ColSpan=[6,8];

        satMethod=this.getDialogWidget('Tfldesigner_SatMethod');
        satMethod.RowSpan=[2,2];
        satMethod.ColSpan=[9,9];
        satMethodLbl.Buddy=satMethod.Tag;
        satMethodLbl.Visible=satMethod.Visible;
        satMethodLbl.ToolTip=satMethod.ToolTip;


        indexsearchmethodLbl.Name=DAStudio.message('RTW:tfldesigner:IndexSearchMethodText');
        indexsearchmethodLbl.Type='text';
        indexsearchmethodLbl.RowSpan=[3,3];
        indexsearchmethodLbl.ColSpan=[1,2];

        indexsearchmethod=this.getDialogWidget('Tfldesigner_IndexSearchMethod');
        indexsearchmethod.RowSpan=[3,3];
        indexsearchmethod.ColSpan=[3,4];
        indexsearchmethodLbl.Buddy=indexsearchmethod.Tag;
        indexsearchmethodLbl.Visible=indexsearchmethod.Visible;
        indexsearchmethodLbl.ToolTip=indexsearchmethod.ToolTip;


        validIndexreachLastLbl.Name=DAStudio.message('RTW:tfldesigner:ValidIndexMayReachLastText');
        validIndexreachLastLbl.Type='text';
        validIndexreachLastLbl.RowSpan=[3,3];
        validIndexreachLastLbl.ColSpan=[1,2];

        validIndexreachLast=this.getDialogWidget('Tfldesigner_ValidIndexReachLast');
        validIndexreachLast.RowSpan=[3,3];
        validIndexreachLast.ColSpan=[3,4];
        validIndexreachLastLbl.Buddy=validIndexreachLast.Tag;
        validIndexreachLastLbl.Visible=validIndexreachLast.Visible;
        validIndexreachLastLbl.ToolTip=validIndexreachLast.ToolTip;


        removeprotectionLbl.Name=DAStudio.message('RTW:tfldesigner:RemoveProtectionText');
        removeprotectionLbl.Type='text';
        removeprotectionLbl.RowSpan=[3,3];
        removeprotectionLbl.ColSpan=[6,8];

        removeprotection=this.getDialogWidget('Tfldesigner_RemoveProtection');
        removeprotection.RowSpan=[3,3];
        removeprotection.ColSpan=[9,9];
        removeprotectionLbl.Buddy=removeprotection.Tag;
        removeprotectionLbl.Visible=removeprotection.Visible;
        removeprotectionLbl.ToolTip=removeprotection.ToolTip;


        removeprotectionindexLbl.Name=DAStudio.message('RTW:tfldesigner:RemoveProtectionIndexText');
        removeprotectionindexLbl.Type='text';
        removeprotectionindexLbl.RowSpan=[3,3];
        removeprotectionindexLbl.ColSpan=[6,8];

        removeprotectionindex=this.getDialogWidget('Tfldesigner_RemoveProtectionIndex');
        removeprotectionindex.RowSpan=[3,3];
        removeprotectionindex.ColSpan=[9,9];
        removeprotectionindexLbl.Buddy=removeprotectionindex.Tag;
        removeprotectionindexLbl.Visible=removeprotectionindex.Visible;
        removeprotectionindexLbl.ToolTip=removeprotectionindex.ToolTip;


        supporttunabletableLbl.Name=DAStudio.message('RTW:tfldesigner:SupportTunableTableText');
        supporttunabletableLbl.Type='text';
        supporttunabletableLbl.RowSpan=[5,5];
        supporttunabletableLbl.ColSpan=[1,2];

        supporttunabletable=this.getDialogWidget('Tfldesigner_SupportTunableTable');
        supporttunabletable.RowSpan=[5,5];
        supporttunabletable.ColSpan=[3,4];
        supporttunabletableLbl.Buddy=supporttunabletable.Tag;
        supporttunabletableLbl.Visible=supporttunabletable.Visible;
        supporttunabletableLbl.ToolTip=supporttunabletable.ToolTip;


        uselasttablevalueLbl.Name=DAStudio.message('RTW:tfldesigner:UseLastTableValueText');
        uselasttablevalueLbl.Type='text';
        uselasttablevalueLbl.RowSpan=[6,6];
        uselasttablevalueLbl.ColSpan=[1,4];

        uselasttablevalue=this.getDialogWidget('Tfldesigner_UseLastTableValue');
        uselasttablevalue.RowSpan=[6,6];
        uselasttablevalue.ColSpan=[6,6];
        uselasttablevalueLbl.Buddy=uselasttablevalue.Tag;
        uselasttablevalueLbl.Visible=uselasttablevalue.Visible;
        uselasttablevalueLbl.ToolTip=uselasttablevalue.ToolTip;


        uselastbpLbl.Name=DAStudio.message('RTW:tfldesigner:UseLastBreakpointText');
        uselastbpLbl.Type='text';
        uselastbpLbl.RowSpan=[6,6];
        uselastbpLbl.ColSpan=[1,4];

        uselastbp=this.getDialogWidget('Tfldesigner_UseLastBreakpoint');
        uselastbp.RowSpan=[6,6];
        uselastbp.ColSpan=[6,6];
        uselastbpLbl.Buddy=uselastbp.Tag;
        uselastbpLbl.Visible=uselastbp.Visible;
        uselastbpLbl.ToolTip=uselastbp.ToolTip;


        beginsearchusingprevLbl.Name=DAStudio.message('RTW:tfldesigner:BeginIndexSearchUsingPreviousIndexResult');
        beginsearchusingprevLbl.Type='text';
        beginsearchusingprevLbl.RowSpan=[7,7];
        beginsearchusingprevLbl.ColSpan=[1,4];

        beginsearchusingprev=this.getDialogWidget('Tfldesigner_BeginIndexSearchUsingPreviousIndexResult');
        beginsearchusingprev.RowSpan=[7,7];
        beginsearchusingprev.ColSpan=[6,6];
        beginsearchusingprevLbl.Buddy=beginsearchusingprev.Tag;
        beginsearchusingprevLbl.Visible=beginsearchusingprev.Visible;
        beginsearchusingprevLbl.ToolTip=beginsearchusingprev.ToolTip;


        algorithmparampanel.Type='panel';
        algorithmparampanel.LayoutGrid=[5,15];
        algorithmparampanel.RowSpan=[1,4];
        algorithmparampanel.ColSpan=[1,15];
        algorithmparampanel.RowStretch=ones(1,2);
        algorithmparampanel.ColStretch=[zeros(1,14),1];
        algorithmparampanel.Items={lookupintrpmodeLbl,lookupintrpmode,...
        lookupextrpmodeLbl,lookupextrpmode,...
        indexsearchmethodLbl,indexsearchmethod,...
        removeprotectionLbl,removeprotection,...
        removeprotectionindexLbl,removeprotectionindex,...
        satMethodLbl,satMethod,...
        roundmethodLbl,roundmethod,...
        supporttunabletableLbl,supporttunabletable,...
        uselasttablevalueLbl,uselasttablevalue,...
        validIndexreachLastLbl,validIndexreachLast,uselastbpLbl,uselastbp,...
        beginsearchusingprevLbl,beginsearchusingprev};

        algorithmparamgroup.Items={algorithmparampanel};

    case{'lookup1D','lookup2D','lookup3D','lookup4D','lookup5D',...
        'interp1D','interp2D','interp3D','interp4D','interp5D'}


        lookupextrpmodeLbl.Name=DAStudio.message('RTW:tfldesigner:ExtrapolationText');
        lookupextrpmodeLbl.Type='text';
        lookupextrpmodeLbl.RowSpan=[1,1];
        lookupextrpmodeLbl.ColSpan=[1,2];

        lookupextrpmode=this.getDialogWidget('Tfldesigner_ExtrpMethod_AlgoParam');
        lookupextrpmode.RowSpan=[1,1];
        lookupextrpmode.ColSpan=[3,4];
        lookupextrpmodeLbl.Buddy=lookupextrpmode.Tag;
        lookupextrpmodeLbl.Visible=lookupextrpmode.Visible;
        lookupextrpmodeLbl.ToolTip=lookupextrpmode.ToolTip;


        lookupintrpmodeLbl.Name=DAStudio.message('RTW:tfldesigner:InterpolationText');
        lookupintrpmodeLbl.Type='text';
        lookupintrpmodeLbl.RowSpan=[1,1];
        lookupintrpmodeLbl.ColSpan=[6,8];

        lookupintrpmode=this.getDialogWidget('Tfldesigner_IntrpMethod_AlgoParam');
        lookupintrpmode.RowSpan=[1,1];
        lookupintrpmode.ColSpan=[9,9];
        lookupintrpmodeLbl.Buddy=lookupintrpmode.Tag;
        lookupintrpmodeLbl.Visible=lookupintrpmode.Visible;
        lookupintrpmodeLbl.ToolTip=lookupintrpmode.ToolTip;


        roundmethodLbl.Name=DAStudio.message('RTW:tfldesigner:RoundMethodText');
        roundmethodLbl.Type='text';
        roundmethodLbl.RowSpan=[2,2];
        roundmethodLbl.ColSpan=[1,2];

        roundmethod=this.getDialogWidget('Tfldesigner_RoundMethod');
        roundmethod.RowSpan=[2,2];
        roundmethod.ColSpan=[3,4];
        roundmethodLbl.Buddy=roundmethod.Tag;
        roundmethodLbl.Visible=roundmethod.Visible;
        roundmethodLbl.ToolTip=roundmethod.ToolTip;


        satMethodLbl.Name=DAStudio.message('RTW:tfldesigner:SatMethodText');
        satMethodLbl.Type='text';
        satMethodLbl.RowSpan=[2,2];
        satMethodLbl.ColSpan=[6,8];

        satMethod=this.getDialogWidget('Tfldesigner_SatMethod');
        satMethod.RowSpan=[2,2];
        satMethod.ColSpan=[9,9];
        satMethodLbl.Buddy=satMethod.Tag;
        satMethodLbl.Visible=satMethod.Visible;
        satMethodLbl.ToolTip=satMethod.ToolTip;


        indexsearchmethodLbl.Name=DAStudio.message('RTW:tfldesigner:IndexSearchMethodText');
        indexsearchmethodLbl.Type='text';
        indexsearchmethodLbl.RowSpan=[3,3];
        indexsearchmethodLbl.ColSpan=[1,2];

        indexsearchmethod=this.getDialogWidget('Tfldesigner_IndexSearchMethod');
        indexsearchmethod.RowSpan=[3,3];
        indexsearchmethod.ColSpan=[3,4];
        indexsearchmethodLbl.Buddy=indexsearchmethod.Tag;
        indexsearchmethodLbl.Visible=indexsearchmethod.Visible;
        indexsearchmethodLbl.ToolTip=indexsearchmethod.ToolTip;


        validIndexreachLastLbl.Name=DAStudio.message('RTW:tfldesigner:ValidIndexMayReachLastText');
        validIndexreachLastLbl.Type='text';
        validIndexreachLastLbl.RowSpan=[3,3];
        validIndexreachLastLbl.ColSpan=[1,2];

        validIndexreachLast=this.getDialogWidget('Tfldesigner_ValidIndexReachLast');
        validIndexreachLast.RowSpan=[3,3];
        validIndexreachLast.ColSpan=[3,4];
        validIndexreachLastLbl.Buddy=validIndexreachLast.Tag;
        validIndexreachLastLbl.Visible=validIndexreachLast.Visible;
        validIndexreachLastLbl.ToolTip=validIndexreachLast.ToolTip;


        removeprotectionLbl.Name=DAStudio.message('RTW:tfldesigner:RemoveProtectionText');
        removeprotectionLbl.Type='text';
        removeprotectionLbl.RowSpan=[3,3];
        removeprotectionLbl.ColSpan=[6,8];

        removeprotection=this.getDialogWidget('Tfldesigner_RemoveProtection');
        removeprotection.RowSpan=[3,3];
        removeprotection.ColSpan=[9,9];
        removeprotectionLbl.Buddy=removeprotection.Tag;
        removeprotectionLbl.Visible=removeprotection.Visible;
        removeprotectionLbl.ToolTip=removeprotection.ToolTip;


        removeprotectionindexLbl.Name=DAStudio.message('RTW:tfldesigner:RemoveProtectionIndexText');
        removeprotectionindexLbl.Type='text';
        removeprotectionindexLbl.RowSpan=[3,3];
        removeprotectionindexLbl.ColSpan=[6,8];

        removeprotectionindex=this.getDialogWidget('Tfldesigner_RemoveProtectionIndex');
        removeprotectionindex.RowSpan=[3,3];
        removeprotectionindex.ColSpan=[9,9];
        removeprotectionindexLbl.Buddy=removeprotectionindex.Tag;
        removeprotectionindexLbl.Visible=removeprotectionindex.Visible;
        removeprotectionindexLbl.ToolTip=removeprotectionindex.ToolTip;


        supporttunabletableLbl.Name=DAStudio.message('RTW:tfldesigner:SupportTunableTableText');
        supporttunabletableLbl.Type='text';
        supporttunabletableLbl.RowSpan=[5,5];
        supporttunabletableLbl.ColSpan=[1,2];

        supporttunabletable=this.getDialogWidget('Tfldesigner_SupportTunableTable');
        supporttunabletable.RowSpan=[5,5];
        supporttunabletable.ColSpan=[3,4];
        supporttunabletableLbl.Buddy=supporttunabletable.Tag;
        supporttunabletableLbl.Visible=supporttunabletable.Visible;
        supporttunabletableLbl.ToolTip=supporttunabletable.ToolTip;


        uselasttablevalueLbl.Name=DAStudio.message('RTW:tfldesigner:UseLastTableValueText');
        uselasttablevalueLbl.Type='text';
        uselasttablevalueLbl.RowSpan=[6,6];
        uselasttablevalueLbl.ColSpan=[1,4];

        uselasttablevalue=this.getDialogWidget('Tfldesigner_UseLastTableValue');
        uselasttablevalue.RowSpan=[6,6];
        uselasttablevalue.ColSpan=[6,6];
        uselasttablevalueLbl.Buddy=uselasttablevalue.Tag;
        uselasttablevalueLbl.Visible=uselasttablevalue.Visible;
        uselasttablevalueLbl.ToolTip=uselasttablevalue.ToolTip;


        uselastbpLbl.Name=DAStudio.message('RTW:tfldesigner:UseLastBreakpointText');
        uselastbpLbl.Type='text';
        uselastbpLbl.RowSpan=[6,6];
        uselastbpLbl.ColSpan=[1,4];

        uselastbp=this.getDialogWidget('Tfldesigner_UseLastBreakpoint');
        uselastbp.RowSpan=[6,6];
        uselastbp.ColSpan=[6,6];
        uselastbpLbl.Buddy=uselastbp.Tag;
        uselastbpLbl.Visible=uselastbp.Visible;
        uselastbpLbl.ToolTip=uselastbp.ToolTip;


        beginsearchusingprevLbl.Name=DAStudio.message('RTW:tfldesigner:BeginIndexSearchUsingPreviousIndexResult');
        beginsearchusingprevLbl.Type='text';
        beginsearchusingprevLbl.RowSpan=[7,7];
        beginsearchusingprevLbl.ColSpan=[1,4];

        beginsearchusingprev=this.getDialogWidget('Tfldesigner_BeginIndexSearchUsingPreviousIndexResult');
        beginsearchusingprev.RowSpan=[7,7];
        beginsearchusingprev.ColSpan=[6,6];
        beginsearchusingprevLbl.Buddy=beginsearchusingprev.Tag;
        beginsearchusingprevLbl.Visible=beginsearchusingprev.Visible;
        beginsearchusingprevLbl.ToolTip=beginsearchusingprev.ToolTip;


        lookupuserowrajoralgoLbl.Name=DAStudio.message('RTW:tfldesigner:UseRowMajorAlgorithmText');
        lookupuserowrajoralgoLbl.Type='text';
        lookupuserowrajoralgoLbl.RowSpan=[8,8];
        lookupuserowrajoralgoLbl.ColSpan=[1,4];

        lookupuserowrajoralgo=this.getDialogWidget('Tfldesigner_UseRowMajorAlgorithm');
        lookupuserowrajoralgo.RowSpan=[8,8];
        lookupuserowrajoralgo.ColSpan=[5,6];
        lookupuserowrajoralgoLbl.Buddy=lookupuserowrajoralgo.Tag;
        lookupuserowrajoralgoLbl.Visible=lookupuserowrajoralgo.Visible;
        lookupuserowrajoralgoLbl.ToolTip=lookupuserowrajoralgo.ToolTip;


        algorithmparampanel.Type='panel';
        algorithmparampanel.LayoutGrid=[5,15];
        algorithmparampanel.RowSpan=[1,7];
        algorithmparampanel.ColSpan=[1,15];
        algorithmparampanel.RowStretch=ones(1,2);
        algorithmparampanel.ColStretch=[zeros(1,14),1];
        algorithmparampanel.Items={lookupintrpmodeLbl,lookupintrpmode,...
        lookupextrpmodeLbl,lookupextrpmode,...
        indexsearchmethodLbl,indexsearchmethod,...
        removeprotectionLbl,removeprotection,...
        removeprotectionindexLbl,removeprotectionindex,...
        satMethodLbl,satMethod,...
        roundmethodLbl,roundmethod,...
        supporttunabletableLbl,supporttunabletable,...
        uselasttablevalueLbl,uselasttablevalue,...
        validIndexreachLastLbl,validIndexreachLast,...
        uselastbpLbl,uselastbp,beginsearchusingprevLbl,beginsearchusingprev...
        ,lookupuserowrajoralgoLbl,lookupuserowrajoralgo};

        algorithmparamgroup.Items={algorithmparampanel};

    case 'lookupND_Direct'

        tabledimLbl.Name=DAStudio.message('RTW:tfldesigner:NumTableDimensionText');
        tabledimLbl.Type='text';
        tabledimLbl.RowSpan=[1,1];
        tabledimLbl.ColSpan=[1,1];

        tabledim=this.getDialogWidget('Tfldesigner_TableDimension');
        tabledim.RowSpan=[1,1];
        tabledim.ColSpan=[2,4];
        tabledimLbl.Buddy=tabledim.Tag;
        tabledimLbl.Visible=tabledim.Visible;
        tabledimLbl.ToolTip=tabledim.ToolTip;


        inputselectfromtableLbl.Name=DAStudio.message('RTW:tfldesigner:InputSelectFromTableText');
        inputselectfromtableLbl.Type='text';
        inputselectfromtableLbl.RowSpan=[1,1];
        inputselectfromtableLbl.ColSpan=[6,6];

        inputselectfromtable=this.getDialogWidget('Tfldesigner_InputSelectObjectTable');
        inputselectfromtable.RowSpan=[1,1];
        inputselectfromtable.ColSpan=[7,9];
        inputselectfromtableLbl.Buddy=inputselectfromtable.Tag;
        inputselectfromtableLbl.Visible=inputselectfromtable.Visible;
        inputselectfromtableLbl.ToolTip=inputselectfromtable.ToolTip;


        lookupuserowrajoralgoLbl.Name=DAStudio.message('RTW:tfldesigner:UseRowMajorAlgorithmText');
        lookupuserowrajoralgoLbl.Type='text';
        lookupuserowrajoralgoLbl.RowSpan=[2,2];
        lookupuserowrajoralgoLbl.ColSpan=[1,1];

        lookupuserowrajoralgo=this.getDialogWidget('Tfldesigner_UseRowMajorAlgorithm');
        lookupuserowrajoralgo.RowSpan=[2,2];
        lookupuserowrajoralgo.ColSpan=[2,4];
        lookupuserowrajoralgoLbl.Buddy=lookupuserowrajoralgo.Tag;
        lookupuserowrajoralgoLbl.Visible=lookupuserowrajoralgo.Visible;
        lookupuserowrajoralgoLbl.ToolTip=lookupuserowrajoralgo.ToolTip;


        algorithmparampanel.Type='panel';
        algorithmparampanel.LayoutGrid=[2,12];
        algorithmparampanel.RowSpan=[5,7];
        algorithmparampanel.ColSpan=[1,12];
        algorithmparampanel.RowStretch=ones(1,2);
        algorithmparampanel.ColStretch=ones(1,12);
        algorithmparampanel.Items={...
        tabledimLbl,tabledim,inputselectfromtableLbl,inputselectfromtable,...
        lookupuserowrajoralgoLbl,lookupuserowrajoralgo};

        algorithmparamgroup.Items={algorithmparampanel};
    end



    algorithmparamgroup.Name=DAStudio.message('RTW:tfldesigner:AlgorithmParamViewText');
    algorithmparamgroup.Type='group';
    algorithmparamgroup.LayoutGrid=[1,1];
    algorithmparamgroup.Visible=true;

end

function flag=isTrigAlgorithmNotLookup(this)
    flag=false;
    if~isempty(find(strcmp(this.object.Key,{'sin','cos','sincos','cexp','atan2'}),1))


        if(~strcmp(this.object.EntryInfo.Algorithm,'RTW_LOOKUP'))
            flag=true;
        end
    end
end

function algorithmparamgroup=getEmptyAlgorithmParamGroup()
    algorithmparamgroup.Name=DAStudio.message('RTW:tfldesigner:AlgorithmParamViewText');
    algorithmparamgroup.Type='group';
    algorithmparamgroup.Items={};
    algorithmparamgroup.Visible=false;
end