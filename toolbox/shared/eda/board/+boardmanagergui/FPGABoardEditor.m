classdef FPGABoardEditor<handle


































    properties(SetObservable)

        BoardName{matlab.internal.validation.mustBeASCIICharRowVector(BoardName,'BoardName')}='';

        Vendor{matlab.internal.validation.mustBeASCIICharRowVector(Vendor,'Vendor')}='';

        Family{matlab.internal.validation.mustBeASCIICharRowVector(Family,'Family')}='';

        Device{matlab.internal.validation.mustBeASCIICharRowVector(Device,'Device')}='';

        Package{matlab.internal.validation.mustBeASCIICharRowVector(Package,'Package')}='';

        Speed{matlab.internal.validation.mustBeASCIICharRowVector(Speed,'Speed')}='';

        ChainPos{matlab.internal.validation.mustBeASCIICharRowVector(ChainPos,'ChainPos')}='';

        ClockFreq{matlab.internal.validation.mustBeASCIICharRowVector(ClockFreq,'ClockFreq')}='';

        ClockType{matlab.internal.validation.mustBeASCIICharRowVector(ClockType,'ClockType')}='';

        ClockPinP{matlab.internal.validation.mustBeASCIICharRowVector(ClockPinP,'ClockPinP')}='';

        ClockPinN{matlab.internal.validation.mustBeASCIICharRowVector(ClockPinN,'ClockPinN')}='';

        ClockIOStandard{matlab.internal.validation.mustBeASCIICharRowVector(ClockIOStandard,'ClockIOStandard')}='';

        ParentDlg=[];

        ChildDlg=[];

        ResetPin{matlab.internal.validation.mustBeASCIICharRowVector(ResetPin,'ResetPin')}='';

        ResetIOStandard{matlab.internal.validation.mustBeASCIICharRowVector(ResetIOStandard,'ResetIOStandard')}='';

        ResetActiveLevel{matlab.internal.validation.mustBeASCIICharRowVector(ResetActiveLevel,'ResetActiveLevel')}='';

        BoardObj=[];

        OldBoardName{matlab.internal.validation.mustBeASCIICharRowVector(OldBoardName,'OldBoardName')}='';

        isReadOnly(1,1)logical=false;
    end

    methods
        function this=FPGABoardEditor(varargin)
            this.BoardObj=varargin{1};
            if nargin==2
                this.isReadOnly=varargin{2};
            else
                this.isReadOnly=false;
            end
            this.BoardName=this.BoardObj.BoardName;
            this.OldBoardName=this.BoardObj.BoardName;
            this.Vendor=this.BoardObj.FPGA.Vendor;
            this.Family=this.BoardObj.FPGA.Family;
            this.Device=this.BoardObj.FPGA.Device;
            this.Package=this.BoardObj.FPGA.Package;
            this.Speed=this.BoardObj.FPGA.Speed;
            this.ChainPos=num2str(this.BoardObj.FPGA.JTAGChainPosition);
            if this.BoardObj.FPGA.hasClock
                Clock=this.BoardObj.FPGA.getClock;
            else
                Clock=this.BoardObj.FPGA.addInterface(eda.internal.boardmanager.ClockInterface.Name);
            end
            this.ClockFreq=Clock.getParam('Frequency');
            this.ClockType=Clock.getParam('ClockType');


            switch this.ClockType
            case 'Differential'
                this.ClockPinP=Clock.getFPGAPin('Clock_P');
                this.ClockPinN=Clock.getFPGAPin('Clock_N');
                this.ClockIOStandard=Clock.getIOStandard('Clock_P');
            otherwise
                this.ClockPinP=Clock.getFPGAPin('Clock');
                this.ClockIOStandard=Clock.getIOStandard('Clock');
            end
            if this.BoardObj.FPGA.hasReset
                Reset=this.BoardObj.FPGA.getInterface(eda.internal.boardmanager.ResetInterface.Name);
                this.ResetPin=Reset.getFPGAPin('Reset');
                this.ResetActiveLevel=Reset.getParam('ActiveLevel');
                this.ResetIOStandard=Reset.getIOStandard('Reset');
            else
                this.ResetPin='';
                this.ResetActiveLevel='Active-Low';
                this.ResetIOStandard='';
            end
        end
    end

    methods
        function set.BoardName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.BoardName=value;
        end

        function set.Vendor(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.Vendor=value;
        end

        function set.Family(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.Family=value;
        end

        function set.Device(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.Device=value;
        end

        function set.Package(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.Package=value;
        end

        function set.Speed(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.Speed=value;
        end

        function set.ChainPos(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','ChainPos')
            obj.ChainPos=value;
        end

        function set.ClockFreq(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','ClockFreq')
            obj.ClockFreq=value;
        end

        function set.ClockType(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','ClockType')
            obj.ClockType=value;
        end

        function set.ClockPinP(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.ClockPinP=value;
        end

        function set.ClockPinN(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','ClockPinN')
            obj.ClockPinN=value;
        end

        function set.ClockIOStandard(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.ClockIOStandard=value;
        end

        function set.ResetPin(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.ResetPin=value;
        end

        function set.ResetIOStandard(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.ResetIOStandard=value;
        end

        function set.ResetActiveLevel(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);

            validateattributes(value,{'char'},{'row'},'','ResetActiveLevel')
            obj.ResetActiveLevel=value;
        end

        function set.OldBoardName(obj,value)
            value=matlab.internal.validation.makeCharRowVector(value);


            obj.OldBoardName=value;
        end

        function set.isReadOnly(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','isReadOnly')
            value=logical(value);
            obj.isReadOnly=value;
        end
    end

    methods(Hidden)

        function DeviceGrp=getDeviceWidgets(this)
            VendorTxt.Type='text';
            VendorTxt.Name=DAStudio.message('EDALink:boardmanagergui:Vendor');
            VendorTxt.RowSpan=[1,1];
            VendorTxt.ColSpan=[1,1];

            VendorBox.Type='combobox';
            VendorBox.Tag='fpgaVendorBox';
            VendorBox.RowSpan=[1,1];
            VendorBox.ColSpan=[2,2];
            VendorBox.Entries={'Altera','Xilinx'};
            VendorBox.ObjectProperty='Vendor';
            VendorBox.Mode=true;
            VendorBox.DialogRefresh=true;
            VendorBox.Source=this;
            if~ismember(this.Vendor,VendorBox.Entries)
                this.Vendor=VendorBox.Entries{1};
            end

            FamilyTxt.Type='text';
            FamilyTxt.Name=DAStudio.message('EDALink:boardmanagergui:Family');
            FamilyTxt.RowSpan=[1,1];
            FamilyTxt.ColSpan=[3,3];

            switch this.Vendor
            case 'Altera'
                FamilyBox.Entries=eda.internal.fpgadevice.getAlteraDeviceList;
            otherwise
                FamilyBox.Entries=eda.internal.fpgadevice.getXilinxDeviceList;
            end

            FamilyBox.Type='combobox';
            FamilyBox.Tag='fpgaFamilyBox';
            FamilyBox.RowSpan=[1,1];
            FamilyBox.ColSpan=[4,4];
            FamilyBox.ObjectProperty='Family';
            FamilyBox.Mode=true;
            FamilyBox.DialogRefresh=true;
            if~ismember(this.Family,FamilyBox.Entries)
                this.Family=FamilyBox.Entries{1};
            end
            FamilyBox.Source=this;

            DeviceTxt.Type='text';
            DeviceTxt.Name=DAStudio.message('EDALink:boardmanagergui:Device');
            DeviceTxt.RowSpan=[1,1];
            DeviceTxt.ColSpan=[5,5];

            switch this.Vendor
            case 'Altera'
                DeviceBox.Entries=eda.internal.fpgadevice.getAlteraDeviceList(this.Family);
            otherwise
                DeviceBox.Entries=eda.internal.fpgadevice.getXilinxDeviceList(this.Family);
            end

            DeviceBox.Type='combobox';
            DeviceBox.Tag='fpgaDeviceBox';
            DeviceBox.RowSpan=[1,1];
            DeviceBox.ColSpan=[6,6];
            DeviceBox.ObjectProperty='Device';
            DeviceBox.Mode=true;
            DeviceBox.DialogRefresh=true;
            if~ismember(this.Device,DeviceBox.Entries)
                this.Device=DeviceBox.Entries{1};
            end
            DeviceBox.Source=this;

            switch this.Vendor
            case 'Altera'
                PackageBox.Entries={''};
                SpeedBox.Entries={''};
                this.Speed='';
                this.Package='';
                PackageTxt.Visible=false;
                PackageBox.Visible=false;
                SpeedTxt.Visible=false;
                SpeedBox.Visible=false;
            otherwise
                PackageBox.Entries=eda.internal.fpgadevice.getXilinxDeviceList(this.Family,this.Device,'package');
                SpeedBox.Entries=eda.internal.fpgadevice.getXilinxDeviceList(this.Family,this.Device,'speed');
                PackageTxt.Visible=true;
                PackageBox.Visible=true;
                SpeedTxt.Visible=true;
                SpeedBox.Visible=true;
            end

            PackageTxt.Type='text';
            PackageTxt.Name=DAStudio.message('EDALink:boardmanagergui:Package');
            PackageTxt.RowSpan=[2,2];
            PackageTxt.ColSpan=[1,1];

            PackageBox.Type='combobox';
            PackageBox.Tag='fpgaPackageBox';
            PackageBox.RowSpan=[2,2];
            PackageBox.ColSpan=[2,2];
            PackageBox.ObjectProperty='Package';
            PackageBox.Mode=true;
            PackageBox.Source=this;

            if~ismember(this.Package,PackageBox.Entries)
                this.Package=PackageBox.Entries{1};
            end

            SpeedTxt.Type='text';
            SpeedTxt.Name=DAStudio.message('EDALink:boardmanagergui:Speed');
            SpeedTxt.RowSpan=[2,2];
            SpeedTxt.ColSpan=[3,3];

            SpeedBox.Type='combobox';
            SpeedBox.Tag='fpgaSpeedBox';
            SpeedBox.RowSpan=[2,2];
            SpeedBox.ColSpan=[4,4];
            SpeedBox.ObjectProperty='Speed';
            SpeedBox.Source=this;
            SpeedBox.Mode=true;
            if~ismember(this.Speed,SpeedBox.Entries)
                this.Speed=SpeedBox.Entries{1};
            end

            ChainPosBox.Type='combobox';
            ChainPosBox.Tag='fpgaChainPosBox';
            ChainPosBox.Editable=true;
            ChainPosBox.Name=DAStudio.message('EDALink:boardmanagergui:JtagPosition');
            ChainPosBox.RowSpan=[2,2];
            ChainPosBox.ColSpan=[5,6];
            ChainPosBox.Entries={'1','2','3','4','5','6','7','8','9'};
            ChainPosBox.Mode=true;
            ChainPosBox.Source=this;
            ChainPosBox.ObjectProperty='ChainPos';

            DeviceGrp.Type='group';
            DeviceGrp.Name=DAStudio.message('EDALink:boardmanagergui:DeviceInformation');
            DeviceGrp.LayoutGrid=[2,6];
            DeviceGrp.ColStretch=[0,1,0,1,0,1];
            DeviceGrp.Items={VendorTxt,VendorBox,FamilyTxt,FamilyBox,...
            DeviceTxt,DeviceBox,PackageTxt,PackageBox,...
            SpeedTxt,SpeedBox,ChainPosBox};
        end



        function dlgStruct=getDialogSchema(this,~)
            DescTxt.Type='text';
            DescTxt.Tag='fpgaDescTxt';
            DescTxt.Name=DAStudio.message('EDALink:boardmanagergui:SpecifyFPGAInfo');
            DescTxt.RowSpan=[1,1];
            DescTxt.ColSpan=[1,1];

            TextGroup.Type='group';
            TextGroup.Tag='fpgaTextGroup';
            TextGroup.Name='Action';
            TextGroup.Visible=true;
            TextGroup.RowSpan=[1,1];
            TextGroup.ColSpan=[1,10];
            TextGroup.Items={DescTxt};

            GeneralPanel=l_getGeneralTabItems(this);
            GeneralTabItem.Name='General';
            GeneralTabItem.Items={GeneralPanel};

            InterfacePanel=l_getInterfaceItems(this);
            InterfaceTabItem.Name='Interface';
            InterfaceTabItem.Items={InterfacePanel};

            TabC.Type='tab';
            TabC.Tag='fpgaTab';
            TabC.RowSpan=[2,9];
            TabC.ColSpan=[1,10];
            TabC.Tabs={GeneralTabItem,InterfaceTabItem};


            dlgStruct.DialogTitle=[this.BoardName,' (',this.BoardObj.BoardFile,') - Properties'];
            dlgStruct.Items={TextGroup,TabC};
            dlgStruct.LayoutGrid=[10,10];
            dlgStruct.RowStretch=[0,1,1,1,1,1,1,1,1,0];
            dlgStruct.ColStretch=[1,1,1,1,1,1,1,1,1,1];
            dlgStruct.ShowGrid=false;
            dlgStruct.PreApplyMethod='preApplyCallback';
            dlgStruct.PreApplyArgs={'%dialog'};
            dlgStruct.PreApplyArgsDT={'handle'};

            dlgStruct.StandaloneButtonSet={'Help','OK','Cancel','Apply'};
            dlgStruct.Sticky=true;

            dlgStruct.HelpMethod='eda.internal.boardmanager.helpview';
            dlgStruct.HelpArgs={'FPGABoard_Editor'};


            dlgStruct.DialogTag=class(this);
            dlgStruct.DisplayIcon=...
            '\toolbox\shared\eda\board\resources\MATLAB.png';
        end


        function PinAssignGrp=getPinAssignWidgets(this)
            ClockFreqTxt.Type='text';
            ClockFreqTxt.RowSpan=[1,1];
            ClockFreqTxt.ColSpan=[1,1];
            ClockFreqTxt.Name=DAStudio.message('EDALink:boardmanagergui:ClockFrequency');

            pf=getpixunit;

            ClockFreqEdt.Type='edit';
            ClockFreqEdt.Tag='fpgaClockFreqEdt';
            ClockFreqEdt.RowSpan=[1,1];
            ClockFreqEdt.ColSpan=[2,2];
            ClockFreqEdt.ObjectProperty='ClockFreq';
            ClockFreqEdt.Mode=true;
            ClockFreqEdt.Source=this;
            ClockFreqEdt.MaximumSize=[80,60]*pf;

            ClockFreqUnitBox.Type='text';
            ClockFreqUnitBox.Name='MHz';
            ClockFreqUnitBox.RowSpan=[1,1];
            ClockFreqUnitBox.ColSpan=[3,3];

            ClockTypeTxt.Type='text';
            ClockTypeTxt.Name='Clock Type:';
            ClockTypeTxt.RowSpan=[1,1];
            ClockTypeTxt.ColSpan=[4,4];

            ClockTypeBox.Type='combobox';
            ClockTypeBox.Tag='fpgaClockTypeBox';
            ClockTypeBox.RowSpan=[1,1];
            ClockTypeBox.ColSpan=[5,6];
            ClockTypeBox.ObjectProperty='ClockType';
            ClockTypeBox.Mode=true;
            ClockTypeBox.Entries={'Single-Ended','Differential'};
            ClockTypeBox.DialogRefresh=true;
            ClockTypeBox.Source=this;

            ClockPinPTxt.Type='text';
            ClockPinPTxt.RowSpan=[2,2];
            ClockPinPTxt.ColSpan=[1,1];

            ClockPinPEdt.Type='edit';
            ClockPinPEdt.Tag='fpgaClockPinPEdt';
            ClockPinPEdt.Name='';
            ClockPinPEdt.RowSpan=[2,2];
            ClockPinPEdt.ColSpan=[2,3];
            ClockPinPEdt.Mode=true;
            ClockPinPEdt.ObjectProperty='ClockPinP';
            ClockPinPEdt.Source=this;
            ClockPinPEdt.MaximumSize=[80,60]*pf;

            ClockPinNTxt.RowSpan=[2,2];
            ClockPinNTxt.ColSpan=[4,4];
            ClockPinNTxt.Type='text';
            ClockPinNEdt.Tag='fpgaClockPinNEdt';
            ClockPinNEdt.RowSpan=[2,2];
            ClockPinNEdt.ColSpan=[5,6];
            ClockPinNEdt.Name='';
            ClockPinNEdt.MaximumSize=[80,60]*pf;
            ClockPinNEdt.Type='edit';
            ClockPinNEdt.Mode=true;
            ClockPinNEdt.ObjectProperty='ClockPinN';
            ClockPinNEdt.Source=this;

            if strcmpi(this.ClockType,'Single-Ended')
                ClockPinPTxt.Name=DAStudio.message('EDALink:boardmanagergui:ClockPinNumber');
                ClockPinNTxt.Name='';
                ClockPinNEdt.Visible=false;
            else
                ClockPinPTxt.Name=DAStudio.message('EDALink:boardmanagergui:ClockPPinNumber');
                ClockPinNTxt.Name=DAStudio.message('EDALink:boardmanagergui:ClockNPinNumber');
                ClockPinNEdt.Visible=true;
            end

            ClockIOStandardTxt.Type='text';
            ClockIOStandardTxt.Name='Clock IO Standard:';
            ClockIOStandardTxt.RowSpan=[3,3];
            ClockIOStandardTxt.ColSpan=[1,1];

            ClockIOStandardField.Type='edit';
            ClockIOStandardField.Tag='fpgaClockIOStandard';
            ClockIOStandardField.Name='';
            ClockIOStandardField.RowSpan=[3,3];
            ClockIOStandardField.ColSpan=[2,3];
            ClockIOStandardField.Mode=true;
            ClockIOStandardField.ObjectProperty='ClockIOStandard';
            ClockIOStandardField.Source=this;


            ClockGrp.Type='group';
            ClockGrp.Name=DAStudio.message('EDALink:boardmanagergui:FPGAInputClock');
            ClockGrp.RowSpan=[1,2];
            ClockGrp.ColSpan=[1,6];
            ClockGrp.LayoutGrid=[3,6];
            ClockGrp.RowStretch=[0,0,0];
            ClockGrp.ColStretch=[0,0,1,0,1,1];
            ClockGrp.Items={ClockFreqTxt,ClockFreqEdt,ClockFreqUnitBox,...
            ClockTypeTxt,ClockTypeBox,...
            ClockPinPTxt,ClockPinPEdt,...
            ClockIOStandardTxt,ClockIOStandardField,...
            ClockPinNTxt,ClockPinNEdt};

            ResetPinTxt.Type='text';
            ResetPinTxt.Name=DAStudio.message('EDALink:boardmanagergui:ResetPinNumber');
            ResetPinTxt.RowSpan=[1,1];
            ResetPinTxt.ColSpan=[1,1];

            ResetPinEdt.Type='edit';
            ResetPinEdt.Tag='fpgaResetPinEdt';
            ResetPinEdt.ObjectProperty='ResetPin';
            ResetPinEdt.Mode=true;
            ResetPinEdt.RowSpan=[1,1];
            ResetPinEdt.ColSpan=[2,3];
            ResetPinEdt.Source=this;
            ResetPinEdt.MaximumSize=[80,60]*pf;

            ResetActLvlBox.Type='combobox';
            ResetActLvlBox.Tag='fpgaResetActLvlBox';
            ResetActLvlBox.Name=DAStudio.message('EDALink:boardmanagergui:ActiveLevel');
            ResetActLvlBox.ObjectProperty='ResetActiveLevel';
            ResetActLvlBox.Mode=true;
            ResetActLvlBox.RowSpan=[1,1];
            ResetActLvlBox.ColSpan=[4,6];
            ResetActLvlBox.Entries={'Active-Low','Active-High'};
            ResetActLvlBox.Source=this;

            ResetIOStandardTxt.Type='text';
            ResetIOStandardTxt.Name='Reset IO Standard:';
            ResetIOStandardTxt.RowSpan=[3,3];
            ResetIOStandardTxt.ColSpan=[1,1];

            ResetIOStandardField.Type='edit';
            ResetIOStandardField.Tag='fpgaResetIOStandard';
            ResetIOStandardField.Name='';
            ResetIOStandardField.RowSpan=[3,3];
            ResetIOStandardField.ColSpan=[2,3];
            ResetIOStandardField.Mode=true;
            ResetIOStandardField.ObjectProperty='ResetIOStandard';
            ResetIOStandardField.Source=this;


            ResetGrp.Type='group';
            ResetGrp.Name='Reset (Optional)';
            ResetGrp.RowSpan=[3,3];
            ResetGrp.ColSpan=[1,6];
            ResetGrp.LayoutGrid=[1,6];
            ResetGrp.Items={ResetPinTxt,ResetPinEdt,ResetActLvlBox,...
            ResetIOStandardTxt,ResetIOStandardField};

            PinAssignGrp.Type='panel';

            PinAssignGrp.LayoutGrid=[3,6];
            PinAssignGrp.Items={ClockGrp,ResetGrp};
        end


        function onEdit(this,dlg)
            indx=dlg.getSelectedTableRow('fpgaInterfaceTbl');
            if indx<0
                return;
            end
            select=dlg.getTableItemValue('fpgaInterfaceTbl',indx,0);
            hInterf=this.BoardObj.FPGA.getInterface(select);
            newDlg=boardmanagergui.InterfaceEditor(hInterf,this.isReadOnly);
            newDlg.ParentDlg=dlg;

            DAStudio.Dialog(newDlg);
        end


        function onNew(this,dlg)
            if this.BoardObj.isFILCompatible&&this.BoardObj.isTurnkeyCompatible
                error(message('EDALink:boardmanagergui:ErrorAddNewInterface'));
            end
            h=boardmanagergui.NewInterface;
            h.ParentDlg=dlg;
            this.ChildDlg=DAStudio.Dialog(h);
        end


        function onRemove(this,dlg)
            indx=dlg.getSelectedTableRow('fpgaInterfaceTbl');
            if indx<0
                return;
            end
            select=dlg.getTableItemValue('fpgaInterfaceTbl',indx,0);
            this.BoardObj.FPGA.removeInterface(select);
            dlg.enableApplyButton(true);
            dlg.refresh;
        end


        function preApplyCallback(this,~)
            if this.isReadOnly
                return;
            end
            this.BoardObj.BoardName=this.BoardName;

            this.saveBasicInfo(true);
            this.BoardObj.validate;
            if numel(this.BoardObj.FPGA.getIOTableTypeInterface)==0
                error(message('EDALink:boardmanagergui:NoInterface'));
            end

            hManager=this.ParentDlg.getSource;

            if isempty(this.OldBoardName)
                hManager.BoardManager.saveBoard(this.BoardObj,'','');
            else
                hManager.BoardManager.saveBoard(this.BoardObj,this.OldBoardName,this.BoardObj.BoardFile);
            end

            this.OldBoardName=this.BoardObj.BoardName;
            hManager=this.ParentDlg.getSource;

            hManager.SearchTxt='';
            if strcmpi(hManager.Display,'Pre-installed Boards')
                hManager.Display='All';
            end
            this.ParentDlg.refresh;
        end


        function saveBasicInfo(this,validate)
            this.BoardObj.FPGA.Vendor=this.Vendor;
            this.BoardObj.FPGA.Family=this.Family;
            this.BoardObj.FPGA.Device=this.Device;
            this.BoardObj.FPGA.Package=this.Package;
            this.BoardObj.FPGA.Speed=this.Speed;
            this.BoardObj.FPGA.JTAGChainPosition=round(str2double(this.ChainPos));

            clk=this.BoardObj.FPGA.getClock;
            clkcp=copy(clk);
            clkcp.setParam('ClockType',this.ClockType);
            clkcp.setParam('Frequency',this.ClockFreq);

            if validate
                clkcp.validateFrequency;
            end

            assert(~any(double(this.ClockIOStandard)>127),message('EDALink:boardmanagergui:OnlyASCIIChars','Clock IO Standard'));
            switch(this.ClockType)
            case 'Single-Ended'
                if validate
                    l_checkPin(this.ClockPinP,DAStudio.message('EDALink:boardmanagergui:ClockPinNumber'));
                end
                clkcp.setPin('Clock',this.ClockPinP,this.ClockIOStandard);
            otherwise
                if validate
                    l_checkPin(this.ClockPinP,DAStudio.message('EDALink:boardmanagergui:ClockPPinNumber'));
                    l_checkPin(this.ClockPinN,DAStudio.message('EDALink:boardmanagergui:ClockNPinNumber'));
                end
                clkcp.setPin('Clock_P',this.ClockPinP,this.ClockIOStandard);
                clkcp.setPin('Clock_N',this.ClockPinN,this.ClockIOStandard);
            end
            if validate
                clkcp.validate;
            end
            this.BoardObj.FPGA.setInterface(clkcp);
            resetPin=strtrim(this.ResetPin);
            if~isempty(resetPin)
                rst=this.BoardObj.FPGA.addInterface(eda.internal.boardmanager.ResetInterface.Name);
                rst.setPin('Reset',resetPin,this.ResetIOStandard);
                rst.setParam('ActiveLevel',this.ResetActiveLevel);
            else

                this.BoardObj.FPGA.removeInterface(eda.internal.boardmanager.ResetInterface.Name);
            end
        end
    end
end

function InterfacePanel=l_getInterfaceItems(this)

    DescTxt.Type='text';
    DescTxt.Name=DAStudio.message('EDALink:boardmanagergui:AddIOInterface');
    DescTxt.RowSpan=[1,1];
    DescTxt.ColSpan=[1,10];

    InterfaceTbl.Type='table';
    InterfaceTbl.Tag='fpgaInterfaceTbl';
    InterfaceTbl.Name='';
    InterfaceTbl.ColHeader={DAStudio.message('EDALink:boardmanagergui:IOInterfaces')};
    InterfaceTbl.RowSpan=[2,6];
    InterfaceTbl.ColSpan=[1,8];
    InterfaceTbl.HeaderVisibility=[0,1];
    InterfaceTbl.ColumnStretchable=1;
    InterfaceTbl.SelectionBehavior='Row';
    InterfaceTbl.Data=this.BoardObj.FPGA.getIOTableTypeInterface';
    InterfaceTbl.Size=[length(InterfaceTbl.Data),1];

    AddBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:AddNewBtn'),'fpgaNew','onNew',[2,2],[9,10]);
    AddBtn.Enabled=~this.isReadOnly;
    RemoveBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:RemoveBtn'),'fpgaRemove','onRemove',[3,3],[9,10]);
    RemoveBtn.Enabled=~this.isReadOnly;
    if this.isReadOnly
        EditBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:ViewBtn'),'fpgaEdit','onEdit',[4,4],[9,10]);
    else
        EditBtn=l_getPushButton(DAStudio.message('EDALink:boardmanagergui:EditBtn'),'fpgaEdit','onEdit',[4,4],[9,10]);
    end

    if this.BoardObj.isFILCompatible
        filComp=DAStudio.message('EDALink:boardmanagergui:Yes');
    else
        filComp=DAStudio.message('EDALink:boardmanagergui:NoEthIO');
    end
    FILSummaryTxt.Type='text';
    FILSummaryTxt.Name=[DAStudio.message('EDALink:boardmanagergui:FILCompatibility'),' ',filComp];
    FILSummaryTxt.RowSpan=[1,1];
    FILSummaryTxt.ColSpan=[1,1];

    if this.BoardObj.isTurnkeyCompatible
        turnkeyComp=DAStudio.message('EDALink:boardmanagergui:Yes');
    else
        turnkeyComp=DAStudio.message('EDALink:boardmanagergui:NoUserIO');
    end

    TurnkeySummaryTxt.Type='text';
    TurnkeySummaryTxt.Name=[DAStudio.message('EDALink:boardmanagergui:TurnkeyCompatibility'),' ',turnkeyComp];
    TurnkeySummaryTxt.RowSpan=[2,2];
    TurnkeySummaryTxt.ColSpan=[1,1];

    SummaryGrp.Type='group';
    SummaryGrp.Name=DAStudio.message('EDALink:boardmanagergui:IOInterfaceSummary');
    SummaryGrp.RowSpan=[7,8];
    SummaryGrp.ColSpan=[1,8];
    SummaryGrp.LayoutGrid=[2,1];
    SummaryGrp.Items={FILSummaryTxt,TurnkeySummaryTxt};

    InterfacePanel.Name='Interface';
    InterfacePanel.Type='panel';
    InterfacePanel.RowSpan=[2,9];
    InterfacePanel.ColSpan=[1,8];
    InterfacePanel.Items={DescTxt,InterfaceTbl,AddBtn,RemoveBtn,EditBtn,SummaryGrp};
    InterfacePanel.LayoutGrid=[10,10];
end


function GeneralPanel=l_getGeneralTabItems(this)

    GeneralPanel.Name='';
    GeneralPanel.Type='panel';
    GeneralPanel.RowSpan=[2,9];
    GeneralPanel.ColSpan=[1,10];
    GeneralPanel.LayoutGrid=[10,10];

    DescTxt.Type='text';
    DescTxt.Name=DAStudio.message('EDALink:boardmanagergui:InterfaceInstruction');
    DescTxt.RowSpan=[1,1];
    DescTxt.ColSpan=[1,10];
    DescTxt.WordWrap=true;

    BoardNameTxt.Type='text';
    BoardNameTxt.Name=[DAStudio.message('EDALink:boardmanagergui:BoardName'),':'];
    BoardNameTxt.RowSpan=[2,2];
    BoardNameTxt.ColSpan=[1,2];

    BoardNameEdt.Type='edit';
    BoardNameEdt.Tag='fpgaBoardNameEdt';
    BoardNameEdt.ObjectProperty='BoardName';
    BoardNameEdt.Mode=true;
    BoardNameEdt.RowSpan=[2,2];
    BoardNameEdt.ColSpan=[3,10];
    BoardNameEdt.Enabled=~this.isReadOnly;

    BoardFileTxt.Type='text';
    BoardFileTxt.Name=DAStudio.message('EDALink:boardmanagergui:FileLocation');
    BoardFileTxt.RowSpan=[3,3];
    BoardFileTxt.ColSpan=[1,2];

    FileLocTxt.Type='text';
    FileLocTxt.Tag='fpgaFileLocation';
    FileLocTxt.Name=this.BoardObj.BoardFile;
    FileLocTxt.RowSpan=[3,3];
    FileLocTxt.ColSpan=[3,10];
    FileLocTxt.WordWrap=true;

    DeviceGrp=this.getDeviceWidgets;
    DeviceGrp.RowSpan=[5,6];
    DeviceGrp.ColSpan=[1,10];
    DeviceGrp.Enabled=~this.isReadOnly;

    PinAssignGrp=this.getPinAssignWidgets;
    PinAssignGrp.RowSpan=[7,10];
    PinAssignGrp.ColSpan=[1,10];
    PinAssignGrp.Enabled=~this.isReadOnly;

    GeneralPanel.Items={DescTxt,BoardNameTxt,BoardNameEdt,...
    BoardFileTxt,FileLocTxt,...
    DeviceGrp,PinAssignGrp};
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
end


function pf=getpixunit

    if isunix
        pf=1;
    else
        pf=get(0,'screenpixelsperinch')/96;
    end
end


function l_checkPin(pinName,widgetTxt)
    pinName=strtrim(pinName);


    assert(~any(double(pinName)>127),message('EDALink:boardmanagergui:OnlyASCIIChars',widgetTxt));
    if isempty(pinName)
        error('Parameter "%s" can not be empty.',widgetTxt);
    end
end
