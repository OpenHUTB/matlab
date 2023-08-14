classdef DemodulatorBase<matlab.system.SFunSystem




%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Transient,Hidden)
        OutputDataTypeSet=matlab.system.StringSet({'Full precision'});
    end

    properties(Hidden,Transient)
        pIntOutputDataType;
        pBitOutputDataType;
    end

    properties(Access=protected)
        pIntOutputDataTypeSet=comm.CommonSets.getSet('IntDataType');
        pBitOutputDataTypeSet=comm.CommonSets.getSet('BitDataType');
    end

    properties(Nontunable)













        OutputDataType='Full precision'
    end

    properties(Abstract,Nontunable)
        BitOutput(1,1)logical
    end

    methods(Access=protected)
        function obj=DemodulatorBase(sfun)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem(sfun);
            setForceInputRealToComplex(obj,1,true);
        end

        function idx=getOutputDataTypeIndex(obj)
            idx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);
            coder.internal.errorIf(isempty(idx),'comm:system:DemodulatorBase:invalidOutputDataType',obj.OutputDataType,class(obj));
        end
    end

    methods

        function value=get.OutputDataTypeSet(obj)
            if obj.BitOutput
                value=obj.pBitOutputDataTypeSet;
            else
                value=obj.pIntOutputDataTypeSet;
            end
        end

        function set.OutputDataTypeSet(~,~)
        end
    end

end

