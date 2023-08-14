


classdef PortInfoT
    properties
        name='';
        elemBitwidth=uint32(0);
        validPhase=int32(0);
        dimensions=uint32([]);
        numElems=uint32(0);
        sampleTime=eda.internal.filhost.STimeSpecT;
        dtypeSpec=eda.internal.filhost.DTypeSpecT;
        complexity=eda.internal.filhost.PortComplexityT.ComplexNo;
        frameness=eda.internal.filhost.PortFramenessT.FramedInherited;
        directFeedthrough=eda.internal.filhost.PortDirectFeedthroughT.FeedthroughYes;
    end

    methods
        function this=PortInfoT(varargin)
            this=eda.internal.mcosutils.ObjUtilsT.Ctor(this,varargin{:});
        end

        function val=isNullObj(this)


            if(this.elemBitwidth==0)
                val=logical(true);
            else
                val=logical(false);
            end
        end

        function this=set.elemBitwidth(this,val)
            this.elemBitwidth=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'uint32',[1,intmax('uint32')],'elemBitwidth');
        end
        function val=getElemBitwidth(this)
            val=this.elemBitwidth;
        end
        function this=set.numElems(this,val)
            this.numElems=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'uint32',[1,intmax('uint32')],'numElems');
        end
        function this=set.validPhase(this,val)
            this.validPhase=eda.internal.mcosutils.ObjUtilsT.CheckNumeric(val,'int32',[-1,intmax('int32')],'validPhase');
        end
        function this=set.dimensions(this,val)
            this.dimensions=uint32(val);
        end
        function this=set.sampleTime(this,val)

            classVal=eda.internal.filhost.STimeSpecT(val);
            this.sampleTime=classVal;
        end
        function this=set.dtypeSpec(this,val)
            classVal=eda.internal.filhost.DTypeSpecT(val);
            if(classVal.getBitwidth~=-1&&...
                classVal.getBitwidth~=this.getElemBitwidth&&...
                ~classVal.isEvalInBaseCtor())
                ME=MException('FIL:PortInfoT:BadBitwidthInDtypeSpec',...
                ['Attempted to assign a port data type with a bit width of %d ',...
                'but the FPGA DUT bit width is %d.'],...
                classVal.getBitwidth,this.getElemBitwidth);
                throw(ME);
            end
            this.dtypeSpec=classVal;
        end
        function this=set.complexity(this,val)
            this.complexity=eda.internal.filhost.PortComplexityT(val);
        end
        function this=set.frameness(this,val)
            this.frameness=eda.internal.filhost.PortFramenessT(val);
        end
        function this=set.directFeedthrough(this,val)
            this.directFeedthrough=eda.internal.filhost.PortDirectFeedthroughT(val);
        end

        function outS=getStruct(this,simstatus)
            outS=struct(this);
            outS.sampleTime=this.sampleTime.getStruct(simstatus);
            outS.dtypeSpec=this.dtypeSpec.getStruct(simstatus);
            outS.complexity=int32(this.complexity);
            outS.frameness=int32(this.frameness);
            outS.directFeedthrough=int32(this.directFeedthrough);
        end
    end
end
