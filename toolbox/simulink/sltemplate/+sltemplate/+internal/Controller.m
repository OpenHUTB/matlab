classdef(Abstract)Controller<handle






    methods(Access='public',Abstract)

        showDialog(obj);

        hideDialog(obj);

        closeDialog(obj);

        broadcast(obj,eventName,eventData);

        onError(obj,message);

        onWarning(obj,message);

        onCompletedRequest(obj,result);

    end

end