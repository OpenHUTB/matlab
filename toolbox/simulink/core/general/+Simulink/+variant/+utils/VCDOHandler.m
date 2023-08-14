classdef(Sealed,Hidden)VCDOHandler<handle




    properties(SetAccess=private)
        mModelName(1,:)char;

        mVCDOName(1,:)char;

        mNeedsDeletion(1,1)logical=true;
    end

    methods(Access={?Simulink.variant.reducer.Environment})
        function obj=VCDOHandler(modelName,vcdoName,vcdObj,toDelete)


            obj.mModelName=modelName;
            obj.mVCDOName=vcdoName;
            obj.mNeedsDeletion=toDelete;


            if~isempty(obj.mVCDOName)
                obj.addToWS(vcdObj);
            end
        end

        function delete(obj)
            if obj.mNeedsDeletion&&~isempty(obj.mVCDOName)

                obj.clearFromWS();
            end
        end
    end


    methods(Access=private)
        function clearFromWS(obj)
            try
                evalinConfigurationsScope(obj.mModelName,['clear(''',obj.mVCDOName,''')']);
            catch ex %#ok<NASGU>
            end
        end

        function addToWS(obj,vcdObj)
            try
                Simulink.variant.utils.slddaccess.assignInConfigurationsSection(obj.mModelName,obj.mVCDOName,vcdObj);
            catch ex %#ok<NASGU>
            end
        end
    end

end


