classdef SystemDiagramFinder<slreportgen.finder.DiagramFinder












































































    properties





        IncludeRoot(1,1)logical=true;
    end

    methods
        function h=SystemDiagramFinder(varargin)
            h=h@slreportgen.finder.DiagramFinder(varargin{:});
        end

        function set.IncludeRoot(h,val)
            mustNotBeIterating(h,"IncludeRoot");
            h.IncludeRoot=val;
        end

        function results=find(h)








































            results=find@slreportgen.finder.DiagramFinder(h);
        end
    end

    methods(Access=protected)
        function tf=satisfyResultConstraint(h,result)
            tf=false;
            r=slroot();
            obj=result.Object;
            if r.isValidSlObject(obj)
                objType=get_param(obj,'Type');

                isSubSystem=strcmp(objType,'block')...
                &&strcmp(get_param(obj,'BlockType'),'SubSystem');

                if(~isSubSystem&&h.IncludeRoot)
                    tf=strcmp(objType,'block_diagram');
                else
                    tf=isSubSystem;
                end
            end
        end
    end
end

