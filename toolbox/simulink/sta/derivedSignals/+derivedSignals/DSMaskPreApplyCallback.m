function[ret,msg]=DSMaskPreApplyCallback(obj,~)




    imd=DAStudio.imDialog.getIMWidgets(obj);



    tbl=find(imd,'WidgetId','expressionTable');
    tblItems=tbl.getAllTableItems();
    if~isempty(strfind(strjoin(tblItems,''),'#'))
        ret=false;
        msg=getString(message('sl_sta_ds:exceptions:UnknownASTToken','#'));
        return;
    end


    dialogSource=obj.getDialogSource();
    subsystemName=getFullName(dialogSource.getBlock);


    sampleTime=get(find(imd,'Tag','SampleTime'));

    Ts=str2num(sampleTime.text);%#ok<ST2NM> % can be string or array

    if~isempty(Ts)


        if(isinf(Ts(1))||~isreal(Ts(1)))

            ret=false;
            msg=getString(message('Simulink:SampleTime:InvTsParamSetting_Constant',subsystemName,'SampleTime'));
            return;
        elseif(Ts(1)==0)

            ret=false;
            msg=getString(message('Simulink:SampleTime:InvTsParamSetting_No_Continuous',subsystemName,'SampleTime'));
            return;
        end
    end

    ret=true;
    msg=getString(message('sl_sta_ds:staDerivedSignal:DSNoError'));

    blkHandle=get_param(subsystemName,'Object');
    parentNames=strsplit(blkHandle.parent,'/');
    modelNm=parentNames{1};

    selectionWidget=get(find(imd,'WidgetId','signalSelect'));
    currentSelection=selectionWidget.currentText;

    if(strcmp(get_param(modelNm,'SimulationStatus'),'stopped'))&&...
        ~(strcmp(get_param(modelNm,'BlockDiagramType'),'library')...
        &&strcmp(get_param(modelNm,'Lock'),'on'))





        maskValues=get_param(subsystemName,'MaskValues');


        outMinWidget=get(find(imd,'Tag','OutMin'));
        minTxt=outMinWidget.text;
        maskValues{1,1}=minTxt;


        outMaxWidget=get(find(imd,'Tag','OutMax'));
        maxTxt=outMaxWidget.text;
        maskValues{2,1}=maxTxt;


        outDataTypeWidget=get(find(imd,'Tag','OutDataTypeStr'));
        dataTypeTxt=outDataTypeWidget.currentText;
        maskValues{3,1}=dataTypeTxt;
        obj.clearWidgetDirtyFlag('OutDataTypeStr');


        lockScaleWidget=get(find(imd,'Tag','LockScale'));
        boolLock=lockScaleWidget.checked;
        strLock='off';
        if(boolLock==1)
            strLock='on';
        end
        maskValues{4,1}=strLock;


        roundingModeWidget=get(find(imd,'Tag','RndMeth'));
        roundingModeTxt=roundingModeWidget.currentText;
        maskValues{5,1}=roundingModeTxt;


        intSaturationWidget=get(find(imd,'Tag','SaturateOnIntegerOverflow'));
        boolSaturate=intSaturationWidget.checked;
        strSaturate='off';
        if(boolSaturate==1)
            strSaturate='on';
        end
        maskValues{6,1}=strSaturate;

        sampleTime=get(find(imd,'Tag','SampleTime'));
        sampleTimeTxt=sampleTime.text;
        maskValues{13,1}=sampleTimeTxt;
        set_param(subsystemName,'SampleTime',sampleTimeTxt);

        selectedSignal=get(find(imd,'Tag','SelectedSignal'));
        maskValues{7,1}=selectedSignal.currentText;
        set_param(subsystemName,'SelectedSignal',currentSelection);

        set_param(subsystemName,'MaskValues',maskValues);







        set_param(subsystemName,'Signals',strjoin(dialogSource.signals,'#'));
        set_param(subsystemName,'ApplyFlag',num2str(1));

    end



    if~(strcmp(get_param(modelNm,'BlockDiagramType'),'library')...
        &&strcmp(get_param(modelNm,'Lock'),'on'))
        set_param(subsystemName,'SelectedSignal',currentSelection);
    end
end
