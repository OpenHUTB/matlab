classdef BlobAnalysis<matlab.system.SFunSystem









































































































































%#function mvipblob

%#ok<*EMCLS>
%#ok<*EMCA>

    properties



        MinimumBlobArea=0;



        MaximumBlobArea=double(intmax('uint32'));
    end

    properties(Nontunable)






        OutputDataType='double';


        Connectivity=8;



        MaximumCount=50;








        RoundingMethod='Floor';




        OverflowAction='Wrap';




        ProductDataType='Custom';








        CustomProductDataType=numerictype([],32,16);



        AccumulatorDataType='Custom';







        CustomAccumulatorDataType=numerictype([],32,0);





        CentroidDataType='Custom';








        CustomCentroidDataType=numerictype([],32,16);







        EquivalentDiameterSquaredDataType='Same as product';










        CustomEquivalentDiameterSquaredDataType=numerictype([],32,16);





        ExtentDataType='Custom';








        CustomExtentDataType=numerictype([],16,14);





        PerimeterDataType='Custom';








        CustomPerimeterDataType=numerictype([],32,16);




        AreaOutputPort(1,1)logical=true;



        CentroidOutputPort(1,1)logical=true;



        BoundingBoxOutputPort(1,1)logical=true;







        MajorAxisLengthOutputPort(1,1)logical=false;







        MinorAxisLengthOutputPort(1,1)logical=false;






        OrientationOutputPort(1,1)logical=false;







        EccentricityOutputPort(1,1)logical=false;






        EquivalentDiameterSquaredOutputPort(1,1)logical=false;





        ExtentOutputPort(1,1)logical=false;





        PerimeterOutputPort(1,1)logical=false;



        LabelMatrixOutputPort(1,1)logical=false;




        ExcludeBorderBlobs(1,1)logical=false;
    end

    properties(Hidden,Dependent,Nontunable)




        MinimumBlobAreaSource='Property';




        MaximumBlobAreaSource='Property';
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=matlab.system.StringSet(...
        {'double','single','Fixed point'});

        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeScaledOnly');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeScaledOnly');
        CentroidDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumNoInput');
        EquivalentDiameterSquaredDataTypeSet=...
        dsp.CommonSets.getSet('FixptModeAccumProdNoInput');
        ExtentDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumNoInput');
        PerimeterDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumNoInput');
        MinimumBlobAreaSourceSet=matlab.system.StringSet(...
        {'Auto','Property'});
        MaximumBlobAreaSourceSet=matlab.system.StringSet(...
        {'Auto','Property'});
    end

    methods

        function obj=BlobAnalysis(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipblob');
            setProperties(obj,nargin,varargin{:});
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomCentroidDataType(obj,val)
            validateCustomDataType(obj,'CustomCentroidDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomCentroidDataType=val;
        end

        function set.CustomEquivalentDiameterSquaredDataType(obj,val)
            validateCustomDataType(obj,'CustomEquivalentDiameterSquaredDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomEquivalentDiameterSquaredDataType=val;
        end

        function set.CustomExtentDataType(obj,val)
            validateCustomDataType(obj,'CustomExtentDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomExtentDataType=val;
        end

        function set.CustomPerimeterDataType(obj,val)
            validateCustomDataType(obj,'CustomPerimeterDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomPerimeterDataType=val;
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
        end

        function set.Connectivity(obj,val)
            coder.internal.errorIf(val~=4&&val~=8,...
            'vision:labeling:invalidConnectivity');
            obj.Connectivity=val;
        end

        function set.MinimumBlobAreaSource(obj,val)
            if~strcmp(val,'Property')
                obj.MinimumBlobArea=0;
            end
        end

        function val=get.MinimumBlobAreaSource(obj)%#ok<MANU>
            val='Property';
        end

        function set.MaximumBlobAreaSource(obj,val)
            if~strcmp(val,'Property')
                obj.MaximumBlobArea=intmax('uint32');
            end
        end

        function val=get.MaximumBlobAreaSource(obj)%#ok<MANU>
            val='Property';
        end
    end

    methods(Hidden)
        function setParameters(obj)
            StatsOutputDType=getIndex(...
            obj.OutputDataTypeSet,obj.OutputDataType);
            ConnectivityIdx=(obj.Connectivity==4)+1;

            stats=false(1,9);
            stats(1:3)=[obj.AreaOutputPort,obj.CentroidOutputPort,obj.BoundingBoxOutputPort];


            if StatsOutputDType~=3
                stats(4:7)=[obj.MajorAxisLengthOutputPort,obj.MinorAxisLengthOutputPort...
                ,obj.OrientationOutputPort,obj.EccentricityOutputPort];
            end
            stats(8:10)=[obj.EquivalentDiameterSquaredOutputPort,obj.ExtentOutputPort...
            ,obj.PerimeterOutputPort];

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                stats,...
                obj.MaximumCount,...
                0,...
                0,...
                StatsOutputDType,...
                0,...
                -1,...
                ConnectivityIdx,...
                double(obj.LabelMatrixOutputPort),...
                1,...
                obj.MinimumBlobArea,...
                1,...
                obj.MaximumBlobArea,...
                double(obj.ExcludeBorderBlobs),...
                1,...
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
                {'Product','Accumulator','Centroid','EquivalentDiameterSquared',...
                'Extent','Perimeter'});
                obj.compSetParameters({...
                stats,...
                obj.MaximumCount,...
                0,...
                0,...
                StatsOutputDType,...
                0,...
                -1,...
                ConnectivityIdx,...
                double(obj.LabelMatrixOutputPort),...
                1,...
                obj.MinimumBlobArea,...
                1,...
                obj.MaximumBlobArea,...
                double(obj.ExcludeBorderBlobs),...
                1,...
                dtInfo.ExtentDataType,...
                dtInfo.ExtentWordLength,...
                dtInfo.ExtentFracLength,...
                dtInfo.PerimeterDataType,...
                dtInfo.PerimeterWordLength,...
                dtInfo.PerimeterFracLength,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.EquivalentDiameterSquaredDataType,...
                dtInfo.EquivalentDiameterSquaredWordLength,...
                dtInfo.EquivalentDiameterSquaredFracLength,...
                dtInfo.CentroidDataType,...
                dtInfo.CentroidWordLength,...
                dtInfo.CentroidFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~strcmp(obj.OutputDataType,'Fixed point')
                props=[props,vision.BlobAnalysis.getDisplayFixedPointPropertiesImpl()];
                flag=ismember(prop,props);
                return;
            end
            props=[props,{'MajorAxisLengthOutputPort',...
            'MinorAxisLengthOutputPort',...
            'OrientationOutputPort',...
            'EccentricityOutputPort'}];
            if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                props{end+1}='CustomAccumulatorDataType';
            end
            if obj.CentroidOutputPort
                if~matlab.system.isSpecifiedTypeMode(obj.CentroidDataType)
                    props{end+1}='CustomCentroidDataType';
                end
            else
                props=[props,{'CentroidDataType','CustomCentroidDataType'}];
            end
            if obj.EquivalentDiameterSquaredOutputPort
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    props{end+1}='CustomProductDataType';
                end
                if~matlab.system.isSpecifiedTypeMode(obj.EquivalentDiameterSquaredDataType)
                    props{end+1}='CustomEquivalentDiameterSquaredDataType';
                end
            else
                props=[props,{'EquivalentDiameterSquaredDataType',...
                'CustomEquivalentDiameterSquaredDataType',...
                'ProductDataType','CustomProductDataType'}];
            end
            if obj.ExtentOutputPort
                if~matlab.system.isSpecifiedTypeMode(obj.ExtentDataType)
                    props{end+1}='CustomExtentDataType';
                end
            else
                props=[props,{'ExtentDataType','CustomExtentDataType'}];
            end
            if obj.PerimeterOutputPort
                if~matlab.system.isSpecifiedTypeMode(obj.PerimeterDataType)
                    props{end+1}='CustomPerimeterDataType';
                end
            else
                props=[props,{'PerimeterDataType','CustomPerimeterDataType'}];
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static)
        function helpFixedPoint





            matlab.system.dispFixptHelp('vision.BlobAnalysis',vision.BlobAnalysis.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'AreaOutputPort'...
            ,'CentroidOutputPort'...
            ,'BoundingBoxOutputPort'...
            ,'MajorAxisLengthOutputPort'...
            ,'MinorAxisLengthOutputPort'...
            ,'OrientationOutputPort'...
            ,'EccentricityOutputPort'...
            ,'EquivalentDiameterSquaredOutputPort'...
            ,'ExtentOutputPort'...
            ,'PerimeterOutputPort'...
            ,'OutputDataType'...
            ,'Connectivity'...
            ,'LabelMatrixOutputPort'...
            ,'MaximumCount'...
            ,'MinimumBlobArea'...
            ,'MaximumBlobArea'...
            ,'ExcludeBorderBlobs'...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'RoundingMethod','OverflowAction'...
            ,'ProductDataType','CustomProductDataType'...
            ,'AccumulatorDataType','CustomAccumulatorDataType'...
            ,'CentroidDataType','CustomCentroidDataType'...
            ,'EquivalentDiameterSquaredDataType','CustomEquivalentDiameterSquaredDataType'...
            ,'ExtentDataType','CustomExtentDataType'...
            ,'PerimeterDataType','CustomPerimeterDataType'...
            };
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.MinimumBlobArea=10;
            tunePropsMap.MaximumBlobArea=12;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/Blob Analysis';
        end
    end
end


