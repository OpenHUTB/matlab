classdef AXIM<soc.xilcomp.XilinxComponentBase
    properties
    end

    methods
        function obj=AXIM(varargin)


            obj.Configuration={...
            'type','reader',...
            'mem_addr','0x00000000',...
            'mem_range','0',...
            'mm_dw','32',...
            'mem_type','memPL',...
            };

            if nargin>0
                obj.Configuration=varargin;
            end

            obj.Instance=[];
        end
    end
end
