classdef(StrictDefaults)CCSDSLDPCFinalOutput<matlab.System





%#codegen

    properties(Nontunable)
        LDPCConfiguration='(8160,7136) LDPC';
        scalarFlag=false;
    end

    properties(Nontunable,Access=private)
        memDepth;
    end


    properties(Access=private)


        iterDoneReg;
        startReg;


        startOutO;
        endOutO;
        validOutO;
        dataOutO;
        zCountO;
        dataIdx;
        countO;
        count8O;
        dataRegO;
        dataVecO;
        dataVecRegO;
        countDataO;
        enbVecO;
        enbCountO;
        startRegO;
        startReg1O;
        startOutRegO;


        startOutR;
        validOutR;
        dataReg;
        dataAdj;
        enbData;
        enbDataReg;
        count8R;
        selCount;


        delayBalancer1;
        delayBalancer2;
        delayBalancer3;


        dataOut;
        ctrlOut;

    end

    properties(Constant,Hidden)
        LDPCConfigurationSet=matlab.system.StringSet({'(8160,7136) LDPC','AR4JA LDPC'});
    end

    methods

        function obj=CCSDSLDPCFinalOutput(varargin)
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
    end

    methods(Access=protected)

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function resetImpl(obj)

            reset(obj.delayBalancer1);
            reset(obj.delayBalancer2);
            reset(obj.delayBalancer3);

            if obj.scalarFlag
                obj.dataOut(:)=zeros(1,1);
            else
                obj.dataOut(:)=zeros(8,1);
            end
            obj.ctrlOut(:)=struct('start',false,'end',false,'valid',false);
        end

        function setupImpl(obj,varargin)

            obj.iterDoneReg=false;
            obj.startReg=false;


            obj.startOutO=false;
            obj.endOutO=false;
            obj.validOutO=false;
            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                obj.memDepth=64;
                if obj.scalarFlag
                    obj.zCountO=fi(18,0,7,0,hdlfimath);
                    obj.countO=fi(1,0,13,0,hdlfimath);
                else
                    obj.zCountO=fi(0,0,3,0,hdlfimath);
                    obj.countO=fi(0,0,10,0,hdlfimath);
                end
            else
                obj.memDepth=128;
                if obj.scalarFlag
                    obj.zCountO=fi(1,0,8,0,hdlfimath);
                    obj.countO=fi(1,0,15,0,hdlfimath);
                else
                    obj.zCountO=fi(1,0,5,0,hdlfimath);
                    obj.countO=fi(0,0,12,0,hdlfimath);
                end
            end

            obj.dataIdx=fi(0,0,7,0,hdlfimath);
            obj.count8O=fi(0,0,4,0,hdlfimath);
            obj.dataRegO=zeros(obj.memDepth,1)>0;
            obj.dataVecO=zeros(8,1)>0;
            obj.dataVecRegO=zeros(8,1)>0;
            obj.countDataO=fi(1,0,10,0,hdlfimath);
            obj.enbVecO=false;
            obj.enbCountO=false;
            obj.startRegO=false;
            obj.startReg1O=false;
            obj.startOutRegO=false;


            obj.startOutR=false;
            obj.validOutR=false;
            obj.dataReg=zeros(obj.memDepth,1)>0;
            obj.dataAdj=zeros(obj.memDepth,1)>0;
            obj.enbData=false;
            obj.enbDataReg=false;
            obj.count8R=fi(1,0,4,0,hdlfimath);
            obj.selCount=fi(1,0,4,0,hdlfimath);


            if obj.scalarFlag
                obj.dataOut=zeros(1,1)>0;
                obj.dataOutO=zeros(1,1)>0;
            else
                obj.dataOut=zeros(8,1)>0;
                obj.dataOutO=zeros(8,1)>0;
            end
            obj.ctrlOut=struct('start',false,'end',false,'valid',false);


            obj.delayBalancer1=dsp.Delay(18);
            obj.delayBalancer2=dsp.Delay(8);
            obj.delayBalancer3=dsp.Delay(8);

        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.ctrlOut;
        end

        function updateImpl(obj,varargin)

            reset=varargin{1};
            iterdone=varargin{2};
            rdvalid=varargin{3};
            data=varargin{4};
            outlen=varargin{5};
            shiftsel=varargin{6};


            out_start=~(obj.iterDoneReg)&&iterdone;
            obj.iterDoneReg(:)=iterdone;

            if strcmpi(obj.LDPCConfiguration,'(8160,7136) LDPC')
                if obj.scalarFlag
                    starti=obj.delayBalancer1(out_start);
                    [data_out,start_out,end_out,valid_out]=outputGenerationSerial(obj,reset,starti,iterdone,data);
                else
                    [starto,valido,datao]=dataRearrange(obj,reset,data,out_start,iterdone,out_start||rdvalid);
                    start_delay=obj.delayBalancer2(starto);
                    valid_delay=obj.delayBalancer3(valido);
                    [data_out,start_out,end_out,valid_out]=outputGenerationVector(obj,reset,start_delay,valid_delay,datao);
                end
            else
                [data_out,start_out,end_out,valid_out]=outputGeneration(obj,reset,obj.startReg,iterdone,data,outlen,shiftsel);
                obj.startReg(:)=out_start;
            end

            obj.ctrlOut.start(:)=start_out;
            obj.ctrlOut.end(:)=end_out;
            obj.ctrlOut.valid(:)=valid_out;

            if valid_out
                obj.dataOut(:)=data_out;
            else
                if obj.scalarFlag
                    obj.dataOut(:)=0;
                else
                    obj.dataOut(:)=zeros(8,1);
                end
            end
        end

        function[datao,starto,endo,valido]=outputGenerationSerial(obj,reset,starti,iterdone,datai)

            starto=obj.startOutO;
            valido=obj.validOutO;
            datao=obj.dataOutO;


            if reset
                obj.zCountO(:)=18;
                obj.countO(:)=0;
                obj.validOutO(:)=false;
                obj.endOutO(:)=false;
            else
                if starti
                    obj.zCountO(:)=19;
                    obj.countO(:)=1;
                    obj.validOutO(:)=true;
                    obj.endOutO(:)=false;
                elseif iterdone&&obj.validOutO
                    if obj.countO==7136
                        obj.validOutO(:)=false;
                        obj.endOutO(:)=true;
                    else
                        obj.countO(:)=obj.countO+1;
                        obj.validOutO(:)=true;
                        obj.endOutO(:)=false;
                    end
                    if(obj.zCountO==63&&obj.count8O==7)||obj.zCountO==64
                        obj.zCountO(:)=1;
                        if obj.count8O==8
                            obj.count8O(:)=1;
                        else
                            obj.count8O(:)=obj.count8O+1;
                        end
                    else
                        obj.zCountO(:)=obj.zCountO+1;
                    end
                else
                    obj.validOutO(:)=false;
                    obj.endOutO(:)=false;
                end
            end

            obj.dataIdx(:)=obj.zCountO;
            obj.startOutO(:)=starti;
            obj.dataOutO(:)=datai((obj.dataIdx));
            endo=obj.endOutO;
        end

        function[starto,valido,datao]=dataRearrange(obj,reset,data,start,iterdone,valid)

            datao=obj.dataAdj;
            starto=obj.startOutR;
            valido=obj.validOutR;


            if reset
                obj.count8R(:)=0;
                obj.selCount(:)=0;
                obj.enbData(:)=false;
            else
                if valid
                    if start
                        obj.count8R(:)=1;
                        obj.selCount(:)=1;
                        obj.enbData(:)=true;
                    elseif iterdone&&obj.enbData
                        if obj.count8R==8
                            obj.selCount(:)=obj.selCount+1;
                            obj.count8R(:)=1;
                        else
                            obj.count8R(:)=obj.count8R+1;
                        end
                    end
                end
            end

            if valid
                if obj.selCount==fi(1,0,4,0)
                    obj.dataAdj(:)=obj.dataReg;
                elseif obj.selCount==fi(2,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(1:63);data(1)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(2:64);data(1)];
                    end
                elseif obj.selCount==fi(3,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(2:63);data(1:2)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(3:64);data(1:2)];
                    end
                elseif obj.selCount==fi(4,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(3:63);data(1:3)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(4:64);data(1:3)];
                    end
                elseif obj.selCount==fi(5,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(4:63);data(1:4)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(5:64);data(1:4)];
                    end
                elseif obj.selCount==fi(6,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(5:63);data(1:5)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(6:64);data(1:5)];
                    end
                elseif obj.selCount==fi(7,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(6:63);data(1:6)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(7:64);data(1:6)];
                    end
                elseif obj.selCount==fi(8,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(7:63);data(1:7)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(8:64);data(1:7)];
                    end
                elseif obj.selCount==fi(9,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(8:63);data(1:8)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(9:64);data(1:8)];
                    end
                elseif obj.selCount==fi(10,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(9:63);data(1:9)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(10:64);data(1:9)];
                    end
                elseif obj.selCount==fi(11,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(10:63);data(1:10)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(11:64);data(1:10)];
                    end
                elseif obj.selCount==fi(12,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(11:63);data(1:11)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(12:64);data(1:11)];
                    end
                elseif obj.selCount==fi(13,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(12:63);data(1:12)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(13:64);data(1:12)];
                    end
                elseif obj.selCount==fi(14,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(13:63);data(1:13)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(14:64);data(1:13)];
                    end
                elseif obj.selCount==fi(15,0,4,0)
                    if obj.count8R==1
                        obj.dataAdj(:)=[obj.dataReg(14:63);data(1:14)];
                    else
                        obj.dataAdj(:)=[obj.dataReg(15:64);data(1:14)];
                    end
                else
                    obj.dataAdj(:)=zeros(64,1);
                end
            end

            obj.dataReg(:)=data;
            obj.enbDataReg(:)=obj.enbData;
            if obj.selCount==15
                obj.enbData(:)=false;
            end

            obj.startOutR(:)=start;
            obj.validOutR(:)=obj.enbDataReg||obj.enbData;
        end

        function[datao,starto,endo,valido]=outputGenerationVector(obj,reset,starti,validi,datai)

            starto=obj.startOutRegO;
            endo=obj.endOutO;
            valido=obj.validOutO;
            datao=obj.dataOutO;

            if reset
                obj.zCountO(:)=0;
                obj.countO(:)=0;
                obj.enbVecO(:)=false;
            else
                if starti
                    obj.zCountO(:)=0;
                    obj.countO(:)=1;
                    obj.enbVecO(:)=true;
                elseif validi
                    if obj.countO==895
                        obj.enbVecO(:)=false;
                    else
                        obj.countO(:)=obj.countO+1;
                        obj.enbVecO(:)=true;
                    end
                    obj.zCountO(:)=obj.zCountO+1;
                end
            end


            if reset
                obj.enbCountO(:)=false;
                obj.countDataO(:)=0;
                obj.validOutO(:)=false;
                obj.endOutO(:)=false;
            else
                if obj.startOutO
                    obj.countDataO(:)=1;
                    obj.enbCountO(:)=true;
                    obj.validOutO(:)=true;
                    obj.endOutO(:)=false;
                elseif obj.enbCountO
                    obj.validOutO(:)=true;
                    if obj.countDataO==891
                        obj.enbCountO(:)=false;
                        obj.endOutO(:)=true;
                    else
                        obj.countDataO(:)=obj.countDataO+1;
                        obj.endOutO(:)=false;
                    end
                else
                    obj.enbCountO(:)=false;
                    obj.countDataO(:)=0;
                    obj.validOutO(:)=false;
                    obj.endOutO(:)=false;
                end
            end

            obj.startOutRegO(:)=obj.startOutO;
            obj.startOutO(:)=obj.startReg1O;
            obj.startReg1O(:)=obj.startRegO;
            obj.startRegO(:)=starti;


            obj.dataRegO(:)=datai;
            if obj.enbVecO
                if obj.zCountO==fi(0,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(1:8);
                elseif obj.zCountO==fi(1,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(9:16);
                elseif obj.zCountO==fi(2,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(17:24);
                elseif obj.zCountO==fi(3,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(25:32);
                elseif obj.zCountO==fi(4,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(33:40);
                elseif obj.zCountO==fi(5,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(41:48);
                elseif obj.zCountO==fi(6,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(49:56);
                elseif obj.zCountO==fi(7,0,3,0)
                    obj.dataVecO(:)=obj.dataRegO(57:64);
                end
            else
                obj.dataVecO(:)=zeros(8,1);
            end

            obj.dataOutO(:)=[obj.dataVecRegO(3:8);obj.dataVecO(1:2)];
            obj.dataVecRegO(:)=obj.dataVecO;

        end

        function[datao,starto,endo,valido]=outputGeneration(obj,reset,starti,validi,datai,outlen,shiftsel)

            starto=obj.startOutO;
            valido=obj.validOutO;
            datao=obj.dataOutO;
            cnt=obj.countO;
            zcount=obj.zCountO;

            if obj.scalarFlag
                if shiftsel==1
                    maxZCount=fi(64,0,8,0);
                elseif shiftsel==2
                    maxZCount=fi(32,0,8,0);
                elseif shiftsel==0
                    maxZCount=fi(128,0,8,0);
                else
                    maxZCount=fi(128,0,8,0);
                end
            else
                if shiftsel==1
                    maxZCount=fi(8,0,5,0);
                elseif shiftsel==2
                    maxZCount=fi(4,0,5,0);
                elseif shiftsel==0
                    maxZCount=fi(16,0,5,0);
                else
                    maxZCount=fi(16,0,5,0);
                end
            end


            if reset
                obj.zCountO(:)=1;
                obj.countO(:)=0;
                obj.startOutO(:)=false;
                obj.endOutO(:)=false;
                obj.validOutO(:)=false;
            else
                if starti
                    obj.zCountO(:)=1;
                    obj.countO(:)=1;
                    obj.startOutO(:)=true;
                    obj.endOutO(:)=false;
                    obj.validOutO(:)=true;
                elseif validi&&obj.validOutO
                    obj.startOutO(:)=false;
                    if obj.countO==outlen
                        obj.endOutO(:)=true;
                        obj.validOutO(:)=false;
                    else
                        obj.countO(:)=obj.countO+1;
                        obj.endOutO(:)=false;
                        obj.validOutO(:)=true;
                    end
                    if obj.zCountO==maxZCount
                        obj.zCountO(:)=1;
                    else
                        obj.zCountO(:)=obj.zCountO+1;
                    end
                else
                    obj.startOutO(:)=false;
                    obj.endOutO(:)=false;
                    obj.validOutO(:)=false;
                end
            end

            if obj.scalarFlag
                obj.dataOutO(:)=datai(obj.zCountO);
            else
                if obj.zCountO==fi(1,0,5,0)
                    obj.dataOutO(:)=datai(1:8);
                elseif obj.zCountO==fi(2,0,5,0)
                    obj.dataOutO(:)=datai(9:16);
                elseif obj.zCountO==fi(3,0,5,0)
                    obj.dataOutO(:)=datai(17:24);
                elseif obj.zCountO==fi(4,0,5,0)
                    obj.dataOutO(:)=datai(25:32);
                elseif obj.zCountO==fi(5,0,5,0)
                    obj.dataOutO(:)=datai(33:40);
                elseif obj.zCountO==fi(6,0,5,0)
                    obj.dataOutO(:)=datai(41:48);
                elseif obj.zCountO==fi(7,0,5,0)
                    obj.dataOutO(:)=datai(49:56);
                elseif obj.zCountO==fi(8,0,5,0)
                    obj.dataOutO(:)=datai(57:64);
                elseif obj.zCountO==fi(9,0,5,0)
                    obj.dataOutO(:)=datai(65:72);
                elseif obj.zCountO==fi(10,0,5,0)
                    obj.dataOutO(:)=datai(73:80);
                elseif obj.zCountO==fi(11,0,5,0)
                    obj.dataOutO(:)=datai(81:88);
                elseif obj.zCountO==fi(12,0,5,0)
                    obj.dataOutO(:)=datai(89:96);
                elseif obj.zCountO==fi(13,0,5,0)
                    obj.dataOutO(:)=datai(97:104);
                elseif obj.zCountO==fi(14,0,5,0)
                    obj.dataOutO(:)=datai(105:112);
                elseif obj.zCountO==fi(15,0,5,0)
                    obj.dataOutO(:)=datai(113:120);
                elseif obj.zCountO==fi(16,0,5,0)
                    obj.dataOutO(:)=datai(121:128);
                else
                    obj.dataOutO(:)=zeros(8,1);
                end
            end
            endo=obj.endOutO;


        end

        function num=getNumInputsImpl(~)
            num=6;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked


                s.iterDoneReg=obj.iterDoneReg;
                s.startReg=obj.startReg;


                s.startOutO=obj.startOutO;
                s.endOutO=obj.endOutO;
                s.validOutO=obj.validOutO;
                s.dataOutO=obj.dataOutO;
                s.zCountO=obj.zCountO;
                s.dataIdx=obj.dataIdx;
                s.countO=obj.countO;
                s.count8O=obj.count8O;
                s.dataRegO=obj.dataRegO;
                s.dataVecO=obj.dataVecO;
                s.dataVecRegO=obj.dataVecRegO;
                s.countDataO=obj.countDataO;
                s.enbVecO=obj.enbVecO;
                s.enbCountO=obj.enbCountO;
                s.startRegO=obj.startRegO;
                s.startReg1O=obj.startReg1O;
                s.startOutRegO=obj.startOutRegO;


                s.startOutR=obj.startOutR;
                s.validOutR=obj.validOutR;
                s.dataReg=obj.dataReg;
                s.dataAdj=obj.dataAdj;
                s.enbData=obj.enbData;
                s.enbDataReg=obj.enbDataReg;
                s.count8R=obj.count8R;
                s.selCount=obj.selCount;


                s.delayBalancer1=obj.delayBalancer1;
                s.delayBalancer2=obj.delayBalancer2;
                s.delayBalancer3=obj.delayBalancer3;


                s.dataOut=obj.dataOut;
                s.ctrlOut=obj.ctrlOut;

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
