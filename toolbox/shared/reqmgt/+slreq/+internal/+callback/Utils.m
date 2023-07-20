classdef Utils






    methods(Static)
        function executeCallback(obj,fcnType,fcnText,varargin)





            cmdString=strtrim(regexprep(fcnText,'^%[^\n]+\n',''));
            if isempty(strtrim(cmdString))

                return;
            end

            cbHelper=slreq.internal.callback.Utils.createCallbackHelper(obj);


            cbHelper.setupCallback(fcnType,cmdString,varargin{:});
            cbHelper.run()
        end
    end
    methods(Static,Access=private)
        function cbHelper=createCallbackHelper(obj)
            switch class(obj)
            case{'double','slreq.data.Requirement'}



                cbHelper=slreq.internal.callback.ImportNodeHelper(obj);
            case 'slreq.data.RequirementSet'
                cbHelper=slreq.internal.callback.ReqSetHelper(obj);
            end
        end
    end
end

