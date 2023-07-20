classdef LARequestResponse<handle





    properties(SetAccess=protected)
        Data=[];
        Channel='';
        Action='';
        ClientID='';
    end

    properties(Access=protected)
        Subscription=[];
    end

    methods

        function this=LARequestResponse(cName,aName,clientId)

            this.Channel=cName;
            this.Action=aName;
            this.ClientID=clientId;
            this.Subscription=uiservices.Subscription(cName,@this.subscriptionCallback);
        end

        function subscriptionCallback(this,args)
            action=args.action;
            clientId=args.clientId;
            if isequal(clientId,this.ClientID)&&strcmp(action,this.Action)



                this.Data=args.params;
            end
        end

        function reset(this)
            this.Data=[];
        end

        function b=isComplete(this)
            b=~isempty(this.Data);
        end
    end
end


