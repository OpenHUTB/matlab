classdef(Abstract)AbstractSimMem<handle


    properties(Abstract)
SystemObject
Model
Id
DataSize
    end


    methods(Abstract)
        [r,nextAddr]=bdRead(obj,addr,num)
        nextAddr=bdWrite(obj,addr,data)
        [r,nextAddr]=read(obj,addr,num)
    end


    methods

        function validateSelf(obj)
            if~obj.isValid
                error("SimMem is no longer valid.");
            end
        end

        function v=isValid(obj)
            v=true;
            if~bdIsLoaded(obj.Model)
                v=false;
            end
            if v
                try
                    workSpace=get_param(obj.Model,'ModelWorkspace');
                    init=evalin(workSpace,'modelInit');
                catch
                    v=false;
                end
            end
            if v
                v=isvalid(obj.SystemObject);
            end
        end

        function objNew=replace(obj)
            import dnnfpga.interact.*
            objNew=SimMemStore.getMem(obj.Model,obj.Id);
        end

        function validateBDAddr(obj,address)
            bytesPerOne=uint32(double(obj.DataSize)/double(8));
            r=mod(address,bytesPerOne);
            if r~=0
                error("Address/Offset values must be an even multiple of %u bytes.\n",bytesPerOne);
            end
        end
    end
end
