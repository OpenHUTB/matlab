classdef FilAssistantDlg<handle




    properties(SetObservable,GetObservable)

        Status='';

        WidgetStackItems=[];

        StepID=0;

        BuildInfo=[];

        EnableDialog(1,1)logical=false;

        Tool(1,1)int32{mustBeReal}=0;

        Vendor{matlab.internal.validation.mustBeASCIICharRowVector(Vendor,'Vendor')}='';

        Board{matlab.internal.validation.mustBeCharRowVector(Board,'Board')}='';

        FPGASystemClockFrequency{matlab.internal.validation.mustBeASCIICharRowVector(FPGASystemClockFrequency,'FPGASystemClockFrequency')}='';

        IpAddrByte1{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte1,'IpAddrByte1')}='';

        IpAddrByte2{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte2,'IpAddrByte2')}='';

        IpAddrByte3{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte3,'IpAddrByte3')}='';

        IpAddrByte4{matlab.internal.validation.mustBeASCIICharRowVector(IpAddrByte4,'IpAddrByte4')}='';

        MacAddrByte1{matlab.internal.validation.mustBeASCIICharRowVector(MacAddrByte1,'MacAddrByte1')}='';

        MacAddrByte2{matlab.internal.validation.mustBeASCIICharRowVector(MacAddrByte2,'MacAddrByte2')}='';

        MacAddrByte3{matlab.internal.validation.mustBeASCIICharRowVector(MacAddrByte3,'MacAddrByte3')}='';

        MacAddrByte4{matlab.internal.validation.mustBeASCIICharRowVector(MacAddrByte4,'MacAddrByte4')}='';

        MacAddrByte5{matlab.internal.validation.mustBeASCIICharRowVector(MacAddrByte5,'MacAddrByte5')}='';

        MacAddrByte6{matlab.internal.validation.mustBeASCIICharRowVector(MacAddrByte6,'MacAddrByte6')}='';

        EnableHWBuffer(1,1)logical=true;

        BoardList=[];

        ConnectionSelection(1,1)int32{mustBeReal}=0;

        FileTableData=[];

        ShowFullFilePath(1,1)logical=false;

        PrevBrowsePath=[];

        HasChangedTopModuleName=false;

        PortEditOption(1,1)int32{mustBeReal}=0;

        SavedPortEditOption(1,1)int32{mustBeReal}=0;

        HasParsingError(1,1)logical=false;

        PortTableData=[];

        NewPortTableData=[];

        TopModuleName{matlab.internal.validation.mustBeASCIICharRowVector(TopModuleName,'TopModuleName')}='';

        ResetAssertLevel{matlab.internal.validation.mustBeASCIICharRowVector(ResetAssertLevel,'ResetAssertLevel')}='';

        ClockEnableAssertLevel{matlab.internal.validation.mustBeASCIICharRowVector(ClockEnableAssertLevel,'ClockEnableAssertLevel')}='';

        OutputDataTypeTableData=[];

        NewOutputDataTypeTableData=[];

        OutputFolder{matlab.internal.validation.mustBeASCIICharRowVector(OutputFolder,'OutputFolder')}='';

        HasChangedOutputFolder(1,1)logical=false;

        IsInHDLWA(1,1)logical=false;

        lastErrorID=[];

        lastWarningID=[];

        buildOptions=[];
    end

    properties(Hidden)
        RMIIDeprecationDlgDisplayed=false;
    end


    methods
        function this=FilAssistantDlg(varargin)




            this.StepID=1;
            this.EnableDialog=true;

            this.PrevBrowsePath='';
            this.NewPortTableData=cell(0,4);
            this.HasChangedOutputFolder=false;
            this.buildOptions={};
            this.FileTableData=cell(0,3);
            this.PortTableData=cell(0,4);
            this.HasParsingError=false;
            this.ShowFullFilePath=false;
            this.IsInHDLWA=false;
            this.NewOutputDataTypeTableData=cell(0,5);
            this.OutputDataTypeTableData=cell(0,5);


            if(nargin==0)
                this.BuildInfo=eda.internal.workflow.FILBuildInfo;
                this.TopModuleName='';
                this.PortEditOption=0;
            else

                this.BuildInfo=varargin{1};
                this.TopModuleName=this.BuildInfo.DUTName;
                this.PortEditOption=this.BuildInfo.AutoPortInfo;
            end


            this.SavedPortEditOption=this.PortEditOption;
            this.Tool=find(strcmp(this.BuildInfo.ToolList,this.BuildInfo.Tool))-1;
            this.Vendor='All';
            this.ResetAssertLevel=this.BuildInfo.ResetAssertedLevel;
            this.ClockEnableAssertLevel=this.BuildInfo.ClockEnableAssertedLevel;



            byte=textscan(this.BuildInfo.IPAddress,'%s%s%s%s','Delimiter','.');
            this.IpAddrByte1=byte{1}{1};
            this.IpAddrByte2=byte{2}{1};
            this.IpAddrByte3=byte{3}{1};
            this.IpAddrByte4=byte{4}{1};
            byte=textscan(this.BuildInfo.MACAddress,'%s%s%s%s%s%s','Delimiter','-');
            this.MacAddrByte1=byte{1}{1};
            this.MacAddrByte2=byte{2}{1};
            this.MacAddrByte3=byte{3}{1};
            this.MacAddrByte4=byte{4}{1};
            this.MacAddrByte5=byte{5}{1};
            this.MacAddrByte6=byte{6}{1};


            if isprop(this.BuildInfo,'EnableHWBuffer')
                this.EnableHWBuffer=this.BuildInfo.EnableHWBuffer;
            else
                this.EnableHWBuffer=true;
            end



            this.WidgetStackItems=cell(1,5);
            this.WidgetStackItems{1}=this.getHwOptWidgets;
            this.WidgetStackItems{2}=this.getSrcFileWidgets;
            this.WidgetStackItems{3}=this.getPortsWidgets;
            this.WidgetStackItems{4}=this.getOutputTypesWidgets;
            this.WidgetStackItems{5}=this.getBuildOptWidgets;





            if(nargin~=0)
                for m=1:numel(this.BuildInfo.SourceFiles.FilePath)
                    filename=this.BuildInfo.SourceFiles.FilePath{m};
                    filetypeenum=this.BuildInfo.FileTypeEnum;
                    filetypestr=this.BuildInfo.SourceFiles.FileType{m};
                    filetypeint=find(strcmpi(filetypestr,filetypeenum),1);
                    assert(~isempty(filetypeint),'EDALink:FilAssistantDlg:InvalidFileType',...
                    'Invalid file type in loaded MAT file.');
                    this.addNewFile(filename,filetypeint-1,filetypeenum);
                end

                this.FileTableData{this.BuildInfo.TopLevelIndex,3}.Value=true;

                for m=1:numel(this.BuildInfo.DUTPorts.PortName)
                    Direction=this.BuildInfo.DUTPorts.PortDirection{m};
                    PortKindEnum=this.BuildInfo.getPortTypes(Direction);
                    PortType=find(strcmpi(this.BuildInfo.DUTPorts.PortType{m},PortKindEnum),1);
                    assert(~isempty(filetypeint),'EDALink:FilAssistantDlg:InvalidPortType',...
                    'Invalid port type in loaded MAT file.');

                    this.addNewPort(this.BuildInfo.DUTPorts.PortName{m},...
                    this.BuildInfo.DUTPorts.PortDirection{m},...
                    this.BuildInfo.DUTPorts.PortWidth{m},...
                    PortType-1,false);
                end

                for m=1:numel(this.BuildInfo.OutputDataTypes.Name)
                    name=this.BuildInfo.OutputDataTypes.Name{m};
                    bitwidth=num2str(this.BuildInfo.OutputDataTypes.BitWidth{m});
                    datatype=this.BuildInfo.OutputDataTypes.DataType{m};
                    if this.BuildInfo.OutputDataTypes.Sign{m}
                        sign='Signed';
                    else
                        sign='Unsigned';
                    end
                    fraclen=num2str(this.BuildInfo.OutputDataTypes.FracLen{m});

                    this.addNewOutputDataType(name,bitwidth,datatype,sign,fraclen,false);
                end
            end

        end

    end


    methods
        addNewFile(this,filename,filetypeint,filetypeenum)
        addNewOutputDataType(this,name,width,datatype,sign,fraclen,toNewTable)
        addNewPort(this,name,direction,width,type,toNewTable)
        onCleanupObj=disableWidgets(this,dlg)
        str=fileTypeInt2Str(this,index)
        indx=fileTypeStr2Int(this,str)
        WidgetGroup=getBuildOptWidgets(this)
        [BoardCommInfo,showAdvancedOptions,showIPWidget]=getConnectionWidget(this,boardName)
        dlgStruct=getDialogSchema(this,~)
        WidgetGroup=getHwOptWidgets(this)
        WidgetGroup=getOutputTypesWidgets(this)
        WidgetGroup=getPortsWidgets(this)
        WidgetGroup=getSrcFileWidgets(this)
        onAddFile(this,dlg)
        onBrowseOutputFolder(this,dlg)
        onCancel(~,dlg)
        onChangeAddr(this,dlg,tag,value)
        onChangeModuleName(this)
        onChangeOutputFolder(this,dlg)
        onChangeShowFullPath(this,dlg)
        onChangeEnableHWBuffer(this)
        onHelp(this,~)
        onMoveDownFile(this,dlg)
        onMoveUpFile(this,dlg)
        onNext(this,dlg)
        onRemoveFile(this,dlg)
    end


    methods(Hidden)
        success=buildFIL(this,dlg)
        generateNewOutputDataTypeTable(this,dlg)
        generateNewPortTable(this,dlg)
        WidgetGroup=getWidgetGroup(~)
        onAddNewPort(this,dlg)
        onBack(this,dlg)
        onBoardChange(this,dlg)
        onLaunchBoardManager(~,dlg)
        onRegeneratePort(this,dlg)
        onRemovePort(this,dlg)
        showStatusMsg(this,msg,mode)
    end


    methods(Static)
        str=getCatalogMsgStr(key,varargin)
    end

    methods
        function set.OutputFolder(obj,value)
            obj.OutputFolder=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.ClockEnableAssertLevel(obj,value)
            obj.ClockEnableAssertLevel=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.ResetAssertLevel(obj,value)
            obj.ResetAssertLevel=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.TopModuleName(obj,value)
            obj.TopModuleName=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.MacAddrByte6(obj,value)
            obj.MacAddrByte6=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.MacAddrByte5(obj,value)
            obj.MacAddrByte5=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.MacAddrByte4(obj,value)
            obj.MacAddrByte4=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.MacAddrByte3(obj,value)
            obj.MacAddrByte3=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.MacAddrByte2(obj,value)
            obj.MacAddrByte2=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.MacAddrByte1(obj,value)
            obj.MacAddrByte1=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.IpAddrByte4(obj,value)
            obj.IpAddrByte4=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.IpAddrByte3(obj,value)
            obj.IpAddrByte3=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.IpAddrByte2(obj,value)
            obj.IpAddrByte2=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.IpAddrByte1(obj,value)
            obj.IpAddrByte1=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.FPGASystemClockFrequency(obj,value)
            obj.FPGASystemClockFrequency=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.Board(obj,value)
            obj.Board=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.Vendor(obj,value)
            obj.Vendor=matlab.internal.validation.makeCharRowVector(value);
        end
    end
    methods
        function set.Status(obj,value)
            obj.Status=matlab.internal.validation.makeCharRowVector(value);
        end
    end
end

