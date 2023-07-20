classdef SBioDataInterfaceForGSAResults<SimBiology.internal.plotting.data.SBioDataInterface




    methods(Access=public)
        function obj=SBioDataInterfaceForGSAResults(sbiodata,dataSource,~,~)
            obj.dataSource=dataSource;

            obj.data=sbiodata;
        end
    end




    methods(Access=public)
        function flag=isMPGSA(obj)
            flag=isa(obj.data,'SimBiology.gsa.MPGSA');
        end

        function flag=isSobol(obj)
            flag=isa(obj.data,'SimBiology.gsa.Sobol');
        end

        function flag=isElementaryEffects(obj)
            flag=isa(obj.data,'SimBiology.gsa.ElementaryEffects');
        end

        function names=getParameterNames(obj)
            names=obj.data.ParameterSamples.Properties.VariableDescriptions();
        end

        function names=getObservableNames(obj)
            names=obj.data.Observables();
        end

        function names=getClassifierNames(obj)
            names=obj.data.Classifiers();
        end

        function flag=isEmptyGSAResults(obj)
            flag=isempty(obj.getParameterNames());
            if obj.isMPGSA()
                flag=flag||isempty(obj.getClassifierNames());
            else
                flag=flag||isempty(obj.getObservableNames());
            end
        end

        function gsaObject=getGSAObject(obj)
            gsaObject=obj.data;
        end
    end
end