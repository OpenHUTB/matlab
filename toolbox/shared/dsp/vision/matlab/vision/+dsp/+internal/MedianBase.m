classdef(Hidden)MedianBase<matlab.system.SFunSystem






%#function mdspmdn2

%#codegen
%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)



        SortMethod='Quick sort';






        CustomDimension=1;






        RoundingMethod='Floor';


        OverflowAction='Wrap';



        ProductDataType='Same as input';







        CustomProductDataType=numerictype([],32,30);



        AccumulatorDataType='Same as product';







        CustomAccumulatorDataType=numerictype([],32,30);



        OutputDataType='Same as accumulator';







        CustomOutputDataType=numerictype([],16,15);
    end

    properties(Abstract,Nontunable)
        Dimension;
    end

    properties(Constant,Hidden)
        SortMethodSet=matlab.system.StringSet({...
        'Quick sort',...
        'Insertion sort'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasic');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumProd');
    end

    methods

        function obj=MedianBase(varargin)
            obj@matlab.system.SFunSystem('mdspmdn2');
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
            SortMethodIdx=getIndex(...
            obj.SortMethodSet,obj.SortMethod);
            DimensionIdx=getIndex(...
            obj.DimensionSet,obj.Dimension);

            dtInfo=getFixptDataTypeInfo(obj,{...
            'Product','Accumulator','Output'});

            obj.compSetParameters({...
            SortMethodIdx,...
            DimensionIdx,...
            obj.CustomDimension,...
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

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~strcmp(obj.Dimension,'Custom')
                props{end+1}='CustomDimension';
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

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'SortMethod'...
            ,'Dimension'...
            ,'CustomDimension'...
            };
        end
        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'OutputDataType','CustomOutputDataType'...
            };
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

