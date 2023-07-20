classdef(ConstructOnLoad=true)Signal<eda.internal.diagram.Edge








    properties

        HDL=hdlcodeinit
FiType
UniqueName













    end


    properties(SetAccess=private)


    end

    methods
        function this=Signal(varargin)

            arg=this.signalArg(varargin);
            signalSet(this,arg);

        end




        function out=bit(in)
            out=in;
        end
        function out=slice(in)
            out=in;
        end
        function out=concat(in)
            out=in;
        end

        signalSet(varargin);
        arg=signalArg(varargin);
        hdl=componentBody(signal,comp)
    end

    methods(Access=private)

    end
end

