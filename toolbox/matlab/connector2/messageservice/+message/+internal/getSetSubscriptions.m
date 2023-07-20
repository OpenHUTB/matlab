function subs=getSetSubscriptions(varargin)
    persistent subscriptions;

    if nargin>0
mlock
        subscriptions=varargin{1};
    end

    subs=subscriptions;
