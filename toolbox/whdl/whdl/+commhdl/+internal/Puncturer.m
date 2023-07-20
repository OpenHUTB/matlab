classdef(StrictDefaults)Puncturer<matlab.System











%#codegen


    properties(Nontunable)


        OpMode='Continuous';


        VecSource='Input port';


        EncRate='1/2';


        puncVector=[1,1,1,0,0,1]';
    end

    properties(Hidden,Constant)
        OpModeSet=matlab.system.StringSet(...
        {'Continuous','Frame'});
        VecSourceSet=matlab.system.StringSet(...
        {'Input port','Property'});
        EncRateSet=matlab.system.StringSet(...
        {'1/2','1/3','1/4','1/5','1/6','1/7'});
    end

    properties(Nontunable,Access=private)

        vecLen;

        EncLen;

        Scalar;

dataRegReset

dataOutReset
    end

    properties(Access=private)

        dataOut;
        dataOutBuf;
        dataReg1;
        dataReg2;
        dataReg3;


        initPos;
        vecInd;
        puncVec;
        subVec;



        regInd1;
        regInd2;
        regInd3;


        syncReg1;
        syncReg2;
        puncVecBuf;

        startReg1;
        endReg1;
        validReg1;
        dataInBuf1;

        startReg2;
        endReg2;
        validReg2;
        dataInBuf2;


        startOut;
        endOut;
        validOut;
        ctrlOut;


        initStart;
        frameOn;
        startFlag;


        intToggle;
        endFlag;
    end


    methods

        function obj=Puncturer(varargin)
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

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function setupImpl(obj,varargin)

            if(length(varargin{1})==1)
                obj.Scalar=true;
            else
                obj.Scalar=false;
            end

            if strcmpi(obj.EncRate,'1/2')
                obj.EncLen=2;
            elseif strcmpi(obj.EncRate,'1/3')
                obj.EncLen=3;
            elseif strcmpi(obj.EncRate,'1/4')
                obj.EncLen=4;
            elseif strcmpi(obj.EncRate,'1/5')
                obj.EncLen=5;
            elseif strcmpi(obj.EncRate,'1/6')
                obj.EncLen=6;
            else
                obj.EncLen=7;
            end

            if(obj.Scalar)
                obj.dataOut=cast(0,'like',varargin{1});
                obj.dataOutBuf=cast(0,'like',varargin{1});
                obj.dataInBuf1=cast(0,'like',varargin{1});
                obj.dataInBuf2=cast(0,'like',varargin{1});
                obj.dataOutReset=cast(0,'like',varargin{1});
                obj.subVec=false;
            else
                obj.dataOut=cast(zeros(obj.EncLen,1),'like',varargin{1});
                obj.dataOutBuf=cast(0,'like',varargin{1});
                obj.dataInBuf1=cast(zeros(obj.EncLen,1),'like',varargin{1});
                obj.dataInBuf2=cast(zeros(obj.EncLen,1),'like',varargin{1});
                obj.dataOutReset=cast(zeros(obj.EncLen,1),'like',varargin{1});
                obj.subVec=false(obj.EncLen,1);
            end

            obj.initPos=fi(1,0,5,0,hdlfimath);
            obj.vecInd=fi(1,0,5,0,hdlfimath);

            obj.regInd1=fi(0,0,4,0,hdlfimath);
            obj.regInd2=fi(0,0,4,0,hdlfimath);
            obj.regInd3=fi(0,0,4,0,hdlfimath);

            obj.dataReg1=cast(zeros(2*obj.EncLen,1),'like',varargin{1});
            obj.dataReg2=cast(zeros(2*obj.EncLen,1),'like',varargin{1});
            obj.dataReg3=cast(zeros(2*obj.EncLen,1),'like',varargin{1});
            obj.dataRegReset=cast(zeros(2*obj.EncLen,1),'like',varargin{1});

            obj.syncReg1=false;
            obj.syncReg2=false;

            obj.startReg1=false;
            obj.endReg1=false;
            obj.validReg1=false;

            obj.startReg2=false;
            obj.endReg2=false;
            obj.validReg2=false;

            obj.startOut=false;
            obj.endOut=false;
            obj.validOut=false;
            obj.ctrlOut=struct('start',false,...
            'end',false,...
            'valid',false);

            obj.initStart=false;
            obj.frameOn=false;
            obj.startFlag=false;

            obj.intToggle=false;
            obj.endFlag=false;

            if strcmpi(obj.VecSource,'Property')
                obj.vecLen=fi(length(obj.puncVector),0,5,0);
            else
                obj.vecLen=fi(length(varargin{2}),0,5,0);
            end

            obj.puncVecBuf=false(length(varargin{2}),1);

            if strcmpi(obj.VecSource,'Input port')
                obj.puncVec=false(length(varargin{2}),1);
            end
        end

        function resetImpl(obj)


            obj.initPos=fi(1,0,5,0,hdlfimath);
            obj.vecInd=fi(1,0,5,0,hdlfimath);

            obj.regInd1=fi(0,0,4,0,hdlfimath);
            obj.regInd2=fi(0,0,4,0,hdlfimath);
            obj.regInd3=fi(0,0,4,0,hdlfimath);

            obj.syncReg1=false;
            obj.syncReg2=false;

            obj.initStart=false;
            obj.frameOn=false;
            obj.startFlag=false;

            obj.startOut=false;
            obj.endOut=false;
            obj.validOut=false;

            obj.startReg1=false;
            obj.endReg1=false;
            obj.validReg1=false;

            obj.startReg2=false;
            obj.endReg2=false;
            obj.validReg2=false;

            obj.intToggle=false;
            obj.endFlag=false;
        end

        function flag=getExecutionSemanticsImpl(~)

            flag={'Classic','Synchronous'};
        end

        function varargout=outputImpl(obj,varargin)

            if strcmpi(obj.OpMode,'Continuous')

                if(obj.validOut)
                    varargout{1}=obj.dataOut;
                else
                    varargout{1}=obj.dataOutReset;
                end
                varargout{2}=obj.validOut;
            else

                if(obj.validOut)
                    varargout{1}=obj.dataOut;
                else
                    varargout{1}=obj.dataOutReset;
                end
                obj.ctrlOut.start=obj.startOut;
                obj.ctrlOut.end=obj.endOut;
                obj.ctrlOut.valid=obj.validOut;
                varargout{2}=obj.ctrlOut;
            end
        end

        function updateImpl(obj,varargin)

            dataIn=varargin{1};


            if strcmpi(obj.OpMode,'Continuous')
                if strcmpi(obj.VecSource,'Input port')
                    vector=varargin{2};
                    syncPunc=varargin{3};
                    validIn=varargin{4};
                else
                    syncPunc=varargin{2};
                    validIn=varargin{3};
                end
            else
                if strcmpi(obj.VecSource,'Input port')
                    vector=varargin{2};
                    ctrlIn=varargin{3};
                    startIn=ctrlIn.start;
                    endIn=ctrlIn.end;
                    validIn=ctrlIn.valid;
                else
                    ctrlIn=varargin{2};
                    startIn=ctrlIn.start;
                    endIn=ctrlIn.end;
                    validIn=ctrlIn.valid;
                end
            end



            if(~obj.Scalar)

                if((strcmpi(obj.OpMode,'Continuous')))
                    if(obj.syncReg2&&obj.validReg2)
                        regInd1D=fi(0,0,4,0,hdlfimath);
                        dataReg1D=obj.dataRegReset;
                    else
                        regInd1D=obj.regInd1;
                        dataReg1D=obj.dataReg1;
                    end
                else
                    if(obj.startReg2&&obj.validReg2)
                        regInd1D=fi(0,0,4,0,hdlfimath);
                        dataReg1D=obj.dataRegReset;
                    else
                        regInd1D=obj.regInd1;
                        dataReg1D=obj.dataReg1;
                    end
                end



                [obj.dataReg2,obj.regInd2]=updateDataReg(obj,regInd1D,dataReg1D);
            end


            if strcmpi(obj.OpMode,'Continuous')

                if(obj.Scalar)

                    obj.validOut=obj.subVec;
                    dataOutD=obj.dataInBuf2;

                else

                    if(obj.regInd2>fi((obj.EncLen-1),0,4,0,hdlfimath))


                        obj.validOut=true;
                        dataOutD=obj.dataReg2(1:obj.EncLen);
                        obj.dataReg1(1:end-obj.EncLen)=obj.dataReg2(obj.EncLen+1:end);
                        obj.regInd1=fi(obj.regInd2-obj.EncLen,0,4,0,hdlfimath);
                    else


                        obj.validOut=false;
                        dataOutD=obj.dataOutReset;
                        obj.dataReg1=obj.dataReg2;
                        obj.regInd1=fi(obj.regInd2,0,4,0,hdlfimath);
                    end
                end
            else

                if(obj.Scalar)

                    dataOutD=obj.dataOutReset;

                    if(obj.startReg2&&obj.validReg2)

                        obj.frameOn=true;
                        obj.startFlag=true;
                        obj.initStart=~obj.subVec;
                        if(obj.subVec||obj.endFlag)
                            dataOutD=obj.dataOutBuf;
                            obj.dataOutBuf=obj.dataInBuf2;
                        end
                        obj.validOut=obj.endFlag;
                        obj.startOut=false;
                        obj.endOut=obj.endFlag;
                        obj.endFlag=false;

                    elseif(obj.endReg2&&obj.frameOn&&obj.validReg2)

                        obj.frameOn=false;
                        if(obj.initStart)
                            subVecD=obj.subVec;
                            endFlagD=obj.subVec;
                            toggle2=false;
                        else
                            subVecD=true;
                            endFlagD=~obj.subVec;
                            toggle2=obj.subVec;
                        end
                        if(subVecD)
                            dataOutD=obj.dataOutBuf;
                            obj.dataOutBuf=obj.dataInBuf2;
                        end
                        obj.initStart=false;
                        obj.validOut=subVecD;
                        if(subVecD)
                            obj.startOut=obj.startFlag;
                        else
                            obj.startOut=false;
                        end
                        if(subVecD&&endFlagD)
                            obj.endOut=true;
                            obj.endFlag=false;
                        else
                            obj.endOut=false;
                            obj.endFlag=toggle2;
                        end
                        obj.startFlag=false;

                    else

                        if(obj.subVec)
                            if(obj.initStart)
                                obj.initStart=false;
                                subVecD=false;
                            else
                                subVecD=true;
                            end
                        else
                            subVecD=false;
                        end
                        if(obj.endFlag||subVecD)
                            subVecD2=true;
                        else
                            subVecD2=false;
                        end
                        if(subVecD2||obj.subVec)
                            dataOutD=obj.dataOutBuf;
                            obj.dataOutBuf=obj.dataInBuf2;
                        end
                        validOutD=subVecD2&&(obj.frameOn||obj.endFlag);

                        if(validOutD&&obj.startFlag)
                            obj.startFlag=false;
                            obj.startOut=true;
                        else
                            obj.startOut=false;
                        end
                        obj.endOut=obj.endFlag;
                        obj.validOut=validOutD;
                        obj.endFlag=false;
                    end
                else

                    if(obj.startReg2&&obj.validReg2)

                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            if(obj.endFlag&&(obj.regInd3<fi(obj.EncLen,0,4,0,hdlfimath)))
                                coder.internal.warning('whdl:Puncturer:ZeroPaddedOutputData');
                            end
                        end
                        if(obj.endFlag)
                            dataOutD=assignDataOut(obj,obj.regInd3,obj.dataReg3);
                        else
                            dataOutD=obj.dataOutReset;
                        end

                        obj.frameOn=true;
                        obj.startFlag=true;

                        obj.startOut=false;
                        obj.endOut=obj.endFlag;
                        obj.validOut=obj.endFlag;

                        obj.regInd1=obj.regInd2;
                        obj.dataReg1=obj.dataReg2;

                        obj.endFlag=false;

                    elseif(obj.endReg2&&obj.frameOn&&obj.validReg2)


                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            if((obj.regInd2~=fi(0,0,4,0,hdlfimath))&&(obj.regInd2<fi(obj.EncLen,0,4,0,hdlfimath)))
                                coder.internal.warning('whdl:Puncturer:ZeroPaddedOutputData');
                            end
                        end

                        if(obj.regInd2<fi(obj.EncLen+1,0,4,0,hdlfimath))




                            dataOutD=assignDataOut(obj,obj.regInd2,obj.dataReg2);
                            obj.dataReg3=obj.dataRegReset;
                            regIndtemp=fi(obj.regInd2,0,4,0,hdlfimath);
                            obj.endFlag=false;
                            endtemp=true;
                        else




                            dataOutD=obj.dataReg2(1:obj.EncLen);
                            obj.dataReg3(1:end-obj.EncLen)=obj.dataReg2(obj.EncLen+1:end);
                            regIndtemp=fi(obj.regInd2-obj.EncLen,0,4,0,hdlfimath);
                            obj.endFlag=true;
                            endtemp=false;
                        end
                        obj.frameOn=false;
                        NonZero=(obj.regInd2~=fi(0,0,4,0,hdlfimath));
                        obj.startOut=obj.startFlag&&NonZero;
                        obj.endOut=endtemp&&NonZero;
                        obj.validOut=NonZero;
                        obj.startFlag=false;
                        obj.regInd3=fi(regIndtemp,0,4,0,hdlfimath);

                    elseif(obj.validReg2||obj.endFlag)


                        if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                            if(obj.endFlag&&(obj.regInd3<fi(obj.EncLen,0,4,0,hdlfimath)))
                                coder.internal.warning('whdl:Puncturer:ZeroPaddedOutputData');
                            end
                        end

                        if(obj.endFlag)
                            dataOutD=assignDataOut(obj,obj.regInd3,obj.dataReg3);
                            validtemp=true;

                        elseif(obj.regInd2>fi((obj.EncLen-1),0,4,0,hdlfimath))



                            dataOutD=obj.dataReg2(1:obj.EncLen);
                            obj.dataReg1(1:end-obj.EncLen)=obj.dataReg2(obj.EncLen+1:end);
                            obj.regInd1=fi(obj.regInd2-obj.EncLen,0,4,0,hdlfimath);
                            validtemp=true;
                        else



                            dataOutD=obj.dataOutReset;
                            obj.dataReg1=obj.dataReg2;
                            obj.regInd1=fi(obj.regInd2,0,4,0,hdlfimath);
                            validtemp=false;
                        end


                        if(obj.startFlag&&validtemp)
                            obj.startOut=true;
                            obj.startFlag=false;
                        else
                            obj.startOut=false;
                        end

                        obj.endOut=obj.endFlag;
                        obj.validOut=validtemp&&(obj.frameOn||obj.endFlag);

                        obj.endFlag=false;

                    else
                        obj.startOut=false;
                        obj.endOut=false;
                        obj.validOut=false;
                        dataOutD=obj.dataOutReset;
                    end
                end
            end
            obj.dataOut=dataOutD;



            if strcmpi(obj.OpMode,'Continuous')


                if strcmpi(obj.VecSource,'Property')

                    reset=((obj.syncReg1||~obj.intToggle)&&obj.validReg1);

                    prevInd=obj.vecInd;

                    if(obj.syncReg1||~obj.intToggle)
                        initPosDD=findInitPos(obj,obj.puncVector);
                    else
                        initPosDD=obj.initPos;
                    end

                    if(obj.validReg1)
                        initPosD=initPosDD;
                    else
                        initPosD=obj.initPos;
                    end

                    if(obj.validReg1)
                        if(reset)
                            vecIndD=initPosD;
                        else
                            vecIndD=updateVecInd(obj,prevInd,initPosD);
                        end
                    else
                        vecIndD=obj.vecInd;
                    end

                    if(obj.Scalar)

                        subVecD=(obj.puncVector(vecIndD)==1);
                        Null=false;
                    else

                        subVecD=(findSubVec(obj,vecIndD,obj.puncVector)==1);
                        Null=false(obj.EncLen,1);
                    end

                    obj.vecInd=vecIndD;

                    if(obj.validReg1)
                        obj.initPos=initPosD;
                        obj.subVec=subVecD;
                    else
                        obj.subVec=Null;
                    end

                    if((obj.syncReg1||~obj.intToggle)&&obj.validReg1)
                        obj.intToggle=true;
                    end

                else

                    reset=((obj.syncReg1||~obj.intToggle)&&obj.validReg1);

                    prevInd=obj.vecInd;

                    if(reset)
                        puncVecD=obj.puncVecBuf;
                    else
                        puncVecD=obj.puncVec;
                    end

                    if(obj.syncReg1||~obj.intToggle)
                        initPosDD=findInitPos(obj,puncVecD);
                    else
                        initPosDD=obj.initPos;
                    end

                    if(obj.validReg1)
                        initPosD=initPosDD;
                    else
                        initPosD=obj.initPos;
                    end

                    if(obj.validReg1)
                        if(reset)
                            vecIndD=initPosD;
                        else
                            vecIndD=updateVecInd(obj,prevInd,initPosD);
                        end
                    else
                        vecIndD=obj.vecInd;
                    end

                    if(obj.Scalar)

                        subVecD=(puncVecD(vecIndD)==1);
                        Null=false;
                    else

                        subVecD=(findSubVec(obj,vecIndD,puncVecD)==1);
                        Null=false(obj.EncLen,1);
                    end

                    obj.puncVec=puncVecD;
                    obj.vecInd=vecIndD;

                    if(obj.validReg1)
                        obj.initPos=initPosD;
                        obj.subVec=subVecD;
                    else
                        obj.subVec=Null;
                    end

                    if((obj.syncReg1||~obj.intToggle)&&obj.validReg1)
                        obj.intToggle=true;
                    end
                end
            else


                if strcmpi(obj.VecSource,'Property')

                    reset=obj.startReg1&&obj.validReg1;

                    prevInd=obj.vecInd;

                    if(obj.startReg1)
                        initPosDD=findInitPos(obj,obj.puncVector);
                    else
                        initPosDD=obj.initPos;
                    end

                    if(obj.validReg1)
                        initPosD=initPosDD;
                    else
                        initPosD=obj.initPos;
                    end

                    if(obj.validReg1)
                        if(reset)
                            vecIndD=initPosD;
                        else
                            vecIndD=updateVecInd(obj,prevInd,initPosD);
                        end
                    else
                        vecIndD=obj.vecInd;
                    end

                    if(obj.Scalar)

                        subVecD=(obj.puncVector(vecIndD)==1);
                        Null=false;
                    else

                        subVecD=(findSubVec(obj,vecIndD,obj.puncVector)==1);
                        Null=false(obj.EncLen,1);
                    end

                    obj.vecInd=vecIndD;

                    if(obj.validReg1)
                        obj.initPos=initPosD;
                        obj.subVec=subVecD;
                    else
                        obj.subVec=Null;
                    end
                else

                    reset=obj.startReg1&&obj.validReg1;

                    prevInd=obj.vecInd;

                    if(reset)
                        puncVecD=obj.puncVecBuf;
                    else
                        puncVecD=obj.puncVec;
                    end

                    if(obj.startReg1)
                        initPosDD=findInitPos(obj,puncVecD);
                    else
                        initPosDD=obj.initPos;
                    end

                    if(obj.validReg1)
                        initPosD=initPosDD;
                    else
                        initPosD=obj.initPos;
                    end

                    if(obj.validReg1)
                        if(reset)
                            vecIndD=initPosD;
                        else
                            vecIndD=updateVecInd(obj,prevInd,initPosD);
                        end
                    else
                        vecIndD=obj.vecInd;
                    end

                    if(obj.Scalar)

                        subVecD=(puncVecD(vecIndD)==1);
                        Null=false;
                    else

                        subVecD=(findSubVec(obj,vecIndD,puncVecD)==1);
                        Null=false(obj.EncLen,1);
                    end

                    obj.puncVec=puncVecD;
                    obj.vecInd=vecIndD;

                    if(obj.validReg1)
                        obj.initPos=initPosD;
                        obj.subVec=subVecD;
                    else
                        obj.subVec=Null;
                    end
                end
            end

            obj.dataInBuf2=obj.dataInBuf1;
            obj.validReg2=obj.validReg1;

            if strcmpi(obj.OpMode,'Continuous')
                obj.syncReg2=obj.syncReg1;
            else
                obj.startReg2=obj.startReg1;
                obj.endReg2=obj.endReg1;
            end

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes
                if(strcmpi(obj.VecSource,'Input port'))
                    if(reset&&(nnz(obj.puncVecBuf)==0))
                        coder.internal.warning('whdl:Puncturer:ZeroOutput');
                    end
                else
                    if(reset&&(nnz(obj.puncVector)==0))
                        coder.internal.warning('whdl:Puncturer:ZeroOutput');
                    end
                end
            end


            obj.dataInBuf1=dataIn;
            obj.validReg1=validIn;

            if strcmpi(obj.VecSource,'Input port')
                obj.puncVecBuf=vector;
            end

            if strcmpi(obj.OpMode,'Continuous')
                obj.syncReg1=syncPunc;
            else
                obj.startReg1=startIn;
                obj.endReg1=endIn;
            end
        end




        function initPos=findInitPos(obj,vector)
            toggle=true;
            initPos=fi(1,0,5,0,hdlfimath);


            if(obj.EncLen==2)
                for i=1:2:obj.vecLen
                    if((vector(i)||vector(i+1))&&toggle)
                        initPos=fi(i,0,5,0,hdlfimath);
                        toggle=false;
                    end
                end

            elseif(obj.EncLen==3)
                for i=1:3:obj.vecLen
                    if((vector(i)||vector(i+1)||vector(i+2))&&toggle)
                        initPos=fi(i,0,5,0,hdlfimath);
                        toggle=false;
                    end
                end

            elseif(obj.EncLen==4)
                for i=1:4:obj.vecLen
                    if((vector(i)||vector(i+1)||vector(i+2)||vector(i+3))&&toggle)
                        initPos=fi(i,0,5,0,hdlfimath);
                        toggle=false;
                    end
                end

            elseif(obj.EncLen==5)
                for i=1:5:obj.vecLen
                    if((vector(i)||vector(i+1)||vector(i+2)||vector(i+3)||vector(i+4))&&toggle)
                        initPos=fi(i,0,5,0,hdlfimath);
                        toggle=false;
                    end
                end

            elseif(obj.EncLen==6)
                for i=1:6:obj.vecLen
                    if((vector(i)||vector(i+1)||vector(i+2)||vector(i+3)||vector(i+4)||vector(i+5))&&toggle)
                        initPos=fi(i,0,5,0,hdlfimath);
                        toggle=false;
                    end
                end

            else
                for i=1:7:obj.vecLen
                    if((vector(i)||vector(i+1)||vector(i+2)||vector(i+3)||vector(i+4)||vector(i+5)||vector(i+6))&&toggle)
                        initPos=fi(i,0,5,0,hdlfimath);
                        toggle=false;
                    end
                end
            end
        end


        function index=updateVecInd(obj,prevIndex,initPosition)
            if(obj.Scalar)
                n=1;
            else
                n=obj.EncLen;
            end

            flag=(prevIndex==fi(obj.vecLen+1-n,0,5,0,hdlfimath));

            if(flag)
                index=initPosition;
            else
                if(obj.Scalar)
                    index=fi(prevIndex+fi(1,0,1,0,hdlfimath),0,5,0,hdlfimath);
                else
                    index=fi(prevIndex+obj.EncLen,0,5,0,hdlfimath);
                end
            end
        end


        function subVector=findSubVec(obj,vecIndex,vector)
            subVector=false(obj.EncLen,1);

            if(obj.EncLen>1)
                subVector(1)=vector(fi(vecIndex,0,5,0,hdlfimath));
                subVector(2)=vector(fi(vecIndex+1,0,5,0,hdlfimath));
            end

            if(obj.EncLen>2)
                subVector(3)=vector(fi(vecIndex+2,0,5,0,hdlfimath));
            end

            if(obj.EncLen>3)
                subVector(4)=vector(fi(vecIndex+3,0,5,0,hdlfimath));
            end

            if(obj.EncLen>4)
                subVector(5)=vector(fi(vecIndex+4,0,5,0,hdlfimath));
            end

            if(obj.EncLen>5)
                subVector(6)=vector(fi(vecIndex+5,0,5,0,hdlfimath));
            end

            if(obj.EncLen>6)
                subVector(7)=vector(fi(vecIndex+6,0,5,0,hdlfimath));
            end
        end


        function[dataReg,regIndex]=updateDataReg(obj,Index,Reg)
            index=Index;
            reg=Reg;


            if(obj.EncLen>1)
                if(obj.subVec(1))
                    reg(fi(index+1,0,4,0,hdlfimath))=obj.dataInBuf2(1);
                    index=fi(index+1,0,4,0,hdlfimath);
                end

                if(obj.subVec(2))
                    reg(fi(index+1,0,4,0,hdlfimath))=obj.dataInBuf2(2);
                    index=fi(index+1,0,4,0,hdlfimath);
                end
            end

            if(obj.EncLen>2)
                if(obj.subVec(3))
                    reg(fi(index+1,0,4,0,hdlfimath))=obj.dataInBuf2(3);
                    index=fi(index+1,0,4,0,hdlfimath);
                end
            end

            if(obj.EncLen>3)
                if(obj.subVec(4))
                    reg(fi(index+1,0,4,0,hdlfimath))=obj.dataInBuf2(4);
                    index=fi(index+1,0,4,0,hdlfimath);
                end
            end

            if(obj.EncLen>4)
                if(obj.subVec(5))
                    reg(fi(index+1,0,4,0,hdlfimath))=obj.dataInBuf2(5);
                    index=fi(index+1,0,4,0,hdlfimath);
                end
            end

            if(obj.EncLen>5)
                if(obj.subVec(6))
                    reg(fi(index+1,0,4,0,hdlfimath))=obj.dataInBuf2(6);
                    index=fi(index+1,0,4,0,hdlfimath);
                end
            end

            if(obj.EncLen>6)
                if(obj.subVec(7))
                    reg(fi(index+1,0,4,0,hdlfimath))=obj.dataInBuf2(7);
                    index=fi(index+1,0,4,0,hdlfimath);
                end
            end

            dataReg=reg;
            regIndex=index;
        end


        function dataOut=assignDataOut(obj,regIndex,dataReg)
            tempData=obj.dataOutReset;

            if(obj.EncLen>1)
                if(regIndex==fi(1,0,4,0,hdlfimath))
                    tempData(1)=dataReg(1);
                end

                if(regIndex==fi(2,0,4,0,hdlfimath))
                    tempData(1:2)=dataReg(1:2);
                end
            end

            if(obj.EncLen>2)
                if(regIndex==fi(3,0,4,0,hdlfimath))
                    tempData(1:3)=dataReg(1:3);
                end
            end

            if(obj.EncLen>3)
                if(regIndex==fi(4,0,4,0,hdlfimath))
                    tempData(1:4)=dataReg(1:4);
                end
            end

            if(obj.EncLen>4)
                if(regIndex==fi(5,0,4,0,hdlfimath))
                    tempData(1:5)=dataReg(1:5);
                end
            end

            if(obj.EncLen>5)
                if(regIndex==fi(6,0,4,0,hdlfimath))
                    tempData(1:6)=dataReg(1:6);
                end
            end

            if(obj.EncLen>6)
                if(regIndex==fi(7,0,4,0,hdlfimath))
                    tempData(1:7)=dataReg(1:7);
                end
            end

            dataOut=tempData;
        end



        function validatePropertiesImpl(obj)

            if strcmpi(obj.VecSource,'Property')

                if strcmpi(obj.EncRate,'1/2')
                    obj.EncLen=2;
                elseif strcmpi(obj.EncRate,'1/3')
                    obj.EncLen=3;
                elseif strcmpi(obj.EncRate,'1/4')
                    obj.EncLen=4;
                elseif strcmpi(obj.EncRate,'1/5')
                    obj.EncLen=5;
                elseif strcmpi(obj.EncRate,'1/6')
                    obj.EncLen=6;
                else
                    obj.EncLen=7;
                end


                validateattributes(obj.puncVector,...
                {'logical','single','double'},...
                {'column','binary'},'Puncturer','Puncture vector');

                vectorLength=length(obj.puncVector);

                coder.internal.errorIf((vectorLength==0)||(mod(vectorLength,obj.EncLen)~=0),...
                'whdl:Puncturer:InvalidPunctureVectorLength');

                if((obj.EncLen==4)||(obj.EncLen==7))
                    coder.internal.errorIf((vectorLength>28),...
                    'whdl:Puncturer:MaximumVectorLengthExceeded');
                else
                    coder.internal.errorIf((vectorLength>30),...
                    'whdl:Puncturer:MaximumVectorLengthExceeded');
                end
            end

        end

        function validateInputsImpl(obj,varargin)


            if strcmpi(obj.EncRate,'1/2')
                obj.EncLen=2;
            elseif strcmpi(obj.EncRate,'1/3')
                obj.EncLen=3;
            elseif strcmpi(obj.EncRate,'1/4')
                obj.EncLen=4;
            elseif strcmpi(obj.EncRate,'1/5')
                obj.EncLen=5;
            elseif strcmpi(obj.EncRate,'1/6')
                obj.EncLen=6;
            else
                obj.EncLen=7;
            end


            if(length(varargin{1})~=1)
                coder.internal.errorIf((length(varargin{1})~=obj.EncLen),...
                'whdl:Puncturer:InvalidInputDataSize');
            end

            validateattributes(varargin{1},{'logical','embedded.fi','double','single','numeric'},...
            {'column','real'},'Puncturer','data');


            if strcmpi(obj.OpMode,'Continuous')
                if strcmpi(obj.VecSource,'Property')
                    syncPunc=varargin{2};
                    validIn=varargin{3};
                else
                    syncPunc=varargin{3};
                    validIn=varargin{4};
                end
                validateattributes(syncPunc,{'logical'},{'scalar'},'Puncturer','syncPunc');
                validateattributes(validIn,{'logical'},{'scalar'},'Puncturer','valid');
            else
                if strcmpi(obj.VecSource,'Property')
                    ctrl=varargin{2};
                else
                    ctrl=varargin{3};
                end

                if~isstruct(ctrl)
                    coder.internal.error('whdl:Puncturer:InvalidSampleCtrlBus');
                end
                ctrlNames=fieldnames(ctrl);
                if~isequal(numel(ctrlNames),3)
                    coder.internal.error('whdl:Puncturer:InvalidSampleCtrlBus');
                end

                if isfield(ctrl,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                    validateattributes(ctrl.start,{'logical'},...
                    {'scalar'},'Puncturer','start');
                else
                    coder.internal.error('whdl:Puncturer:InvalidSampleCtrlBus');
                end

                if isfield(ctrl,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                    validateattributes(ctrl.end,{'logical'},...
                    {'scalar'},'Puncturer','end');
                else
                    coder.internal.error('whdl:Puncturer:InvalidSampleCtrlBus');
                end

                if isfield(ctrl,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                    validateattributes(ctrl.valid,{'logical'},...
                    {'scalar'},'Puncturer','valid');
                else
                    coder.internal.error('whdl:Puncturer:InvalidSampleCtrlBus');
                end
            end


            if strcmpi(obj.VecSource,'Input port')
                vectorLength=length(varargin{2});

                validateattributes(varargin{2},{'logical'},{'column'},'Puncturer','puncVector');

                coder.internal.errorIf((vectorLength==0)||(mod(vectorLength,obj.EncLen)~=0),...
                'whdl:Puncturer:InvalidPunctureVectorLength');

                if((obj.EncLen==4)||(obj.EncLen==7))
                    coder.internal.errorIf((vectorLength>28),...
                    'whdl:Puncturer:MaximumVectorLengthExceeded');
                else
                    coder.internal.errorIf((vectorLength>30),...
                    'whdl:Puncturer:MaximumVectorLengthExceeded');
                end
            end
        end

        function num=getNumInputsImpl(obj)
            if strcmpi(obj.OpMode,'Continuous')
                if strcmpi(obj.VecSource,'Input port')
                    num=4;
                else
                    num=3;
                end
            else
                if strcmpi(obj.VecSource,'Input port')
                    num=3;
                else
                    num=2;
                end
            end
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end

        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);


            if obj.isLocked


                s.vecLen=obj.vecLen;
                s.EncLen=obj.EncLen;
                s.Scalar=obj.Scalar;
                s.dataRegReset=obj.dataRegReset;
                s.dataOutReset=obj.dataOutReset;


                s.dataOut=obj.dataOut;
                s.dataOutBuf=obj.dataOutBuf;
                s.dataReg1=obj.dataReg1;
                s.dataReg2=obj.dataReg2;
                s.dataReg3=obj.dataReg3;

                s.initPos=obj.initPos;
                s.vecInd=obj.vecInd;
                s.puncVec=obj.puncVec;
                s.subVec=obj.subVec;

                s.regInd1=obj.regInd1;
                s.regInd2=obj.regInd2;
                s.regInd3=obj.regInd3;

                s.syncReg1=obj.syncReg1;
                s.syncReg2=obj.syncReg2;
                s.puncVecBuf=obj.puncVecBuf;

                s.startReg1=obj.startReg1;
                s.endReg1=obj.endReg1;
                s.validReg1=obj.validReg1;
                s.dataInBuf1=obj.dataInBuf1;

                s.startReg2=obj.startReg2;
                s.endReg2=obj.endReg2;
                s.validReg2=obj.validReg2;
                s.dataInBuf2=obj.dataInBuf2;

                s.startOut=obj.startOut;
                s.endOut=obj.endOut;
                s.validOut=obj.validOut;
                s.ctrlOut=obj.ctrlOut;

                s.initStart=obj.initStart;
                s.frameOn=obj.frameOn;
                s.startFlag=obj.startFlag;

                s.intToggle=obj.intToggle;
                s.endFlag=obj.endFlag;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)



            loadObjectImpl@matlab.System(obj,s,wasLocked);

            if wasLocked


                obj.vecLen=s.vecLen;
                obj.EncLen=s.EncLen;
                obj.Scalar=s.Scalar;
                obj.dataRegReset=s.dataRegReset;
                obj.dataOutReset=s.dataOutReset;


                obj.dataOut=s.dataOut;
                obj.dataOutBuf=s.dataOutBuf;
                obj.dataReg1=s.dataReg1;
                obj.dataReg2=s.dataReg2;
                obj.dataReg3=s.dataReg3;

                obj.initPos=s.initPos;
                obj.vecInd=s.vecInd;
                obj.puncVec=s.puncVec;
                obj.subVec=s.subVec;

                obj.regInd1=s.regInd1;
                obj.regInd2=s.regInd2;
                obj.regInd3=s.regInd3;

                obj.syncReg1=s.syncReg1;
                obj.syncReg2=s.syncReg2;
                obj.puncVecBuf=s.puncVecBuf;

                obj.startReg1=s.startReg1;
                obj.endReg1=s.endReg1;
                obj.validReg1=s.validReg1;
                obj.dataInBuf1=s.dataInBuf1;

                obj.startReg2=s.startReg2;
                obj.endReg2=s.endReg2;
                obj.validReg2=s.validReg2;
                obj.dataInBuf2=s.dataInBuf2;

                obj.startOut=s.startOut;
                obj.endOut=s.endOut;
                obj.validOut=s.validOut;
                obj.ctrlOut=s.ctrlOut;

                obj.initStart=s.initStart;
                obj.frameOn=s.frameOn;
                obj.startFlag=s.startFlag;

                obj.intToggle=s.intToggle;
                obj.endFlag=s.endFlag;
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            if strcmpi(prop,'puncVector')
                if strcmpi(obj.VecSource,'Input port')
                    flag=true;
                else
                    flag=false;
                end
            else
                flag=false;
            end
        end

        function icon=getIconImpl(~)
            icon='Puncturer';
        end

        function varargout=getInputNamesImpl(obj)
            if strcmpi(obj.OpMode,'Continuous')
                if strcmpi(obj.VecSource,'Input port')
                    varargout{1}='data';
                    varargout{2}='puncVector';
                    varargout{3}='syncPunc';
                    varargout{4}='valid';
                else
                    varargout{1}='data';
                    varargout{2}='syncPunc';
                    varargout{3}='valid';
                end
            else
                if strcmpi(obj.VecSource,'Input port')
                    varargout{1}='data';
                    varargout{2}='puncVector';
                    varargout{3}='ctrl';
                else
                    varargout{1}='data';
                    varargout{2}='ctrl';
                end
            end
        end

        function varargout=getOutputNamesImpl(obj)
            if strcmpi(obj.OpMode,'Continuous')
                varargout{1}='data';
                varargout{2}='valid';
            else
                varargout{1}='data';
                varargout{2}='ctrl';
            end
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=[1,1];
        end

        function varargout=getOutputDataTypeImpl(obj)
            if strcmpi(obj.OpMode,'Continuous')
                varargout={propagatedInputDataType(obj,1),...
                'logical'};
            else
                varargout={propagatedInputDataType(obj,1),...
                samplecontrolbustype};
            end
        end

        function varargout=isOutputComplexImpl(~)
            varargout{1}=false;
            varargout{2}=false;
        end

        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
            varargout{2}=true;
        end

    end

    methods(Access=protected,Static)
        function header=getHeaderImpl
            text1='Punctures data according to the specified puncture vector.';
            text2='A ''1'' in the puncture vector indicates valid data whereas a ''0'' indicates punctured data.';
            header=matlab.system.display.Header('commhdl.internal.Puncturer',...
            'Title','Puncturer',...
            'Text',[text1,newline,newline,text2],...
            'ShowSourceLink',false);
        end

        function group=getPropertyGroupsImpl

            group1=matlab.system.display.Section(...
            'Title','Parameters','PropertyList',{'OpMode','EncRate','VecSource','puncVector'});

            group=matlab.system.display.SectionGroup('Title','Main',...
            'Sections',group1);
        end

        function flag=showSimulateUsingImpl

            flag=false;
        end

    end
end
