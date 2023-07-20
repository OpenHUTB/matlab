classdef FILBuildInfo<eda.internal.workflow.FPGABuildInfo




    properties(SetAccess=protected)
        FILVersion;
    end

    properties
        Tool='Simulink';
        TopLevelName='';
        DUTClockFrequency=25;
        ContainsPrefDirSettings;
        EnableHWBuffer=true;
    end

    properties
        SkipFPGAProgFile=false;
    end

    properties(SetAccess=protected)
        OutputDataTypes;
    end

    properties(Constant,Hidden)
        ToolList={'MATLAB System Object','Simulink'};
    end

    properties(Constant,Hidden)
        OutputDataTypeEnum={'Inherit','Fixedpoint','Boolean','Logical','Integer','Double','Single'};
    end

    properties(Dependent)
        FPGATool;
    end

    methods(Access=private)
        function PreferedSetting=IsTherePreferredSettings(h)
            PreferedSetting=true;
            h.ContainsPrefDirSettings=true;

            if ispref('FILSetup','PreferedFPGABoard')

                BoardName=getpref('FILSetup','PreferedFPGABoard');

                hManager=eda.internal.boardmanager.BoardManager.getInstance;
                filBoardNames=hManager.getFILBoardNamesByVendor('all');
                if~any(strcmp(BoardName,filBoardNames))

                    PreferedSetting=false;
                    h.ContainsPrefDirSettings=false;
                    return;
                end
            else
                PreferedSetting=false;
                h.ContainsPrefDirSettings=false;
                return;
            end


            if ispref('FILSetup','PreferedFPGABoard')

                ConnectionsAvailable=hManager.getBoardObj(BoardName).getFILConnectionOptions;
                FILConnection=cellfun(@(x)x.Name,ConnectionsAvailable,'UniformOutput',false);
                TempInterfaceIdx=find(strcmp(getpref('FILSetup','PreferedFILInterface'),...
                FILConnection));
                if isempty(TempInterfaceIdx)

                    PreferedSetting=false;
                    h.ContainsPrefDirSettings=false;
                    return;
                end
            else
                PreferedSetting=false;
                h.ContainsPrefDirSettings=false;
                return;
            end

            if strcmpi(FILConnection{TempInterfaceIdx(1)},'Ethernet')

                if ispref('FILSetup','PreferedFPGA_IP')

                    IpAddress=getpref('FILSetup','PreferedFPGA_IP');
                    CorrectFormat=iscell(IpAddress)&&...
                    numel(IpAddress)==4&&...
                    ~any(cellfun(@isempty,IpAddress));

                    if~CorrectFormat
                        PreferedSetting=false;
                        h.ContainsPrefDirSettings=false;
                        return;
                    end

                    CorrectIP=~any(cellfun(@(byte)isempty(str2num(byte))||~isnumeric(str2num(byte))||(rem(str2num(byte),1)~=0)...
                    ||(str2num(byte)<0)||(str2num(byte)>255),IpAddress));

                    if~CorrectIP
                        PreferedSetting=false;
                        h.ContainsPrefDirSettings=false;
                        return;
                    end

                else

                    PreferedSetting=false;
                    h.ContainsPrefDirSettings=false;
                    return;
                end
            end
        end
    end

    methods

        function h=FILBuildInfo

            h.FILVersion=struct('Major',uint8(2),'Minor',uint8(0));

            h.BuildInfoVersion=struct('Major',1,'Minor',1);

            if h.IsTherePreferredSettings()
                h.Board=getpref('FILSetup','PreferedFPGABoard');


                h.setConnection(getpref('FILSetup','PreferedFILInterface'));
                if strcmp(getpref('FILSetup','PreferedFILInterface'),'Ethernet')
                    FPGA_IPAddress=getpref('FILSetup','PreferedFPGA_IP');


                    h.IPAddress=[FPGA_IPAddress{1},'.',FPGA_IPAddress{2},'.',FPGA_IPAddress{3},'.',FPGA_IPAddress{4}];
                end

                try

                    h.FPGASystemClockFrequency='25MHz';
                catch



                    h.FPGASystemClockFrequency=[num2str(h.getActualDUTFrequency),'MHz'];
                end

            else

                h.BoardObj=eda.board.AlteraArriaIIGX;

                h.FPGASystemClockFrequency='25MHz';
            end


            h.setToolInfoObj;

            h.ProjectSuffix='fil';
            h.initializeSourceFiles;
            h.initializeDUTPorts;
            h.initializeOutputDataTypes;

        end

        function setBoardObj(h,value)
            if ischar(value)
                h.validateChar(value,'Board');
                hManager=eda.internal.boardmanager.BoardManager.getInstance;
                filBoardNames=hManager.getFILBoardNamesByVendor('all');
                if~any(strcmp(value,filBoardNames))
                    error(message('EDALink:FILBuildInfo:InvalidBoard',value));
                end
                boardObj=hManager.getFILBoardObj(value);
                h.BoardObj=boardObj;
            else
                h.BoardObj=value;
            end
        end
        function setConnection(h,connection)
            if ischar(connection)

                hManager=eda.internal.boardmanager.BoardManager.getInstance;
                boardObj=hManager.getBoardObj(h.Board);
                ConnectionOpts=boardObj.getFILConnectionOptions;

                connectionStruct=ConnectionOpts{1};
                for m=2:numel(ConnectionOpts)
                    if strcmpi(connection,ConnectionOpts{m}.Name)
                        connectionStruct=ConnectionOpts{m};
                    end
                end
            else
                connectionStruct=connection;
            end

            if isempty(connectionStruct.Name)

                return;
            end
            h.BoardObj.ConnectionOptions=connectionStruct;
            Component=h.BoardObj.Component;
            Component.Communication_Channel=connectionStruct.Communication_Channel;
            h.BoardObj.setComponent(Component);
        end


        function set.Tool(h,value)
            if(~any(strcmp(h.ToolList,value)))
                error(message('EDALink:FILBuildInfo.InvalidTool',value));
            end
            h.Tool=value;
        end



        function set.SkipFPGAProgFile(h,value)
            if(~isa(value,'logical')||(numel(value)~=1))
                error(message('EDALink:FILBuildInfo.InvalidSkipFPGAProgFile',value));
            end
            h.SkipFPGAProgFile=value;
        end


        function initializeOutputDataTypes(h)
            h.OutputDataTypes=struct('Name',{{}},'BitWidth',{{}},...
            'DataType',{{}},'Sign',{{}},'FracLen',{{}});
        end

        function addOutputDataType(h,name,bitwidth,datatype,sign,fraclen)

            h.validateOutputDataTypeName(name);
            h.validateOutputDataTypeBitWidth(bitwidth);
            h.validateOutputDataTypeDataType(datatype);
            h.validateOutputDataTypeSign(sign);
            h.validateOutputDataTypeFracLen(fraclen);

            h.OutputDataTypes.Name{end+1}=name;
            h.OutputDataTypes.BitWidth{end+1}=bitwidth;
            h.OutputDataTypes.DataType{end+1}=datatype;
            h.OutputDataTypes.Sign{end+1}=sign;
            h.OutputDataTypes.FracLen{end+1}=fraclen;
        end

        function removeOutputDataType(h,index)
            h.validateOutputDataTypeIndex(index);
            h.OutputDataTypes.Name(index)=[];
            h.OutputDataTypes.BitWidth(index)=[];
            h.OutputDataTypes.DataType(index)=[];
            h.OutputDataTypes.Sign(index)=[];
            h.OutputDataTypes.FracLen(index)=[];
        end

        function validateOutputDataTypeName(h,value)
            h.validateChar(value,'Output name');
        end

        function validateOutputDataTypeBitWidth(h,value)
            h.validatePosInteger(value,'Output bit width');
        end

        function validateOutputDataTypeDataType(h,value)
            h.validateChar(value,'Output datatype');
            if~any(strcmp(value,h.OutputDataTypeEnum))
                error(message('EDALink:FILBuildInfo:InvalidOutputDataType',value));
            end
        end

        function validateOutputDataTypeSign(h,value)
            h.validateLogical(value,'Output sign');
        end

        function validateOutputDataTypeFracLen(h,value)
            h.validateInteger(value,'Output fraction length');
        end

        function validateOutputDataTypeIndex(h,value)
            h.validatePosInteger(value,'Output data type index');
            num=numel(h.OutputDataTypes.Name);
            if value>num
                error(message('EDALink:FILBuildInfo:InvalidOutputDataTypeIdx',value,num));
            end
        end

        function validateOutputDataTypes(h)

            [uniquePorts,idx]=unique(lower(h.OutputDataTypes.Name));
            if numel(uniquePorts)<numel(h.OutputDataTypes.Name)
                dup=setdiff(1:numel(h.OutputDataTypes.Name),idx);
                error(message('EDALink:FILBuildInfo:DuplicateOutputDataType',sprintf('%s\n',h.OutputDataTypes.Name{dup})));
            end
        end

        function r=get.FPGATool(h)
            hMgr=eda.internal.boardmanager.BoardManager.getInstance;
            bObj=hMgr.getBoardObj(h.Board);
            r=bObj.getFILFPGAToolName;
        end

        function filetypestr=getDefaultFileType(this,filename)
            fpgavendor=this.BoardObj.Component.PartInfo.FPGAVendor;

            [~,~,ext]=fileparts(filename);
            ext=lower(ext);
            switch(fpgavendor)
            case 'Xilinx'
                switch(ext)
                case '.vhd'
                    type=0;
                case '.v'
                    type=1;
                case{'.edif','.edf','.ngc'}
                    type=2;
                case '.tcl'
                    type=3;
                case '.ucf'
                    type=4;
                otherwise
                    type=5;
                end
            otherwise
                switch(ext)
                case '.vhd'
                    type=0;
                case '.v'
                    type=1;
                case{'.edif','.edf'}
                    type=2;
                case '.vqm'
                    type=3;
                case '.qsf'
                    type=4;
                case '.sdc'
                    type=5;
                otherwise
                    type=6;
                end
            end
            filetypeenum=this.FileTypeEnum;
            filetypestr=filetypeenum{type+1};
        end
        function set.EnableHWBuffer(h,val)

            if strcmpi(h.BoardObj.ConnectionOptions.RTIOStreamLibName,'mwrtiostreamtcpip')
                if val
                    h.BoardObj.ConnectionOptions.ProtocolParams='NumHWBuf=22';
                else
                    h.BoardObj.ConnectionOptions.ProtocolParams='';
                end
            end
            h.EnableHWBuffer=val;
        end
    end

end
