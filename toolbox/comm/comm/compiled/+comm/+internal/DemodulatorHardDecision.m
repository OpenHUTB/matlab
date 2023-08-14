classdef DemodulatorHardDecision<matlab.system.SFunSystem






%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)








        OutputDataType='Full precision';
    end

    properties(Hidden,Transient)
        pIntOutputDataType;
        pBitOutputDataType;
    end
    properties(Transient,Hidden)
        OutputDataTypeSet=matlab.system.StringSet({'Full precision'});
        pIntOutputDataTypeSet=comm.CommonSets.getSet('IntDataType');
        pBitOutputDataTypeSet=comm.CommonSets.getSet('BitDataType');
    end

    properties(Abstract,Nontunable)
        BitOutput(1,1)logical
    end

    methods
        function value=get.OutputDataTypeSet(obj)
            coder.allowpcode('plain');
            if obj.BitOutput
                value=obj.pBitOutputDataTypeSet;
            else
                value=obj.pIntOutputDataTypeSet;
            end
        end

        function set.OutputDataTypeSet(~,~)
        end
    end

    methods(Access=protected)
        function obj=DemodulatorHardDecision(sfun)
            obj@matlab.system.SFunSystem(sfun);
            setForceInputRealToComplex(obj,1,true);
        end

        function setPortDataTypeConnections(obj)
            if strcmp(obj.OutputDataType,'Full precision')&&...
                isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,1);
            end
        end

        function idx=getOutputDataTypeIndex(obj)
            idx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);
            coder.internal.errorIf(isempty(idx),'comm:system:DemodulatorBase:invalidOutputDataType',obj.OutputDataType,class(obj));
        end
    end
end
