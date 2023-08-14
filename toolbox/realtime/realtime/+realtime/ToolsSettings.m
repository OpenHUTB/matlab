classdef(Sealed=true)ToolsSettings<realtime.Info






    properties(SetAccess='private')
    end

    properties(Constant)
    end


    methods
        function h=ToolsSettings(filePathName,hardwareName,varargin)
            h.Data.Parameters={};
            h.Data.ParametersGroup={};
            h.deserialize(filePathName,hardwareName,varargin);
        end

        function set(h,field,value)
            h.Data.(field)=value;
        end

        function value=get(h,field)
            value=h.Data.(field);
        end
    end


    methods(Access='private')
    end
end
