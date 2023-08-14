classdef FPGABuildInfo<handle










    properties(Dependent)
Board
FPGAPartInfo
BoardFPGAVendor
FPGASystemClockFrequency
    end

    properties
        IPAddress='192.168.0.2';
        MACAddress='00-0A-35-02-21-8A';
        DUTName='top';
        ResetAssertedLevel='Active-high';
        ClockEnableAssertedLevel='Active-high';
        AutoPortInfo=0;
        HDLSourceType='LegacyCode';
        ProjectSuffix='';

        SynthesisFrequency;

    end

    properties(SetAccess=protected)
BuildInfoVersion
SourceFiles
DUTPorts
TopLevelIndex
    end

    properties(Dependent)
TopLevelSourceFile
FPGAProjectName
    end

    properties(SetAccess=protected,Dependent)
        OutputFolder='';
        FPGAProjectFolder='';
FPGAProjectFile
FPGAProgrammingFile
    end

    properties(Hidden)
BoardObj
ToolInfoObj
ParamsTObj
OrigDutBaseRate
DutBaseRateScalingFactor
    end

    properties(Access=protected,Hidden)
BoardObjList
    end

    properties(Access=private)
PrivSynthesisFrequency
PrivOutputFolder
        ActualDUTFrequency_P;
    end

    properties(Transient,Access=protected)
BoardList
XilinxBoardList
AlteraBoardList
OldNetlistType
    end

    properties(Transient)
        FPGAVendor='All';
    end

    properties(Dependent,Hidden)
