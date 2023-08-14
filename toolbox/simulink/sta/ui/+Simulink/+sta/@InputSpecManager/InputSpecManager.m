classdef InputSpecManager<handle



    properties(Access=private)
        thisInstanceSpecs;
    end



    methods(Access=protected)

        function obj=InputSpecManager()
            obj.thisInstanceSpecs=containers.Map();
        end

    end



    methods(Static)


        function theManager=getInstance()

            persistent thisInstance;


            if(isempty(thisInstance))

                thisInstance=Simulink.sta.InputSpecManager();
            end

            theManager=thisInstance;
        end
    end



    methods


        function addInputSpec(obj,appID,inputSpec)

            obj.thisInstanceSpecs(appID)=inputSpec;
        end


        function inputSpec=getInputSpec(obj,appID)

            inputSpec=[];
            if obj.thisInstanceSpecs.isKey(appID)
                inputSpec=obj.thisInstanceSpecs(appID);
            end
        end
    end

end

