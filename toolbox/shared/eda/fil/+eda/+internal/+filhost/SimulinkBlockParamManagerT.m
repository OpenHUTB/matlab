



classdef SimulinkBlockParamManagerT<handle

    methods(Static)





        function CopyFcn(blkH)
            try
                p=get_param(blkH,'UserData');
                params=eda.internal.filhost.ParamsT(p);
            catch ME %#ok<NASGU>
                warndlg(['UserData did not contain a valid parameter object. ',...
                'Using the default FIL block parameter set.'],...
                'No saved parameter set.');

                params=CreateDefaultParams();
            end
            eda.internal.filhost.SimulinkBlockParamManagerT.SetUserData(blkH,params);
        end

        function InitFcn(blkH)

            try
                p=get_param(blkH,'UserData');
                if strcmpi(p.connectionOptions.Communication_Channel,'PSEthernet')
                    setuplibiio;
                end
            catch
            end
        end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

        function params=CreateDefaultParams()
            inport=eda.internal.filhost.PortInfoT(...
            'name','hdl_input_signal',...
            'elemBitwidth',8,...
            'sampleTime','Inherit: Inherit via propagation',...
            'dtypeSpec','Inherit: auto'...
            );
            outport=eda.internal.filhost.PortInfoT(...
            'name','hdl_output_signal',...
            'elemBitwidth',8,...
            'sampleTime','Inherit: Inherit via internal rule',...
            'dtypeSpec','ufix8'...
            );
            params=eda.internal.filhost.ParamsT(...
            'inputPorts',inport,...
            'outputPorts',outport...
            );
        end

        function SetUserData(blk,params)
            set_param(blk,'UserDataPersistent','on');
            set_param(blk,'UserData',params);
            eda.internal.filhost.SimulinkBlockParamManagerT.ForceLibLoad(blk);
        end

        function ForceLibLoad(blk)
            set_param(blk,'ForceInterfaceUpdate',num2str(rand(1)));
        end

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...


        function fp=l_flattenPorts(portArray)

            tmpA=sprintf('''%s'',',portArray.name);tmpA(end)=[];
            fp{1}=tmpA;

            fp{end+1}=[portArray.elemBitwidth];
            fp{end+1}=[portArray.validPhase];




            tmpc1=cellfun(@(x)(sprintf('''%s'',',mat2str(x))),{portArray.dimensions},'UniformOutput',false);
            tmpc2=regexprep(tmpc1,'[\[\]]','');
            tmpc3=sprintf('%s',tmpc2{:});
            fp{end+1}=tmpc3(1:end-1);

            fp{end+1}=[portArray.numElems];
            fp{end+1}=[portArray.complexity];
            fp{end+1}=[portArray.frameness];
            fp{end+1}=[portArray.directFeedthrough];

            stimes=[portArray.sampleTime];
            fp{end+1}=[stimes.inhRule];
            fp{end+1}=[stimes.period];
            fp{end+1}=[stimes.offset];

            dtypes=[portArray.dtypeSpec];
            fp{end+1}=[dtypes.mode];
            fp{end+1}=[dtypes.inhRule];
            fp{end+1}=[dtypes.builtin];
            fp{end+1}=[dtypes.fxScalingMode];
            fp{end+1}=[dtypes.signedness];
            dtsspec=[dtypes.fxScalingSpec];
            fp{end+1}=[dtsspec.wordLength];
            fp{end+1}=[dtsspec.fractionLength];
            fp{end+1}=[dtsspec.totalSlope];
            fp{end+1}=[dtsspec.bias];
        end







        function fp=GetFlatSfuncParams(blkH)
            p=get_param(blkH,'UserData');
            if(isempty(p))
                disp('ERROR: no user data associated with FIL block.  You must create a new block using the FIL Wizard.');
                return;




            else
                simstat=get_param(bdroot(blkH),'SimulationStatus');
                fp=eda.internal.filhost.SimulinkBlockParamManagerT.GetFlatSfuncParamsP(p,simstat);
            end
        end


        function fp=GetFlatSfuncParamsP(p,simstat)

            ps=p.getStruct(simstat);

            fp{1}=ps.softwareVersion.majorRev;
            fp{end+1}=ps.softwareVersion.minorRev;
            fp{end+1}=ps.overclocking.inhRule;
            fp{end+1}=ps.overclocking.value;
            fp{end+1}=ps.resetFpga;
            fp{end+1}=ps.resetDut;
            fp{end+1}=ps.processingMode;
            fp{end+1}=ps.inputFrameSize.inhRule;
            fp{end+1}=ps.inputFrameSize.value;
            fp{end+1}=ps.outputFrameSize.inhRule;
            fp{end+1}=ps.outputFrameSize.value;
            fp{end+1}=ps.numInputPorts;
            fp{end+1}=ps.numOutputPorts;
            fp{end+1}=ps.testMode;

            fin=eda.internal.filhost.SimulinkBlockParamManagerT.l_flattenPorts([ps.inputPorts]);
            finl=length(fin);
            fp(end+1:end+1+finl-1)=fin;

            fout=eda.internal.filhost.SimulinkBlockParamManagerT.l_flattenPorts([ps.outputPorts]);
            foutl=length(fout);
            fp(end+1:end+1+foutl-1)=fout;

            protoParams='';
            if isempty(ps.connectionOptions)...
                ||strcmpi(ps.connectionOptions.Name,'UDP')...
                ||(strcmpi(ps.connectionOptions.Name,'Ethernet')&&~strcmpi(ps.connectionOptions.Communication_Channel,'PSEthernet'))
                RemoteURL=ps.commIPDevices(1).remoteURL;
                if ps.commIPDevices(1).remotePort==-1
                    RemotePort='50101';
                else
                    RemotePort=num2str(ps.commIPDevices(1).remotePort);
                end
                if ps.testMode
                    TimeOut='5';
                else
                    TimeOut='1';
                end
                connection='UDP';
                libName='libmwrtiostreamtcpip';
                libParams=['-protocol UDP -port ',RemotePort,' -hostname ',RemoteURL,' -client 1 -recv_timeout_secs ',TimeOut,' -blocking 1'];
            else
                if strcmpi(ps.connectionOptions.Communication_Channel,'PSEthernet')
                    connection='TCPIP';
                else
                    connection=ps.connectionOptions.Name;
                end
                libName=eda.internal.workflow.getRtiostreamLibraryPath(ps.connectionOptions.RTIOStreamLibName);
                libParams=ps.connectionOptions.RTIOStreamParams;
                if strcmpi(libName,'libmwrtiostream_xjtag')
                    ftd2xxLibPath=matlab.internal.get3pInstallLocation('FTCJTAG.instrset');
                    libParams=sprintf('%s;FTD2XXLIBPath=%s',libParams,ftd2xxLibPath);
                elseif contains(libName,'libmwrtiostream_libiio')
                    libParams=sprintf('ip:%s',ps.dialogState.IPAddress);
                end
            end
            if isfield(ps.connectionOptions,'ProtocolParams')
                protoParams=ps.connectionOptions.ProtocolParams;
            end

            fp{end+1}=connection;
            fp{end+1}=libName;
            fp{end+1}=libParams;
            fp{end+1}=protoParams;



        end

        function SetSfuncIconStr(blkH)
            imageStr='image(imread(''filblkicon.png''),''center'');';
            imageLabel='fprintf(''\n\n\nFIL'');';

            p=get_param(blkH,'UserData');
            portLabels='';
            for idx=1:p.getNumInputPorts()
                portLabels=sprintf('%s\nport_label(''input'', %d, ''%s'');',...
                portLabels,idx,l_createPortName(p.inputPorts(idx).name));
            end
            for idx=1:p.getNumOutputPorts()
                portLabels=sprintf('%s\nport_label(''output'', %d, ''%s'');',...
                portLabels,idx,l_createPortName(p.outputPorts(idx).name));
            end
            iconStr=sprintf('%s\n%s\n%s\n',imageStr,imageLabel,portLabels);
            set_param(blkH,'MaskDisplay',iconStr);
        end


        function CreateUntitledMdl(params)
            load_system('fillib');

            ns=new_system('','FromTemplate','factory_default_model');
            nsName=get_param(ns,'Name');


            blkName=[nsName,'/',params.buildInfo.DUTName];

            position=double([45,25,45+l_blockWidth(params),25+l_blockHeight(params)]);
            add_block('fillib/FPGA-in-the-Loop (FIL)',blkName,...
            'Position',position);

            eda.internal.filhost.SimulinkBlockParamManagerT.SetUserData(blkName,params);


            position=double([45,(25+l_blockHeight(params)+45)]);

            instruction=[nsName,'/',...
            'Follow these steps to perform FPGA-in-the-Loop simulation:',newline,...
            newline,...
            '1. Drag this block into a Simulink model.',newline,...
            '2. Connect all inputs and outputs.',newline,...
            '3. Open the block mask to optionally change:',newline,...
            '    - output sample times, data types, and frame size',newline,...
            '    - HDL overclocking factor',newline,...
            '    Usually the mask defaults will work in your model without modification.',newline];
            if~isempty(params.connectionOptions)&&strcmpi(params.connectionOptions.Name,'PCI Express')

                instruction=[instruction,...
                '4. Open the block mask and click Load to download the FPGA programming file.',newline,...
                newline,...
                'See the product documentation for more detailed instructions and',newline,...
                'troubleshooting tips.'];
            else

                instruction=[instruction,...
                '4. Attach the FPGA development board to your host computer (FPGA ',newline,...
                '    programming cable and Gigabit Ethernet cable).',newline,...
                '5. Set the host IP address (see product documentation).',newline,...
                '6. Open the block mask and click Load to download the FPGA programming file.',newline,...
                newline,...
                'See the product documentation for more detailed instructions and',newline,...
                'troubleshooting tips.'];
            end

            add_block('built-in/Note',instruction,...
            'FontSize',14,...
            'Position',position,...
            'HorizontalAlignment','left',...
            'VerticalAlignment','top',...
            'DropShadow','on');

            close_system('fillib',0);


            open_system(ns);
            set_param(ns,'ZoomFactor','FitSystem');
            curPos=get_param(ns,'Location');
            set_param(ns,'Location',1.4*(curPos));

            set_param(ns,'ZoomFactor','100');
        end

    end

end

function w=l_blockWidth(params)
    pnames={params.inputPorts.name,params.outputPorts.name};
    maxCharsPerPort=18;
    charsPerPort=min(max(cellfun(@(x)(length(x)),pnames)),maxCharsPerPort);
    pixelsPerChar=8;
    imageWidth=5;
    w=pixelsPerChar*(charsPerPort*2+imageWidth);
end
function h=l_blockHeight(params)
    pixelsPerPort=30;
    maxPorts=max(params.getNumInputPorts,params.getNumOutputPorts);
    h=pixelsPerPort*maxPorts;
end
function iconName=l_createPortName(fullName)
    if(length(fullName)>15)
        iconName=[fullName(1:15),'...'];
    else
        iconName=fullName;
    end
end
