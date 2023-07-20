classdef(Sealed)DynamicStringSet<matlab.system.StringSet




    methods
        function obj=DynamicStringSet(varargin)
            obj@matlab.system.StringSet(varargin{:});
        end

        function changeValues(obj,newValues,sysObj,prop,newPropValue)
            oldVals=getAllowedValues(obj);
            try
                verifyNotDefaultStringSet(obj,sysObj,prop);
                setValues(obj,newValues);
                sysObj.(prop)=newPropValue;
            catch me
                setValues(obj,oldVals);
                rethrow(me);
            end
        end
    end

    methods(Hidden)
        function flag=isValidPerInstanceReplacement(obj,other)




            flag=false;
            if isequal(obj,other)&&(obj~=other)
                flag=true;
            end
        end
    end

    methods(Access=private)
        function verifyNotDefaultStringSet(obj,sysObj,targetPropName)
            propSetName=[targetPropName,'Set'];
            metaProp=findprop(sysObj,propSetName);
            if isempty(metaProp)||(metaProp.DefaultValue==obj)
                matlab.system.internal.error('MATLAB:system:DynamicStringSet:NotInstanceSpecific');
            end
        end
    end
end
