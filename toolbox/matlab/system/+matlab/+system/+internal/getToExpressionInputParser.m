function toExpressionInputParser=getToExpressionInputParser






    persistent p;
    if isempty(p)
        p=inputParser;
        p.addParameter('Split',true);
        p.addParameter('IncludeHidden',true);
        p.addParameter('Defaults',[]);
    end
    toExpressionInputParser=p;