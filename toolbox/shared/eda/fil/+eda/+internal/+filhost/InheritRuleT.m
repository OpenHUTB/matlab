classdef InheritRuleT<eda.internal.mcosutils.FullStringEnumT
    properties(Constant=true,Hidden=true)
        strValues={'No inheritance','Inherit: auto'};
        intValues=int32([-23,0]);
    end
    methods
        function this=InheritRuleT(varargin)
            this=this@eda.internal.mcosutils.FullStringEnumT(varargin{:});
        end
    end
end
