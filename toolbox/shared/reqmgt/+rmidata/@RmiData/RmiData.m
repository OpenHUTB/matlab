classdef RmiData<handle

    properties
repository
statusMap
    end


    methods(Access='protected')

        function obj=RmiData
            obj.repository=rmimap.RMIRepository.getInstance;
        end
    end


    methods(Abstract)
        close(this,srcRoot)
        discard(this,rootObj)
        result=hasData(this,rootObj)
        result=hasChanges(this,rootObj)
        out=get(this,srcObj,varargin)
        varargout=load(this,rootObj,reqFile)
        loadFromFile(this,rootObj)
        saveStorage(this,rootObj,varargin)
        set(this,srcObj,newData,varargin)
        writeToStorage(this,rootObj,storageName)
    end


    methods(Static,Abstract)
        singleObj=getInstance(varargin)
        result=isInitialized()
        reset()
    end

end

