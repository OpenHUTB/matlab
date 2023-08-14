function dlgstruct=getSectionDialogSchema(hSrc,schemaname)%#ok<INUSD>




    dlgstruct=[];

    if~hSrc.PreConfigFlag&&isempty(hSrc.Data)
        dlgstruct.DialogTitle=DAStudio.message('RTW:fcnClass:cppConfigModelStep');
        dlgstruct.Items={};
        return;
    end


    if isempty(hSrc.cache)
        hSrc.cache=hSrc.copy();

        if~isempty(hSrc.Data)
            hSrc.cache.Data=hSrc.Data.copy();
        end
    end

    thisObj=hSrc.cache;

    eFuncName.Type='edit';
    eFuncName.Tag='CPPPrototypeFuncName';
    eFuncName.Name=DAStudio.message('RTW:fcnClass:cppFunctionName');
    eFuncName.MinimumSize=[150,0];
    eFuncName.Mode=true;
    eFuncName.DialogRefresh=true;
    eFuncName.ToolTip=DAStudio.message('RTW:fcnClass:cppFuncNameTip');
    eFuncName.ObjectProperty='FunctionName';
    eFuncName.ValidationCallback=@onNameChanged;
    eFuncName.Source=thisObj;
    eFuncName.RowSpan=[1,1];
    eFuncName.ColSpan=[1,5];

    eClassName.Type='edit';
    eClassName.Tag='CPPPrototypeClassName';
    eClassName.Name=DAStudio.message('RTW:fcnClass:className');
    eClassName.MinimumSize=[150,0];
    eClassName.Mode=true;
    eClassName.DialogRefresh=true;
    eClassName.ToolTip=DAStudio.message('RTW:fcnClass:classNameTip');
    eClassName.ObjectProperty='ModelClassName';
    eClassName.ValidationCallback=@onNameChanged;
    eClassName.Source=thisObj;
    eClassName.RowSpan=[1,1];
    eClassName.ColSpan=[6,10];

    eNamespaceName.Type='edit';
    eNamespaceName.Tag='CPPNamespaceName';
    eNamespaceName.Name=DAStudio.message('RTW:fcnClass:namespaceName');
    eNamespaceName.MinimumSize=[150,0];
    eNamespaceName.Mode=true;
    eNamespaceName.DialogRefresh=true;
    eNamespaceName.ToolTip=DAStudio.message('RTW:fcnClass:namespaceNameTip');
    eNamespaceName.ObjectProperty='ClassNamespace';
    eNamespaceName.ValidationCallback=@onNameChanged;
    eNamespaceName.Source=thisObj;
    eNamespaceName.RowSpan=[1,1];
    eNamespaceName.ColSpan=[11,15];

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


    dataTable.ColumnCharacterWidth=[5,8,8,9,11,14];
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


        rowData{rowID,1}=argSpecData(i).PositionString;

        rowData{rowID,2}=argSpecData(i).SLObjectName;%#ok


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
        elseif strcmp(argSpecData(i).Category,'Reference')
            if strcmp(argSpecData(i).SLObjectType,'Outport')
                argQual.Entries={'none'};
            else
                argQual.Entries={'none','const &'};
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




        if(strcmp(argSpecData(i).Category,'Value')||...
            strcmp(argSpecData(i).Category,'Reference'))&&...
            (strcmp(argSpecData(i).Qualifier,'* const')||...
            strcmp(argSpecData(i).Qualifier,'const * const')||...
            strcmp(argSpecData(i).Qualifier,'const *'))
            argQual.Value=0;
            argSpecData(i).Qualifier='none';





            if strcmp(argSpecData(i).Category,'Value')
                if strcmp(argSpecData(i).SLObjectType,'Outport')
                    argQual.Entries={'none'};
                else
                    argQual.Entries={'none','const'};
                end
            elseif strcmp(argSpecData(i).Category,'Reference')
                if strcmp(argSpecData(i).SLObjectType,'Outport')
                    argQual.Entries={'none'};
                else
                    argQual.Entries={'none','const &'};
                end
            end


        elseif(strcmp(argSpecData(i).Category,'Pointer')||...
            strcmp(argSpecData(i).Category,'Reference'))&&...
            strcmp(argSpecData(i).Qualifier,'const')
            argQual.Value=0;
            argSpecData(i).Qualifier='none';


        elseif(strcmp(argSpecData(i).Category,'Pointer')||...
            strcmp(argSpecData(i).Category,'Value'))&&...
            strcmp(argSpecData(i).Qualifier,'const &')
            argQual.Value=0;
            argSpecData(i).Qualifier='none';



        elseif strcmp(argSpecData(i).Qualifier,'none')
            argQual.Value=0;
        elseif strcmp(argSpecData(i).Qualifier,'const')
            argQual.Value=1;
        elseif strcmp(argSpecData(i).Qualifier,'const &')
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

    dataTable.Data=rowData;
    dataTable.SelectedRow=thisObj.selRow;
    dataTable.RowSpan=[1,9];
    dataTable.ColSpan=[1,14];


    tablePanel.Name=DAStudio.message('RTW:fcnClass:configRootIO');
    tablePanel.Type='panel';
    tablePanel.LayoutGrid=[9,9];


    tablePanel.RowSpan=[2,10];
    tablePanel.ColSpan=[1,14];
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
    bUp.RowSpan=[2,2];
    bUp.ColSpan=[15,15];
    bUp.Mode=true;
    bUp.DialogRefresh=true;

    bDown.Name=DAStudio.message('RTW:fcnClass:down');
    bDown.Type='pushbutton';
    bDown.Tag='fcnproto_tag_down';
    bDown.ToolTip=DAStudio.message('RTW:fcnClass:downTip');
    bDown.MinimumSize=[50,25];
    bDown.Source=hSrc;
    bDown.ObjectMethod='downCallback';
    bDown.MethodArgs={'%dialog'};
    bDown.ArgDataTypes={'handle'};
    bDown.RowSpan=[3,3];
    bDown.ColSpan=[15,15];
    bDown.Mode=true;
    bDown.DialogRefresh=true;

    dlgstruct.DialogTitle=DAStudio.message('RTW:fcnClass:configModelStep');


    if numRows==0
        dlgstruct.Items={eFuncName,eClassName,eNamespaceName,tablePanel};
        return;
    end

    if~isempty(thisObj.data)
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
    else
        bUp.Enabled=0;
        bDown.Enabled=0;
    end
    if strcmp(thisObj.Data(thisObj.selRow+1).Category,'None')||...
        thisObj.selRow==(length(thisObj.Data)-1)||...
        strcmp(thisObj.Data(thisObj.selRow+1).PositionString,'Return')||...
        (isTopOrBottom&&thisObj.selRow==(length(thisObj.Data)-2))
        bDown.Enabled=0;
    else
        bDown.Enabled=1;
    end

    dlgstruct.Items={eFuncName,eClassName,eNamespaceName,tablePanel,bUp,bDown};


    function onNameChanged(d,r,val,~)
        if~RTW.CPPFcnArgSpec('','Inport','Pointer',val,0,'None',0,0).isValidCPPIdentifier
            source=d.getSource();
            if source.isa('RTW.CPPFcnCtlUI')
                switch r
                case 'CPPPrototypeFuncName'
                    data=source.fcnclass.FunctionName;
                    source.fcnclass.cache.FunctionName=data;
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidFunctionName',val);
                case 'CPPNamespaceName'
                    if isempty(val)
                        return;
                    end
                    data=source.fcnclass.ClassNamespace;
                    source.fcnclass.cache.ClassNamespace=data;
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidNamespaceName',val);
                case 'CPPPrototypeClassName'
                    data=source.fcnclass.ModelClassName;
                    source.fcnclass.cache.ModelClassName=data;
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidClassName',val);
                otherwise
                    data='';
                    msg=DAStudio.message('RTW:fcnClass:cppNotValidIdentifier',val);
                end
            else
                data='';
                msg=DAStudio.message('RTW:fcnClass:cppNotValidIdentifier',val);
            end
            d.setWidgetValue(r,data);
            d.restoreFromSchema;
            error(msg);
        end

        function onValueChanged(d,r,c,val)
            source=d.getSource();

            if source.isa('RTW.CPPFcnCtlUI')
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
                elseif val==1
                    cat='Pointer';
                else
                    cat='Reference';
                end

                if(strcmp(cat,'Value')&&strcmp(data(r+1).SLObjectType,'Outport')&&...
                    strcmp(data(1).SLObjectType,'Outport')&&strcmp(data(1).Category,'Value')&&...
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
                    if~data(r+1).isValidCPPIdentifier()
                        data(r+1).ArgName=prevVal;
                        d.restoreFromSchema;
                        error(DAStudio.message('RTW:fcnClass:cppNotValidIdentifier',val));
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
                    elseif strcmp(data(r+1).Category,'Pointer')


                        data(r+1).Qualifier='const *';%#ok %'* const';
                    else
                        data(r+1).Qualifier='const &';
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
