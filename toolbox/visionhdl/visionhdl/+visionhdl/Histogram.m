classdef(StrictDefaults)Histogram<matlab.System

















































































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        NumBins='256';



        OutputDataType='Unsigned fixed point';





        OutputWL=16;
    end


    properties(Access=private)

        inFrame;
        inLine;
        histState;
        waddr;
        histRAM;
        resetRAM;
        dataAcq;
        readOut;
        readAtReset;

        dataInWL;
        dataInRef;
        yRef;
        yReg;
        readReadyReg;
        validOutReg;
        histMaxValue;
        dataReg;
        hsReg;
        heReg;
        vsReg;
        veReg;
        vldReg;
    end

    properties(Nontunable,Access=private)
        binNumber=256;
        binWL=8;
    end


    properties(Constant,Hidden)


        NumBinsSet=matlab.system.StringSet({...
        '32','64','128','256','512','1024','2048','4096'});

        OutputDataTypeSet=matlab.system.StringSet({...
        'double',...
        'single',...
        'Unsigned fixed point'});

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('visionhdl.Histogram',...
            'ShowSourceLink',false,...
            'Title','Histogram');
        end

        function groups=getPropertyGroupsImpl



            nbin=matlab.system.display.Section(...
            'PropertyList',{'NumBins'});
            outputDT=matlab.system.display.Section(...
            'Title','Output data type',...
            'PropertyList',{'OutputDataType','OutputWL'});

            groups=[nbin,outputDT];
        end
    end

    methods
        function obj=Histogram(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'NumBins');
        end

        function set.OutputWL(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'Histogram','output word length');
            obj.OutputWL=double(val);
        end
    end

    methods(Access=protected)

        function[y,readReady,validOut]=outputImpl(obj,~,~,~,~)

            y=obj.yReg(2,1);
            readReady=obj.readReadyReg(1,1);
            validOut=obj.validOutReg(2,1);
        end

        function updateImpl(obj,dataIn,CtrlIn,binAddr,RAMReset)



            histFSM(obj,obj.vsReg,CtrlIn.vStart,obj.veReg,RAMReset);

            histvalue=dataProcess(obj,obj.dataReg,obj.hsReg,obj.heReg,obj.vsReg,obj.veReg,obj.vldReg,binAddr);

            obj.dataReg=dataIn;
            obj.hsReg=CtrlIn.hStart;
            obj.heReg=CtrlIn.hEnd;
            obj.vsReg=CtrlIn.vStart;
            obj.veReg=CtrlIn.vEnd;
            obj.vldReg=CtrlIn.valid;
            obj.yReg(2,1)=obj.yReg(1,1);

            obj.validOutReg(2,1)=obj.validOutReg(1,1);
            obj.validOutReg(1,1)=obj.readReadyReg(1,1);


            if obj.readReadyReg(1,1)
                obj.yReg(1,1)=cast(histvalue,'like',obj.yRef);
            else
                obj.yReg(1,1)=obj.yRef;
            end

            obj.readReadyReg(1,1)=obj.readOut;

        end


        function setupImpl(obj,dataIn,~,binAddr,RAMReset)


            switch obj.NumBins
            case '32'
                obj.binNumber=32;
            case '64'
                obj.binNumber=64;
            case '128'
                obj.binNumber=128;
            case '256'
                obj.binNumber=256;
            case '512'
                obj.binNumber=512;
            case '1024'
                obj.binNumber=1024;
            case '2048'
                obj.binNumber=2048;
            case '4096'
                obj.binNumber=4096;
            otherwise
                obj.binNumber=256;
            end

            obj.binWL=log2(obj.binNumber);
            obj.dataInRef=fi(zeros(size(dataIn,1),size(dataIn,2)),0,obj.binWL,0);



            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(RAMReset,{'logical'},{'scalar'},'Histogram','RAMReset');
                validateattributes(binAddr,{'uint8','embedded.fi'},{'scalar','integer'},'Histogram','binAddr');
                [binAddrWL,binAddrFL,binAddrsigned]=(visionhdlshared.hdlgetwordsizefromdata(binAddr));
                coder.internal.errorIf(~(binAddrWL==obj.binWL&&binAddrFL==0&&binAddrsigned==0),'visionhdl:Histogram:InvalidBinAddr');



                if isfloat(dataIn)
                    obj.dataInWL=obj.binWL;

                else
                    obj.dataInWL=coder.const(visionhdlshared.hdlgetwordsizefromdata(dataIn));
                    [~,~,datasigned]=visionhdlshared.hdlgetwordsizefromdata(dataIn);
                    coder.internal.errorIf(datasigned==1,'visionhdl:Histogram:SignedType');
                end
            end

            outWL=double(obj.OutputWL);


            switch obj.OutputDataType
            case 'double'
                obj.yRef=double(0);
                obj.yReg=zeros(2,1);
                obj.histMaxValue=2^128;
            case 'single'
                obj.yRef=single(0);
                obj.yReg=single(zeros(2,1));
                obj.histMaxValue=2^64;
            case 'Unsigned fixed point'
                obj.yRef=fi(0,0,outWL,0);
                obj.yReg=fi(zeros(2,1),0,outWL,0);
                obj.histMaxValue=2^outWL-1;
            end

            startFrameCleanup(obj);
            obj.dataReg=cast(zeros(size(dataIn,1),size(dataIn,2)),'like',dataIn);
        end


        function validateInputsImpl(obj,dataIn,CtrlIn)


            if isempty(coder.target)||~eml_ambiguous_types


                validateattributes(dataIn,{'single','double','uint8','uint16','uint32','uint64','logical','embedded.fi','logical'},{'real'},'Histogram','pixel input');
                validatecontrolsignals(CtrlIn);



                if~(ismember((size(dataIn,1)),[1,2,4,8]))
                    coder.internal.error('visionhdl:Histogram:InputDimensions');
                end


                if(size(dataIn,2))~=1
                    coder.internal.error('visionhdl:Histogram:UnsupportedComps');
                end

                if isfloat(dataIn)
                    obj.dataInWL=log2(str2double(obj.NumBins));

                else
                    obj.dataInWL=coder.const(visionhdlshared.hdlgetwordsizefromdata(dataIn));
                    [~,~,datasigned]=visionhdlshared.hdlgetwordsizefromdata(dataIn);
                    coder.internal.errorIf(datasigned==1,'visionhdl:Histogram:SignedType');
                end

            end
        end


        function startFrameCleanup(obj)
            obj.validOutReg=false(2,1);
            obj.readReadyReg=false(1,1);


            obj.hsReg=false;
            obj.heReg=false;
            obj.vsReg=false;
            obj.veReg=false;
            obj.vldReg=false;

            obj.inFrame=false;
            obj.inLine=false;
            obj.histState=0;
            obj.waddr=1;
            obj.histRAM=ones(obj.binNumber,1);
            obj.resetRAM=true;
            obj.dataAcq=false;
            obj.readOut=false;
            obj.readAtReset=false;


        end

        function num=getNumInputsImpl(~)
            num=4;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end


        function icon=getIconImpl(~)

            icon=sprintf('Histogram');
        end


        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
            varargout{3}='binAddr';
            varargout{4}='binReset';
        end


        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='hist';
            varargout{2}='readRdy';
            varargout{3}='validOut';
        end


        function[sz1,sz2,sz3]=getOutputSizeImpl(obj)
            sz1=[1,1];
            sz2=propagatedInputSize(obj,4);
            sz3=propagatedInputSize(obj,4);
        end

        function[cp1,cp2,cp3]=isOutputComplexImpl(obj)
            cp1=propagatedInputComplexity(obj,1);
            cp2=propagatedInputComplexity(obj,4);
            cp3=propagatedInputComplexity(obj,4);
        end

        function[dt1,dt2,dt3]=getOutputDataTypeImpl(obj)
            if strcmp(obj.OutputDataType,'double')||strcmp(obj.OutputDataType,'single')
                dt1=obj.OutputDataType;
            else
                dt1=numerictype(false,obj.OutputWL,0);
            end
            dt2='logical';
            dt3='logical';
        end

        function[sz1,sz2,sz3]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,4);
            sz3=propagatedInputFixedSize(obj,4);
        end

        function flag=isInactivePropertyImpl(obj,prop)



            if strcmp(prop,'OutputWL')&&~strcmp(obj.OutputDataType,'Unsigned fixed point')
                flag=true;
            else
                flag=false;
            end


        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.inFrame=obj.inFrame;
                s.inLine=obj.inLine;
                s.histState=obj.histState;
                s.waddr=obj.waddr;
                s.histRAM=obj.histRAM;
                s.resetRAM=obj.resetRAM;
                s.dataAcq=obj.dataAcq;
                s.readOut=obj.readOut;
                s.readAtReset=obj.readAtReset;

                s.dataInWL=obj.dataInWL;
                s.dataInRef=obj.dataInRef;
                s.yRef=obj.yRef;
                s.yReg=obj.yReg;
                s.readReadyReg=obj.readReadyReg;
                s.validOutReg=obj.validOutReg;
                s.histMaxValue=obj.histMaxValue;
                s.dataReg=obj.dataReg;
                s.hsReg=obj.hsReg;
                s.heReg=obj.heReg;
                s.vsReg=obj.vsReg;
                s.veReg=obj.veReg;
                s.vldReg=obj.vldReg;
            end
        end


        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function resetImpl(obj)



            startFrameCleanup(obj)
            obj.dataReg(:)=0;
        end



        function histFSM(obj,vStartReg,vStart,vEnd,RAMReset)











            switch(obj.histState)
            case 0
                obj.resetRAM=true;
                obj.dataAcq=false;
                obj.readOut=false;

                if obj.waddr==obj.binNumber
                    obj.histState=1;

                else
                    obj.histState=0;
                end


            case 1
                obj.resetRAM=false;
                obj.dataAcq=false;
                obj.readOut=false;

                if vStartReg
                    obj.histState=2;
                    obj.dataAcq=true;
                elseif RAMReset
                    obj.histState=0;
                    obj.resetRAM=true;
                end

            case 2
                obj.dataAcq=true;
                obj.resetRAM=false;
                obj.readOut=false;

                if RAMReset
                    obj.histState=0;
                    obj.resetRAM=true;
                    obj.dataAcq=false;
                elseif vEnd
                    obj.histState=3;


                end

            case 3

                obj.resetRAM=false;
                obj.dataAcq=false;
                obj.readOut=true;
                if vStart
                    obj.histState=2;
                    obj.dataAcq=true;
                    obj.readAtReset=true;

                elseif RAMReset
                    obj.histState=0;
                    obj.resetRAM=true;

                    obj.readAtReset=true;
                end
            end
        end


        function histvalue=dataProcess(obj,dataIn,hStart,hEnd,vStart,vEnd,dataValid,binAddr)

            histvalue=0;
            if obj.resetRAM
                obj.histRAM(obj.waddr)=0;
                if obj.waddr==obj.binNumber
                    obj.waddr=1;
                else
                    obj.waddr=obj.waddr+1;
                end

                obj.inFrame=false;
                obj.inLine=false;
            end


            if obj.dataAcq

                if dataValid

                    if obj.inFrame&&obj.inLine
                        computeHist(obj,dataIn);
                    end

                    if vStart
                        obj.inFrame=true;
                        obj.inLine=false;
                        if hStart
                            obj.inLine=true;
                            computeHist(obj,dataIn);
                        end

                    elseif obj.inFrame&&vEnd

                        obj.inFrame=false;

                        if hEnd
                            obj.inLine=false;
                        end
                    elseif obj.inFrame&&obj.inLine&&hEnd

                        obj.inLine=false;


                    elseif obj.inFrame&&hStart

                        obj.inLine=true;
                        computeHist(obj,dataIn);

                    elseif obj.inFrame&&~obj.inLine&&hEnd
                        obj.inLine=false;
                        coder.internal.warning('visionhdl:PixelsToFrame:extrahend');
                    elseif~obj.inFrame&&(hStart||hEnd)
                        coder.internal.warning('visionhdl:PixelsToFrame:lineoutsideframe');
                    end

                end

            end

            if obj.readOut
                if isinteger(binAddr)
                    index=double(binAddr)+1;
                else
                    index=binAddr.data+1;
                end

                histvalue=obj.histRAM(index);

            end

            if obj.readAtReset
                obj.readAtReset=false;
                obj.readOut=false;
            end
        end

        function computeHist(obj,dataIn)

            if isa(dataIn,'double')||isa(dataIn,'single')
                ramAddr=cast(dataIn,'like',obj.dataInRef);
            elseif obj.dataInWL>obj.binWL
                ramAddr=bitshift(dataIn,obj.binWL-obj.dataInWL);
            else
                ramAddr=dataIn;
            end

            if isinteger(ramAddr)
                index=double(ramAddr)+1;
            else
                index=ramAddr.data+1;
            end

            for ii=1:size(dataIn,1)
                oldhist=obj.histRAM(index(ii));
                newhist=oldhist+1;
                if newhist>obj.histMaxValue
                    newhist=obj.histMaxValue;
                    coder.internal.warning('visionhdl:Histogram:HistogramOverflow');
                    sprintf('hist value overflow\n')
                end
                obj.histRAM(index(ii))=newhist;
            end
        end
    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end
