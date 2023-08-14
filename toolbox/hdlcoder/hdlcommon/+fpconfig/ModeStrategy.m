


classdef ModeStrategy<fpconfig.DeepCopiable
    methods(Abstract=true)
        modeSettings=createModeSettings(~,varargin)

        obj=constructFromFields(this,varargin)
        obj=constructFromVisualStruct(this,lEntry)
        obj=constructFromVisualStructInString(this,lEntry)
        obj=constructFromInternalStruct(this,lEntry)
        obj=constructDefault(this)
        [key,validNewKey,value]=fromVisualPV(this,varargin)
        baseKey=getBaseKey(this,key)
    end

end




