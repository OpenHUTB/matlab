classdef STimeInheritRuleT<eda.internal.mcosutils.FullStringEnumT
    properties(Constant=true,Hidden=true)
        strValues={'No inheritance',...
        'Inherit: Inherit via internal rule',...
        'Inherit: Inherit via propagation'};
        intValues=int32([-23,0,-1]);
    end
    methods
        function this=STimeInheritRuleT(varargin)
            this=this@eda.internal.mcosutils.FullStringEnumT(varargin{:});
        end
    end
end
