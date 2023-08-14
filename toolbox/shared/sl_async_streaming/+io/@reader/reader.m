classdef reader<handle






    methods(Static)
        ret=getRegisteredWorkspaceReaders()
        ret=getRegisteredFileReaders()
        ret=getSupportedReadersForFile(fname)
    end


    properties
        FileName=''
        VariableName=''
VariableValue
    end


    methods
        registerWorkspaceReader(this);
        registerFileReader(this,ext);

        unregisterWorkspaceReader(this);
        unregisterFileReader(this,ext);
    end


    methods(Abstract)
        ret=getName(this);
        ret=getTimeValues(this);
        ret=getDataValues(this);
    end


    methods
        ret=getDescription(this);
        ret=supportsVariable(this,obj);
        ret=supportsFile(this,fname);

        ret=getSampleDimensions(this);
        ret=getChildren(this);

        ret=getSignalDescription(this);
        ret=getBlockPath(this);
        ret=getPortIndex(this);
        ret=getInterpolation(this);
        ret=getUnit(this);
        ret=isEventBasedSignal(this);
    end

end
