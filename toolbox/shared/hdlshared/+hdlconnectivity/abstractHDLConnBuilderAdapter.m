classdef abstractHDLConnBuilderAdapter<hgsetget&hdlconnectivity.HDLConnTree


















    properties
currentHDLPath
builder

    end

    methods(Abstract=true)
        addDriverReceiverPair(varargin);
        addRegister(varargin);
        addDriverReceiverRegistered(varargin);
    end






    methods
        function setCurrentHDLPath(this,path)
            this.currentHDLPath=path;
        end

        function path=getCurrentHDLPath(this)
            path=this.currentHDLPath;
        end


    end

end


