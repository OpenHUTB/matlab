classdef SetInterfaceOptionGUI<handle




    properties(Access=protected)

hTurnkey

hInterface

portName

ParentDlg
    end

    properties(GetAccess=protected,SetAccess=immutable)


InitialInterfaceOptData
    end


    properties(SetObservable)

        InterfaceOptionData=cell(0,2);

    end


    methods
        function obj=SetInterfaceOptionGUI(taskobj,hTurnkey,rowIdx)

            obj.ParentDlg=taskobj;
            obj.hTurnkey=hTurnkey;
            obj.hInterface=obj.getInterfaceObj(rowIdx);

            obj.getInterfaceOptionData();

        end
    end


    methods(Access=protected)

        function h=getInterfaceObj(obj,rowIdx)

            lengthInputPort=length(obj.hTurnkey.hTable.hIOPortList.InputPortNameList);
            if rowIdx+1<=lengthInputPort
                obj.portName=obj.hTurnkey.hTable.hIOPortList.InputPortNameList{rowIdx+1};
            else
                obj.portName=obj.hTurnkey.hTable.hIOPortList.OutputPortNameList{rowIdx+1-lengthInputPort};
            end
            h=obj.hTurnkey.hTable.hTableMap.getInterface(obj.portName);
        end

        function getInterfaceOptionData(obj)

            Enable=true;

            optStr=obj.hTurnkey.hTable.hTableMap.getInterfaceOption(obj.portName);

            optionList=obj.hInterface.getInterfaceOptionList(obj.portName,obj.hTurnkey.hTable.hTableMap);

            hIOPort=obj.hTurnkey.hTable.hIOPortList.getIOPort(obj.portName);

            for ii=1:length(optionList)
                id=find(strcmp(optionList{ii},optStr));
                if(isempty(id))

                    value=obj.hInterface.getInterfaceOptionValue(obj.portName,optionList{ii});
                else




                    value=optStr{id+1};
                end

                if strcmp(optionList{ii},'SamplePackingDimension')
                    if~iscell(value)
                        if strcmp(value,'None')
                            value={value,'All'};
                        else
                            value={value,'None'};
                        end
                    end


                    obj.hInterface.SamplePackingDimension=value{1};


                elseif strcmp(optionList{ii},'PackingMode')
                    if~iscell(value)
                        if strcmp(value,'Bit Aligned')
                            value={value,'Power of 2 Aligned'};
                        else
                            value={value,'Bit Aligned'};
                        end
                    end


                    obj.hInterface.PackingMode=value{1};



                    if strcmp(obj.hInterface.SamplePackingDimension,'None')
                        Enable=false;
                    else
                        Enable=true;
                    end
                elseif strcmp(optionList{ii},'EnableReadback')
                    if~iscell(value)

                        if strcmp(value,'inherit')
                            value={value,'on','off'};
                        elseif strcmp(value,'on')
                            value={value,'inherit','off'};
                        elseif strcmp(value,'off')
                            value={value,'inherit','on'};
                        end
                    end


                    obj.hInterface.EnableReadback=value{1};
                elseif strcmp(optionList{ii},'DefaultFrameLength')


                    if(hIOPort.isStreamedPort)
                        value=prod(hIOPort.Dimension);
                    else
                        Enable=true;
                    end

                end
                if(hIOPort.isStreamedPort)



                    Enable=false;
                end
                obj.addInterfaceOptionToGUI(optionList{ii},value,ii,Enable);
            end
        end

        function updateInterfaceOptionData(obj,hDlg)

            for nRow=1:size(obj.InterfaceOptionData,1)
                opt=obj.InterfaceOptionData{nRow,1}.Tag;
                value=obj.hInterface.getInterfaceOptionValue(obj.portName,opt);
                obj.InterfaceOptionData{nRow,2}.Value=value;
            end
            hDlg.refresh;
        end

        function addInterfaceOptionToGUI(obj,option,value,index,Enable)


            optionStr=obj.hInterface.getInterfaceOptionStr(option);


            InterfaceOptions.Type='text';

            InterfaceOptions.Tag=option;
            InterfaceOptions.RowSpan=[index,index];
            InterfaceOptions.ColSpan=[1,1];
            InterfaceOptions.Name=optionStr;

            if strcmp(option,'SamplePackingDimension')||strcmp(option,'PackingMode')

                InterfaceOptValue.Type='combobox';
                InterfaceOptValue.Tag=[option,'_DropBox'];
                InterfaceOptValue.RowSpan=[index,index];
                InterfaceOptValue.ColSpan=[2,2];
                InterfaceOptValue.Mode=true;
                InterfaceOptValue.Graphical=true;
                if~iscell(value)
                    value={value};
                end
                InterfaceOptValue.Entries=value;
                InterfaceOptValue.Enabled=Enable;

            elseif strcmp(option,'EnableReadback')

                InterfaceOptValue.Type='combobox';
                InterfaceOptValue.Tag=[option,'_DropBox'];
                InterfaceOptValue.RowSpan=[index,index];
                InterfaceOptValue.ColSpan=[2,2];
                InterfaceOptValue.Mode=false;
                InterfaceOptValue.Graphical=false;
                if~iscell(value)
                    value={value};
                end
                InterfaceOptValue.Entries=value;
                InterfaceOptValue.Enabled=Enable;

            elseif strcmp(option,'WriteSync')

                InterfaceOptValue.Type='checkbox';
                InterfaceOptValue.Tag=[option,'_CheckBox'];
                InterfaceOptValue.RowSpan=[index,index];
                InterfaceOptValue.ColSpan=[2,2];
                InterfaceOptValue.Mode=false;
                InterfaceOptValue.Graphical=false;
                if ischar(value)
                    value=strcmpi(value,'1');
                end
                InterfaceOptValue.Value=value;
                InterfaceOptValue.Enabled=Enable;

            else

                InterfaceOptValue.Type='edit';
                InterfaceOptValue.Tag=[option,'_ValueBox'];
                InterfaceOptValue.RowSpan=[index,index];
                InterfaceOptValue.ColSpan=[2,2];
                InterfaceOptValue.Mode=false;
                InterfaceOptValue.Graphical=false;
                InterfaceOptValue.Value=value;
                InterfaceOptValue.Enabled=Enable;
            end

            obj.InterfaceOptionData(end+1,:)={InterfaceOptions,InterfaceOptValue};
        end


        function exportInterfaceOptionToTurnkey(obj,hDlg)
            pvPair=cell(size(obj.InterfaceOptionData));

            for nRow=1:size(obj.InterfaceOptionData,1)
                opt=obj.InterfaceOptionData{nRow,1}.Tag;
                if strcmp(opt,'SamplePackingDimension')||strcmp(opt,'PackingMode')||strcmp(opt,'EnableReadback')
                    value=hDlg.getComboBoxText(obj.InterfaceOptionData{nRow,2}.Tag);
                elseif strcmp(opt,'WriteSync')
                    value=hDlg.getWidgetValue(obj.InterfaceOptionData{nRow,2}.Tag);
                    value=num2str(value);
                else
                    value=hDlg.getWidgetValue(obj.InterfaceOptionData{nRow,2}.Tag);
                end
                pvPair(nRow,:)={opt,value};
            end


            [r,c]=size(pvPair);
            if r*c>2
                pvPair_reorder=cell(1,r*c);
                index=1;
                for ii=1:r
                    [option,value]=pvPair{ii,:};
                    pvPair_reorder{index}=option;
                    pvPair_reorder{index+1}=value;
                    index=index+2;
                end
                pvPair=pvPair_reorder;
            end



            obj.hTurnkey.hTable.setTableCellOption(obj.portName,pvPair);
        end

    end


    methods(Hidden)
        function dlgStruct=getDialogSchema(obj,~)


            [r,c]=size(obj.InterfaceOptionData);
            OptionItemsCell=reshape(obj.InterfaceOptionData,[1,r*c]);

            AvailableOptions.Type='group';
            AvailableOptions.Tag='AvailableInterfaceOptionsGroup';
            AvailableOptions.Name=['Interface Options for ',obj.portName];
            AvailableOptions.RowSpan=[1,1];
            AvailableOptions.ColSpan=[1,1];
            AvailableOptions.LayoutGrid=[r,c];
            AvailableOptions.RowStretch=zeros(1,r);
            AvailableOptions.ColStretch=zeros(1,c);
            AvailableOptions.Items=OptionItemsCell;


            dlgStruct.DialogTag=class(obj);
            dlgStruct.DialogTitle='Set Interface Options';
            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.RowStretch=zeros(1,1);
            dlgStruct.ColStretch=zeros(1,1);

            dlgStruct.Sticky=true;

            dlgStruct.PostApplyMethod='onApply';
            dlgStruct.PostApplyArgs={'%dialog'};
            dlgStruct.PostApplyArgsDT={'handle'};

            dlgStruct.HelpMethod='onHelp';
            dlgStruct.HelpArgs={'%dialog'};
            dlgStruct.HelpArgsDT={'handle'};

            dlgStruct.CloseMethod='onClose';
            dlgStruct.CloseMethodArgs={'%closeaction'};
            dlgStruct.CloseMethodArgsDT={'string'};
            dlgStruct.Items={AvailableOptions};



        end

    end


    methods(Hidden)


        function[success,msg]=onApply(obj,hDlg)
            success=true;
            msg='';
            try

                obj.exportInterfaceOptionToTurnkey(hDlg);

            catch me

                obj.updateInterfaceOptionData(hDlg);

                success=false;
                msg=me.message;
            end
        end


        function onHelp(obj,~)

            try

                helpview(fullfile(docroot,'toolbox','hdlcoder','helptargets.map'),obj.hInterface.getHelpDocID);
            catch



                doc;
            end
        end



        function onClose(obj,~)
            updateParentGUI(obj.ParentDlg);
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
