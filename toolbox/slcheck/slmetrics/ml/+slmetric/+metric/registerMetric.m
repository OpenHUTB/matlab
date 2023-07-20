










function[id,msg]=registerMetric(className)
    if nargin>0
        className=convertStringsToChars(className);
    end

    id='';
    msg='';

    mm=slmetric.internal.MetricManager();

    try
        id=mm.registerMetric(className);
    catch E
        msg=E.message;
    end
end
