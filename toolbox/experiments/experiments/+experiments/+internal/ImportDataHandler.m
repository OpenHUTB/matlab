classdef ImportDataHandler<handle




    properties(SetAccess=private)
        Data={};
    end

    properties(SetObservable)
        Status char{mustBeMember(Status,{'Successful','Failed',''})}=''
    end

    methods
        function obj=ImportDataHandler(input)
            if nargin==1
                obj.Data=deal(input(1:2));
            end
        end

    end

end
