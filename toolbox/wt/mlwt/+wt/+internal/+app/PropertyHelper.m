classdef PropertyHelper<handle

    properties
sysObj
    end


    methods
        function obj=PropertyHelper(sysObj)
            obj.sysObj=sysObj;
        end


        function applyAllProperties(obj)

            try
                if~isLocked(obj.sysObj)
                    step(obj.sysObj);
                end
            catch ME
                throwAsCaller(ME);
            end
        end


        function setNontunable(obj,propertyName,value,canRelease,message)

            try
                if isLocked(obj.sysObj)
                    if canRelease


                        if isequal(get(obj.sysObj,propertyName),value)
                            return
                        end
                        release(obj.sysObj);
                        set(obj.sysObj,propertyName,value);
                    else
                        error(message);
                    end
                else
                    set(obj.sysObj,propertyName,value);
                end
            catch ME
                throwAsCaller(ME);
            end
        end


        function applyTunable(obj,propertyName,value)

            try
                set(obj.sysObj,propertyName,value);
                if isLocked(obj.sysObj)
                    step(obj.sysObj);
                end
            catch ME
                throwAsCaller(ME);
            end
        end


        function applyVectorTunable(obj,propertyName,value,expectedLength,canRelease,message)
            if~isscalar(value)&&length(value)~=expectedLength
                obj.setNontunable(propertyName,value,canRelease,message);
            else
                obj.applyTunable(propertyName,value);
            end
        end
    end
end

