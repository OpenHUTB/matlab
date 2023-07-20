function out=debugReportV2(value)



    persistent debugValue

    if isempty(debugValue)

        debugValue=false;
    end
    out=debugValue;
    if nargin>0
        debugValue=value;
    end
end


