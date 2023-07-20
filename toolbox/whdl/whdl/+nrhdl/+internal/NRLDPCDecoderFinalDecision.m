classdef(StrictDefaults)NRLDPCDecoderFinalDecision<matlab.System




%#codegen

    properties(Nontunable)
        memDepth=384;
        vectorSize=64;
    end


    properties(Access=private)
        decBits;
        ctrl;
        countMax;
        count;
        decision;
        dataOut;
        finShift;
        iterDone;
        zCount;
        zCount2;
        cntEnb;
        endD;
    end

    methods


        function obj=NRLDPCDecoderFinalDecision(varargin)
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

            obj.decBits(:)=zeros(obj.memDepth,1);
            obj.ctrl=struct('start',false,'end',false,'valid',false);
            obj.finShift=fi(0,0,9,0);
        end

        function setupImpl(obj,varargin)
            obj.decBits=zeros(obj.memDepth,1)>0;
            obj.ctrl=struct('start',false,'end',false,'valid',false);
            obj.countMax=fi(21,0,5,0,hdlfimath);
            obj.count=fi(0,0,5,0,hdlfimath);
            obj.decision=false;
            obj.dataOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
            obj.finShift=fi(0,0,9,0);
            obj.iterDone=false;
            obj.zCount=fi(1,0,9,0);
            obj.zCount2=fi(1,0,9,0);
            obj.cntEnb=false;
            obj.endD=false;
        end

        function varargout=outputImpl(obj,varargin)
            varargout{1}=obj.decBits;
            varargout{2}=obj.ctrl;
            varargout{3}=obj.finShift;
        end

        function updateImpl(obj,varargin)

            data=varargin{1};
            iter_done=obj.iterDone;
            obj.iterDone=varargin{2};
            liftsize=varargin{3};
            bgn=varargin{4};
            finalV=varargin{5};
            reset=varargin{6};

            if reset
                obj.decBits(:)=zeros(obj.memDepth,1);
                obj.ctrl=struct('start',false,'end',false,'valid',false);
                obj.countMax=fi(21,0,5,0,hdlfimath);
                obj.count=fi(0,0,5,0,hdlfimath);
                obj.decision=false;
                obj.dataOut=cast(zeros(obj.memDepth,1),'like',varargin{1});
                obj.finShift=fi(0,0,9,0);
                obj.iterDone=false;
                obj.zCount=fi(1,0,9,0);
                obj.zCount2=fi(1,0,9,0);
                obj.cntEnb=false;
                obj.endD=false;
            end

            if bgn
                obj.countMax(:)=9;
            else
                obj.countMax(:)=21;
            end

            starti=~iter_done&&obj.iterDone;

            if starti
                obj.decision(:)=true;
                obj.zCount=fi(1,0,9,0);
                obj.zCount2=fi(1,0,9,0);
            end

            if obj.vectorSize==64
                if liftsize<=fi(64,0,9,0)
                    zcount=1;
                elseif liftsize<=fi(128,0,9,0)
                    zcount=2;
                elseif liftsize<=fi(192,0,9,0)
                    zcount=3;
                elseif liftsize<=fi(256,0,9,0)
                    zcount=4;
                elseif liftsize<=fi(320,0,9,0)
                    zcount=5;
                else
                    zcount=6;
                end

                if obj.decision
                    if obj.zCount==cast(zcount,'like',obj.zCount)
                        obj.zCount(:)=1;
                        obj.cntEnb=true;
                    else
                        obj.cntEnb=false;
                        obj.zCount(:)=obj.zCount+1;
                    end
                end

                if(obj.decision)
                    if obj.count==obj.countMax
                        obj.endD=true;
                        obj.decision(:)=false;
                    else
                        if obj.cntEnb
                            obj.count(:)=obj.count+1;
                        end
                    end
                    validi=true;
                else
                    validi=false;
                end
            else
                zcount=liftsize;

                if(obj.decision)
                    if obj.count==obj.countMax
                    else
                        if obj.cntEnb
                            obj.count(:)=obj.count+1;
                        end
                    end
                end

                if obj.decision
                    if obj.zCount==cast(zcount,'like',obj.zCount)
                        obj.zCount(:)=1;
                        obj.cntEnb=true;
                    else
                        obj.cntEnb=false;
                        obj.zCount(:)=obj.zCount+1;
                    end
                end

                if(obj.decision)
                    if obj.count==obj.countMax
                        obj.endD=true;
                        obj.decision(:)=false;
                    end
                    validi=true;
                else
                    validi=false;
                end

            end

            finaldecision(obj,data,liftsize,finalV);

            bits=obj.dataOut<=0;

            obj.decBits(:)=bits;
            obj.ctrl.start(:)=starti;
            if obj.endD
                if obj.zCount2==cast(zcount,'like',obj.zCount)
                    obj.zCount2(:)=1;
                    obj.ctrl.end(:)=true;
                    obj.endD(:)=false;
                else
                    obj.ctrl.end(:)=false;
                    obj.zCount2(:)=obj.zCount2+1;
                end
            else
                obj.ctrl.end(:)=false;
            end
            obj.ctrl.valid(:)=validi||obj.endD||obj.ctrl.end;

            if obj.ctrl.end
                obj.count(:)=0;
            end

        end

        function finaldecision(obj,data,Z,finalV)

            obj.finShift=mod(finalV(obj.count+1),Z);
            obj.dataOut(1:Z)=data(1:Z);
        end

        function num=getNumInputsImpl(~)
            num=6;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.decBits=obj.decBits;
                s.ctrl=obj.ctrl;
                s.countMax=obj.countMax;
                s.count=obj.count;
                s.decision=obj.decision;
                s.dataOut=obj.dataOut;
                s.finShift=obj.finShift;
                s.iterDone=obj.iterDone;
                s.zCount=obj.zCount;
                s.zCount2=obj.zCount2;
                s.cntEnb=obj.cntEnb;
                s.endD=obj.endD;
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
