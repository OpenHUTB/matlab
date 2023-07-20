classdef ConfigResult<matlab.mixin.SetGet&matlab.mixin.Heterogeneous




    properties

        SessionID=''

        Features=''


        FeatureVariantMap=[]

        FeatureData=[]

        TestPlan=[]

        VehicleScenarioData=[]

        VehicleScenarioTestPlan=[]

        SimModel=[];

        VehClass='PassengerCar';

        AppConfiguration=[];

        version=[];
        SelectedVariants=[];
    end

    methods
        function obj=ConfigResult(varargin)
            if~isempty(varargin)
                if ischar(varargin{1})

                    varargin=[{'SessionID'},varargin];
                end

                set(obj,varargin{:});
            end
        end
    end

    methods
        function reset(obj)
            obj.FeatureData=[];
            obj.FeatureVariantMap=[];
            obj.TestPlan=[];
            obj.VehicleScenarioData=[];
            obj.VehicleScenarioTestPlan=[];
            obj.AppConfiguration=[];
            obj.SelectedVariants=[];
        end

    end
end