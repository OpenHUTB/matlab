classdef ReqSetHelper<slreq.internal.callback.CallbackHelper




    methods

        function setupCallback(this,type,text)
            setupCallback@slreq.internal.callback.CallbackHelper(this,type,text);
            if strcmpi(type,'PreSaveFcn')

                this.ErrorAction='Error';
            end
        end
    end

    methods(Access=protected)

        function setup(this)
            setup@slreq.internal.callback.CallbackHelper(this);
            slreq.internal.callback.CurrentInformation.setCurrentReqSet(this.Object);
        end
    end
end

