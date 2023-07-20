classdef ShapeInserter<matlab.system.SFunSystem























































































































%#function mvipdrawshapes

%#ok<*EMCLS>
%#ok<*EMCA>

    properties

        LineWidth=1;




        Opacity=0.6;
    end
    properties(Nontunable)



        Shape='Rectangles';






        BorderColorSource='Property';






        BorderColor='Black';










        CustomBorderColor=[200,255,100];






        FillColorSource='Property';






        FillColor='Black';










        CustomFillColor=[200,255,100];








        RoundingMethod='Floor';




        OverflowAction='Wrap';




        OpacityDataType='Custom';







        CustomOpacityDataType=numerictype([],16);




        ProductDataType='Custom';








        CustomProductDataType=numerictype([],32,14);





        AccumulatorDataType='Same as product';








        CustomAccumulatorDataType=numerictype([],32,14);





        Fill(1,1)logical=false;









        ROIInputPort(1,1)logical=false;





        Antialiasing(1,1)logical=false;
    end

    properties(Hidden,Nontunable)

        useFltptMath4IntImage=0;
    end






    properties(Constant,Hidden)
        ShapeSet=matlab.system.StringSet({...
        'Rectangles','Lines','Polygons','Circles'});
        BorderColorSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        BorderColorSet=matlab.system.StringSet({...
        'Black','White','Custom'});
        FillColorSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        FillColorSet=matlab.system.StringSet({...
        'Black','White','Custom'});
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        OpacityDataTypeSet=dsp.CommonSets.getSet('FixptModeUnscaled');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProdFirst');
    end

    methods
        function obj=ShapeInserter(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipdrawshapes');
            setEmptyAllowedStatus(obj,true);
            setProperties(obj,nargin,varargin{:});
        end

        function set.CustomOpacityDataType(obj,val)
            validateCustomDataType(obj,'CustomOpacityDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomOpacityDataType=val;
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
    end

    methods(Hidden)
        function setParameters(obj)

            ShapeIdx=getIndex(...
            obj.ShapeSet,obj.Shape);
            ROIInputPortIdx=double(obj.ROIInputPort)+1;
            if~strcmp(obj.Shape,'Lines')
                if obj.Fill
                    BorderOrFill=getIndex(...
                    obj.FillColorSet,obj.FillColor);
                    BorderOrFillSrc=getIndex(...
                    obj.FillColorSourceSet,obj.FillColorSource);
                    BorderOrFillValue=obj.CustomFillColor;
                else
                    BorderOrFill=getIndex(...
                    obj.BorderColorSet,obj.BorderColor);
                    BorderOrFillSrc=getIndex(...
                    obj.BorderColorSourceSet,obj.BorderColorSource);
                    BorderOrFillValue=obj.CustomBorderColor;
                end
            else
                BorderOrFill=getIndex(...
                obj.BorderColorSet,obj.BorderColor);
                BorderOrFillSrc=getIndex(...
                obj.BorderColorSourceSet,obj.BorderColorSource);
                BorderOrFillValue=obj.CustomBorderColor;
            end

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                3,...
                ShapeIdx,...
                double(obj.Fill),...
                double(obj.LineWidth),...
                BorderOrFillSrc,...
                BorderOrFill,...
                BorderOrFillValue,...
                BorderOrFillValue,...
                obj.Opacity,...
                ROIInputPortIdx,...
                double(obj.Antialiasing),...
                1,...
                obj.useFltptMath4IntImage,...
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
                {'Opacity','Product','Accumulator'});

                if(obj.useFltptMath4IntImage)
                    dtInfo.RoundingMethod=6;
                    dtInfo.OverflowAction=1;
                end

                obj.compSetParameters({...
                3,...
                ShapeIdx,...
                double(obj.Fill),...
                double(obj.LineWidth),...
                BorderOrFillSrc,...
                BorderOrFill,...
                BorderOrFillValue,...
                BorderOrFillValue,...
                obj.Opacity,...
                ROIInputPortIdx,...
                double(obj.Antialiasing),...
                1,...
                obj.useFltptMath4IntImage,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.OpacityDataType,...
                dtInfo.OpacityWordLength,...
                dtInfo.OpacityFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if strcmp(obj.Shape,'Lines')
                props={'FillColorSource','FillColor','CustomFillColor','Fill',...
                'Opacity','OpacityDataType','CustomOpacityDataType'};
                if strcmp(obj.BorderColorSource,'Input port')
                    props=[props,'BorderColor','CustomBorderColor'];
                else
                    if~strcmp(obj.BorderColor,'Custom')
                        props{end+1}='CustomBorderColor';
                    end
                end
                if~obj.Antialiasing
                    props=[props,{'RoundingMethod','OverflowAction',...
                    'ProductDataType','CustomProductDataType',...
                    'AccumulatorDataType','CustomAccumulatorDataType'}];
                end
            else
                if obj.Fill
                    props=[props,{'BorderColorSource','BorderColor','CustomBorderColor'}];
                    if strcmp(obj.FillColorSource,'Input port')
                        props=[props,'FillColor','CustomFillColor'];
                    else
                        if~strcmp(obj.FillColor,'Custom')
                            props{end+1}='CustomFillColor';
                        end
                    end
                else
                    props(end+1:end+4)={'Opacity','FillColorSource','FillColor','CustomFillColor'};
                    if strcmp(obj.BorderColorSource,'Input port')
                        props=[props,'BorderColor','CustomBorderColor'];
                    else
                        if~strcmp(obj.BorderColor,'Custom')
                            props{end+1}='CustomBorderColor';
                        end
                    end
                    if~obj.Antialiasing
                        props=[props,{'RoundingMethod','OverflowAction',...
                        'OpacityDataType','CustomOpacityDataType',...
                        'ProductDataType','CustomProductDataType',...
                        'AccumulatorDataType','CustomAccumulatorDataType'}];
                    end
                end
            end

            if strcmp(obj.Shape,'Rectangles')
                props{end+1}='Antialiasing';
                if~obj.Fill
                    props=[props,{'RoundingMethod','OverflowAction',...
                    'OpacityDataType','CustomOpacityDataType',...
                    'ProductDataType','CustomProductDataType',...
                    'AccumulatorDataType','CustomAccumulatorDataType'}];
                end
            end

            if~matlab.system.isSpecifiedTypeMode(obj.OpacityDataType)
                props{end+1}='CustomOpacityDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                props{end+1}='CustomProductDataType';
            end
            if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                props{end+1}='CustomAccumulatorDataType';
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('vision.ShapeInserter',...
            vision.ShapeInserter.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'Shape'...
            ,'Fill'...
            ,'LineWidth'...
            ,'BorderColorSource'...
            ,'BorderColor'...
            ,'CustomBorderColor'...
            ,'FillColorSource'...
            ,'FillColor'...
            ,'CustomFillColor'...
            ,'Opacity'...
            ,'ROIInputPort'...
            ,'Antialiasing'...
            };
        end
        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod','OverflowAction',...
            'OpacityDataType','CustomOpacityDataType',...
            'ProductDataType','CustomProductDataType',...
            'AccumulatorDataType','CustomAccumulatorDataType'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.LineWidth=3;
            tunePropsMap.Opacity=8;
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

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visiontextngfix/Draw Shapes';
        end
    end
end


