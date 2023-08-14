classdef DemodulatorSoftDecision<matlab.system.SFunSystem






%#ok<*EMCLS>
%#ok<*EMCA>

    properties











        Variance=1;
    end

    properties(Nontunable)




















        OutputDataType='Full precision';
    end

    properties(Hidden,Transient)
        pIntOutputDataTypeSet=comm.CommonSets.getSet('IntDataType');
        pBitOutputDataTypeSet=comm.CommonSets.getSet('BitDataType');
        OutputDataTypeSet=matlab.system.StringSet({'Full precision'});
    end
    properties(Access=protected,Hidden,Transient)
        pIntOutputDataType;
        pBitOutputDataType;
    end

    properties(Abstract,Nontunable)
        BitOutput(1,1)logical
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

    methods(Access=protected)
        function obj=DemodulatorSoftDecision(sfun)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem(sfun);
            setForceInputRealToComplex(obj,1,true);
        end

        function idx=getOutputDataTypeIndex(obj)
            idx=getIndex(obj.OutputDataTypeSet,obj.OutputDataType);
            coder.internal.errorIf(isempty(idx),'comm:system:DemodulatorBase:invalidOutputDataType',obj.OutputDataType,class(obj));
        end

        function setPortDataTypeConnections(obj)





            if(obj.BitOutput&&~strcmp(obj.DecisionMethod,'Hard decision'))...
                ||(strcmp(obj.OutputDataType,'Full precision')&&isInputFloatingPoint(obj,1))
                setPortDataTypeConnection(obj,1,1);
            end

        end
    end
end

