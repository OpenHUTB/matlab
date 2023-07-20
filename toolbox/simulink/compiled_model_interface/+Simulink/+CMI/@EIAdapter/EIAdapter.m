


classdef EIAdapter<handle&Simulink.CMI.CompiledSession
    properties(SetAccess=private)
oldFeatureValue
oldSessionInit
    end
    methods
        function ei=EIAdapter(new_feature_value)
            ei@Simulink.CMI.CompiledSession;
            ei.oldFeatureValue=slfeature('engineinterface');
            ei.oldSessionInit=getLicenseValue(ei);
            setLicenseValue(ei,new_feature_value);
            slfeature('engineinterface',new_feature_value);
        end
        function delete(obj)
            pName='oldFeatureValue';
            setLicenseValue(obj,obj.(pName));
            slfeature('engineinterface',obj.(pName));
            pName2='oldSessionInit';
            setLicenseValue(obj,obj.(pName2));
        end
    end
end
