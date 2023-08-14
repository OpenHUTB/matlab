



















classdef ParamsT
    properties
        buildInfo=eda.internal.workflow.FILBuildInfo;
        dialogState=eda.internal.filhost.DialogStateT;
        softwareVersion=eda.internal.filhost.SoftwareVersionT;
        overclocking=eda.internal.filhost.InhUint32T('1');
        resetFpga=true;
        resetDut=true;
        processingMode=eda.internal.filhost.ProcessingModeT.ProcessAsSamples;
        inputFrameSize=eda.internal.filhost.InhUint32T('Inherit: auto');
        outputFrameSize=eda.internal.filhost.InhUint32T('Inherit: auto');
        testMode=eda.internal.filhost.TestModeT('FPGA-in-the-Loop');
        inputPorts=eda.internal.filhost.PortInfoT;
        outputPorts=eda.internal.filhost.PortInfoT;
        connectionOptions=[];
        programFPGAOptions=[];
        commIPDevices=repmat(eda.internal.filhost.CommIPAddressInfoT,1,4);
    end
    methods(Static)
        function obj=loadobj(a)
            obj=a;
            if isa(a.buildInfo,'eda.internal.workflow.FILBuildInfo')
                newBuildInfo=l_convertBuildInfoToStruct(a.buildInfo);
                obj.buildInfo=newBuildInfo;
            end
        end
    end
    methods
        function obj=saveobj(a)
            obj=a;
            newBuildInfo=l_convertBuildInfoToStruct(a.buildInfo);
            obj.buildInfo=newBuildInfo;
        end
    end
    methods
        function this=ParamsT(varargin)
            if(nargin==1&&isa(varargin{1},'eda.internal.workflow.FILBuildInfo'))
                this=l_FILBuildInfoToParamsTCtor(this,varargin{1});
            else
                this=eda.internal.mcosutils.ObjUtilsT.Ctor(this,varargin{:});
            end
        end

        function this=addPort(this,portDir,portInfo)
            if(~isa(portInfo,'eda.internal.filhost.PortInfoT'))
                error(message('EDALink:ParamsT:BadPortInfoClass'));
            end
            switch(portDir)
            case 'InputPort'
                this.inputPorts(this.getNumInputPorts()+1)=portInfo;
            case 'OutputPort'
                this.outputPorts(this.getNumOutputPorts()+1)=portInfo;
            otherwise
                error(message('EDALink:ParamsT:BadPortDir'));
            end
        end

        function this=clearPorts(this,portDir)
            switch(portDir)
            case 'InputPort'
                this.inputPorts=eda.internal.filhost.PortInfoT;
            case 'OutputPort'
                this.outputPorts=eda.internal.filhost.PortInfoT;
            otherwise
                error(message('EDALink:ParamsT:BadPortDir'));
            end
        end

        function numports=getNumInputPorts(this)
            if(isempty(this.inputPorts)||this.inputPorts(1).isNullObj())
                numports=int32(0);
            else
                numports=int32(numel(this.inputPorts));
            end
        end
        function numports=getNumOutputPorts(this)
            if(isempty(this.outputPorts)||this.outputPorts(1).isNullObj())
                numports=int32(0);
            else
                numports=int32(numel(this.outputPorts));
            end
        end
        function bitCount=getTotalBitCount(this,portDir)
            switch(portDir)
            case 'InputPort'
                portCount=this.getNumInputPorts();
                portList=this.inputPorts;
            case 'OutputPort'
                portCount=this.getNumOutputPorts();
                portList=this.outputPorts;
            end
            bitCount=0;
            while(portCount>0)
                bitCount=bitCount+portList(portCount).elemBitwidth;
                portCount=portCount-1;
            end
        end




        function this=set.softwareVersion(this,val)
            classVal=eda.internal.filhost.SoftwareVersionT(val);
            this.softwareVersion=classVal;
        end


        function this=set.overclocking(this,val)
            if(isa(val,'eda.internal.filhost.InhUint32T')&&...
                strcmp(val.inhRule.asString(),'No inheritance')&&...
                ~val.isEvalInBaseCtor)
                val=val.value;
            end
            classVal=eda.internal.filhost.InhUint32T(val,1,2^31-1);
            this.overclocking=classVal;
        end

        function this=set.resetFpga(this,val)
            this.resetFpga=eda.internal.mcosutils.ObjUtilsT.CheckBool(val,'resetFpga');
        end

        function this=set.resetDut(this,val)
            this.resetDut=eda.internal.mcosutils.ObjUtilsT.CheckBool(val,'resetDut');
        end

        function this=set.processingMode(this,val)
            this.processingMode=eda.internal.filhost.ProcessingModeT(val);
        end


        function this=set.inputFrameSize(this,val)
            if(isa(val,'eda.internal.filhost.InhUint32T')&&...
                strcmp(val.inhRule.asString(),'No inheritance')&&...
                ~val.isEvalInBaseCtor)
                val=val.value;
            end
            classVal=eda.internal.filhost.InhUint32T(val,1,2^31-1);
            this.inputFrameSize=classVal;
        end


        function this=set.outputFrameSize(this,val)
            if(isa(val,'eda.internal.filhost.InhUint32T')&&...
                strcmp(val.inhRule.asString(),'No inheritance')&&...
                ~val.isEvalInBaseCtor)
                val=val.value;
            end
            classVal=eda.internal.filhost.InhUint32T(val,1,2^31-1);
            this.outputFrameSize=classVal;
        end






        function outS=getStruct(this,simstatus)
            warnId='MATLAB:structOnObject';
            savedWarnState=warning('off',warnId);
            try
                outS=struct(this);

                outS.buildInfo=struct(this.buildInfo);
                outS.softwareVersion=struct(this.softwareVersion);
                outS.overclocking=this.overclocking.getStruct(simstatus);
                outS.resetFpga=int32(this.resetFpga);
                outS.resetDut=int32(this.resetDut);
                outS.processingMode=int32(this.processingMode);
                outS.inputFrameSize=this.inputFrameSize.getStruct(simstatus);
                outS.outputFrameSize=this.outputFrameSize.getStruct(simstatus);
                outS.numInputPorts=this.getNumInputPorts;
                outS.numOutputPorts=this.getNumOutputPorts;
                outS.testMode=this.testMode.asInt();



                if(this.getNumInputPorts==0||this.getNumInputPorts==1)
                    outS.inputPorts=this.inputPorts(1).getStruct(simstatus);
                else
                    for i=1:this.getNumInputPorts
                        if(i==1),outS.inputPorts=this.inputPorts(1).getStruct(simstatus);
                        else outS.inputPorts(i)=this.inputPorts(i).getStruct(simstatus);
                        end
                    end
                end

                if(this.getNumOutputPorts==0||this.getNumOutputPorts==1)
                    outS.outputPorts=this.outputPorts(1).getStruct(simstatus);
                else
                    for i=1:this.getNumOutputPorts
                        if(i==1),outS.outputPorts=this.outputPorts(1).getStruct(simstatus);
                        else outS.outputPorts(i)=this.outputPorts(i).getStruct(simstatus);
                        end
                    end
                end

                for i=1:numel(this.commIPDevices)
                    if(i==1)
                        outS.commIPDevices=struct(this.commIPDevices(i));
                    else
                        outS.commIPDevices(i)=struct(this.commIPDevices(i));
                    end
                end


            catch ME
                warning(savedWarnState);
                rethrow(ME);
            end
            warning(savedWarnState);
        end

    end

