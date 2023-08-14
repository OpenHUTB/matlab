function dialogStruct=compositebusddg(h,name,source)%#ok<INUSD>





    dialogTag='compositeBusDialog';
    dlgList=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag',dialogTag);
    matchedDlg=[];
    if~isempty(dlgList)
        for i=1:length(dlgList)
            dlg=dlgList(i);
            if isequal(dlg.getWidgetSource('ElementInfoTable'),h)
                matchedDlg=dlg;
                break;
            end
        end
    end

    if~isempty(matchedDlg)
        prototypeIdx=matchedDlg.getWidgetValue('prototype_val')+1;
    else
        prototypeIdx=1;
    end

    mainRowIndex=1;

    functionElementMap=containers.Map('KeyType','double','ValueType','double');



    elements=h.Element.toArray;
    nEle=length(elements);
    eleData=cell(nEle,3);
    hasFunctionElement=false;
    fcnProtpTypeList={};
    funnctionCount=0;
    for eleIndex=1:nEle
        element=elements(eleIndex);
        eleType=element.Type;
        if isa(eleType,'slid.FunctionType')
            eleData{eleIndex,1}=eleType.Prototype;
            eleData{eleIndex,2}='';
            eleData{eleIndex,3}='';
            eleData{eleIndex,4}='';
            hasFunctionElement=true;
            fcnProtpTypeList{end+1}=eleType.Prototype;%#ok<AGROW>
            funnctionCount=funnctionCount+1;
            functionElementMap(funnctionCount)=eleIndex;
        else
            eleData{eleIndex}=element.Name;
            [dataType,complexity,unit]=getTypeAttributes(eleType);
            eleData{eleIndex,2}=dataType;
            eleData{eleIndex,3}=complexity;
            eleData{eleIndex,4}=unit;
        end
    end

    busGrIndex=1;

    eleTable.Name='';
    eleTable.Type='table';
    eleTable.Size=size(eleData);
    eleTable.Data=eleData;
    eleTable.Grid=1;
    eleTable.ColHeader={'Element','Data Type','Complexity','Unit'};
    eleTable.HeaderVisibility=[0,1];
    eleTable.ColumnCharacterWidth=[20,12,7,7];
    eleTable.RowSpan=[busGrIndex,busGrIndex];
    eleTable.ColSpan=[1,4];
    eleTable.Enabled=0;
    eleTable.Editable=0;
    eleTable.LastColumnStretchable=1;
    eleTable.Tag='ElementInfoTable';
    eleTable.Enabled=true;
    eleTable.Editable=false;
    eleTable.Source=h;




    busInfoGrp.Type='group';
    busInfoGrp.LayoutGrid=[1,4];

    busInfoGrp.Items={eleTable};
    busInfoGrp.RowSpan=[1,1];
    busInfoGrp.ColSpan=[1,1];

    mainRowIndex=mainRowIndex+1;





    if hasFunctionElement

        selectedFcnType=elements(functionElementMap(prototypeIdx)).Type;

        fcnGroupIndex=1;

        ProtoypeLbl.Name='Details of Function Element';
        ProtoypeLbl.Type='text';
        ProtoypeLbl.RowSpan=[fcnGroupIndex,fcnGroupIndex];
        ProtoypeLbl.ColSpan=[1,1];
        ProtoypeLbl.Tag='prototype_label';

        fcnGroupIndex=fcnGroupIndex+1;
        protoTypeValue.Name=ProtoypeLbl.Name;
        protoTypeValue.HideName=1;
        protoTypeValue.RowSpan=[fcnGroupIndex,fcnGroupIndex];
        protoTypeValue.ColSpan=[1,4];
        protoTypeValue.Type='combobox';
        protoTypeValue.Tag='prototype_val';
        protoTypeValue.Value=selectedFcnType.Prototype;
        protoTypeValue.Bold=1;
        protoTypeValue.Editable=false;
        protoTypeValue.Graphical=true;
        protoTypeValue.Entries=fcnProtpTypeList;
        protoTypeValue.MatlabMethod='compositebusddg_cb';
        protoTypeValue.MatlabArgs={'%dialog','%tag','%value',h};

        fcnGroupIndex=fcnGroupIndex+1;
        argInfoLbl.Name=DAStudio.message('Simulink:blkprm_prompts:FcnEntryArguments');
        argInfoLbl.Type='text';
        argInfoLbl.RowSpan=[fcnGroupIndex,fcnGroupIndex];
        argInfoLbl.ColSpan=[1,1];
        argInfoLbl.Tag='arg_label';

        fcnGroupIndex=fcnGroupIndex+1;


        args=selectedFcnType.Argument.toArray;


        argNameSet=containers.Map;
        maxNumberOfArgs=length(args);
        argData=cell(maxNumberOfArgs,4);
        dataIdx=1;
        for i=1:length(args)
            argName=args(i).Name;
            if~argNameSet.isKey(argName)
                argNameSet(argName)=true;
                [dataType,complexity,unit]=getTypeAttributes(args(i).OwnedType);
                argData(dataIdx,:)={argName,dataType,complexity,unit};
                dataIdx=dataIdx+1;
            end
        end
        argData=argData(1:argNameSet.Count,:);


        argTable.Name='';
        argTable.Type='table';
        argTable.Size=size(argData);
        argTable.Data=argData;
        argTable.Grid=1;
        argTable.ColHeader={DAStudio.message('Simulink:dialog:FcnColumnHeaderName'),...
        DAStudio.message('Simulink:dialog:FcnColumnHeaderDataType'),...
        DAStudio.message('Simulink:dialog:FcnColumnHeaderComplexity'),...
        'Unit'};
        argTable.HeaderVisibility=[0,1];
        argTable.ColumnCharacterWidth=[20,12,7,7];
        argTable.RowSpan=[fcnGroupIndex,fcnGroupIndex];
        argTable.ColSpan=[1,4];
        argTable.Enabled=0;
        argTable.Editable=0;
        argTable.LastColumnStretchable=1;
        argTable.Tag='ArgInfoTable';
        argTable.Enabled=true;
        argTable.Editable=false;

        fcnGroupIndex=fcnGroupIndex+1;
        spacer.Type='panel';
        spacer.RowSpan=[fcnGroupIndex,fcnGroupIndex];





        fcnInfoGrp.Type='group';
        fcnInfoGrp.LayoutGrid=[fcnGroupIndex,4];
        fcnInfoGrp.RowStretch=[zeros(1,fcnGroupIndex-1),1];
        fcnInfoGrp.Items={ProtoypeLbl,...
        protoTypeValue,...
        argInfoLbl,...
        argTable,spacer};
        fcnInfoGrp.RowSpan=[mainRowIndex,mainRowIndex];
        fcnInfoGrp.ColSpan=[1,1];
    end

    mainRowIndex=mainRowIndex+1;
    spacer.Type='panel';
    spacer.RowSpan=[mainRowIndex,mainRowIndex];






    dialogStruct.DialogTitle=['Bus : ',name];


    if hasFunctionElement
        dialogStruct.LayoutGrid=[3,1];
        dialogStruct.RowStretch=[0,0,1];
        dialogStruct.Items={busInfoGrp,fcnInfoGrp,spacer};
    else
        dialogStruct.LayoutGrid=[2,1];
        dialogStruct.RowStretch=[0,1];
        dialogStruct.Items={busInfoGrp,spacer};
    end
    dialogStruct.HelpMethod='helpview';
    dialogStruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'data_dictionary'};
    dialogStruct.DialogTag=dialogTag;
    dialogStruct.Source=h;

    function[dataType,complexity,unit]=getTypeAttributes(type)

        dataType=type.TypeIdentifier;
        complexity='auto';
        if slid.ComplexityKind.REAL==type.Complexity
            complexity='real';
        end
        if slid.ComplexityKind.COMPLEX==type.Complexity
            complexity='complex';
        end
        unit=type.UnitExpression;



