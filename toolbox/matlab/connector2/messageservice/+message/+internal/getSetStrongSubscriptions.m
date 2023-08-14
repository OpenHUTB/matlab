
function subs=getSetStrongSubscriptions(varargin)

    persistent subscriptions;

    if isempty(subscriptions)
mlock
        subscriptions=message.internal.Subscription.empty;
    end

    if nargin>0
        subscriptions=varargin{1};
    end

    subs=subscriptions;
