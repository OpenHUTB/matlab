










function[status,msg]=unregisterMetric(id)
    if nargin>0
        id=convertStringsToChars(id);
    end

    status=false;
    msg='';

    mm=slmetric.internal.MetricManager();

    try
        mm.unregisterMetric(id);
        status=true;
    catch E
        msg=E.message;
    end
end