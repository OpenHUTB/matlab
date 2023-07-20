classdef CodePerspectiveListener<handle




    properties
bd
cps
        ls={}
    end

    methods
        function obj=CodePerspectiveListener(bd,cps)

            obj.bd=bd;
            obj.cps=cps;
            obj.init();

        end

        function delete(obj)
            for i=1:length(obj.ls)
                l=obj.ls{i};
                delete(l);
            end

        end
    end

    methods

        init(obj)
        callback(obj,varargin)
        ddChangeCallbck(obj,varargin)
        onSelect(obj,varargin)
        onCodeGenStart(obj,varargin)
        enable(obj,bool,varargin)
    end
end
