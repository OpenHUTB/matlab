classdef Elaborator<dsphdlshared.basiccomp.baseElab




    properties
        CurrentNetwork=[]
        PIROriginalComponent=[]
        AutoCopyComments=false
    end

    properties(Access=private)
componentCount
    end
    methods
        function this=Elaborator(varargin)
            for ii=1:2:numel(varargin)
                this.(varargin{ii})=varargin{ii+1};
            end
            this.componentCount=0;
        end
    end


    methods
        h=Adder(this,varargin)
        h=Subtractor(this,varargin)
        h=Multiplier(this,varargin)
        h=UnaryMinus(this,varargin)
        h=DataTypeConverter(this,varargin)
        h=Wire(this,varargin)
        h=ShiftArith(this,varargin)
        h=ShiftLogical(this,varargin)
        h=LUT(this,varargin)
        h=Mux(this,varargin)
        h=CompareToValue(this,varargin)
        h=Slicer(this,varargin)
        h=BitConcat(this,varargin)
        h=ComplexToRealImag(this,varargin)
        h=RealImagToComplex(this,varargin)
    end

    methods
        commsIntegerToBitVector(this,insig,outsig)
    end

    methods(Access=private)

        function ctx=preCompConst(this,varargin)%#ok<MANU>
            ctx=[];
        end

        function postCompConst(this,comp,ctx)%#ok<INUSD>
            if this.AutoCopyComments&&(this.componentCount==0),
                if~isempty(this.PIROriginalComponent)
                    comp.copyComment(this.PIROriginalComponent);
                else
                    error(message('dsp:hdlshared:ElaboratorError'));
                end

            end
            this.componentCount=this.componentCount+1;
        end
    end

end
