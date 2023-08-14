classdef(StrictDefaults)DVBS2SymbolModulator<matlab.System









%#codegen







    properties(Nontunable)

        ModulationSourceParams='Input port';

        ModulationScheme='QPSK';

        CodeRateAPSK='3/4';



        OutputDataType='double';

        WordLength=16;
    end


    properties(Constant,Hidden)
        ModulationSourceParamsSet=matlab.system.StringSet({...
        'Input port','Property'});

        ModulationSchemeSet=matlab.system.StringSet({...
        'QPSK','8-PSK','16-APSK','32-APSK','pi/2-BPSK'});

        CodeRateAPSKSet=matlab.system.StringSet({...
        '2/3','3/4','4/5','5/6','8/9','9/10'});

        OutputDataTypeSet=matlab.system.StringSet({...
        'double','single','Custom'});
    end

    properties(Nontunable)%#ok<*MTMAT>

        UnitAveragePower(1,1)logical=false;
    end


    properties(Access=private)

        countBits;


        buffDataIn;
        buffDataInLen;


        inDisp;


        numBitsPerSym;
        modIndx;
        codeRateIndx;
        lutCodeRateIdx;


        evenSymFlag;
        validBefLoadAssert;
        validBefLoadFlag;
        firstLoadFlag;


        lutPiBy2BPSKEven;
        lutPiBy2BPSKOdd;
        lutQPSK;
        lut8PSK;
        lut16APSKInCirc;
        lut16APSKOutCirc;
        lutN16APSK;
        lut32APSKInMidCirc;
        lut32APSKOutCirc;
