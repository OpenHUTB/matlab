function[promptWidgets,comboxWidgets,shwBtnWidgets,hdeBtnWidgets,udtAssists]=getSPCDataTypeWidgets(hSource,udtSpecs,idxOnAssist,ruleTranslator)
















































    nPrms=length(udtSpecs);
    promptWidgets=cell(1,nPrms);
    comboxWidgets=cell(1,nPrms);
    shwBtnWidgets=cell(1,nPrms);
    hdeBtnWidgets=cell(1,nPrms);
    udtAssists=cell(1,nPrms);
    dtTags=cell(1,nPrms);
    nDtTags=1;

    assert(idxOnAssist==-1||(idxOnAssist>=1&&idxOnAssist<=nPrms));

    for idx=1:nPrms
        udtSpec=udtSpecs{idx};
        dtName=udtSpec.dtName;
        dtPrompt=udtSpec.dtPrompt;
        dtTag=udtSpec.dtTag;
        dtVal=udtSpec.dtVal;
        customAsstName=~isfield(udtSpec,'customAsstName')||udtSpec.customAsstName;
        dtaItems=udtSpec.dtaItems;
        dtaItems.ruleTranslator=ruleTranslator;
        dtaOn=(idx==idxOnAssist);
        panel=Simulink.DataTypePrmWidget.getDataTypeWidget(hSource,...
        dtName,...
        dtPrompt,...
        dtTag,...
        dtVal,...
        dtaItems,...
        dtaOn);



        items=panel.Items;
        assert(length(items)>=2);
        hasAssistant=(length(items)>2);


        udtPrompt=items{1};
        udtPrompt.RowSpan=[1,1];
        udtPrompt.ColSpan=[1,1];
        promptWidgets{idx}=udtPrompt;


        udtCombobox=items{2};
        udtCombobox.RowSpan=[1,1];
        udtCombobox.ColSpan=[2,2];
        comboxWidgets{idx}=udtCombobox;

        if hasAssistant

            udtShowBtn=items{3};
            udtShowBtn.RowSpan=[1,1];
            udtShowBtn.ColSpan=[3,3];
            shwBtnWidgets{idx}=udtShowBtn;


            udtHideBtn=items{4};
            udtHideBtn.RowSpan=[1,1];
            udtHideBtn.ColSpan=[3,3];
            hdeBtnWidgets{idx}=udtHideBtn;



            udtAssist=items{6};
            if customAsstName
                udtAssist.Name=DAStudio.message('Simulink:dialog:UDTSpcDataTypeAssistGrp',...
                regexprep(dtPrompt,[DAStudio.message('Simulink:dialog:UDTPromptColon'),'$'],''));
            else
                udtAssist.Name=DAStudio.message('Simulink:dialog:UDTDataTypeAssistGrp');
            end
            udtAssists{idx}=udtAssist;


            dtTags{nDtTags}=dtTag;
            nDtTags=nDtTags+1;
        end
    end

    nDtTagsMinusOne=nDtTags-1;

    for idx=1:nPrms
        if hasAssistant
            shwBtnWidgets{idx}.MatlabMethod='Simulink.DataTypePrmWidget.callbackSPCDataTypeWidgets';
            shwBtnWidgets{idx}.UserData=dtTags(1:nDtTagsMinusOne);
        end
    end