FileTypeEnum
    end

    properties(Constant,Hidden)

        HDLFilesEnum={'VHDL','Verilog'};
        OtherSourceFilesEnum={'Constraints','Others'};


        InPortEnum={'In'};
        OutPortEnum={'Out'};
        InPortTypeEnum={'Data','Clock','Clock enable','Reset'};
        OutPortTypeEnum={'Data'};
        PortDateTypeEnum={'ufix','sfix','int','uint','std'};
        InPortConnectivityEnum={'Drive','ExternalIO','APB_CLOCK','APB_RESET','APB_SEL','APB_WRITE','APB_ENABLE','APB_ADDR','APB_WDATA','APB_RDATA','APB_READY','APB_SLVERR','APB_STRB',''};
        OutPortConnectivityEnum={'Capture','ExternalIO','Strobe','APB_CLOCK','APB_RESET','APB_SEL','APB_WRITE','APB_ENABLE','APB_ADDR','APB_WDATA','APB_RDATA','APB_READY','APB_SLVERR','APB_STRB',''};


        AssertedLevelEnum={'Active-high','Active-low'};


        HDLSourceTypeEnum={'LegacyCode','SLHDLCoder','FDHDLCoder'};


        FPGAVendorList={'All','Altera','Xilinx'};
    end

    methods



        function set.FPGAVendor(h,value)
            if(~any(strcmp(h.FPGAVendorList,value)))
                error(message('EDALink:FILBuildInfo.InvalidVendor',value));
            end
            h.FPGAVendor=value;
        end

        function setBoardObj(h,value)
            h.validateChar(value,'Board');
            match=strcmp(value,h.BoardList);
            if sum(match)~=1
                error(message('EDALink:FILBuildInfo:InvalidBoard',value));
            end
            h.BoardObj=h.BoardObjList{match};
        end
        function set.Board(h,value)
            h.setBoardObj(value);

            if~isempty(h.ToolInfoObj)

                h.OldNetlistType=h.ToolInfoObj.NetlistType;
            end

            h.setToolInfoObj;

            if~isempty(h.OldNetlistType)

                h.updateNetlistFileType;
            end
        end

        function set.FPGASystemClockFrequency(h,value)
            h.validateChar(value,'FPGA System Clock Frequency');


            [Freq,Rem]=strtok(value,'MHz');
            if isnan(str2double(Freq))||~strcmp(Rem,'MHz')
                error(message('EDALink:FILBuildInfo:InvalidFreq',value));
            end


            h.validateFPGASystemClockFrequency(str2double(strtok(value,'MHz')));

            h.PrivSynthesisFrequency=value;
        end

        function set.IPAddress(h,value)
            h.validateChar(value);
            addr=textscan(value,'%s','Delimiter','.');
            if numel(addr{1})~=4||any(cellfun(@isempty,addr{1}))
                error(message('EDALink:FILBuildInfo:InvalidIPAddr'));
            end
            cellfun(@h.validateIPByte,addr{1});
            h.IPAddress=value;
        end







        function set.MACAddress(h,value)
            h.validateChar(value);
            addr=textscan(value,'%s','Delimiter','-');
            if numel(addr{1})~=6||any(cellfun(@isempty,addr{1}))
                error(message('EDALink:FILBuildInfo:InvalidMACAddrFormat'));
            end
            cellfun(@h.validateMACByte,addr{1});
            h.MACAddress=value;
        end

        function set.DUTName(h,value)
            h.validateChar(value,'Top-level module name');
            if~h.isValidHDLName(value)
                error(message('EDALink:FILBuildInfo:InvalidHDLTopName',value));
            end
            h.DUTName=value;
        end

        function set.ResetAssertedLevel(h,value)
            if~h.isValidAssertedLevel(value)
                error(message('EDALink:FILBuildInfo:InvalidResetLvl',value));
            end
            h.ResetAssertedLevel=value;
        end

        function set.ClockEnableAssertedLevel(h,value)
            if~h.isValidAssertedLevel(value)
                error(message('EDALink:FILBuildInfo:InvalidClkEnLvl',value));
            end
            h.ClockEnableAssertedLevel=value;
        end

        function set.AutoPortInfo(h,value)
            if~isnumeric(value)
                error(message('EDALink:FILBuildInfo:InvalidAutoPortInfo1'));
            end
            if value~=0&&value~=1
                error(message('EDALink:FILBuildInfo:InvalidAutoPortInfo2'));
            end
            h.AutoPortInfo=value;
        end

        function set.HDLSourceType(h,value)
            h.validateChar(value);
            if~any(strcmp(value,h.getHDLSourceTypes))
                error(message('EDALink:FILBuildInfo:InvalidHDLSrcType',value));
            end
            h.HDLSourceType=value;
        end




        function result=get.Board(h)
            result=h.BoardObj.Name;
        end

        function result=get.FPGAPartInfo(h)
            result=h.BoardObj.Component.PartInfo.FPGAPartInfo;
        end

        function result=get.BoardFPGAVendor(h)
            result=h.BoardObj.Component.PartInfo.FPGAVendor;
        end

        function result=get.FPGASystemClockFrequency(h)
            result=h.PrivSynthesisFrequency;
        end


        function result=get.FileTypeEnum(h)
            netlist=h.ToolInfoObj.NetlistType;
            tclscript=h.ToolInfoObj.TclScriptType;
            result=[h.HDLFilesEnum,netlist,tclscript,h.OtherSourceFilesEnum];
        end

        function result=get.TopLevelSourceFile(h)
            if h.TopLevelIndex>0
                result=h.SourceFiles.FilePath{h.TopLevelIndex};
            else
                result='';
            end
        end

        function result=get.FPGAProjectName(h)
            if isempty(h.DUTName)
                result='';
            else
                result=[h.DUTName,'_',h.ProjectSuffix];
            end
        end

        function result=get.OutputFolder(h)
            if isempty(h.PrivOutputFolder)
                if isempty(h.FPGAProjectName)
                    result='';
                else

                    result=fullfile('.',h.FPGAProjectName);
                end
            else
                result=h.PrivOutputFolder;
            end
        end

        function result=get.FPGAProjectFolder(h)
            if isempty(h.OutputFolder)
                result='';
            else
                result=fullfile(h.OutputFolder,'fpgaproj');
            end
        end

        function result=get.FPGAProjectFile(h)
            if isempty(h.OutputFolder)
                result='';
            else

                result=fullfile(h.OutputFolder,'fpgaproj',...
                [h.FPGAProjectName,h.ToolInfoObj.ProjectFileExt]);
            end
        end

        function result=get.FPGAProgrammingFile(h)
            if isempty(h.OutputFolder)
                result='';
            else

                result=fullfile(h.OutputFolder,...
                [h.FPGAProjectName,h.ToolInfoObj.ProgrammingFileExt]);
            end
        end



        function result=getBoards(h)
            switch h.FPGAVendor
            case 'Xilinx'
                result=h.XilinxBoardList;
            case 'Altera'
                result=h.AlteraBoardList;
            otherwise
                result=h.BoardList;
            end
        end


        function result=getFileTypes(h)
            result=h.FileTypeEnum;
        end

        function result=getAssertedLevels(h)
            result=h.AssertedLevelEnum;
        end

        function result=getPortDirections(h)
            result=[h.InPortEnum,h.OutPortEnum];
        end

        function result=getPortDatatypes(h)
            result=h.PortDateTypeEnum;
        end

        function result=getPortTypes(h,direction)
            switch direction
            case h.InPortEnum
                result=h.InPortTypeEnum;
            case h.OutPortEnum
                result=h.OutPortTypeEnum;
            otherwise
                error(message('EDALink:FILBuildInfo:UndefinedDir'));
            end
        end

        function result=getHDLSourceTypes(h)
            result=h.HDLSourceTypeEnum;
        end

        function result=getInPortConnectivity(h)
            result=[h.InPortConnectivityEnum];
        end

        function result=getOutPortConnectivity(h)
            result=[h.OutPortConnectivityEnum];
        end


        function[family,device,package,speed]=getFPGAParts(h)
            family=h.BoardObj.Component.PartInfo.FPGAFamily;
            device=h.BoardObj.Component.PartInfo.FPGADevice;
            package=h.BoardObj.Component.PartInfo.FPGAPackage;
            speed=h.BoardObj.Component.PartInfo.FPGASpeed;
        end

        function f=getActualDUTFrequency(h)
            f=h.ActualDUTFrequency_P;
        end




        function initializeSourceFiles(h)
            h.SourceFiles=struct('FilePath',{{}},'FileType',{{}},'FileLib',{{}});
            h.TopLevelIndex=-1;
        end

        function addSourceFile(h,filePath,fileType,fileLib)
            narginchk(2,4);

            h.validateSourceFilePath(filePath);
            if nargin<3
                validValues=h.getFileTypes;
                fileType=validValues{1};
            else
                h.validateSourceFileType(fileType);
            end
            if nargin<4
                fileLib=[];
            end

            h.SourceFiles.FilePath{end+1}=filePath;
            h.SourceFiles.FileType{end+1}=fileType;
            h.SourceFiles.FileLib{end+1}=fileLib;
        end

        function removeSourceFile(h,index)
            h.validateSourceFileIndex(index);
            h.SourceFiles.FilePath(index)=[];
            h.SourceFiles.FileType(index)=[];
            h.SourceFiles.FileLib(index)=[];

            if index==h.TopLevelIndex

                h.TopLevelIndex=-1;
            elseif(h.TopLevelIndex>0)&&(index<h.TopLevelIndex)

                h.TopLevelIndex=h.TopLevelIndex-1;
            end
        end

        function swapSourceFile(h,index1,index2)
            tmp=h.SourceFiles.FilePath(index1);
            h.SourceFiles.FilePath(index1)=h.SourceFiles.FilePath(index2);
            h.SourceFiles.FilePath(index2)=tmp;

            tmp=h.SourceFiles.FileType(index1);
            h.SourceFiles.FileType(index1)=h.SourceFiles.FileType(index2);
            h.SourceFiles.FileType(index2)=tmp;

            tmp=h.SourceFiles.FileLib(index1);
            h.SourceFiles.FileLib(index1)=h.SourceFiles.FileLib(index2);
            h.SourceFiles.FileLib(index2)=tmp;

            if index1==h.TopLevelIndex
                h.TopLevelIndex=index2;
            elseif index2==h.TopLevelIndex
                h.TopLevelIndex=index1;
            end
        end

        function setSourceFilePath(h,index,filePath)
            h.validateSourceFileIndex(index);
            h.validateSourceFilePath(filePath);
            h.SourceFiles.FilePath{index}=filePath;
        end

        function setSourceFileLib(h,index,fileLib)
            h.validateSourceFileIndex(index);
            h.validateSourceFileLib(fileLib);
            h.SourceFiles.FileLib{index}=fileLib;
        end

        function setSourceFileType(h,index,fileType)
            h.validateSourceFileIndex(index);
            h.validateSourceFileType(fileType);
            h.SourceFiles.FileType{index}=fileType;

            if index==h.TopLevelIndex&&...
                ~h.isEligibleTopLevel(h.SourceFiles.FileType{index})

                h.TopLevelIndex=-1;
            end
        end

        function dispSourceFiles(h)
            if~isempty(h.SourceFiles.FilePath)
                disp('');
                maxPathLen=max(cellfun(@length,h.SourceFiles.FilePath));
                printFormat=['    %-',num2str(maxPathLen+3),'s%s\n'];
                for n=1:numel(h.SourceFiles.FilePath)
                    fprintf(printFormat,h.SourceFiles.FilePath{n},...
                    h.SourceFiles.FileType{n});
                end
            end
        end


        function setTopLevelSourceFile(h,index)
            h.validateSourceFileIndex(index);
            if~h.isEligibleTopLevel(h.SourceFiles.FileType{index})
                error(message('EDALink:FILBuildInfo:NonHDLTop'));
            end
            h.TopLevelIndex=index;
        end

        function unsetTopLevelSourceFile(h)
            h.TopLevelIndex=-1;
        end



        function initializeDUTPorts(h)
            h.DUTPorts=struct('PortName',{{}},'PortDirection',{{}},...
            'PortWidth',{{}},'PortType',{{}},'PortDataType',{{}},...
            'PortConnectivity',{{}});
        end

        function addDUTPort(h,name,direction,width,type,datatype,connectivity,varargin)
            if(nargin==5)
                datatype='std';
                connectivity='';
            elseif nargin==6
                connectivity='';
            end

            h.validateDUTPortName(name);
            h.validateDUTPortDirection(direction);
            h.validateDUTPortWidth(width);
            h.validateDUTPortType(type,direction);
            h.validateDUTPortDataType(datatype);
            h.validateDUTPortConnectivity(direction,connectivity);

            h.DUTPorts.PortName{end+1}=name;
            h.DUTPorts.PortDirection{end+1}=direction;
            h.DUTPorts.PortWidth{end+1}=width;
            h.DUTPorts.PortType{end+1}=type;
            h.DUTPorts.PortDataType{end+1}=datatype;
            h.DUTPorts.PortConnectivity{end+1}=connectivity;
        end

        function removeDUTPort(h,index)
            h.validateDUTPortIndex(index);
            h.DUTPorts.PortName(index)=[];
            h.DUTPorts.PortDirection(index)=[];
            h.DUTPorts.PortWidth(index)=[];
            h.DUTPorts.PortType(index)=[];
            h.DUTPorts.PortDataType(index)=[];
        end

        function setDUTPortName(h,index,name)
            h.validateDUTPortIndex(index);
            h.validateDUTPortName(name);
            h.DUTPorts.PortName{index}=name;
        end

        function setDUTPortDirection(h,index,direction)
            h.validateDUTPortIndex(index);
            h.validateDUTPortDirection(direction);
            h.DUTPorts.PortDirection{index}=direction;

            currentType=h.DUTPorts.PortType{index};
            validTypes=h.getPortTypes(direction);
            if~any(strcmp(currentType,validTypes))
                h.DUTPorts.PortType{index}=validTypes{1};
                warning(message('EDALink:FILBuildInfo:ChangePortType',h.DUTPorts.PortName{index},currentType,lower(direction)));
            end
        end

        function setDUTPortWidth(h,index,width)
            h.validateDUTPortIndex(index);
            h.validateDUTPortWidth(width);
            h.DUTPorts.PortWidth{index}=width;
        end

        function setDUTPortType(h,index,type)
            h.validateDUTPortIndex(index);
            direction=h.DUTPorts.PortDirection{index};
            h.validateDUTPortType(type,direction);
            h.DUTPorts.PortType{index}=type;
        end

        function setDUTPortDataType(h,index,type)
            h.validateDUTPortIndex(index);
            h.validateDUTPortDataType(type);
            h.DUTPorts.PortDataType{index}=type;
        end

        function dispDUTPorts(h)
            if~isempty(h.DUTPorts.PortName)
                disp('');
                maxName=max(cellfun(@length,h.DUTPorts.PortName));
                printFormat=['    %-',num2str(maxName+3),'s%-8s%-6d%s\n'];
                for n=1:numel(h.DUTPorts.PortName)
                    fprintf(printFormat,...
                    h.DUTPorts.PortName{n},h.DUTPorts.PortDirection{n},...
                    h.DUTPorts.PortWidth{n},h.DUTPorts.PortType{n});
                end
            end
        end



        function result=getClockPortName(h)
            result=h.DUTPorts.PortName(strcmp('Clock',h.DUTPorts.PortType));
            if~isempty(result)
                result=result{1};
            else
                result='';
            end
        end

        function result=getClockEnablePortName(h)
            result=h.DUTPorts.PortName(strcmp('Clock enable',h.DUTPorts.PortType));
            if~isempty(result)
                result=result{1};
            else
                result='';
            end
        end

        function result=getResetPortName(h)
            result=h.DUTPorts.PortName(strcmp('Reset',h.DUTPorts.PortType));
            if~isempty(result)
                result=result{1};
            else
                result='';
            end
        end



        function setOutputFolder(h,value)
            h.validateChar(value,'Output folder');
            h.PrivOutputFolder=value;
        end

        function unsetOutputFolder(h)
            h.PrivOutputFolder='';
        end



        function validateSourceFiles(h)

            if~any(cellfun(@h.isEligibleTopLevel,h.SourceFiles.FileType))
                error(message('EDALink:FILBuildInfo:NoHDLSrcFile'));
            end



            idx=cellfun(@(x)exist(x,'file')~=2,h.SourceFiles.FilePath);
            if any(idx)
                invalidFile=h.SourceFiles.FilePath(idx);
                error(message('EDALink:FILBuildInfo:MissingSrcFile',sprintf('    %s\n',invalidFile{:})));
            end
        end

        function validateDUTPortName(h,value)
            h.validateChar(value,'Port name');
            if~h.isValidHDLName(value)
                error(message('EDALink:FILBuildInfo:InvalidHDLPortName',value));
            end
        end

        function validateDUTPortWidth(h,value)
            h.validatePosInteger(value,'Port width');
        end

        function validateDUTPortDataType(h,value)
            h.validateChar(value,'Port datatype');
            if~any(strcmp(value,h.PortDateTypeEnum))
                error(message('EDALink:FILBuildInfo:InvalidPortDataType',value));
            end
        end

        function validateDUTPorts(h)

            inPorts=strcmp(h.InPortEnum,h.DUTPorts.PortDirection);
            outPorts=strcmp(h.OutPortEnum,h.DUTPorts.PortDirection);