end









function this=l_FILBuildInfoToParamsTCtor(this,fbinfo)
    import eda.internal.filhost.*;

    this.buildInfo=fbinfo;
    p=fbinfo.DUTPorts;
    for idx=1:numel(p.PortName)
        if(~isempty(p.PortName{idx})&&strcmp(p.PortType{idx},'Data'))
            switch(p.PortDirection{idx})
            case 'In'
                portdir='InputPort';
                stime='Inherit: Inherit via propagation';
                dtype='Inherit: auto';
            case 'Out'
                portdir='OutputPort';
                stime='Inherit: Inherit via internal rule';
                dtype=['ufix',num2str(p.PortWidth{idx})];
            end
            this=this.addPort(...
            portdir,...
            eda.internal.filhost.PortInfoT(...
            'name',p.PortName{idx},...
            'elemBitwidth',p.PortWidth{idx},...
            'dtypeSpec',dtype,...
            'sampleTime',stime...
            )...
            );

        end
    end

    dSend=eda.internal.filhost.CommIPAddressInfoT(...
    'localURL','0.0.0.0','localPort',-1,...
    'remoteURL',fbinfo.IPAddress,'remotePort',-1);
    dRecv=eda.internal.filhost.CommIPAddressInfoT(...
    'localURL','0.0.0.0','localPort',-1,...
    'remoteURL',fbinfo.IPAddress,'remotePort',-1);
    cSend=dSend;
    cRecv=dRecv;

    this.commIPDevices=[dSend,dRecv,cSend,cRecv];

end

function newBuildInfo=l_convertBuildInfoToStruct(a)
    newBuildInfo.Board=a.Board;
    newBuildInfo.FPGAPartInfo=a.FPGAPartInfo;
    newBuildInfo.MACAddress=a.MACAddress;
    newBuildInfo.IPAddress=a.IPAddress;
    newBuildInfo.FPGAProjectFile=a.FPGAProjectFile;
    newBuildInfo.FPGATool=a.FPGATool;
    newBuildInfo.BoardObj.Component.PartInfo.FPGAVendor=a.BoardObj.Component.PartInfo.FPGAVendor;
    newBuildInfo.BoardObj.Component.ScanChain=a.BoardObj.Component.ScanChain;
    if isfield(a.BoardObj.Component,'UseDigilentPlugin')
        newBuildInfo.BoardObj.Component.UseDigilentPlugin=a.BoardObj.Component.UseDigilentPlugin;
    end
end
