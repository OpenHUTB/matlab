classdef UpperTriangularSolver<matlab.system.SFunSystem


















































%#function mdspfbsub2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)







        RoundingMethod='Floor';



        OverflowAction='Wrap';




        ProductDataType='Full precision';







        CustomProductDataType=numerictype([],32,30);




        AccumulatorDataType='Full precision';







        CustomAccumulatorDataType=numerictype([],32,30);



        OutputDataType='Same as first input';







        CustomOutputDataType=numerictype([],16,15);





        OverwriteDiagonal(1,1)logical=false;





        RealDiagonalElements(1,1)logical=false;
    end

    properties(Constant,Hidden)

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritFirst');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeInheritProdFirst');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
    end

    methods
        function obj=UpperTriangularSolver(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:UpperTriangularSolver_NotSupported');
            obj@matlab.system.SFunSystem('mdspfbsub2');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomOutputDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                double(obj.OverwriteDiagonal),...
                double(obj.RealDiagonalElements),...
                1,...
                [],[],...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Product','Accumulator','Output'});
                obj.compSetParameters({...
                double(obj.OverwriteDiagonal),...
                double(obj.RealDiagonalElements),...
                1,...
                [],[],...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            if obj.OverwriteDiagonal
                props={'RealDiagonalElements'};
            else
                props={};
            end
            if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                props{end+1}='CustomProductDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                props{end+1}='CustomAccumulatorDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                props{end+1}='CustomOutputDataType';
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.UpperTriangularSolver',dsp.UpperTriangularSolver.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsolvers/Backward Substitution';
        end

        function props=getDisplayPropertiesImpl()
            props={'OverwriteDiagonal',...
            'RealDiagonalElements'};
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod','OverflowAction',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType',...
            'OutputDataType','CustomOutputDataType'};
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end
    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end
end
