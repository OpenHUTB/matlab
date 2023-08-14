classdef NewInterface<handle













    properties(SetObservable)

        Interface{matlab.internal.validation.mustBeASCIICharRowVector(Interface,'Interface')}='';

        ParentDlg=[];
    end


    methods
        function this=NewInterface(varargin)
        end

    end

    methods
        function set.Interface(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','Interface')
            obj.Interface=value;
        end

    end

    methods(Hidden)

        function dlgStruct=getDialogSchema(this,~)
            InterfaceBox.Type='combobox';
            InterfaceBox.Name=DAStudio.message('EDALink:boardmanagergui:Type');
            InterfaceBox.Tag='fpgaInterface';
            InterfaceBox.ObjectProperty='Interface';

            vendor=this.ParentDlg.getSource.Vendor;
            family=this.ParentDlg.getSource.Family;
            filInterfList=eda.internal.boardmanager.InterfaceManager.getSupportedFILInterfaces(...
            vendor,family);

            InterfaceBox.Entries=cellfun(@(x)x.Name,filInterfList,'UniformOutput',false);

            if eda.internal.boardmanager.InterfaceManager.isTurnkeyInterfaceSupported(vendor,family)
                InterfaceBox.Entries=[InterfaceBox.Entries,{eda.internal.boardmanager.UserdefinedInterface.Name}];
            end

            InterfaceBox.Mode=true;
            InterfaceBox.RowSpan=[1,1];
            InterfaceBox.ColSpan=[1,2];
            InterfaceBox.DialogRefresh=true;
            if~ismember(this.Interface,InterfaceBox.Entries)
                this.Interface=InterfaceBox.Entries{1};
            end

            interfInst=eda.internal.boardmanager.InterfaceManager.getInterfaceInstance(this.Interface);
            if isa(interfInst,'eda.internal.boardmanager.UserdefinedInterface')
                txt=DAStudio.message('EDALink:boardmanagergui:UserIODesc');
            else
                txt=DAStudio.message('EDALink:boardmanagergui:EthernetInterfaceDesc');
            end

            DescTxt.Type='text';
            DescTxt.Name=txt;
            DescTxt.RowSpan=[2,2];
            DescTxt.ColSpan=[1,2];
            DescTxt.WordWrap=true;

            OkBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:OkBtn'),'fpgaOK','onOK',[2,2],[2,2]);
            CancelBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:CancelBtn'),'fpgaCancel','onCancel',[2,2],[3,3]);

            Panel.Type='panel';
            Panel.Items={InterfaceBox,DescTxt};
            Panel.RowSpan=[1,1];
            Panel.ColSpan=[1,3];
            Panel.LayoutGrid=[2,1];


            dlgStruct.DialogTitle='New Interface';
            dlgStruct.Items={Panel,OkBtn,CancelBtn};
            dlgStruct.Sticky=true;

            dlgStruct.LayoutGrid=[2,3];
            dlgStruct.ShowGrid=false;

            dlgStruct.StandaloneButtonSet={''};

            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end



        function onCancel(~,dlg)
            delete(dlg);
        end


        function onOK(this,dlg)
            boardObj=this.ParentDlg.getSource.BoardObj;

            if boardObj.FPGA.hasInterface(this.Interface)
                error(message('EDALink:boardmanagergui:InterfaceExists',this.Interface));
            end

            hInterf=eda.internal.boardmanager.InterfaceManager.getInterfaceInstance(this.Interface);

            if isa(hInterf,'eda.internal.boardmanager.EthInterface')
                if boardObj.FPGA.hasGMII||boardObj.FPGA.hasRGMII||boardObj.FPGA.hasSGMII||boardObj.FPGA.hasMII


                    error(message('EDALink:boardmanager:FPGAMoreThanOneEthInterface'));
                end
            end

            newDlg=boardmanagergui.InterfaceEditor(hInterf);
            newDlg.ParentDlg=this.ParentDlg;


            delete(dlg);


            DAStudio.Dialog(newDlg);


        end
    end
end

function button=l_getPushButton(Name,Tag,ObjectMethod,RowSpan,ColSpan)
    button.Name=Name;
    button.Tag=Tag;
    button.Type='pushbutton';
    button.ObjectMethod=ObjectMethod;
    button.MethodArgs={'%dialog'};
    button.ArgDataTypes={'handle'};
    button.RowSpan=RowSpan;
    button.ColSpan=ColSpan;
    button.Visible=true;
end

