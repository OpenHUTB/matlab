classdef SLTCustomizer<handle

    properties(SetAccess=private)
createHarnessDefaultsObj
    end

    methods(Hidden=true)
        function obj=SLTCustomizer()
            mlock;
            obj.createHarnessDefaultsObj=Simulink.harness.HarnessCreateCustomizer();
        end


        function setHarnessCreateDefaults(obj,harnessStruct)
            obj.createHarnessDefaultsObj.setDefaults(harnessStruct);
        end
    end

end
