function dlgstruct=getDialogSchema(hSrc,schemaname)%#ok<INUSD>




    dlgstruct=[];

    if~hSrc.PreConfigFlag&&isempty(hSrc.Data)&&...
        ~isempty(hSrc.FunctionName)


        dlgstruct.DialogTitle=DAStudio.message('RTW:fcnClass:configModelStep');
        dlgstruct.Items={};
        dlgstruct.LayoutGrid=[1,1];
        return;
    end

    if isempty(hSrc.cache)
        hSrc.cache=RTW.ModelSpecificCPrototype;
        hSrc.cache.Name=hSrc.Name;
        hSrc.cache.ModelHandle=hSrc.ModelHandle;
        hSrc.cache.FunctionName=hSrc.FunctionName;
        hSrc.cache.InitFunctionName=hSrc.InitFunctionName;
        hSrc.cache.selRow=0;
        hSrc.cache.RightClickBuild=hSrc.RightClickBuild;
        hSrc.cache.SubsysBlockHdl=hSrc.SubsysBlockHdl;

        if~isempty(hSrc.Data)
            hSrc.cache.Data=hSrc.Data.copy();
        end
    end

    isExportFcnDiagram=ishandle(hSrc.ModelHandle)&&...
    isequal(get_param(hSrc.ModelHandle,'SolverType'),'Fixed-step')&&...
    slprivate('getIsExportFcnModel',hSrc.ModelHandle);

    thisObj=hSrc.cache;

    eInitFuncLabel.Type='text';
    eInitFuncLabel.Tag='PrototypeInitFuncLabel';
    eInitFuncLabel.Name=DAStudio.message('RTW:fcnClass:initFunctionName');
    eInitFuncLabel.MinimumSize=[150,0];
    eInitFuncLabel.Mode=true;
    eInitFuncLabel.DialogRefresh=true;
    eInitFuncLabel.ToolTip=DAStudio.message('RTW:fcnClass:initFuncNameTip');
    eInitFuncLabel.Source=thisObj;
    eInitFuncLabel.RowSpan=[1,1];
    eInitFuncLabel.ColSpan=[1,3];

    eInitFuncName.Type='edit';
    eInitFuncName.Tag='PrototypeInitFuncName';
    eInitFuncName.Name='';
    eInitFuncName.MinimumSize=[150,0];
    eInitFuncName.Mode=true;
    eInitFuncName.DialogRefresh=true;
    eInitFuncName.ToolTip=DAStudio.message('RTW:fcnClass:initFuncNameTip');
    eInitFuncName.ObjectProperty='InitFunctionName';
    eInitFuncName.ValidationCallback=@onNameChanged;
    eInitFuncName.Source=thisObj;
    eInitFuncName.RowSpan=[1,1];
    eInitFuncName.ColSpan=[4,10];

    eFuncLabel.Type='text';
    eFuncLabel.Tag='PrototypeFuncLabel';
    eFuncLabel.Name=DAStudio.message('RTW:fcnClass:functionName');
    eFuncLabel.MinimumSize=[150,0];
    eFuncLabel.Mode=true;
    eFuncLabel.DialogRefresh=true;
    eFuncLabel.ToolTip=DAStudio.message('RTW:fcnClass:funcNameTip');
    eFuncLabel.Source=thisObj;
    eFuncLabel.RowSpan=[2,2];
    eFuncLabel.ColSpan=[1,3];

    eFuncName.Type='edit';
    eFuncName.Tag='PrototypeFuncName';
    eFuncName.Name='';
    eFuncName.MinimumSize=[150,0];
    eFuncName.Mode=true;
    eFuncName.DialogRefresh=true;
    eFuncName.ToolTip=DAStudio.message('RTW:fcnClass:funcNameTip');
    eFuncName.ObjectProperty='FunctionName';
    eFuncName.ValidationCallback=@onNameChanged;
    eFuncName.Source=thisObj;
    eFuncName.RowSpan=[2,2];
    eFuncName.ColSpan=[4,10];

    [inpH,outpH]=hSrc.getPortHandles(thisObj.ModelHandle);



    argSpecData=thisObj.Data;
    idxArray=get(argSpecData,'Position');
    if iscell(idxArray)
        idxArray=cell2mat(idxArray);
    end
    [~,index]=sort(idxArray);
    argSpecData=argSpecData(index);
    thisObj.Data=argSpecData;

    thisObj.Data=thisObj.syncWithModel();
    argSpecData=thisObj.Data;

    numRows=length(inpH)+length(outpH);
    dataTable.Tag='IOConfigurationTable';
    dataTable.Type='table';
    dataTable.Size=[numRows,6];
    dataTable.Grid=true;
    dataTable.HeaderVisibility=[0,1];
    dataTable.RowHeader={};
    dataTable.ColHeader={DAStudio.message('RTW:fcnClass:argorder'),...
    DAStudio.message('RTW:fcnClass:portname'),...
    DAStudio.message('RTW:fcnClass:porttype'),...
    DAStudio.message('RTW:fcnClass:argcat'),...
    DAStudio.message('RTW:fcnClass:argname'),...
    DAStudio.message('RTW:fcnClass:qualifier')};

    dataTable.Mode=true;
    dataTable.DialogRefresh=true;
    dataTable.ColumnCharacterWidth=[4,7,7,8,10,12];
    dataTable.ColumnHeaderHeight=2;
    dataTable.ReadOnlyColumns=[0,1,2];

    dataTable.Editable=true;
    dataTable.ValueChangedCallback=@onValueChanged;
    dataTable.CurrentItemChangedCallback=@onCurrentChanged;

    grayColor=[255,255,255];
    rowData={};
    rowID=1;
    returnArgPresent=0;

    for i=1:length(argSpecData)
        argSpecData(i).RowID=rowID;


        if(strcmp(argSpecData(i).SLObjectType,'Outport')&&strcmp(argSpecData(i).Category,'Value'))
            argSpecData(i).PositionString='Return';
            returnArgPresent=1;
        else
            if returnArgPresent==0
                argSpecData(i).PositionString=int2str(rowID);
            else
                argSpecData(i).PositionString=int2str(rowID-1);
            end
        end


        rowData{rowID,1}=argSpecData(i).PositionString;%#ok

        portName.Type='edit';
        portName.ObjectProperty='SLObjectName';
        portName.Source=argSpecData(i);
        portName.Editable=false;
        portName.BackgroundColor=grayColor;
        rowData{rowID,2}=portName;%#ok

        portType.Type='edit';
        portType.Source=argSpecData(i);
        portType.Editable=false;
        portType.BackgroundColor=grayColor;
        portType.Value=argSpecData(i).SLObjectType;
        rowData{rowID,3}=portType;%#ok

        argCat.Type='combobox';
        argCat.ObjectProperty='Category';
        argCat.Source=argSpecData(i);
        argCat.Mode=true;
        rowData{rowID,4}=argCat;%#ok

        argName.Type='edit';
        argName.ObjectProperty='ArgName';
        argName.Source=argSpecData(i);
        argName.Mode=true;
        rowData{rowID,5}=argName;%#ok

        argQual.Type='combobox';

        if strcmp(argSpecData(i).Category,'Value')
            if strcmp(argSpecData(i).SLObjectType,'Outport')
                argQual.Entries={'none'};
            else
                argQual.Entries={'none','const'};
            end
        else

            if strcmp(argSpecData(i).SLObjectType,'Outport')

                argQual.Entries={'none'};
            else
                argQual.Entries={'none',...
                'const *','const * const'};
            end
        end

        if~ismember(argSpecData(i).Qualifier,argQual.Entries)


            argQual.Entries=[argQual.Entries,argSpecData(i).Qualifier];
        end



        if strcmp(argSpecData(i).Category,'Value')&&...
            (strcmp(argSpecData(i).Qualifier,'* const')||...
            strcmp(argSpecData(i).Qualifier,'const * const')||...
            strcmp(argSpecData(i).Qualifier,'const *'))
            argQual.Value=0;
            argSpecData(i).Qualifier='none';



        elseif strcmp(argSpecData(i).Category,'Pointer')&&strcmp(argSpecData(i).Qualifier,'const')
            argQual.Value=0;
            argSpecData(i).Qualifier='none';



        elseif strcmp(argSpecData(i).Qualifier,'none')
            argQual.Value=0;
        elseif strcmp(argSpecData(i).Qualifier,'const')
            argQual.Value=1;





        elseif strcmp(argSpecData(i).Qualifier,'const *')
            argQual.Value=1;
        elseif strcmp(argSpecData(i).Qualifier,'const * const')
            argQual.Value=2;
        else
            argQual.Value=0;
        end

        rowData{rowID,6}=argQual;%#ok
        argQual.Source=argSpecData(i);
        argQual.Mode=true;
        rowID=rowID+1;
    end

    configureStepArgsText.Type='text';
    configureStepArgsText.Visible=true;
    configureStepArgsText.Name=DAStudio.message('RTW:fcnClass:configRootIO');
    configureStepArgsText.WordWrap=false;
    configureStepArgsText.RowSpan=[3,3];
    configureStepArgsText.ColSpan=[1,10];

    dataTable.Data=rowData;
    dataTable.SelectedRow=thisObj.selRow;

    tablePanel.Name='';
    tablePanel.Type='panel';
    tablePanel.RowSpan=[4,11];
    tablePanel.ColSpan=[1,9];
    tablePanel.Items={dataTable};

    bUp.Name=DAStudio.message('RTW:fcnClass:up');
    bUp.Type='pushbutton';
    bUp.Tag='fcnproto_tag_up';
    bUp.ToolTip=DAStudio.message('RTW:fcnClass:upTip');
    bUp.MinimumSize=[50,25];
    bUp.Source=hSrc;
    bUp.ObjectMethod='upCallback';
    bUp.MethodArgs={'%dialog'};
    bUp.ArgDataTypes={'handle'};
    bUp.RowSpan=[4,4];
    bUp.ColSpan=[10,10];
    bUp.Mode=true;
    bUp.DialogRefresh=true;
    bUp.Visible=~isExportFcnDiagram;

    bDown.Name=DAStudio.message('RTW:fcnClass:down');
    bDown.Type='pushbutton';
    bDown.Tag='fcnproto_tag_down';
    bDown.ToolTip=DAStudio.message('RTW:fcnClass:downTip');
    bDown.MinimumSize=[50,25];
    bDown.Source=hSrc;
    bDown.ObjectMethod='downCallback';
    bDown.MethodArgs={'%dialog'};
    bDown.ArgDataTypes={'handle'};
    bDown.RowSpan=[5,5];
    bDown.ColSpan=[10,10];
    bDown.Mode=true;
    bDown.DialogRefresh=true;
    bDown.Visible=~isExportFcnDiagram;

    dlgstruct.LayoutGrid=[11,10];
    dlgstruct.ColStretch=[1,1,1,1,1,1,1,1,1,1];
    dlgstruct.RowStretch=[1,1,1,1,1,1,1,1,1,1,1];
    dlgstruct.DialogTitle=DAStudio.message('RTW:fcnClass:configModelStep');

    if(isExportFcnDiagram)
        eFuncLabel.Visible=false;
        eFuncName.Visible=false;
        dlgstruct.Items={eInitFuncLabel,eInitFuncName,eFuncLabel,eFuncName};
        return;
    end

    if numRows==0
        dlgstruct.Items={eInitFuncLabel,eInitFuncName,eFuncLabel,eFuncName,configureStepArgsText,tablePanel};
        return;
    end

    [~,~,isTopOrBottom,~]=...
    thisObj.foundCombinedIO(thisObj.selRow,thisObj.Data,thisObj.Data(thisObj.selRow+1).ArgName);

    if strcmp(thisObj.Data(thisObj.selRow+1).Category,'None')||...
        thisObj.selRow==0||...
        strcmp(thisObj.Data(thisObj.selRow+1).PositionString,'1')||...
        (isTopOrBottom&&thisObj.selRow==1)

        bUp.Enabled=0;
    else
        bUp.Enabled=1;
    end

    if strcmp(thisObj.Data(thisObj.selRow+1).Category,'None')||...
        thisObj.selRow==(length(thisObj.Data)-1)||...
        strcmp(thisObj.Data(thisObj.selRow+1).PositionString,'Return')||...
        (isTopOrBottom&&thisObj.selRow==(length(thisObj.Data)-2))

        bDown.Enabled=0;
    else
        bDown.Enabled=1;
    end

    dlgstruct.Items={eInitFuncLabel,eInitFuncName,eFuncLabel,eFuncName,configureStepArgsText,tablePanel,bUp,bDown};



    function onNameChanged(d,r,val,~)
        if~RTW.FcnArgSpec('','Inport','Pointer',val,0,'None',0,0).isValidIdentifier
            source=d.getSource();
            if source.isa('RTW.FcnCtlUI')
                switch r
                case 'PrototypeInitFuncName'
                    data=source.fcnclass.InitFunctionName;
                    source.fcnclass.cache.InitFunctionName=data;
                case 'PrototypeFuncName'
                    data=source.fcnclass.FunctionName;
                    source.fcnclass.cache.FunctionName=data;
                otherwise
                    data='';
                end
            else
                data='';
            end
            d.setWidgetValue(r,data);
            d.restoreFromSchema;
            error(DAStudio.message('RTW:fcnClass:notValidFunctionName',val));
        end

        function onValueChanged(d,r,c,val)
            source=d.getSource();

            if source.isa('RTW.FcnCtlUI')
                data=source.fcnclass.cache.Data;
                obj=source.fcnclass.cache;
            else
                data=source.cache.Data;
                obj=source.cache;
            end

            if c==3
                [foundCombinedOne,combinedRow,~,~]=...
                obj.foundCombinedIO(r,data,data(r+1).ArgName);
                if foundCombinedOne&&val==0

                    d.restoreFromSchema;
                    errordlg(DAStudio.message('RTW:fcnClass:noValueForCombinedIO',data(r+1).SLObjectName));
                    return;
                end

                if val==-1
                    cat='None';
                    data(r+1).Position=99999999;
                elseif val==0
                    cat='Value';
                else
                    cat='Pointer';
                end

                if(strcmp(cat,'Value')&&...
                    strcmp(data(r+1).SLObjectType,'Outport')&&...
                    strcmp(data(1).SLObjectType,'Outport')&&...
                    strcmp(data(1).Category,'Value')&&...
                    r>0)
                    d.enableApplyButton(1);
                    data(r+1).Category='Pointer';%#ok

                    d.restoreFromSchema;

                    errordlg(DAStudio.message('RTW:fcnClass:tooManyReturnValues'));
                    return;
                end

                data(r+1).Category=cat;

                if(data(r+1).Position==99999999)&&(r>0)&&(val~=-1)&&...
                    ~(strcmp(data(r+1).SLObjectType,'Outport')&&strcmp(cat,'Value'))

                    data(r+1).Position=1;

                    for i=1:r
                        if data(r+1-i).Position~=99999999

                            data(r+1).Position=r+2-i;
                            break;
                        end
                    end
                    obj.selRow=data(r+1).Position-1;
                elseif(strcmp(data(r+1).SLObjectType,'Outport')&&strcmp(cat,'Value'))

                    data(r+1).Position=1;

                    for i=1:r
                        if data(r+1-i).Position~=99999999

                            data(r+1-i).Position=data(r+1-i).Position+1;
                        end
                    end
                    obj.selRow=data(r+1).Position-1;
                elseif val==-1
                    for i=1:length(data)
                        if r+1+i>length(data)
                            break;
                        end

                        if data(r+1+i).Position==99999999
                            break;
                        end

                        data(r+1+i).Position=data(r+1+i).Position-1;
                    end
                end


                if foundCombinedOne
                    data(combinedRow+1).Category=data(r+1).Category;
                end
            elseif c==4
                if~isempty(val)

                    [foundCombinedOne,combinedRow,~,msg]=...
                    obj.foundCombinedIO(r,data,val);
                    if~isempty(msg)
                        d.restoreFromSchema;
                        errordlg(msg);
                        return;
                    end

                    if foundCombinedOne

                        if strcmp(data(r+1).Category,'Value')&&strcmp(data(combinedRow+1).Category,'Value')
                            data(r+1).Category='Pointer';
                            data(combinedRow+1).Category='Pointer';
                        elseif strcmp(data(r+1).Category,'Value')
                            data(r+1).Category=data(combinedRow+1).Category;
                        elseif strcmp(data(combinedRow+1).Category,'Value')
                            data(combinedRow+1).Category=data(r+1).Category;
                        elseif~strcmp(data(combinedRow+1).Category,data(r+1).Category)


                            data(r+1).Category=data(combinedRow+1).Category;
                        end



                        if~isempty(strfind(data(r+1).Qualifier,'const'))||...
                            ~isempty(strfind(data(combinedRow+1).Qualifier,'const'))
                            data(r+1).Qualifier='none';
                            data(combinedRow+1).Qualifier='none';
                        elseif~strcmp(data(combinedRow+1).Qualifier,data(r+1).Qualifier)


                            data(r+1).Qualifier=data(combinedRow+1).Qualifier;
                        end



                        if combinedRow-r>1
                            if combinedRow>0&&~strcmp(data(combinedRow+1).Category,'None')&&...
                                ~(strcmp(data(combinedRow).SLObjectType,'Outport')&&...
                                strcmp(data(combinedRow).Category,'Value'))
                                data(combinedRow+1).Position=r+2;
                                for id=2:(combinedRow-r)
                                    data(r+id).Position=r+id+1;
                                end
                            end
                        end

                        if r-combinedRow>1
                            if combinedRow<length(data)-1&&~strcmp(data(combinedRow+1).Category,'None')&&...
                                ~strcmp(data(combinedRow+2).Category,'None')&&...
                                ~(strcmp(data(combinedRow+1).SLObjectType,'Outport')&&...
                                strcmp(data(combinedRow+1).Category,'Value'))
                                data(combinedRow+1).Position=r;
                                for id=2:(r-combinedRow)
                                    data(combinedRow+id).Position=combinedRow+id-1;
                                end
                            end
                        end

                    end
                    prevVal=data(r+1).ArgName;
                    data(r+1).ArgName=val;%#ok
                    if~data(r+1).isValidIdentifier()
                        data(r+1).ArgName=prevVal;
                        d.restoreFromSchema;
                        error(DAStudio.message('RTW:fcnClass:notValidIdentifier',val));
                    end

                end
            elseif c==5
                [foundCombinedOne,combinedRow,~,~]=...
                obj.foundCombinedIO(r,data,data(r+1).ArgName);
                if foundCombinedOne&&val~=0

                    d.restoreFromSchema;
                    errordlg(DAStudio.message('RTW:fcnClass:noConstForCombinedIO',data(r+1).SLObjectName));
                    return;
                end

                if val==0
                    data(r+1).Qualifier='none';%#ok
                elseif val==1
                    if strcmp(data(r+1).Category,'Value')
                        data(r+1).Qualifier='const';%#ok
                    else


                        data(r+1).Qualifier='const *';%#ok %'* const';
                    end
                elseif val==2
                    data(r+1).Qualifier='const * const';%#ok %'const *';


                end


                if foundCombinedOne
                    data(combinedRow+1).Qualifier=data(r+1).Qualifier;
                end
            end

            d.restoreFromSchema;




            function onCurrentChanged(d,r,c)
                src=d.getSource();
                temp=src.fcnclass.cache;
                if temp.selRow==r||r<0
                    return;
                end

                temp.selRow=r;

                if~(c==3||c==5)


                    d.selectTableRow('IOConfigurationTable',r);
                end

                [~,~,isTopOrBottom,~]=...
                temp.foundCombinedIO(r,temp.Data,temp.Data(r+1).ArgName);

                if strcmp(temp.Data(r+1).Category,'None')||...
                    r==0||temp.Data(r+1).RowID==1||...
                    strcmp(temp.Data(r+1).PositionString,'1')||...
                    (isTopOrBottom&&r==1)
                    d.setEnabled('fcnproto_tag_up',false);
                else
                    d.setEnabled('fcnproto_tag_up',true);
                end

                if strcmp(temp.Data(r+1).Category,'None')||...
                    r==(length(temp.Data)-1)||...
                    strcmp(temp.Data(r+1).PositionString,'Return')||...
                    (isTopOrBottom&&r==(length(temp.Data)-2))
                    d.setEnabled('fcnproto_tag_down',false);
                else
                    d.setEnabled('fcnproto_tag_down',true);
                end



