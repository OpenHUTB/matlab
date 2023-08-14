classdef SBioDataInterfaceForConfidenceIntervals<SimBiology.internal.plotting.data.SBioDataInterface




    methods(Access=public)
        function obj=SBioDataInterfaceForConfidenceIntervals(sbiodata,dataSource,~,~)
            obj.dataSource=dataSource;

            obj.data=sbiodata;
        end
    end




    methods(Access=public)
        function flag=isParameterConfidenceInterval(obj)
            flag=isa(obj.data,'SimBiology.fit.ParameterConfidenceInterval');
        end

        function flag=supportsProfileLikelihood(obj)
            flag=obj.isParameterConfidenceInterval()&&...
            all(strcmpi('ProfileLikelihood',{obj.data.Type}));
        end

        function confidenceIntervalObject=getConfidenceIntervalObject(obj)
            confidenceIntervalObject=obj.data;
        end
    end
end