classdef Framework<handle





    methods(Static=true)
        function varargout=framework(varargin)
            mlock;
            persistent val;


            if isempty(varargin)
                varargout{1}=val;
            else
                val=varargin{1};
            end
        end

        function val=getFramework()
            val=Simulink.sdi.internal.Framework.framework;

            if isempty(val)
                val=Simulink.sdi.internal.MLFramework;
                Simulink.sdi.internal.Framework.framework(val);
            end
        end
    end
end
