




classdef VarURL<Simulink.URL.Base
    methods
        function h=VarURL(varargin)
            narginchk(1,2);
            if nargin==1
                parent='_base';
                name=varargin{1};
            else
                parent=varargin{1};
                name=varargin{2};
            end
            h=h@Simulink.URL.Base(parent,Simulink.URL.URLKind.var,name);
        end
        function out=eval(h)
            if~isempty(h.Model)
                load_system(h.Model);
                hws=get_param(h.Parent,'modelworkspace');
                out=evalin(hws,h.ObjId);
            else
                out=evalin('base',h.ObjId);
            end
        end
    end
end
