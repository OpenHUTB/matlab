
function subs=getSetWeakSubscriptions(varargin)

    persistent subscriptions;

    if isempty(subscriptions)
mlock
        subscriptions=matlab.internal.WeakHandle.empty;
    end

    if nargin>0
        subscriptions=varargin{1};
    end

    subs=subscriptions;
