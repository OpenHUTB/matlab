function varargout=queryInstanceId(this,varargin)




    storedVal=this.instanceIdImpl;

    if doDebug&&isempty(storedVal)

        storedVal=getNewInstanceId;
        this.instanceIdImpl=storedVal;

    end

    varargout={storedVal};

