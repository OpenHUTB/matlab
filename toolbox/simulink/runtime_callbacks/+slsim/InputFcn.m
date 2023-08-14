






























classdef InputFcn

    properties(SetAccess=private,GetAccess=public)



        Fcn(1,1)function_handle=@(~,~)[]




        Data(1,1)struct
    end

    methods


        function obj=InputFcn(fcn,varargin)
            try

                [obj.Fcn,obj.Data]=slsim.internal.getFcnAndSource(fcn,varargin{:});
            catch ME

                throw(ME);
            end
        end
    end

end