...
...
...
...
...
...
            if~(any(strcmp('Data',h.DUTPorts.PortType(outPorts))))
                error(message('EDALink:FILBuildInfo:AtLeastOneOut'));
            end


            [uniquePorts,idx]=unique(lower(h.DUTPorts.PortName));
            if numel(uniquePorts)<numel(h.DUTPorts.PortName)
                dup=setdiff(1:numel(h.DUTPorts.PortName),idx);
                error(message('EDALink:FILBuildInfo:DuplicatePort',sprintf('%s\n',h.DUTPorts.PortName{dup})));
            end


            clkPorts=strcmp('Clock',h.DUTPorts.PortType);
            if sum(clkPorts)>1
                error(message('EDALink:FILBuildInfo:MultipleClocks'));
            else

                cePorts=strcmp('Clock enable',h.DUTPorts.PortType);
                rstPorts=strcmp('Reset',h.DUTPorts.PortType);
                if sum(clkPorts)==1
                    if(sum(cePorts)>1)
                        error(message('EDALink:FILBuildInfo:MultipleClockEnables'));
                    end

                    if(sum(clkPorts)~=1)||(sum(rstPorts)~=1)
                        error(message('EDALink:FILBuildInfo:ClkEnRstNotOne'));
                    end



                    if h.DUTPorts.PortWidth{clkPorts}~=1
                        error(message('EDALink:FILBuildInfo:ClkNot1Bit'));
                    end
                    if sum(cePorts)==1
                        if h.DUTPorts.PortWidth{cePorts}~=1
                            error(message('EDALink:FILBuildInfo:ClkEnNot1Bit'));
                        end
                    end
                    if h.DUTPorts.PortWidth{rstPorts}~=1
                        error(message('EDALink:FILBuildInfo:RstNot1Bit'));
                    end

                elseif(sum(cePorts)~=0)||(sum(rstPorts)~=0)
                    error(message('EDALink:FILBuildInfo:ClkEnRstNotZero'));
                end
            end


            inDataPorts=strcmpi(h.DUTPorts.PortType,'Data')&inPorts;
            outDataPorts=strcmpi(h.DUTPorts.PortType,'Data')&outPorts;

            numInputBytes=sum(ceil([h.DUTPorts.PortWidth{inDataPorts}]/8));
            numOutputBytes=sum(ceil([h.DUTPorts.PortWidth{outDataPorts}]/8));
            if numInputBytes>1472||numOutputBytes>1472
                error(message('EDALink:FILBuildInfo:PortSizeOverMTU'));
            elseif numInputBytes>512||numOutputBytes>512
                warning(message('EDALink:FILBuildInfo:PortSizeTooLarge'));
            end
        end

        function validateDUTPortConnectivity(h,Direction,value)
            if~isempty(value)
                h.validateChar(value,'Port Connectivity');
                if strcmp(Direction,'In')
                    if~any(strcmp(value,h.InPortConnectivityEnum))
                        error(message('EDALink:FILBuildInfo:InvalidPortConnectivity',value));
                    end
                elseif strcmp(Direction,'Out')
                    if~any(strcmp(value,h.OutPortConnectivityEnum))
                        error(message('EDALink:FILBuildInfo:InvalidPortConnectivity',value));
                    end
                else
                    error(message('EDALink:FILBuildInfo:InvalidPortDir',value));
                end
            end
        end






        function valid=isEligibleTopLevel(h,value)
            valid=any(strcmp(value,h.HDLFilesEnum));
        end

        function valid=isValidHDLName(h,value)


            valid=~isempty(value)&&h.isValidVHDLName(value);
        end


        function isDefault=isDefaultOutputFolder(h)
            isDefault=isempty(h.PrivOutputFolder);
        end
    end

    methods(Static)




        function validateIPByte(value)
            byte=str2num(value);%#ok<ST2NM>
            if isempty(byte)||~isnumeric(byte)||(rem(byte,1)~=0)...
                ||(byte<0)||(byte>255)
                error(message('EDALink:FILBuildInfo:InvalidIPByte'));
            end
        end

        function validateMACByte(value)
            if length(value)~=2
                error(message('EDALink:FILBuildInfo:InvalidMACAddr'));
            end
            try
                hex2dec(value(1));
                hex2dec(value(2));
            catch ME
                error(message('EDALink:FILBuildInfo:InvalidMACAddr'));
            end
        end



    end

    methods(Access=protected)


        function setToolInfoObj(h)
            switch h.BoardObj.Component.PartInfo.FPGAVendor
            case 'Xilinx'
                switch h.BoardObj.Component.PartInfo.FPGAFamily
                case{'Kintex7','Virtex7','Zynq UltraScale+'}
                    h.ToolInfoObj=eda.internal.workflow.VivadoInfo;
                otherwise
                    h.ToolInfoObj=eda.internal.workflow.ISEInfo;
                end
            case 'Altera'
                h.ToolInfoObj=eda.internal.workflow.QuartusInfo;
            case 'Microsemi'
                h.ToolInfoObj=eda.internal.workflow.LiberoInfo;
            otherwise
                error(message('EDALink:FILBuildInfo:UndefinedVendor'));
            end
        end

        function updateNetlistFileType(h)
            if~isempty(h.SourceFiles.FileType)
                for n=1:numel(h.OldNetlistType)
                    match=strcmp(h.OldNetlistType{n},h.SourceFiles.FileType);

                    h.SourceFiles.FileType(match)=h.ToolInfoObj.NetlistType(1);
                end
            end
        end



        function valid=isValidAssertedLevel(h,value)
            h.validateChar(value);
            valid=any(strcmp(value,h.getAssertedLevels));
        end

        function validateSourceFileIndex(h,value)
            h.validatePosInteger(value,'Source file index');
            num=numel(h.SourceFiles.FilePath);
            if value>num
                error(message('EDALink:FILBuildInfo:InvalidFileIdx',value,num));
            end
        end

        function validateSourceFilePath(h,value)
            h.validateChar(value,'File path');
        end

        function validateSourceFileType(h,value)
            h.validateChar(value,'File type');
            if~any(strcmp(value,h.getFileTypes))
                error(message('EDALink:FILBuildInfo:InvalidFileType',value));
            end
        end

        function validateDUTPortIndex(h,value)
            h.validatePosInteger(value,'DUT port index');
            num=numel(h.DUTPorts.PortName);
            if value>num
                error(message('EDALink:FILBuildInfo:InvalidPortIdx',value,num));
            end
        end

        function validateDUTPortDirection(h,value)
            h.validateChar(value,'Port direction');
            if~any(strcmp(value,h.getPortDirections))
                error(message('EDALink:FILBuildInfo:InvalidPortDir',value));
            end
        end

        function validateDUTPortType(h,value,direction)
            h.validateChar(value,'Port type');
            if~any(strcmp(value,h.getPortTypes(direction)))
                error(message('EDALink:FILBuildInfo:InvalidPortType',value,lower(direction)));
            end
        end

        function validateFPGASystemClockFrequency(h,FPGASystemClockFrequency)
            SYSCLK=h.BoardObj.Component.SYSCLK;
            ClkComponent=[];

            if FPGASystemClockFrequency<5||FPGASystemClockFrequency>200
                error(message('EDALink:FILBuildInfo:DUTFrequencyOutOfRange',num2str(round(FPGASystemClockFrequency,4))));
            end


            switch h.BoardObj.Component.Communication_Channel
            case{'Altera JTAG','SGMII','GMII'}

                ClkComponent=h.BoardObj.Component.PartInfo.ClkMgr_GMII(SYSCLK,FPGASystemClockFrequency);
            case 'PCIe'

                ClkComponent=h.BoardObj.Component.PartInfo.ClkMgr_PCIe(SYSCLK,FPGASystemClockFrequency);



            case 'MII'

                ClkComponent=h.BoardObj.Component.PartInfo.ClkMgr_MII(SYSCLK,FPGASystemClockFrequency);
            case 'RGMII'

                ClkComponent=h.BoardObj.Component.PartInfo.ClkMgr_RGMII(SYSCLK,FPGASystemClockFrequency);




            end

            DUTClkNode=n_getCorrectChildNode(ClkComponent);


            switch DUTClkNode.UniqueName
            case 'MMCM_BASE'
                Clkfbout_mult_f=str2double(DUTClkNode.generic.CLKFBOUT_MULT_F.default_Value);



                if strcmpi(h.BoardObj.Component.Communication_Channel,'MII')

                    Clkout1_divide=str2double(DUTClkNode.generic.CLKOUT0_DIVIDE_F.default_Value);
                else
                    Clkout1_divide=str2double(DUTClkNode.generic.CLKOUT1_DIVIDE.default_Value);
                end

                ActualDUTFrequency=h.BoardObj.Component.SYSCLK.Frequency*Clkfbout_mult_f/Clkout1_divide;
            case{'DCM_SP','DCM_BASE'}
                CLKDV_DIVIDE=str2double(DUTClkNode.generic.CLKDV_DIVIDE.default_Value);

                ActualDUTFrequency=h.BoardObj.Component.SYSCLK.Frequency/CLKDV_DIVIDE;
            case 'altpll'
                Div1=str2double(DUTClkNode.generic.clk0_divide_by.instance_Value);
                Mult1=str2double(DUTClkNode.generic.clk0_multiply_by.instance_Value);

                ActualDUTFrequency=h.BoardObj.Component.SYSCLK.Frequency*Mult1/Div1;
            otherwise
                ActualDUTFrequency=FPGASystemClockFrequency;
            end
            h.ActualDUTFrequency_P=ActualDUTFrequency;




            l_CheckRequestedVSActualDUTFrequency(ActualDUTFrequency,FPGASystemClockFrequency);

            function DUTClkNode=n_getCorrectChildNode(ClkComponent)
                if isempty(ClkComponent)

                    DUTClkNode.UniqueName='none';
                    return;
                end
                for idx=1:length(ClkComponent.ChildNode)
                    if nnz(strcmpi(ClkComponent.ChildNode{idx}.UniqueName,{'MMCM_BASE','altpll','DCM_SP','DCM_BASE'}))
                        DUTClkNode=ClkComponent.ChildNode{idx};
                        return;
                    end
                end
                DUTClkNode.UniqueName='none';
            end
        end
    end


    methods(Access=protected,Static)
        function valid=isValidVHDLName(value)
            identifier='[a-zA-Z][a-zA-Z0-9_]*';
            tmp=regexp(value,identifier,'match','once');
            valid=strcmp(tmp,value);
        end

        function valid=isValidVerilogName(value)
            identifier='[a-zA-Z_][a-zA-Z0-9_$]*';
            tmp=regexp(value,identifier,'match','once');
            valid=strcmp(tmp,value);
        end

        function validateChar(value,name)
            if nargin<2
                name='Input';
            end
            if isempty(value)||~ischar(value)
                error(message('EDALink:FILBuildInfo:InputNotStr',name));
            end
        end

        function validatePosInteger(value,name)
            if nargin<2
                name='Input';
            end
            if isempty(value)||~isnumeric(value)||(rem(value,1)~=0)||(value<=0)
                error(message('EDALink:FILBuildInfo:InputNotPosInt',name));
            end
        end

        function validateInteger(value,name)
            if nargin<2
                name='Input';
            end
            if isempty(value)||~isnumeric(value)||(rem(value,1)~=0)
                error(message('EDALink:FILBuildInfo:InputNotInt',name));
            end
        end

        function validateLogical(value,name)
            if nargin<2
                name='Input';
            end
            if isempty(value)||~islogical(value)
                error(message('EDALink:FILBuildInfo:InputNotLog',name));
            end
        end

    end
end


function l_CheckRequestedVSActualDUTFrequency(ActualDUTFrequency,FPGASystemClockFrequency)


    if abs(ActualDUTFrequency-FPGASystemClockFrequency)>1e-4

        error(message('EDALink:FILBuildInfo:UnattainableDUTClockFrequency',num2str(round(ActualDUTFrequency,4)),num2str(round(FPGASystemClockFrequency,4))));
    end
end



