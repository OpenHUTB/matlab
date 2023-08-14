classdef(StrictDefaults)NRLDPCDecoderCyclicShifter<matlab.System




%#codegen

    properties(Nontunable)
        memDepth=384;
        vectorSize=64;
    end


    properties(Access=private)
        dataOut;
        validOut;
        dataDelay;
        rdEnbReg;
        shiftDelay;

        variableDelayData;
        variableDelayShift;

        enb;
        rst;
        cnt;
        wrAddr;
        rdAddr;
        rdEnb;
        rdEnbD;
        selAddr;
        shiftData1;
        shiftData2;
        validOutD;
        validOutD1;
    end

    methods


        function obj=NRLDPCDecoderCyclicShifter(varargin)
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

            obj.dataOut(:)=zeros(obj.memDepth,1);
            obj.validOut=false;

            reset(obj.variableDelayData);
            reset(obj.variableDelayShift);
        end

        function setupImpl(obj,varargin)
            obj.dataOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.validOut=false;
            obj.dataDelay=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.shiftDelay=fi(0,0,9,0);
            obj.rdEnbReg=false;

            obj.variableDelayData=hdl.RAM('RAMType','Simple dual port');
            obj.variableDelayShift=hdl.RAM('RAMType','Simple dual port');

            obj.enb=false;
            obj.rst=false;
            obj.cnt=fi(0,0,1,0);
            obj.wrAddr=fi(0,0,5,0,hdlfimath);
            obj.rdAddr=fi(0,0,5,0,hdlfimath);
            obj.rdEnb=false;
            obj.rdEnbD=false;
            obj.selAddr=fi(0,0,9,0);
            obj.shiftData1=cast(zeros(384,1),'like',varargin{1});
            obj.shiftData2=cast(zeros(384,1),'like',varargin{1});
            obj.validOutD=false;
            obj.validOutD1=false;
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.dataOut;
            varargout{2}=obj.validOut;
        end

        function updateImpl(obj,varargin)
            if obj.vectorSize==64
                data=varargin{1};

                Z=varargin{2};
                V=varargin{3};

                validin=varargin{4};
                count=varargin{5};
                iterdone=varargin{6};

                Vshift=mod(V,Z);

                shiftData=circshift(data(1:Z),int32(Z-mod(Vshift(1),Z)));
                dataout=shiftData';

                if validin
                    obj.dataOut(1:Z)=dataout;
                end

                obj.validOut=validin;
            else

                data=varargin{1};
                Z=varargin{2};
                V=varargin{3};
                validin=varargin{4};
                count=varargin{5};
                iterdone=varargin{6};

                Vshift=fi(mod(V,Z),0,9,0);
                wrenb=validin&&(~iterdone);


                rdenable=obj.rdEnbReg;
                [wraddr,rdaddr,obj.rdEnbReg]=addrGeneration(obj,wrenb,count);
                data_delay=obj.dataDelay;
                obj.dataDelay(:)=step(obj.variableDelayData,data,wraddr,wrenb,rdaddr);


                shift_delay1=obj.shiftDelay;
                obj.shiftDelay(:)=step(obj.variableDelayShift,Vshift,wraddr,wrenb,rdaddr);


                shift_sel=fi(Z-shift_delay1,0,9,0);

                shift_tmp=cast(512-shift_sel,'like',Z);
                shift_delay2=cast(1+shift_tmp,'like',Z);

                if rdenable
                    actshift=shift_delay1;
                else
                    actshift=shift_delay2;
                end

                seladdr=cast(384-shift_sel,'like',Z);

                sellut=shiftValuesLUT(obj,seladdr);

                y=[data_delay;cast(zeros(128,1),'like',data_delay)];
                shiftdatad=circshift(y,int32(512-double(actshift)));


                for idx=1:384
                    if(sellut(idx))
                        obj.dataOut(idx)=obj.shiftData2(idx);
                    else
                        obj.dataOut(idx)=obj.shiftData1(idx);
                    end
                end

                obj.shiftData2(:)=obj.shiftData1;
                obj.shiftData1(:)=shiftdatad(1:384);
                obj.validOut(:)=obj.validOutD1;
                obj.validOutD1(:)=obj.validOutD;
                obj.validOutD(:)=rdenable;
            end

        end

        function[wraddr,rdaddr,rdenable]=addrGeneration(obj,valid,count)

            wraddr=obj.wrAddr;
            rdaddr=obj.rdAddr;
            rdenable=obj.rdEnbD;

            if valid
                reset=false;
            else
                reset=obj.rst;
            end


            if count==obj.rdAddr
                obj.rst(:)=true;
            elseif valid
                obj.rst(:)=false;
            end

            if valid
                obj.enb(:)=true;
            else
                if obj.rst
                    obj.enb(:)=false;
                end
            end

            if obj.enb
                if obj.cnt==1
                    obj.cnt(:)=0;
                else
                    obj.cnt(:)=obj.cnt+1;
                end
            else
                obj.cnt(:)=0;
            end


            if reset
                obj.wrAddr(:)=0;
            else
                if obj.enb
                    obj.wrAddr(:)=obj.wrAddr+1;
                end
            end

            obj.rdEnbD(:)=obj.rdEnb;

            if obj.cnt==1
                obj.rdEnb(:)=true;
            else
                obj.rdEnb(:)=false;
            end


            if reset
                obj.rdAddr(:)=0;
            else
                if rdenable
                    obj.rdAddr(:)=obj.rdAddr+1;
                end
            end

        end

        function sel_lut=shiftValuesLUT(obj,seladdr)

            LUT=[
            fi(ones(1,384),0,1,0);
            fi([ones(1,383),0],0,1,0);
            fi([ones(1,382),0,0],0,1,0);
            fi([ones(1,381),zeros(1,3)],0,1,0);
            fi([ones(1,380),zeros(1,4)],0,1,0);
            fi([ones(1,379),zeros(1,5)],0,1,0);
            fi([ones(1,378),zeros(1,6)],0,1,0);
            fi([ones(1,377),zeros(1,7)],0,1,0);
            fi([ones(1,376),zeros(1,8)],0,1,0);
            fi([ones(1,375),zeros(1,9)],0,1,0);
            fi([ones(1,374),zeros(1,10)],0,1,0);
            fi([ones(1,373),zeros(1,11)],0,1,0);
            fi([ones(1,372),zeros(1,12)],0,1,0);
            fi([ones(1,371),zeros(1,13)],0,1,0);
            fi([ones(1,370),zeros(1,14)],0,1,0);
            fi([ones(1,369),zeros(1,15)],0,1,0);
            fi([ones(1,368),zeros(1,16)],0,1,0);
            fi([ones(1,367),zeros(1,17)],0,1,0);
            fi([ones(1,366),zeros(1,18)],0,1,0);
            fi([ones(1,365),zeros(1,19)],0,1,0);
            fi([ones(1,364),zeros(1,20)],0,1,0);
            fi([ones(1,363),zeros(1,21)],0,1,0);
            fi([ones(1,362),zeros(1,22)],0,1,0);
            fi([ones(1,361),zeros(1,23)],0,1,0);
            fi([ones(1,360),zeros(1,24)],0,1,0);
            fi([ones(1,359),zeros(1,25)],0,1,0);
            fi([ones(1,358),zeros(1,26)],0,1,0);
            fi([ones(1,357),zeros(1,27)],0,1,0);
            fi([ones(1,356),zeros(1,28)],0,1,0);
            fi([ones(1,355),zeros(1,29)],0,1,0);
            fi([ones(1,354),zeros(1,30)],0,1,0);
            fi([ones(1,353),zeros(1,31)],0,1,0);
            fi([ones(1,352),zeros(1,32)],0,1,0);
            fi([ones(1,351),zeros(1,33)],0,1,0);
            fi([ones(1,350),zeros(1,34)],0,1,0);
            fi([ones(1,349),zeros(1,35)],0,1,0);
            fi([ones(1,348),zeros(1,36)],0,1,0);
            fi([ones(1,347),zeros(1,37)],0,1,0);
            fi([ones(1,346),zeros(1,38)],0,1,0);
            fi([ones(1,345),zeros(1,39)],0,1,0);
            fi([ones(1,344),zeros(1,40)],0,1,0);
            fi([ones(1,343),zeros(1,41)],0,1,0);
            fi([ones(1,342),zeros(1,42)],0,1,0);
            fi([ones(1,341),zeros(1,43)],0,1,0);
            fi([ones(1,340),zeros(1,44)],0,1,0);
            fi([ones(1,339),zeros(1,45)],0,1,0);
            fi([ones(1,338),zeros(1,46)],0,1,0);
            fi([ones(1,337),zeros(1,47)],0,1,0);
            fi([ones(1,336),zeros(1,48)],0,1,0);
            fi([ones(1,335),zeros(1,49)],0,1,0);
            fi([ones(1,334),zeros(1,50)],0,1,0);
            fi([ones(1,333),zeros(1,51)],0,1,0);
            fi([ones(1,332),zeros(1,52)],0,1,0);
            fi([ones(1,331),zeros(1,53)],0,1,0);
            fi([ones(1,330),zeros(1,54)],0,1,0);
            fi([ones(1,329),zeros(1,55)],0,1,0);
            fi([ones(1,328),zeros(1,56)],0,1,0);
            fi([ones(1,327),zeros(1,57)],0,1,0);
            fi([ones(1,326),zeros(1,58)],0,1,0);
            fi([ones(1,325),zeros(1,59)],0,1,0);
            fi([ones(1,324),zeros(1,60)],0,1,0);
            fi([ones(1,323),zeros(1,61)],0,1,0);
            fi([ones(1,322),zeros(1,62)],0,1,0);
            fi([ones(1,321),zeros(1,63)],0,1,0);
            fi([ones(1,320),zeros(1,64)],0,1,0);
            fi([ones(1,319),zeros(1,65)],0,1,0);
            fi([ones(1,318),zeros(1,66)],0,1,0);
            fi([ones(1,317),zeros(1,67)],0,1,0);
            fi([ones(1,316),zeros(1,68)],0,1,0);
            fi([ones(1,315),zeros(1,69)],0,1,0);
            fi([ones(1,314),zeros(1,70)],0,1,0);
            fi([ones(1,313),zeros(1,71)],0,1,0);
            fi([ones(1,312),zeros(1,72)],0,1,0);
            fi([ones(1,311),zeros(1,73)],0,1,0);
            fi([ones(1,310),zeros(1,74)],0,1,0);
            fi([ones(1,309),zeros(1,75)],0,1,0);
            fi([ones(1,308),zeros(1,76)],0,1,0);
            fi([ones(1,307),zeros(1,77)],0,1,0);
            fi([ones(1,306),zeros(1,78)],0,1,0);
            fi([ones(1,305),zeros(1,79)],0,1,0);
            fi([ones(1,304),zeros(1,80)],0,1,0);
            fi([ones(1,303),zeros(1,81)],0,1,0);
            fi([ones(1,302),zeros(1,82)],0,1,0);
            fi([ones(1,301),zeros(1,83)],0,1,0);
            fi([ones(1,300),zeros(1,84)],0,1,0);
            fi([ones(1,299),zeros(1,85)],0,1,0);
            fi([ones(1,298),zeros(1,86)],0,1,0);
            fi([ones(1,297),zeros(1,87)],0,1,0);
            fi([ones(1,296),zeros(1,88)],0,1,0);
            fi([ones(1,295),zeros(1,89)],0,1,0);
            fi([ones(1,294),zeros(1,90)],0,1,0);
            fi([ones(1,293),zeros(1,91)],0,1,0);
            fi([ones(1,292),zeros(1,92)],0,1,0);
            fi([ones(1,291),zeros(1,93)],0,1,0);
            fi([ones(1,290),zeros(1,94)],0,1,0);
            fi([ones(1,289),zeros(1,95)],0,1,0);
            fi([ones(1,288),zeros(1,96)],0,1,0);
            fi([ones(1,287),zeros(1,97)],0,1,0);
            fi([ones(1,286),zeros(1,98)],0,1,0);
            fi([ones(1,285),zeros(1,99)],0,1,0);
            fi([ones(1,284),zeros(1,100)],0,1,0);
            fi([ones(1,283),zeros(1,101)],0,1,0);
            fi([ones(1,282),zeros(1,102)],0,1,0);
            fi([ones(1,281),zeros(1,103)],0,1,0);
            fi([ones(1,280),zeros(1,104)],0,1,0);
            fi([ones(1,279),zeros(1,105)],0,1,0);
            fi([ones(1,278),zeros(1,106)],0,1,0);
            fi([ones(1,277),zeros(1,107)],0,1,0);
            fi([ones(1,276),zeros(1,108)],0,1,0);
            fi([ones(1,275),zeros(1,109)],0,1,0);
            fi([ones(1,274),zeros(1,110)],0,1,0);
            fi([ones(1,273),zeros(1,111)],0,1,0);
            fi([ones(1,272),zeros(1,112)],0,1,0);
            fi([ones(1,271),zeros(1,113)],0,1,0);
            fi([ones(1,270),zeros(1,114)],0,1,0);
            fi([ones(1,269),zeros(1,115)],0,1,0);
            fi([ones(1,268),zeros(1,116)],0,1,0);
            fi([ones(1,267),zeros(1,117)],0,1,0);
            fi([ones(1,266),zeros(1,118)],0,1,0);
            fi([ones(1,265),zeros(1,119)],0,1,0);
            fi([ones(1,264),zeros(1,120)],0,1,0);
            fi([ones(1,263),zeros(1,121)],0,1,0);
            fi([ones(1,262),zeros(1,122)],0,1,0);
            fi([ones(1,261),zeros(1,123)],0,1,0);
            fi([ones(1,260),zeros(1,124)],0,1,0);
            fi([ones(1,259),zeros(1,125)],0,1,0);
            fi([ones(1,258),zeros(1,126)],0,1,0);
            fi([ones(1,257),zeros(1,127)],0,1,0);
            fi([ones(1,256),zeros(1,128)],0,1,0);
            fi([ones(1,255),zeros(1,129)],0,1,0);
            fi([ones(1,254),zeros(1,130)],0,1,0);
            fi([ones(1,253),zeros(1,131)],0,1,0);
            fi([ones(1,252),zeros(1,132)],0,1,0);
            fi([ones(1,251),zeros(1,133)],0,1,0);
            fi([ones(1,250),zeros(1,134)],0,1,0);
            fi([ones(1,249),zeros(1,135)],0,1,0);
            fi([ones(1,248),zeros(1,136)],0,1,0);
            fi([ones(1,247),zeros(1,137)],0,1,0);
            fi([ones(1,246),zeros(1,138)],0,1,0);
            fi([ones(1,245),zeros(1,139)],0,1,0);
            fi([ones(1,244),zeros(1,140)],0,1,0);
            fi([ones(1,243),zeros(1,141)],0,1,0);
            fi([ones(1,242),zeros(1,142)],0,1,0);
            fi([ones(1,241),zeros(1,143)],0,1,0);
            fi([ones(1,240),zeros(1,144)],0,1,0);
            fi([ones(1,239),zeros(1,145)],0,1,0);
            fi([ones(1,238),zeros(1,146)],0,1,0);
            fi([ones(1,237),zeros(1,147)],0,1,0);
            fi([ones(1,236),zeros(1,148)],0,1,0);
            fi([ones(1,235),zeros(1,149)],0,1,0);
            fi([ones(1,234),zeros(1,150)],0,1,0);
            fi([ones(1,233),zeros(1,151)],0,1,0);
            fi([ones(1,232),zeros(1,152)],0,1,0);
            fi([ones(1,231),zeros(1,153)],0,1,0);
            fi([ones(1,230),zeros(1,154)],0,1,0);
            fi([ones(1,229),zeros(1,155)],0,1,0);
            fi([ones(1,228),zeros(1,156)],0,1,0);
            fi([ones(1,227),zeros(1,157)],0,1,0);
            fi([ones(1,226),zeros(1,158)],0,1,0);
            fi([ones(1,225),zeros(1,159)],0,1,0);
            fi([ones(1,224),zeros(1,160)],0,1,0);
            fi([ones(1,223),zeros(1,161)],0,1,0);
            fi([ones(1,222),zeros(1,162)],0,1,0);
            fi([ones(1,221),zeros(1,163)],0,1,0);
            fi([ones(1,220),zeros(1,164)],0,1,0);
            fi([ones(1,219),zeros(1,165)],0,1,0);
            fi([ones(1,218),zeros(1,166)],0,1,0);
            fi([ones(1,217),zeros(1,167)],0,1,0);
            fi([ones(1,216),zeros(1,168)],0,1,0);
            fi([ones(1,215),zeros(1,169)],0,1,0);
            fi([ones(1,214),zeros(1,170)],0,1,0);
            fi([ones(1,213),zeros(1,171)],0,1,0);
            fi([ones(1,212),zeros(1,172)],0,1,0);
            fi([ones(1,211),zeros(1,173)],0,1,0);
            fi([ones(1,210),zeros(1,174)],0,1,0);
            fi([ones(1,209),zeros(1,175)],0,1,0);
            fi([ones(1,208),zeros(1,176)],0,1,0);
            fi([ones(1,207),zeros(1,177)],0,1,0);
            fi([ones(1,206),zeros(1,178)],0,1,0);
            fi([ones(1,205),zeros(1,179)],0,1,0);
            fi([ones(1,204),zeros(1,180)],0,1,0);
            fi([ones(1,203),zeros(1,181)],0,1,0);
            fi([ones(1,202),zeros(1,182)],0,1,0);
            fi([ones(1,201),zeros(1,183)],0,1,0);
            fi([ones(1,200),zeros(1,184)],0,1,0);
            fi([ones(1,199),zeros(1,185)],0,1,0);
            fi([ones(1,198),zeros(1,186)],0,1,0);
            fi([ones(1,197),zeros(1,187)],0,1,0);
            fi([ones(1,196),zeros(1,188)],0,1,0);
            fi([ones(1,195),zeros(1,189)],0,1,0);
            fi([ones(1,194),zeros(1,190)],0,1,0);
            fi([ones(1,193),zeros(1,191)],0,1,0);
            fi([ones(1,192),zeros(1,192)],0,1,0);
            fi([ones(1,191),zeros(1,193)],0,1,0);
            fi([ones(1,190),zeros(1,194)],0,1,0);
            fi([ones(1,189),zeros(1,195)],0,1,0);
            fi([ones(1,188),zeros(1,196)],0,1,0);
            fi([ones(1,187),zeros(1,197)],0,1,0);
            fi([ones(1,186),zeros(1,198)],0,1,0);
            fi([ones(1,185),zeros(1,199)],0,1,0);
            fi([ones(1,184),zeros(1,200)],0,1,0);
            fi([ones(1,183),zeros(1,201)],0,1,0);
            fi([ones(1,182),zeros(1,202)],0,1,0);
            fi([ones(1,181),zeros(1,203)],0,1,0);
            fi([ones(1,180),zeros(1,204)],0,1,0);
            fi([ones(1,179),zeros(1,205)],0,1,0);
            fi([ones(1,178),zeros(1,206)],0,1,0);
            fi([ones(1,177),zeros(1,207)],0,1,0);
            fi([ones(1,176),zeros(1,208)],0,1,0);
            fi([ones(1,175),zeros(1,209)],0,1,0);
            fi([ones(1,174),zeros(1,210)],0,1,0);
            fi([ones(1,173),zeros(1,211)],0,1,0);
            fi([ones(1,172),zeros(1,212)],0,1,0);
            fi([ones(1,171),zeros(1,213)],0,1,0);
            fi([ones(1,170),zeros(1,214)],0,1,0);
            fi([ones(1,169),zeros(1,215)],0,1,0);
            fi([ones(1,168),zeros(1,216)],0,1,0);
            fi([ones(1,167),zeros(1,217)],0,1,0);
            fi([ones(1,166),zeros(1,218)],0,1,0);
            fi([ones(1,165),zeros(1,219)],0,1,0);
            fi([ones(1,164),zeros(1,220)],0,1,0);
            fi([ones(1,163),zeros(1,221)],0,1,0);
            fi([ones(1,162),zeros(1,222)],0,1,0);
            fi([ones(1,161),zeros(1,223)],0,1,0);
            fi([ones(1,160),zeros(1,224)],0,1,0);
            fi([ones(1,159),zeros(1,225)],0,1,0);
            fi([ones(1,158),zeros(1,226)],0,1,0);
            fi([ones(1,157),zeros(1,227)],0,1,0);
            fi([ones(1,156),zeros(1,228)],0,1,0);
            fi([ones(1,155),zeros(1,229)],0,1,0);
            fi([ones(1,154),zeros(1,230)],0,1,0);
            fi([ones(1,153),zeros(1,231)],0,1,0);
            fi([ones(1,152),zeros(1,232)],0,1,0);
            fi([ones(1,151),zeros(1,233)],0,1,0);
            fi([ones(1,150),zeros(1,234)],0,1,0);
            fi([ones(1,149),zeros(1,235)],0,1,0);
            fi([ones(1,148),zeros(1,236)],0,1,0);
            fi([ones(1,147),zeros(1,237)],0,1,0);
            fi([ones(1,146),zeros(1,238)],0,1,0);
            fi([ones(1,145),zeros(1,239)],0,1,0);
            fi([ones(1,144),zeros(1,240)],0,1,0);
            fi([ones(1,143),zeros(1,241)],0,1,0);
            fi([ones(1,142),zeros(1,242)],0,1,0);
            fi([ones(1,141),zeros(1,243)],0,1,0);
            fi([ones(1,140),zeros(1,244)],0,1,0);
            fi([ones(1,139),zeros(1,245)],0,1,0);
            fi([ones(1,138),zeros(1,246)],0,1,0);
            fi([ones(1,137),zeros(1,247)],0,1,0);
            fi([ones(1,136),zeros(1,248)],0,1,0);
            fi([ones(1,135),zeros(1,249)],0,1,0);
            fi([ones(1,134),zeros(1,250)],0,1,0);
            fi([ones(1,133),zeros(1,251)],0,1,0);
            fi([ones(1,132),zeros(1,252)],0,1,0);
            fi([ones(1,131),zeros(1,253)],0,1,0);
            fi([ones(1,130),zeros(1,254)],0,1,0);
            fi([ones(1,129),zeros(1,255)],0,1,0);
            fi([ones(1,128),zeros(1,256)],0,1,0);
            fi([ones(1,127),zeros(1,257)],0,1,0);
            fi([ones(1,126),zeros(1,258)],0,1,0);
            fi([ones(1,125),zeros(1,259)],0,1,0);
            fi([ones(1,124),zeros(1,260)],0,1,0);
            fi([ones(1,123),zeros(1,261)],0,1,0);
            fi([ones(1,122),zeros(1,262)],0,1,0);
            fi([ones(1,121),zeros(1,263)],0,1,0);
            fi([ones(1,120),zeros(1,264)],0,1,0);
            fi([ones(1,119),zeros(1,265)],0,1,0);
            fi([ones(1,118),zeros(1,266)],0,1,0);
            fi([ones(1,117),zeros(1,267)],0,1,0);
            fi([ones(1,116),zeros(1,268)],0,1,0);
            fi([ones(1,115),zeros(1,269)],0,1,0);
            fi([ones(1,114),zeros(1,270)],0,1,0);
            fi([ones(1,113),zeros(1,271)],0,1,0);
            fi([ones(1,112),zeros(1,272)],0,1,0);
            fi([ones(1,111),zeros(1,273)],0,1,0);
            fi([ones(1,110),zeros(1,274)],0,1,0);
            fi([ones(1,109),zeros(1,275)],0,1,0);
            fi([ones(1,108),zeros(1,276)],0,1,0);
            fi([ones(1,107),zeros(1,277)],0,1,0);
            fi([ones(1,106),zeros(1,278)],0,1,0);
            fi([ones(1,105),zeros(1,279)],0,1,0);
            fi([ones(1,104),zeros(1,280)],0,1,0);
            fi([ones(1,103),zeros(1,281)],0,1,0);
            fi([ones(1,102),zeros(1,282)],0,1,0);
            fi([ones(1,101),zeros(1,283)],0,1,0);
            fi([ones(1,100),zeros(1,284)],0,1,0);
            fi([ones(1,99),zeros(1,285)],0,1,0);
            fi([ones(1,98),zeros(1,286)],0,1,0);
            fi([ones(1,97),zeros(1,287)],0,1,0);
            fi([ones(1,96),zeros(1,288)],0,1,0);
            fi([ones(1,95),zeros(1,289)],0,1,0);
            fi([ones(1,94),zeros(1,290)],0,1,0);
            fi([ones(1,93),zeros(1,291)],0,1,0);
            fi([ones(1,92),zeros(1,292)],0,1,0);
            fi([ones(1,91),zeros(1,293)],0,1,0);
            fi([ones(1,90),zeros(1,294)],0,1,0);
            fi([ones(1,89),zeros(1,295)],0,1,0);
            fi([ones(1,88),zeros(1,296)],0,1,0);
            fi([ones(1,87),zeros(1,297)],0,1,0);
            fi([ones(1,86),zeros(1,298)],0,1,0);
            fi([ones(1,85),zeros(1,299)],0,1,0);
            fi([ones(1,84),zeros(1,300)],0,1,0);
            fi([ones(1,83),zeros(1,301)],0,1,0);
            fi([ones(1,82),zeros(1,302)],0,1,0);
            fi([ones(1,81),zeros(1,303)],0,1,0);
            fi([ones(1,80),zeros(1,304)],0,1,0);
            fi([ones(1,79),zeros(1,305)],0,1,0);
            fi([ones(1,78),zeros(1,306)],0,1,0);
            fi([ones(1,77),zeros(1,307)],0,1,0);
            fi([ones(1,76),zeros(1,308)],0,1,0);
            fi([ones(1,75),zeros(1,309)],0,1,0);
            fi([ones(1,74),zeros(1,310)],0,1,0);
            fi([ones(1,73),zeros(1,311)],0,1,0);
            fi([ones(1,72),zeros(1,312)],0,1,0);
            fi([ones(1,71),zeros(1,313)],0,1,0);
            fi([ones(1,70),zeros(1,314)],0,1,0);
            fi([ones(1,69),zeros(1,315)],0,1,0);
            fi([ones(1,68),zeros(1,316)],0,1,0);
            fi([ones(1,67),zeros(1,317)],0,1,0);
            fi([ones(1,66),zeros(1,318)],0,1,0);
            fi([ones(1,65),zeros(1,319)],0,1,0);
            fi([ones(1,64),zeros(1,320)],0,1,0);
            fi([ones(1,63),zeros(1,321)],0,1,0);
            fi([ones(1,62),zeros(1,322)],0,1,0);
            fi([ones(1,61),zeros(1,323)],0,1,0);
            fi([ones(1,60),zeros(1,324)],0,1,0);
            fi([ones(1,59),zeros(1,325)],0,1,0);
            fi([ones(1,58),zeros(1,326)],0,1,0);
            fi([ones(1,57),zeros(1,327)],0,1,0);
            fi([ones(1,56),zeros(1,328)],0,1,0);
            fi([ones(1,55),zeros(1,329)],0,1,0);
            fi([ones(1,54),zeros(1,330)],0,1,0);
            fi([ones(1,53),zeros(1,331)],0,1,0);
            fi([ones(1,52),zeros(1,332)],0,1,0);
            fi([ones(1,51),zeros(1,333)],0,1,0);
            fi([ones(1,50),zeros(1,334)],0,1,0);
            fi([ones(1,49),zeros(1,335)],0,1,0);
            fi([ones(1,48),zeros(1,336)],0,1,0);
            fi([ones(1,47),zeros(1,337)],0,1,0);
            fi([ones(1,46),zeros(1,338)],0,1,0);
            fi([ones(1,45),zeros(1,339)],0,1,0);
            fi([ones(1,44),zeros(1,340)],0,1,0);
            fi([ones(1,43),zeros(1,341)],0,1,0);
            fi([ones(1,42),zeros(1,342)],0,1,0);
            fi([ones(1,41),zeros(1,343)],0,1,0);
            fi([ones(1,40),zeros(1,344)],0,1,0);
            fi([ones(1,39),zeros(1,345)],0,1,0);
            fi([ones(1,38),zeros(1,346)],0,1,0);
            fi([ones(1,37),zeros(1,347)],0,1,0);
            fi([ones(1,36),zeros(1,348)],0,1,0);
            fi([ones(1,35),zeros(1,349)],0,1,0);
            fi([ones(1,34),zeros(1,350)],0,1,0);
            fi([ones(1,33),zeros(1,351)],0,1,0);
            fi([ones(1,32),zeros(1,352)],0,1,0);
            fi([ones(1,31),zeros(1,353)],0,1,0);
            fi([ones(1,30),zeros(1,354)],0,1,0);
            fi([ones(1,29),zeros(1,355)],0,1,0);
            fi([ones(1,28),zeros(1,356)],0,1,0);
            fi([ones(1,27),zeros(1,357)],0,1,0);
            fi([ones(1,26),zeros(1,358)],0,1,0);
            fi([ones(1,25),zeros(1,359)],0,1,0);
            fi([ones(1,24),zeros(1,360)],0,1,0);
            fi([ones(1,23),zeros(1,361)],0,1,0);
            fi([ones(1,22),zeros(1,362)],0,1,0);
            fi([ones(1,21),zeros(1,363)],0,1,0);
            fi([ones(1,20),zeros(1,364)],0,1,0);
            fi([ones(1,19),zeros(1,365)],0,1,0);
            fi([ones(1,18),zeros(1,366)],0,1,0);
            fi([ones(1,17),zeros(1,367)],0,1,0);
            fi([ones(1,16),zeros(1,368)],0,1,0);
            fi([ones(1,15),zeros(1,369)],0,1,0);
            fi([ones(1,14),zeros(1,370)],0,1,0);
            fi([ones(1,13),zeros(1,371)],0,1,0);
            fi([ones(1,12),zeros(1,372)],0,1,0);
            fi([ones(1,11),zeros(1,373)],0,1,0);
            fi([ones(1,10),zeros(1,374)],0,1,0);
            fi([ones(1,9),zeros(1,375)],0,1,0);
            fi([ones(1,8),zeros(1,376)],0,1,0);
            fi([ones(1,7),zeros(1,377)],0,1,0);
            fi([ones(1,6),zeros(1,378)],0,1,0);
            fi([ones(1,5),zeros(1,379)],0,1,0);
            fi([ones(1,4),zeros(1,380)],0,1,0);
            fi([ones(1,3),zeros(1,381)],0,1,0);
            fi([ones(1,2),zeros(1,382)],0,1,0);
            fi([ones(1,1),zeros(1,383)],0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);
            fi(zeros(1,384),0,1,0);];

            sel_lut=LUT(obj.selAddr+1,:)';
            obj.selAddr(:)=seladdr;
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
                s.dataOut=obj.dataOut;
                s.validOut=obj.validOut;
                s.dataDelay=obj.dataDelay;
                s.rdEnbReg=obj.rdEnbReg;
                s.shiftDelay=obj.shiftDelay;

                s.variableDelayData=obj.variableDelayData;
                s.variableDelayShift=obj.variableDelayShift;

                s.enb=obj.enb;
                s.rst=obj.rst;
                s.cnt=obj.cnt;
                s.wrAddr=obj.wrAddr;
                s.rdAddr=obj.rdAddr;
                s.rdEnb=obj.rdEnb;
                s.rdEnbD=obj.rdEnbD;
                s.selAddr=obj.selAddr;
                s.shiftData1=obj.shiftData1;
                s.shiftData2=obj.shiftData2;
                s.validOutD=obj.validOutD;
                s.validOutD1=obj.validOutD1;
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