lutN32APSK


        delayBalBPSKRe;
        delayBalBPSKIm;
        delayBalValidBPSK;

        delayBalQPSKRe;
        delayBalQPSKIm;
        delayBalValidQPSK;

        delayBal8PSKRe;
        delayBal8PSKIm;
        delayBalValid8PSK;

        delayBal16APSKRe;
        delayBal16APSKIm;
        delayBalValid16APSK;

        delayBalDataOutRe;
        delayBalDataOutIm;
        delayBalValidOut;


        delayBalbitsPerSym;
        bitsPerSymDelay;
        dataOutBPSK;
        dataOutBPSKD1;
        dataOutQPSK;
        dataOutQPSKD1;
        dataOut8PSK;
        dataOut8PSKD1;
        dataOut16APSK;
        dataOut16APSKD1;
        dataOut32APSK;
        validOutBPSK;
        validOutBPSKD1;
        validOutQPSK;
        validOutQPSKD1;
        validOut8PSK;
        validOut8PSKD1;
        validOut16APSK;
        validOut16APSKD1;
        validOut32APSK;
        dataOutDelay;
        validOutDelay;
        dataOut;
        validOut;
    end

    methods
        function obj=DVBS2SymbolModulator(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:});
        end


        function set.WordLength(obj,val)
            validateattributes(val,{'numeric'},{'real','integer',...
            'scalar','>',2,'<',33},'DVBS2SymbolModulator','Word length');
            obj.WordLength=val;
        end

    end


    methods(Access=public)
        function latency=getLatency(obj,varargin)
            latency=[];
            if strcmpi(obj.ModulationSourceParams,'Property')
                latency=5+2+2;
            end
        end
    end


    methods(Static,Access=protected)

        function header=getHeaderImpl
            text=...
            ['Modulate data bits to complex data symbols according to DVB-S2 standard.',newline,newline...
            ,'When the modIdx port value is set to 0, 1, or 4, the block ignores the input port codeRateIdx and the'...
            ,' parameter Unit average power. The values 0, 1, and 4 indicate the modulation types QPSK, 8-PSK, and pi/2-BSPK, respectively.',newline,newline...
            ,'For HDL code generation, set the Output data type to Custom and specify the word length in the range from 3 to 32.'];

            header=matlab.system.display.Header(mfilename('class'),...
            'Title','DVB-S2 Symbol Modulator',...
            'Text',text,...
            'ShowSourceLink',false);
        end



        function groups=getPropertyGroupsImpl
            struc=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'ModulationSourceParams','ModulationScheme','CodeRateAPSK',...
            'UnitAveragePower'});

            main=matlab.system.display.SectionGroup(...
            'Title','Main',...
            'Sections',struc);

            dataTypeProp=matlab.system.display.Section(...
            'Title','',...
            'PropertyList',{'OutputDataType','WordLength'});

            dataType=matlab.system.display.SectionGroup(...
            'Title','Data Types',...
            'Sections',dataTypeProp);

            groups=[main,dataType];
        end



        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end



    methods(Access=protected)

        function icon=getIconImpl(obj,varargin)
            if isempty(obj.inDisp)
                if strcmpi(obj.ModulationSourceParams,'Property')
                    icon=sprintf('DVB-S2 Symbol\nModulator\nLatency = --');
                else
                    icon=sprintf('DVB-S2 Symbol\nModulator');
                end
            elseif strcmpi(obj.ModulationSourceParams,'Property')
                icon=sprintf('DVB-S2 Symbol\nModulator\nLatency = %d',...
                getLatency(obj));
            else
                icon=sprintf('DVB-S2 Symbol\nModulator');
            end
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function resetImpl(obj)

            obj.countBits(:)=0;
            obj.buffDataIn(:)=0;
            obj.numBitsPerSym(:)=0;
            obj.modIndx(:)=5;
            obj.codeRateIndx(:)=4;
            obj.lutCodeRateIdx(:)=1;
            obj.evenSymFlag(:)=true;
            obj.validBefLoadAssert(:)=false;
            obj.validBefLoadFlag(:)=true;
            obj.firstLoadFlag(:)=false;
            if strcmpi(obj.ModulationSourceParams,'Property')
                obj.buffDataInLen(:)=calBitsPerSym(obj);
            else
                obj.buffDataInLen(:)=fi(5,0,3,0,hdlfimath);
            end


            obj.lutPiBy2BPSKEven(:)=[1+j,-1-j]/sqrt(2);
            obj.lutPiBy2BPSKOdd(:)=[-1+j,1-j]/sqrt(2);
            obj.lutQPSK(:)=[1+j,1-j,-1+j,-1-j]/sqrt(2);
            obj.lut8PSK(:)=[(1/sqrt(2)+j/sqrt(2)),1,-1,(-1/sqrt(2)-j/sqrt(2))...
            ,j,(1/sqrt(2)-j/sqrt(2)),(-1/sqrt(2)+j/sqrt(2)),-j];

            g=[3.15,2.85,2.75,2.7,2.6,2.57].';
            APSK16InCirConstl=[(1./g)*((1/sqrt(2))+j*(1/sqrt(2))),(1./g)*((1/sqrt(2))-j*(1/sqrt(2)))...
            ,(1./g)*((-1/sqrt(2))+j*(1/sqrt(2))),(1./g)*((-1/sqrt(2))-j*(1/sqrt(2)))];
            APSK16OutCirConstl=[(1/sqrt(2))+j*(1/sqrt(2)),(1/sqrt(2))-j*(1/sqrt(2)),-(1/sqrt(2))+j*(1/sqrt(2)),-(1/sqrt(2))-j*(1/sqrt(2))...
            ,((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2))...
            ,((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))];

            obj.lut16APSKInCirc(:)=APSK16InCirConstl;
            obj.lut16APSKOutCirc(:)=APSK16OutCirConstl;

            unNorm16APSK=[repmat(APSK16OutCirConstl,6,1),APSK16InCirConstl];
            powUnNorm16APSK=mean(abs(unNorm16APSK).^2,2);
            obj.lutN16APSK(:)=unNorm16APSK./sqrt(powUnNorm16APSK);


            g1=[2.84,2.72,2.64,2.54,2.53].';
            g2=[5.27,4.87,4.64,4.33,4.30].';

            APSK32InMidCirConstl=[(g1./g2)*((1/sqrt(2))+j*(1/sqrt(2))),(g1./g2)*((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*((1/sqrt(2))-j*(1/sqrt(2))),(g1./g2)*((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*(-(1/sqrt(2))+j*(1/sqrt(2))),(g1./g2)*(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*(-(1/sqrt(2))-j*(1/sqrt(2))),(g1./g2)*(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((1/sqrt(2))+j*(1/sqrt(2)))...
            ,(g1./g2)*((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((1/sqrt(2))-j*(1/sqrt(2)))...
            ,(g1./g2)*(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((-1/sqrt(2))+j*(1/sqrt(2)))...
            ,(g1./g2)*(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((-1/sqrt(2))-j*(1/sqrt(2)))];

            APSK32OutCirConstl=[cos(pi/8)+j*sin(pi/8),cos(3*pi/8)+j*sin(3*pi/8),((1/sqrt(2))-j*(1/sqrt(2))),-j...
            ,(-(1/sqrt(2))+j*(1/sqrt(2))),j,-cos(pi/8)-j*sin(pi/8),-cos(3*pi/8)-j*sin(3*pi/8)...
            ,1,((1/sqrt(2))+j*(1/sqrt(2))),cos(pi/8)-j*sin(pi/8),cos(3*pi/8)-j*sin(3*pi/8)...
            ,-cos(pi/8)+j*sin(pi/8),-cos(3*pi/8)+j*sin(3*pi/8),-1,(-(1/sqrt(2))-j*(1/sqrt(2)))];

            obj.lut32APSKInMidCirc(:)=APSK32InMidCirConstl;
            obj.lut32APSKOutCirc(:)=APSK32OutCirConstl;

            unNorm32APSK=[APSK32InMidCirConstl(:,1:8),repmat(APSK32OutCirConstl(1:8),5,1),APSK32InMidCirConstl(:,9:16),repmat(APSK32OutCirConstl(9:16),5,1)];
            powUnNorm32APSK=mean(abs(unNorm32APSK).^2,2);
            obj.lutN32APSK(:)=unNorm32APSK./sqrt(powUnNorm32APSK);


            reset(obj.delayBalBPSKRe);
            reset(obj.delayBalBPSKIm);
            reset(obj.delayBalValidBPSK);

            reset(obj.delayBalQPSKRe);
            reset(obj.delayBalQPSKIm);
            reset(obj.delayBalValidQPSK);

            reset(obj.delayBal8PSKRe);
            reset(obj.delayBal8PSKIm);
            reset(obj.delayBalValid8PSK);

            reset(obj.delayBal16APSKRe);
            reset(obj.delayBal16APSKIm);
            reset(obj.delayBalValid16APSK);

            reset(obj.delayBalDataOutRe);
            reset(obj.delayBalDataOutIm);
            reset(obj.delayBalValidOut);

            reset(obj.delayBalbitsPerSym);

            obj.bitsPerSymDelay(:)=0;
            obj.dataOutBPSK(:)=complex(0);
            obj.dataOutQPSK(:)=complex(0);
            obj.dataOut8PSK(:)=complex(0);
            obj.dataOut16APSK(:)=complex(0);
            obj.dataOut32APSK(:)=complex(0);
            obj.dataOutBPSKD1(:)=complex(0);
            obj.dataOutQPSKD1(:)=complex(0);
            obj.dataOut8PSKD1(:)=complex(0);
            obj.dataOut16APSKD1(:)=complex(0);
            obj.validOutBPSK(:)=false;
            obj.validOutQPSK(:)=false;
            obj.validOut8PSK(:)=false;
            obj.validOut16APSK(:)=false;
            obj.validOut32APSK(:)=false;
            obj.validOutBPSKD1(:)=false;
            obj.validOutQPSKD1(:)=false;
            obj.validOut8PSKD1(:)=false;
            obj.validOut16APSKD1(:)=false;
            obj.dataOutDelay(:)=complex(0);
            obj.dataOut(:)=complex(0);
            obj.validOutDelay(:)=false;
            obj.validOut(:)=false;
        end

        function setupImpl(obj,varargin)


            obj.countBits=fi(0,0,3,0,hdlfimath);


            obj.buffDataIn=fi(zeros(5,1),0,1,0,hdlfimath);
            obj.numBitsPerSym=fi(0,0,3,0,hdlfimath);


            obj.modIndx=fi(5,0,3,0,hdlfimath);
            obj.codeRateIndx=fi(4,0,4,0,hdlfimath);
            obj.lutCodeRateIdx=fi(1,0,3,0,hdlfimath);
            obj.evenSymFlag=true;
            obj.validBefLoadAssert=false;
            obj.validBefLoadFlag=true;
            obj.firstLoadFlag=false;
            if strcmpi(obj.ModulationSourceParams,'Property')

                obj.buffDataInLen=calBitsPerSym(obj);
            else
                obj.buffDataInLen=fi(5,0,3,0,hdlfimath);
            end

            g=[3.15,2.85,2.75,2.7,2.6,2.57].';
            APSK16InCirConstl=[(1./g)*((1/sqrt(2))+j*(1/sqrt(2))),(1./g)*((1/sqrt(2))-j*(1/sqrt(2)))...
            ,(1./g)*((-1/sqrt(2))+j*(1/sqrt(2))),(1./g)*((-1/sqrt(2))-j*(1/sqrt(2)))];
            APSK16OutCirConstl=[(1/sqrt(2))+j*(1/sqrt(2)),(1/sqrt(2))-j*(1/sqrt(2)),-(1/sqrt(2))+j*(1/sqrt(2)),-(1/sqrt(2))-j*(1/sqrt(2))...
            ,((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2))...
            ,((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2)),(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))];
            unNorm16APSK=[repmat(APSK16OutCirConstl,6,1),APSK16InCirConstl];
            powUnNorm16APSK=mean(abs(unNorm16APSK).^2,2);


            g1=[2.84,2.72,2.64,2.54,2.53].';
            g2=[5.27,4.87,4.64,4.33,4.30].';

            APSK32InMidCirConstl=[(g1./g2)*((1/sqrt(2))+j*(1/sqrt(2))),(g1./g2)*((sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*((1/sqrt(2))-j*(1/sqrt(2))),(g1./g2)*((sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*(-(1/sqrt(2))+j*(1/sqrt(2))),(g1./g2)*(-(sqrt(3)-1)+j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*(-(1/sqrt(2))-j*(1/sqrt(2))),(g1./g2)*(-(sqrt(3)-1)-j*(sqrt(3)+1))/(2*sqrt(2))...
            ,(g1./g2)*((sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((1/sqrt(2))+j*(1/sqrt(2)))...
            ,(g1./g2)*((sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((1/sqrt(2))-j*(1/sqrt(2)))...
            ,(g1./g2)*(-(sqrt(3)+1)+j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((-1/sqrt(2))+j*(1/sqrt(2)))...
            ,(g1./g2)*(-(sqrt(3)+1)-j*(sqrt(3)-1))/(2*sqrt(2)),(1./g2)*((-1/sqrt(2))-j*(1/sqrt(2)))];

            APSK32OutCirConstl=[cos(pi/8)+j*sin(pi/8),cos(3*pi/8)+j*sin(3*pi/8),((1/sqrt(2))-j*(1/sqrt(2))),-j...
            ,(-(1/sqrt(2))+j*(1/sqrt(2))),j,-cos(pi/8)-j*sin(pi/8),-cos(3*pi/8)-j*sin(3*pi/8)...
            ,1,((1/sqrt(2))+j*(1/sqrt(2))),cos(pi/8)-j*sin(pi/8),cos(3*pi/8)-j*sin(3*pi/8)...
            ,-cos(pi/8)+j*sin(pi/8),-cos(3*pi/8)+j*sin(3*pi/8),-1,(-(1/sqrt(2))-j*(1/sqrt(2)))];

            unNorm32APSK=[APSK32InMidCirConstl(:,1:8),repmat(APSK32OutCirConstl(1:8),5,1),APSK32InMidCirConstl(:,9:16),repmat(APSK32OutCirConstl(9:16),5,1)];
            powUnNorm32APSK=mean(abs(unNorm32APSK).^2,2);


            if strcmpi(obj.OutputDataType,'double')
                obj.lutPiBy2BPSKEven=double([1+j,-1-j]/sqrt(2));
                obj.lutPiBy2BPSKOdd=double([-1+j,1-j]/sqrt(2));
                obj.lutQPSK=double([1+j,1-j,-1+j,-1-j]/sqrt(2));
                obj.lut8PSK=double([(1/sqrt(2)+j/sqrt(2)),1+j*0,-1+j*0,(-1/sqrt(2)-j/sqrt(2))...
                ,0+j,(1/sqrt(2)-j/sqrt(2)),(-1/sqrt(2)+j/sqrt(2)),0-j]);

                obj.lut16APSKInCirc=double(APSK16InCirConstl);
                obj.lut16APSKOutCirc=double(APSK16OutCirConstl);

                obj.lutN16APSK=double(unNorm16APSK./sqrt(powUnNorm16APSK));

                obj.lut32APSKInMidCirc=double(APSK32InMidCirConstl);
                obj.lut32APSKOutCirc=double(APSK32OutCirConstl);

                obj.lutN32APSK=double(unNorm32APSK./sqrt(powUnNorm32APSK));

                obj.dataOutBPSK=double(complex(0));
                obj.dataOutQPSK=double(complex(0));
                obj.dataOut8PSK=double(complex(0));
                obj.dataOut16APSK=double(complex(0));
                obj.dataOut32APSK=double(complex(0));

                obj.dataOutBPSKD1=double(complex(0));
                obj.dataOutQPSKD1=double(complex(0));
                obj.dataOut8PSKD1=double(complex(0));
                obj.dataOut16APSKD1=double(complex(0));

                obj.dataOutDelay=double(complex(0));
                obj.dataOut=double(complex(0));
            elseif strcmpi(obj.OutputDataType,'single')
                obj.lutPiBy2BPSKEven=single([1+j,-1-j]/sqrt(2));
                obj.lutPiBy2BPSKOdd=single([-1+j,1-j]/sqrt(2));
                obj.lutQPSK=single([1+j,1-j,-1+j,-1-j]/sqrt(2));
                obj.lut8PSK=single([(1/sqrt(2)+j/sqrt(2)),1+j*0,-1+j*0,(-1/sqrt(2)-j/sqrt(2))...
                ,0+j,(1/sqrt(2)-j/sqrt(2)),(-1/sqrt(2)+j/sqrt(2)),0-j]);

                obj.lut16APSKInCirc=single(APSK16InCirConstl);
                obj.lut16APSKOutCirc=single(APSK16OutCirConstl);

                obj.lutN16APSK=single(unNorm16APSK./sqrt(powUnNorm16APSK));

                obj.lut32APSKInMidCirc=single(APSK32InMidCirConstl);
                obj.lut32APSKOutCirc=single(APSK32OutCirConstl);

                obj.lutN32APSK=single(unNorm32APSK./sqrt(powUnNorm32APSK));

                obj.dataOutBPSK=single(complex(0));
                obj.dataOutQPSK=single(complex(0));
                obj.dataOut8PSK=single(complex(0));
                obj.dataOut16APSK=single(complex(0));
                obj.dataOut32APSK=single(complex(0));

                obj.dataOutBPSKD1=single(complex(0));
                obj.dataOutQPSKD1=single(complex(0));
                obj.dataOut8PSKD1=single(complex(0));
                obj.dataOut16APSKD1=single(complex(0));

                obj.dataOutDelay=single(complex(0));
                obj.dataOut=single(complex(0));
            else
                outWL=double(obj.WordLength);

                lutPiBy2BPSKEvenTmp=fi([1+j,-1-j]/sqrt(2),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.lutPiBy2BPSKEven=fi(lutPiBy2BPSKEvenTmp,1,outWL,outWL-2,hdlfimath);
                lutPiBy2BPSKOddTmp=fi([-1+j,1-j]/sqrt(2),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.lutPiBy2BPSKOdd=fi(lutPiBy2BPSKOddTmp,1,outWL,outWL-2,hdlfimath);

                lutQPSKTmp=fi([1+j,1-j,-1+j,-1-j]/sqrt(2),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.lutQPSK=fi(lutQPSKTmp,1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');

                lut8PSKTmp=fi([(1/sqrt(2)+j/sqrt(2)),1+j*0,-1+j*0,(-1/sqrt(2)-j/sqrt(2))...
                ,0+j,(1/sqrt(2)-j/sqrt(2)),(-1/sqrt(2)+j/sqrt(2)),0-j],1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.lut8PSK=fi(lut8PSKTmp,1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');

                obj.lut16APSKInCirc=fi(APSK16InCirConstl,1,outWL,outWL-2,hdlfimath);
                obj.lut16APSKOutCirc=fi(APSK16OutCirConstl,1,outWL,outWL-2,hdlfimath);

                obj.lutN16APSK=fi(unNorm16APSK./sqrt(powUnNorm16APSK),1,outWL,outWL-2,hdlfimath);

                obj.lut32APSKInMidCirc=fi(APSK32InMidCirConstl,1,outWL,outWL-2,hdlfimath);
                obj.lut32APSKOutCirc=fi(APSK32OutCirConstl,1,outWL,outWL-2,hdlfimath);

                obj.lutN32APSK=fi(unNorm32APSK./sqrt(powUnNorm32APSK),1,outWL,outWL-2,hdlfimath);

                obj.dataOutBPSK=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOutQPSK=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOut8PSK=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOut16APSK=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOut32APSK=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');

                obj.dataOutBPSKD1=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOutQPSKD1=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOut8PSKD1=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOut16APSKD1=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');

                obj.dataOutDelay=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.dataOut=fi(complex(0),1,outWL,outWL-2,'RoundingMethod','Floor','OverflowAction','Wrap');
            end

            obj.bitsPerSymDelay=fi(0,0,3,0,hdlfimath);

            obj.validOutBPSK=false;
            obj.validOutQPSK=false;
            obj.validOut8PSK=false;
            obj.validOut16APSK=false;
            obj.validOut32APSK=false;

            obj.validOutBPSKD1=false;
            obj.validOutQPSKD1=false;
            obj.validOut8PSKD1=false;
            obj.validOut16APSKD1=false;

            obj.validOutDelay=false;
            obj.validOut=false;


            delaynumBitsPerSym=4;
            obj.delayBalbitsPerSym=dsp.Delay(delaynumBitsPerSym);



            delayBPSK=4;
            obj.delayBalBPSKRe=dsp.Delay('Length',delayBPSK*(1));
            obj.delayBalBPSKIm=dsp.Delay('Length',delayBPSK*(1));
            obj.delayBalValidBPSK=dsp.Delay(delayBPSK);


            delayQPSK=3;
            obj.delayBalQPSKRe=dsp.Delay('Length',delayQPSK*(1));
            obj.delayBalQPSKIm=dsp.Delay('Length',delayQPSK*(1));
            obj.delayBalValidQPSK=dsp.Delay(delayQPSK);


            delay8PSK=2;
            obj.delayBal8PSKRe=dsp.Delay('Length',delay8PSK*(1));
            obj.delayBal8PSKIm=dsp.Delay('Length',delay8PSK*(1));
            obj.delayBalValid8PSK=dsp.Delay(delay8PSK);


            delay16APSK=1;
            obj.delayBal16APSKRe=dsp.Delay('Length',delay16APSK*(1));
            obj.delayBal16APSKIm=dsp.Delay('Length',delay16APSK*(1));
            obj.delayBalValid16APSK=dsp.Delay(delay16APSK);

            delayValue=2+2;
            obj.delayBalDataOutRe=dsp.Delay('Length',delayValue*(1));
            obj.delayBalDataOutIm=dsp.Delay('Length',delayValue*(1));
            obj.delayBalValidOut=dsp.Delay(delayValue);

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
        end

        function updateImpl(obj,varargin)

            dataIn=varargin{1};
            validIn=varargin{2};

            if strcmpi(obj.ModulationSourceParams,'Property')

                if validIn
                    bufferDataIn(obj,dataIn,validIn);
                    obj.countBits(:)=obj.countBits+1;
                end



                symInd=(obj.countBits==obj.buffDataInLen)&&validIn;
                calCodeRateIndex(obj);
                obj.numBitsPerSym(:)=calBitsPerSym(obj);
            else

                if varargin{5}&&obj.countBits(:)>0&&~(obj.countBits==obj.numBitsPerSym)
                    obj.evenSymFlag(:)=true;
                    obj.buffDataIn(:)=0;
                    obj.countBits(:)=0;
                end


                if validIn
                    bufferDataIn(obj,dataIn,validIn);
                    obj.countBits(:)=obj.countBits+1;
                end


                if~varargin{5}&&obj.countBits(:)~=0&&~obj.firstLoadFlag
                    obj.validBefLoadAssert(:)=true;
                end

                if obj.validBefLoadAssert
                    if obj.validBefLoadFlag
                        coder.internal.warning('whdl:DVBS2SymbolModulator:InpValidBefLoadAssert');
                        obj.validBefLoadFlag(:)=false;
                    end
                    obj.numBitsPerSym(:)=fi(2,0,3,0,hdlfimath);
                    obj.validBefLoadAssert(:)=false;
                else
                    if varargin{5}
                        obj.evenSymFlag(:)=true;
                        obj.firstLoadFlag(:)=true;
                        if(varargin{3}<0)||(varargin{3}>4)||(varargin{3}>0&&varargin{3}<1)...
                            ||(varargin{3}>1&&varargin{3}<2)||(varargin{3}>2&&varargin{3}<3)||(varargin{3}>3&&varargin{3}<4)
                            coder.internal.warning('whdl:DVBS2SymbolModulator:InvalidModIdxValue');
                        end
                        if varargin{3}==2
                            if(varargin{4}<5)||(varargin{4}>10)||(varargin{4}>5&&varargin{4}<6)||(varargin{4}>6&&varargin{4}<7)...
                                ||(varargin{4}>7&&varargin{4}<8)||(varargin{4}>8&&varargin{4}<9)||(varargin{4}>9&&varargin{4}<10)
                                coder.internal.warning('whdl:DVBS2SymbolModulator:InvalidCodeRateIdxValue16APSK');
                            end
                        end
                        if varargin{3}==3
                            if varargin{4}<6||varargin{4}>10||(varargin{4}>6&&varargin{4}<7)...
                                ||(varargin{4}>7&&varargin{4}<8)||(varargin{4}>8&&varargin{4}<9)||(varargin{4}>9&&varargin{4}<10)
                                coder.internal.warning('whdl:DVBS2SymbolModulator:InvalidCodeRateIdxValue32APSK');
                            end
                        end

                        obj.modIndx(:)=varargin{3};
                        obj.codeRateIndx(:)=varargin{4};
                        obj.numBitsPerSym(:)=calBitsPerSym(obj);
                        calCodeRateIndex(obj);
                    end
                end


                symInd=(obj.countBits==obj.numBitsPerSym)&&validIn;
            end

            if(symInd)
                symModulation(obj);
                obj.buffDataIn(:)=0;
                obj.countBits(:)=0;
            else
                obj.dataOutBPSK(:)=complex(0);
                obj.validOutBPSK(:)=false;
                obj.dataOutQPSK(:)=complex(0);
                obj.validOutQPSK(:)=false;
                obj.dataOut8PSK(:)=complex(0);
                obj.validOut8PSK(:)=false;
                obj.dataOut16APSK(:)=complex(0);
                obj.validOut16APSK(:)=false;
                obj.dataOut32APSK(:)=complex(0);
                obj.validOut32APSK(:)=false;
            end

            delayDataAndValidAsPerMod(obj);

            obj.bitsPerSymDelay(:)=obj.delayBalbitsPerSym(obj.numBitsPerSym(:));

            switch obj.bitsPerSymDelay
            case 1
                obj.dataOutDelay(:)=obj.dataOutBPSKD1;
                obj.validOutDelay(:)=obj.validOutBPSKD1;
            case 2
                obj.dataOutDelay(:)=obj.dataOutQPSKD1;
                obj.validOutDelay(:)=obj.validOutQPSKD1;
            case 3
                obj.dataOutDelay(:)=obj.dataOut8PSKD1;
                obj.validOutDelay(:)=obj.validOut8PSKD1;
            case 4
                obj.dataOutDelay(:)=obj.dataOut16APSKD1;
                obj.validOutDelay(:)=obj.validOut16APSKD1;
            case 5
                obj.dataOutDelay(:)=obj.dataOut32APSK;
                obj.validOutDelay(:)=obj.validOut32APSK;
                obj.dataOut32APSK(:)=complex(0);
                obj.validOut32APSK(:)=false;
            otherwise
                obj.dataOutDelay(:)=complex(0);
                obj.validOutDelay(:)=false;
            end



            obj.dataOut(:)=complex(obj.delayBalDataOutRe(real(obj.dataOutDelay(:))),...
            obj.delayBalDataOutIm(imag(obj.dataOutDelay(:))));
            obj.validOut(:)=obj.delayBalValidOut(obj.validOutDelay);

            if~obj.validOut(:)
                obj.dataOut(:)=complex(0);
            end
        end


        function bufferDataIn(obj,bit,enb)

            if(enb)
                for i=obj.buffDataInLen:-1:2
                    obj.buffDataIn(i)=obj.buffDataIn(i-1);
                end
                obj.buffDataIn(1)=bit;
            end
        end


        function symModulation(obj)


            if(obj.numBitsPerSym==1)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'pi/2-BPSK'))
                if obj.evenSymFlag
                    addrOutBpsk=bitconcat(flipud(obj.buffDataIn));
                    obj.dataOutBPSK(:)=obj.lutPiBy2BPSKEven(addrOutBpsk+1);
                    obj.validOutBPSK(:)=true;
                    obj.evenSymFlag=false;
                else
                    addrOutBpsk=bitconcat(flipud(obj.buffDataIn));
                    obj.dataOutBPSK(:)=obj.lutPiBy2BPSKOdd(addrOutBpsk+1);
                    obj.validOutBPSK(:)=true;
                    obj.evenSymFlag=true;
                end
            elseif(obj.numBitsPerSym==2)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'QPSK'))
                addrOutQPSK=bitconcat(flipud(obj.buffDataIn));
                obj.dataOutQPSK(:)=obj.lutQPSK(addrOutQPSK+1);
                obj.validOutQPSK(:)=true;

            elseif(obj.numBitsPerSym==3)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'8-PSK'))
                addrOut8PSK=bitconcat(flipud(obj.buffDataIn));
                obj.dataOut8PSK(:)=obj.lut8PSK(addrOut8PSK+1);
                obj.validOut8PSK(:)=true;
            elseif(obj.numBitsPerSym==4)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'16-APSK'))

                addrCoderateAPSK=obj.lutCodeRateIdx;
                addrModAPSK=bitconcat(flipud(obj.buffDataIn));
                if obj.UnitAveragePower
                    obj.dataOut16APSK(:)=obj.lutN16APSK(addrCoderateAPSK,addrModAPSK+1);
                else
                    if addrModAPSK>=12
                        obj.dataOut16APSK(:)=obj.lut16APSKInCirc(addrCoderateAPSK,addrModAPSK-11);
                    else
                        obj.dataOut16APSK(:)=obj.lut16APSKOutCirc(addrModAPSK+1);
                    end
                end
                obj.validOut16APSK(:)=true;
            else

                addrCoderateAPSK=obj.lutCodeRateIdx-1;
                addrModAPSK=bitconcat(flipud(obj.buffDataIn));
                if obj.UnitAveragePower
                    obj.dataOut32APSK(:)=obj.lutN32APSK(addrCoderateAPSK,addrModAPSK+1);
                else
                    if addrModAPSK<=7
                        obj.dataOut32APSK(:)=obj.lut32APSKInMidCirc(addrCoderateAPSK,addrModAPSK+1);
                    elseif addrModAPSK>7&&addrModAPSK<=15
                        obj.dataOut32APSK(:)=obj.lut32APSKOutCirc(addrModAPSK-7);
                    elseif addrModAPSK>15&&addrModAPSK<=23
                        obj.dataOut32APSK(:)=obj.lut32APSKInMidCirc(addrCoderateAPSK,addrModAPSK-7);
                    else
                        obj.dataOut32APSK(:)=obj.lut32APSKOutCirc(addrModAPSK-15);
                    end
                end
                obj.validOut32APSK(:)=true;
            end
        end


        function delayDataAndValidAsPerMod(obj)
            obj.dataOutBPSKD1(:)=complex(obj.delayBalBPSKRe(real(obj.dataOutBPSK(:))),...
            obj.delayBalBPSKIm(imag(obj.dataOutBPSK(:))));
            obj.validOutBPSKD1(:)=obj.delayBalValidBPSK(obj.validOutBPSK(:));

            obj.dataOutQPSKD1(:)=complex(obj.delayBalQPSKRe(real(obj.dataOutQPSK(:))),...
            obj.delayBalQPSKIm(imag(obj.dataOutQPSK(:))));
            obj.validOutQPSKD1(:)=obj.delayBalValidQPSK(obj.validOutQPSK(:));

            obj.dataOut8PSKD1(:)=complex(obj.delayBal8PSKRe(real(obj.dataOut8PSK(:))),...
            obj.delayBal8PSKIm(imag(obj.dataOut8PSK(:))));
            obj.validOut8PSKD1(:)=obj.delayBalValid8PSK(obj.validOut8PSK(:));


            obj.dataOut16APSKD1(:)=complex(obj.delayBal16APSKRe(real(obj.dataOut16APSK(:))),...
            obj.delayBal16APSKIm(imag(obj.dataOut16APSK(:))));
            obj.validOut16APSKD1(:)=obj.delayBalValid16APSK(obj.validOut16APSK(:));

            obj.dataOutBPSK(:)=complex(0);
            obj.validOutBPSK(:)=false;
            obj.dataOutQPSK(:)=complex(0);
            obj.validOutQPSK(:)=false;
            obj.dataOut8PSK(:)=complex(0);
            obj.validOut8PSK(:)=false;
            obj.dataOut16APSK(:)=complex(0);
            obj.validOut16APSK(:)=false;
        end



        function num=getNumInputsImpl(obj)
            num=2;
            if strcmpi(obj.ModulationSourceParams,'Input port')
                num=num+3;
            end
        end



        function num=getNumOutputsImpl(obj)
            num=2;
        end



        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='valid';
            varargoutInd=2;
            if strcmpi(obj.ModulationSourceParams,'Input port')
                varargoutInd=varargoutInd+1;
                varargout{varargoutInd}='modIdx';
                varargoutInd=varargoutInd+1;
                varargout{varargoutInd}='codeRateIdx';
                varargoutInd=varargoutInd+1;
                varargout{varargoutInd}='load';
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='valid';
        end


        function validatePropertiesImpl(obj)
            if strcmpi(obj.ModulationScheme,'32-APSK')&&...
                strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'2/3')
                coder.internal.error('whdl:DVBS2SymbolModulator:InvalidCodeRate32APSK');
            end
        end

        function validateInputsImpl(obj,varargin)
            coder.extrinsic('tostringInternalSlName');
            if isempty(coder.target)||~coder.internal.isAmbiguousTypes

                if isa(varargin{1},'uint8')||isa(varargin{1},'int8')||isa(varargin{1},'uint16')||isa(varargin{1},'int16')||...
                    isa(varargin{1},'uint32')||isa(varargin{1},'int32')||isa(varargin{1},'double')||isa(varargin{1},'single')
                    coder.internal.error('whdl:DVBS2SymbolModulator:InvalidDataType');
                end

                if isa(varargin{1},'embedded.fi')
                    [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                    errCond=~((WL==1)&&(FL==0)&&~issigned(varargin{1}));
                    if(errCond)
                        coder.internal.error('whdl:DVBS2SymbolModulator:InvalidDataType');
                    end
                end

                validateattributes(varargin{1},...
                {'logical','embedded.fi'},{'real','scalar'},'DVBS2SymbolModulator','data');


                validateattributes(varargin{2},{'logical'},{'scalar'},...
                'DVBS2SymbolModulator','valid');

                if strcmpi(obj.ModulationSourceParams,'Input Port')


                    if isa(varargin{3},'uint8')||isa(varargin{3},'int8')||isa(varargin{3},'uint16')||isa(varargin{3},'int16')||...
                        isa(varargin{3},'uint32')||isa(varargin{3},'int32')||isa(varargin{3},'logical')
                        coder.internal.error('whdl:DVBS2SymbolModulator:InvalidModIdxType');
                    end

                    if isa(varargin{3},'embedded.fi')
                        [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{3});
                        errCond=~((WL==3)&&(FL==0)&&~issigned(varargin{3}));
                        if(errCond)
                            coder.internal.error('whdl:DVBS2SymbolModulator:InvalidModIdxType');
                        end
                    end

                    validateattributes(varargin{3},{'double','single','embedded.fi'},...
                    {'real','scalar'},'DVBS2SymbolModulator','modIdx');


                    if isa(varargin{4},'uint8')||isa(varargin{4},'int8')||isa(varargin{4},'uint16')||isa(varargin{4},'int16')||...
                        isa(varargin{4},'uint32')||isa(varargin{4},'int32')||isa(varargin{4},'logical')
                        coder.internal.error('whdl:DVBS2SymbolModulator:InvalidCodeRateIdxType');
                    end

                    if isa(varargin{4},'embedded.fi')
                        [WL,FL,~]=dsphdlshared.hdlgetwordsizefromdata(varargin{4});
                        errCond=~((WL==4)&&(FL==0)&&~issigned(varargin{4}));
                        if(errCond)
                            coder.internal.error('whdl:DVBS2SymbolModulator:InvalidCodeRateIdxType');
                        end
                    end

                    validateattributes(varargin{4},{'double','single','embedded.fi'},...
                    {'real','scalar'},'DVBS2SymbolModulator','codeRateIdx');


                    validateattributes(varargin{5},{'logical'},{'scalar'},...
                    'DVBS2SymbolModulator','load');
                end
                obj.inDisp=~isempty(varargin{1});
            end
        end




        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if(~strcmpi(obj.ModulationSourceParams,'Property'))
                props=[props,{'ModulationScheme'},{'CodeRateAPSK'}];
            else
                props=[props];
            end
            if(strcmpi(obj.ModulationSourceParams,'Property')&&...
                ~strcmpi(obj.ModulationScheme,'16-APSK')&&...
                ~strcmpi(obj.ModulationScheme,'32-APSK'))
                props=[props,{'UnitAveragePower'},{'CodeRateAPSK'}];
            else
                props=[props];
            end
            if~strcmpi(obj.OutputDataType,'Custom')
                props=[props,...
                {'WordLength'}];
            end
            flag=ismember(prop,props);
        end

        function numBitsPerSym=calBitsPerSym(obj)
            if(obj.modIndx==0)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'QPSK'))
                numBitsPerSym=fi(2,0,3,0,hdlfimath);
            elseif(obj.modIndx==1)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'8-PSK'))
                numBitsPerSym=fi(3,0,3,0,hdlfimath);
            elseif(obj.modIndx==2)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'16-APSK'))
                numBitsPerSym=fi(4,0,3,0,hdlfimath);
            elseif(obj.modIndx==3)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'32-APSK'))
                numBitsPerSym=fi(5,0,3,0,hdlfimath);
            elseif(obj.modIndx==4)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.ModulationScheme,'pi/2-BPSK'))
                numBitsPerSym=fi(1,0,3,0,hdlfimath);
            else
                numBitsPerSym=fi(2,0,3,0,hdlfimath);
            end
        end

        function obj=calCodeRateIndex(obj)
            if(obj.codeRateIndx==5)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'2/3'))
                if(obj.modIndx==3)&&(~strcmpi(obj.ModulationSourceParams,'Property'))
                    obj.lutCodeRateIdx(:)=fi(2,0,3,0,hdlfimath);
                else
                    obj.lutCodeRateIdx(:)=fi(1,0,3,0,hdlfimath);
                end
            elseif(obj.codeRateIndx==6)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'3/4'))
                obj.lutCodeRateIdx(:)=fi(2,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==7)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'4/5'))
                obj.lutCodeRateIdx(:)=fi(3,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==8)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'5/6'))
                obj.lutCodeRateIdx(:)=fi(4,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==9)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'8/9'))
                obj.lutCodeRateIdx(:)=fi(5,0,3,0,hdlfimath);
            elseif(obj.codeRateIndx==10)||(strcmpi(obj.ModulationSourceParams,'Property')&&...
                strcmpi(obj.CodeRateAPSK,'9/10'))
                obj.lutCodeRateIdx(:)=fi(6,0,3,0,hdlfimath);
            else
                obj.lutCodeRateIdx(:)=fi(2,0,3,0,hdlfimath);
            end
        end






        function varargout=getOutputDataTypeImpl(obj,varargin)
            if strcmpi(obj.OutputDataType,'double')||strcmpi(obj.OutputDataType,'single')
                varargout={obj.OutputDataType,'logical'};
            else
                varargout={numerictype(1,double(obj.WordLength),double(obj.WordLength)-2),'logical'};
            end
        end



        function varargout=isOutputComplexImpl(obj)
            varargout={true,false};
        end



        function varargout=getOutputSizeImpl(obj)
            varargout{1}=[1,1];
            varargout{2}=[1,1];
        end



        function varargout=isOutputFixedSizeImpl(obj)
            varargout={true,true};
        end



        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.countBits=obj.countBits;
                s.buffDataIn=obj.buffDataIn;
                s.numBitsPerSym=obj.numBitsPerSym;
                s.buffDataInLen=obj.buffDataInLen;
                s.inDisp=obj.inDisp;
                s.modIndx=obj.modIndx;
                s.codeRateIndx=obj.codeRateIndx;
                s.evenSymFlag=obj.evenSymFlag;
                s.validBefLoadAssert=obj.validBefLoadAssert;
                s.validBefLoadFlag=obj.validBefLoadFlag;
                s.firstLoadFlag=obj.firstLoadFlag;
                s.lutPiBy2BPSKEven=obj.lutPiBy2BPSKEven;
                s.lutPiBy2BPSKOdd=obj.lutPiBy2BPSKOdd;
                s.lutQPSK=obj.lutQPSK;
                s.lut8PSK=obj.lut8PSK;
                s.lut16APSKInCirc=obj.lut16APSKInCirc;
                s.lut16APSKOutCirc=obj.lut16APSKOutCirc;
                s.lutN16APSK=obj.lutN16APSK;
                s.lut32APSKInMidCirc=obj.lut32APSKInMidCirc;
                s.lut32APSKOutCirc=obj.lut32APSKOutCirc;
                s.lutN32APSK=obj.lutN32APSK;
                s.delayBalBPSKRe=obj.delayBalBPSKRe;
                s.delayBalBPSKIm=obj.delayBalBPSKIm;
                s.delayBalValidBPSK=obj.delayBalValidBPSK;
                s.delayBalQPSKRe=obj.delayBalQPSKRe;
                s.delayBalQPSKIm=obj.delayBalQPSKIm;
                s.delayBalValidQPSK=obj.delayBalValidQPSK;
                s.delayBal8PSKRe=obj.delayBal8PSKRe;
                s.delayBal8PSKIm=obj.delayBal8PSKIm;
                s.delayBalValid8PSK=obj.delayBalValid8PSK;
                s.delayBal16APSKRe=obj.delayBal16APSKRe;
                s.delayBal16APSKIm=obj.delayBal16APSKIm;
                s.delayBalValid16APSK=obj.delayBalValid16APSK;
                s.delayBalDataOutRe=obj.delayBalDataOutRe;
                s.delayBalDataOutIm=obj.delayBalDataOutIm;
                s.delayBalValidOut=obj.delayBalValidOut;
                s.bitsPerSymDelay=obj.bitsPerSymDelay;
                s.delayBalbitsPerSym=obj.delayBalbitsPerSym;
                s.dataOutBPSK=obj.dataOutBPSK;
                s.dataOutQPSK=obj.dataOutQPSK;
                s.dataOut8PSK=obj.dataOut8PSK;
                s.dataOut16APSK=obj.dataOut16APSK;
                s.dataOut32APSK=obj.dataOut32APSK;
                s.dataOutBPSKD1=obj.dataOutBPSKD1;
                s.dataOutQPSKD1=obj.dataOutQPSKD1;
                s.dataOut8PSKD1=obj.dataOut8PSKD1;
                s.dataOut16APSKD1=obj.dataOut16APSKD1;
                s.validOutBPSK=obj.validOutBPSK;
                s.validOutQPSK=obj.validOutQPSK;
                s.validOut8PSK=obj.validOut8PSK;
                s.validOut16APSK=obj.validOut16APSK;
                s.validOut32APSK=obj.validOut32APSK;
                s.validOutBPSKD1=obj.validOutBPSKD1;
                s.validOutQPSKD1=obj.validOutQPSKD1;
                s.validOut8PSKD1=obj.validOut8PSKD1;
                s.validOut16APSKD1=obj.validOut16APSKD1;
                s.dataOutDelay=obj.dataOutDelay;
                s.dataOut=obj.dataOut;
                s.validOutDelay=obj.validOutDelay;
                s.validOut=obj.validOut;
            end
        end



        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

    end
end