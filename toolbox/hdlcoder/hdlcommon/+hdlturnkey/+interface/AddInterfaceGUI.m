classdef AddInterfaceGUI<handle





    properties(Access=protected)

hTurnkey


ParentDlg
    end

    properties(GetAccess=protected,SetAccess=immutable)


InitialInterfaceTableData
    end

    properties(Access=protected)














        InterfaceIDMap=containers.Map();
    end





    properties(Constant,Access=protected)

        ColumnToFieldNameMap=containers.Map({1,2},{'Name','Value'});

        ColumnToPropNameMap=containers.Map({1,2},{'DefaultInterfaceID','InterfaceID'});

        PropNameToColumnMap=containers.Map({'DefaultInterfaceID','InterfaceID'},{1,2});
    end


    properties(SetObservable)


        InterfaceTableData=cell(0,3);
        InterfaceTableDataDT='mxArray';
        InterfaceTableTag='InterfaceListTable';



        InterfaceTypeToAdd='';
        InterfaceTypeToAddDT='string';
        InterfaceTypeToAddTag='InterfaceTypeToAddBox';




        NumInterfacesToAdd=1;
        NumInterfacesToAddDT='int32';
        NumInterfacesToAddTag='NumInterfacesToAddBox';

    end


    methods
        function obj=AddInterfaceGUI(taskobj,hTurnkey)
            obj.ParentDlg=taskobj;



            obj.hTurnkey=hTurnkey;
            obj.importInterfaceListFromTurnkey();
            obj.InitialInterfaceTableData=obj.InterfaceTableData;
        end
    end





    methods(Access=protected)

        function importInterfaceListFromTurnkey(obj)
            dynamicInterfaceIDList=obj.hTurnkey.getDynamicInterfaceIDList;
            for ii=1:length(dynamicInterfaceIDList)
                interfaceID=dynamicInterfaceIDList{ii};


                interfaceType=obj.getInterfacePropertyFromTurnkey(interfaceID,'DefaultInterfaceID');
                obj.addInterfaceToTable(interfaceType,interfaceID);
            end
        end


        function exportInterfaceListToTurnkey(obj)


            obj.hTurnkey.clearDynamicInterfaceList;


            for nRow=1:size(obj.InterfaceTableData,1)
                interfaceType=obj.getInterfacePropertyFromTable(nRow,'DefaultInterfaceID');
                interfaceID=obj.getInterfaceID(nRow);


                obj.addInterfaceToTurnkey(interfaceType,'InterfaceID',interfaceID);
            end

            obj.hTurnkey.updateInterfaceList();
        end


        function addInterfaceToTurnkey(obj,interfaceType,varargin)

            obj.hTurnkey.addDynamicInterfaceOfType(interfaceType,varargin{:});
        end

        function addInterfaceToTable(obj,interfaceType,interfaceID)

            InterfaceTypeText.Type='text';
            InterfaceTypeText.Tag=[interfaceID,'_TypeBox'];
            InterfaceTypeText.Name=interfaceType;
            InterfaceTypeText.WordWrap=true;


            InterfaceNameEdit.Type='edit';
            InterfaceNameEdit.Tag=[interfaceID,'_NameBox'];
            InterfaceNameEdit.Value=interfaceID;


            InterfaceRemoveButton.Type='pushbutton';
            InterfaceRemoveButton.Tag=[interfaceID,'_RemoveButton'];
            InterfaceRemoveButton.Name='Remove interface';

            obj.InterfaceTableData(end+1,:)={InterfaceTypeText,InterfaceNameEdit,InterfaceRemoveButton};
        end

        function removeInterfaceFromTable(obj,nRow)
            obj.InterfaceTableData(nRow,:)=[];
        end


        function propVal=getInterfacePropertyFromTable(obj,nRow,propName)

            nCol=obj.PropNameToColumnMap(propName);
            widgetStruct=obj.InterfaceTableData{nRow,nCol};


            fieldName=obj.ColumnToFieldNameMap(nCol);
            propVal=widgetStruct.(fieldName);
        end

        function propVal=getInterfacePropertyFromTurnkey(obj,interfaceID,propName)
            propVal=obj.hTurnkey.getDynamicInterfaceProperty(interfaceID,propName);
        end

        function interfaceID=getInterfaceID(obj,nRow)

            interfaceID=obj.getInterfacePropertyFromTable(nRow,'InterfaceID');
        end

        function interfaceIDList=getInterfaceIDList(obj)

            interfaceIDList={};
            for nRow=1:size(obj.InterfaceTableData,1)
                interfaceID=obj.getInterfaceID(nRow);
                interfaceIDList{end+1}=interfaceID;%#ok<AGROW>
            end
        end

        function setInterfacePropertyOnTable(obj,nRow,nCol,newVal)

            widgetStruct=obj.InterfaceTableData{nRow,nCol};
            fieldName=obj.ColumnToFieldNameMap(nCol);
            widgetStruct.(fieldName)=newVal;


            obj.InterfaceTableData{nRow,nCol}=widgetStruct;
        end


        function interfaceID=generateUniqueInterfaceID(obj,interfaceType)








            nonDynamicIDList=setdiff(obj.hTurnkey.getInterfaceIDList,obj.hTurnkey.getDynamicInterfaceIDList);

            interfaceIDList=union(nonDynamicIDList,obj.getInterfaceIDList);


            count=1;
            interfaceID=interfaceType;
            while~isempty(intersect(interfaceIDList,interfaceID))
                interfaceID=[interfaceType,num2str(count)];
                count=count+1;
            end

        end
    end


    methods
        function set.InterfaceTypeToAdd(obj,val)
            obj.InterfaceTypeToAdd=val;
        end

        function set.NumInterfacesToAdd(obj,val)
            obj.NumInterfacesToAdd=val;
        end
    end


    methods(Hidden)
        function dlgStruct=getDialogSchema(obj,~)



            InterfaceOptions.Type='combobox';
            InterfaceOptions.Tag=obj.InterfaceTypeToAddTag;
            InterfaceOptions.RowSpan=[1,1];
            InterfaceOptions.ColSpan=[1,4];
            InterfaceOptions.Mode=true;
            InterfaceOptions.Graphical=true;
            InterfaceOptions.ObjectProperty='InterfaceTypeToAdd';
            InterfaceOptions.Entries=obj.hTurnkey.getDynamicInterfaceOptions;
            if~ismember(obj.InterfaceTypeToAdd,InterfaceOptions.Entries)
                obj.InterfaceTypeToAdd=InterfaceOptions.Entries{1};
            end


            InterfaceCount.Type='spinbox';
            InterfaceCount.Tag=obj.NumInterfacesToAddTag;
            InterfaceCount.RowSpan=[1,1];
            InterfaceCount.ColSpan=[5,5];
            InterfaceCount.Mode=true;
            InterfaceCount.Graphical=true;
            InterfaceCount.ObjectProperty='NumInterfacesToAdd';
            InterfaceCount.Range=[1,20];


            AddInterfacesButton.Type='pushbutton';
            AddInterfacesButton.Tag='AddInterfacesButton';
            AddInterfacesButton.Name='Add interface(s)';
            AddInterfacesButton.RowSpan=[1,1];
            AddInterfacesButton.ColSpan=[6,8];
            AddInterfacesButton.ObjectMethod='onAddInterfaceClicked';
            AddInterfacesButton.MethodArgs={'%dialog'};
            AddInterfacesButton.ArgDataTypes={'handle'};

            AddTargetInterface.Type='group';
            AddTargetInterface.Tag='AddTargetInterfacesGroup';
            AddTargetInterface.Name='Add Target Interfaces';
            AddTargetInterface.RowSpan=[1,1];
            AddTargetInterface.ColSpan=[1,1];
            AddTargetInterface.LayoutGrid=[1,8];
            AddTargetInterface.RowStretch=zeros(1,1);
            AddTargetInterface.ColStretch=zeros(1,8);
            AddTargetInterface.Items={InterfaceOptions,...
            InterfaceCount,...
            AddInterfacesButton};




            InterfaceTable.Type='table';
            InterfaceTable.Tag=obj.InterfaceTableTag;
            InterfaceTable.RowSpan=[1,1];
            InterfaceTable.ColSpan=[1,1];
            InterfaceTable.ColumnStretchable=[1,1,1];
            InterfaceTable.Size=size(obj.InterfaceTableData);
            InterfaceTable.ColHeader={'Type','Name',' '};
            InterfaceTable.Data=obj.InterfaceTableData;
            InterfaceTable.Editable=true;
            InterfaceTable.ItemClickedCallback=@obj.onItemClicked;
            InterfaceTable.ValueChangedCallback=@obj.onValueChanged;

            TargetInterfaceList.Name='Additional Target Interface List';
            TargetInterfaceList.Type='group';
            TargetInterfaceList.Tag='InterfaceListGroup';
            TargetInterfaceList.RowSpan=[2,6];
            TargetInterfaceList.ColSpan=[1,1];
            TargetInterfaceList.LayoutGrid=[1,1];
            TargetInterfaceList.RowStretch=ones(1,1);
            TargetInterfaceList.ColStretch=ones(1,1);
            TargetInterfaceList.Items={InterfaceTable};


            dlgStruct.DialogTag=class(obj);
            dlgStruct.DialogTitle='Add New Target Interfaces';
            dlgStruct.LayoutGrid=[6,1];
            dlgStruct.RowStretch=zeros(1,6);
            dlgStruct.ColStretch=zeros(1,1);
            dlgStruct.Sticky=true;

            dlgStruct.PostApplyMethod='onApply';
            dlgStruct.PostApplyArgs={'%dialog'};
            dlgStruct.PostApplyArgsDT={'handle'};

            dlgStruct.CloseMethod='onClose';
            dlgStruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgStruct.CloseMethodArgsDT={'handle','string'};

            dlgStruct.HelpMethod='onHelp';
            dlgStruct.HelpArgs={'%dialog'};
            dlgStruct.HelpArgsDT={'handle'};

            dlgStruct.Items={AddTargetInterface,TargetInterfaceList};



        end

        function dataType=getPropDataType(obj,propName)
            propDT=[propName,'DT'];
            dataType=obj.(propDT);
        end
    end


    methods(Hidden)

        function onItemClicked(obj,hDlg,nRow,nCol,tblStr)
            if nCol+1==size(obj.InterfaceTableData,2)
                obj.removeInterfaceFromTable(nRow+1);


                hDlg.refresh;



                hDlg.enableApplyButton(true);
            end
        end


        function onValueChanged(obj,hDlg,nRow,nCol,newVal)
            if isKey(obj.ColumnToPropNameMap,nCol+1)
                propName=obj.ColumnToPropNameMap(nCol+1);
                oldVal=obj.getInterfacePropertyFromTable(nRow+1,propName);
                obj.setInterfacePropertyOnTable(nRow+1,nCol+1,newVal);


                try


                    obj.exportInterfaceListToTurnkey();
                catch me


                    obj.setInterfacePropertyOnTable(nRow+1,nCol+1,oldVal);
                    hDlg.setTableItemValue(obj.InterfaceTableTag,nRow,nCol,oldVal);
                    rethrow(me)
                end
            end
        end


        function onAddInterfaceClicked(obj,hDlg)

            for ii=1:obj.NumInterfacesToAdd
                interfaceType=obj.InterfaceTypeToAdd;
                interfaceID=obj.generateUniqueInterfaceID(interfaceType);
                obj.addInterfaceToTable(interfaceType,interfaceID);
            end


            hDlg.refresh;



            hDlg.enableApplyButton(true);
        end


        function[success,msg]=onApply(obj,hDlg)
            success=true;
            msg='';
            try


                obj.exportInterfaceListToTurnkey();
            catch me
                success=false;
                msg=me.message;
            end
        end



        function onClose(obj,hDlg,closeAction)
            try
                switch lower(closeAction)
                case 'ok'



                    obj.hTurnkey.saveDynamicInterfaceToModel;
                case 'cancel'


                    obj.InterfaceTableData=obj.InitialInterfaceTableData;
                    obj.exportInterfaceListToTurnkey();
                end








                try
                    obj.hTurnkey.hTable.updateInterfaceTable;
                catch me











                    obj.hTurnkey.refreshTableInterface;
                end


                updateParentGUI(obj.ParentDlg);
            catch me





            end
        end


        function onHelp(obj,hDlg)
            try

                helpview(fullfile(docroot,'toolbox','hdlcoder','helptargets.map'),'help.step.targetinterface.multipleAXI4interfaces');
            catch



                doc;
            end
        end
    end

end

function updateParentGUI(taskobj)

    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;


    hModel=bdroot(system);
    hdriver=hdlmodeldriver(hModel);


    hDI=hdriver.DownstreamIntegrationDriver;


    privhdladvisor('utilUpdateInterfaceTable',mdladvObj,hDI);

    taskobj.reset;

end

function displayParentMessage(status,message,messageID)

    validateCell.Status=status;
    validateCell.Message=message;
    validateCell.MEssageID=messageID;

    [ResultDescription,ResultDetails,hasError]=...
    privhdladvisor('utilDisplayValidation',{validateCell},{},{});

end
