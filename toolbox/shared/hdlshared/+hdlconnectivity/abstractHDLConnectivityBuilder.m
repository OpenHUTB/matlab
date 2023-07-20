classdef abstractHDLConnectivityBuilder<hgsetget









    properties(SetAccess='protected')
        pathDelim;
    end


    methods(Abstract)

        bldrAddDriverReceiverPair(this,driver,receiver,varargin)
        bldrAddRegister(this,reg)
        bldrGetReg2RegPaths(this)
    end

    methods

        function setPathDelim(this,punct)
            this.pathDelim=punct;
        end


    end
end


