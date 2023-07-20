




























classdef OutputFcn


    properties(SetAccess=public,GetAccess=public)



        Fcn(1,1)function_handle=@(~,~,~)[]




        Data(1,1)struct
    end

    methods


        function obj=OutputFcn(fcn,varargin)
            try

                [obj.Fcn,obj.Data]=slsim.internal.getFcnAndSource(fcn,varargin{:});
            catch ME

                throw(ME);
            end
        end

    end
end

