classdef MatDataCache<handle



    properties(Access=private,Constant)
        VariableMap=containers.Map();
    end


    methods(Access=private)

        function obj=MatDataCache()
        end

    end


    methods(Access=public,Static)

        function remove(slxFilePath)
            oldState=warning('off','MATLAB:Containers:Map:NoKeyToRemove');
            warningCleanup=onCleanup(@()warning(oldState));
            import slxmlcomp.internal.matdata.MatDataCache;
            MatDataCache.removeFromCache(slxFilePath);
        end

        function matData=get(slxFilePath,variablePath)
            import slxmlcomp.internal.matdata.MatDataCache;
            key=[slxFilePath,'_',variablePath];
            if~MatDataCache.VariableMap.isKey(key)
                MatDataCache.addVariable(slxFilePath,variablePath,key);
            end
            matData=MatDataCache.VariableMap(key);
        end

        function keys=getKeys()
            import slxmlcomp.internal.matdata.MatDataCache
            keys=MatDataCache.VariableMap.keys();
        end

    end


    methods(Access=private,Static)

        function addVariable(slxFilePath,variablePath,key)
            fileDataReader=Simulink.loadsave.SLXPackageReader(char(slxFilePath));
            matData=fileDataReader.readPartToVariable(['/',variablePath,'.mxarray']);
            variableMap=slxmlcomp.internal.matdata.MatDataCache.VariableMap;
            variableMap(key)=matData;%#ok<NASGU>
        end

        function removeFromCache(slxFilePath)
            import slxmlcomp.internal.matdata.MatDataCache;
            variableKeys=MatDataCache.VariableMap.keys;
            keysToRemove=variableKeys(strncmp(slxFilePath,variableKeys,numel(slxFilePath)));
            MatDataCache.VariableMap.remove(keysToRemove);
        end

    end

end

