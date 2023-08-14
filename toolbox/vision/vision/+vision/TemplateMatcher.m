classdef TemplateMatcher<matlab.system.SFunSystem





































































































%#function mviptemplatematching

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)




        Metric='Sum of absolute differences';



        OutputValue='Best match location';










        SearchMethod='Exhaustive';






        NeighborhoodSize=3;






        RoundingMethod='Floor';


        OverflowAction='Wrap';




        ProductDataType='Custom';








        CustomProductDataType=numerictype([],32,0);



        AccumulatorDataType='Custom';







        CustomAccumulatorDataType=numerictype([],32,0);






        OutputDataType='Same as first input';







        CustomOutputDataType=numerictype([],32,0);









        BestMatchNeighborhoodOutputPort(1,1)logical=false;






        ROIInputPort(1,1)logical=false;






        ROIValidityOutputPort(1,1)logical=false;

    end

    properties(Constant,Hidden)
        MetricSet=matlab.system.StringSet({...
        'Sum of absolute differences',...
        'Sum of squared differences',...
        'Maximum absolute difference'});
        OutputValueSet=matlab.system.StringSet({...
        'Metric matrix',...
        'Best match location'});
        SearchMethodSet=matlab.system.StringSet({...
        'Exhaustive',...
        'Three-step'});


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
    end

    methods
        function obj=TemplateMatcher(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mviptemplatematching');
            setProperties(obj,nargin,varargin{:});
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

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            matchMetric=getIndex(obj.MetricSet,obj.Metric);
            enableROI=double(obj.ROIInputPort);
            returnROIFlag=double(obj.ROIValidityOutputPort);
            outputValue=getIndex(obj.OutputValueSet,obj.OutputValue);
            nMetric=double(obj.BestMatchNeighborhoodOutputPort);
            searchAlgo=getIndex(obj.SearchMethodSet,obj.SearchMethod);

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                matchMetric,...
                outputValue,...
                searchAlgo,...
                nMetric,...
                obj.NeighborhoodSize,...
                enableROI,...
                returnROIFlag,...
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
                matchMetric,...
                outputValue,...
                searchAlgo,...
                nMetric,...
                obj.NeighborhoodSize,...
                enableROI,...
                returnROIFlag,...
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
            props={};
            if~obj.ROIInputPort
                props{end+1}='ROIValidityOutputPort';
            end
            if strcmp(obj.OutputValue,'Metric matrix')
                props=[props,{'BestMatchNeighborhoodOutputPort',...
                'NeighborhoodSize','SearchMethod','ROIInputPort','ROIValidityOutputPort'}];
            end
            if~obj.BestMatchNeighborhoodOutputPort
                props{end+1}='NeighborhoodSize';
            end
            if~strcmp(obj.Metric,'Sum of squared differences')
                props=[props,{'ProductDataType','CustomProductDataType'}];
            end
            if~obj.BestMatchNeighborhoodOutputPort&&...
                strcmp(obj.OutputValue,'Best match location')
                props=[props,{'OutputDataType','CustomOutputDataType'}];
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

        function setPortDataTypeConnections(obj)
            if strcmp(obj.OutputValue,'Metric matrix')


                setPortDataTypeConnection(obj,1,1);
            else



                if obj.BestMatchNeighborhoodOutputPort
                    setPortDataTypeConnection(obj,1,2);
                end
            end
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.TemplateMatcher',...
            vision.TemplateMatcher.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)

        function props=getDisplayPropertiesImpl()
            props={...
            'Metric',...
            'OutputValue',...
            'SearchMethod',...
            'BestMatchNeighborhoodOutputPort',...
            'NeighborhoodSize',...
            'ROIInputPort',...
            'ROIValidityOutputPort',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod',...
            'OverflowAction',...
            'ProductDataType',...
            'CustomProductDataType',...
            'AccumulatorDataType',...
            'CustomAccumulatorDataType',...
            'OutputDataType',...
'CustomOutputDataType'...
            };
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end

    end


    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionanalysis/Template Matching';
        end
    end
end
