classdef Response<hgsetget












    properties(Access=public)
        Compartment=0;
        Data=SimBiology.internal.Data.TimeValue;
    end

    properties(SetAccess=private)
        Type='response';
    end

    methods
        function obj=Response(time,value,varargin)
            obj.Data.Time=time;
            obj.Data.Value=value;
        end
    end
end