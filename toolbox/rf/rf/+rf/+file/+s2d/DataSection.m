classdef DataSection<rf.file.shared.sandp2d.DataSection




    properties(SetAccess=protected)
GCOMPx
    end

    methods
        function obj=DataSection(newSmallSignal,newNoise,newIMT,newGCOMP)
            obj=obj@rf.file.shared.sandp2d.DataSection(newSmallSignal,newNoise,newIMT);
            obj.GCOMPx=newGCOMP;
        end
    end

    methods
        function set.GCOMPx(obj,newGCompObj)
            if~isa(newGCompObj,'rf.file.s2d.GcompMethods')
                error(message('rf:rffile:s2d:datasection:setproperty:BadInputArgClass','GCOMP',class(obj)))
            end
            if~isempty(newGCompObj)
                if isa(newGCompObj,'rf.file.s2d.Gcomp7')
                    validateattributes(newGCompObj,{'rf.file.s2d.Gcomp7'},{'vector'});
                else
                    validateattributes(newGCompObj,{'rf.file.s2d.GcompMethods'},{'scalar'});
                end
            end
            obj.GCOMPx=newGCompObj;
        end
    end

    methods
        function out=hasgcomp(obj)
            out=~isempty(obj.GCOMPx);
        end
    end
end