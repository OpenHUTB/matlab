classdef ScalableReport<matlab.mixin.CustomDisplay


    properties(SetAccess=immutable)
TotalModelCompilationTime
SimscapeCompilationTime
ScalableSimscapeCompilationTime
PeakMemory
ScalablePeakMemory
Subsystems
Components
Recommendation
    end
    properties(SetAccess=immutable,Hidden)
Model
    end

    methods
        function obj=ScalableReport(varargin)
            assert(~mod(nargin,2));
            for i=1:2:nargin
                obj.(varargin{i})=varargin{i+1};
            end
        end
    end


    methods(Access=protected)
        function header=getHeader(obj)
            if~isscalar(obj)
                header=getHeader@matlab.mixin.CustomDisplay(obj);
            else
                className=matlab.mixin.CustomDisplay.getClassNameForHeader(obj);
                newHeader=sprintf('%s %s ''%s''',className,txt('ForModel'),obj.Model);
                header=sprintf('%s\n',newHeader);
            end
        end

        function propgrps=getPropertyGroups(obj)
            if~isscalar(obj)
                propgrps=getPropertyGroups@matlab.mixin.CustomDisplay(obj);
            else
                normComp=matlab.mixin.util.PropertyGroup({'TotalModelCompilationTime','SimscapeCompilationTime','PeakMemory'});
                scaleComp=matlab.mixin.util.PropertyGroup({'ScalableSimscapeCompilationTime','ScalablePeakMemory'});
                details=matlab.mixin.util.PropertyGroup({'Subsystems','Components'});
                propgrps=[normComp,scaleComp,details];
            end
        end

        function footer=getFooter(obj)
            if~isscalar(obj)
                footer=getFooter@matlab.mixin.CustomDisplay(obj);
            else
                footer=obj.Recommendation;
            end
        end
    end
end

function str=txt(id)
    m=message(['physmod:simscape:simscape:sb_advisor:',id]);
    str=m.string;
end
