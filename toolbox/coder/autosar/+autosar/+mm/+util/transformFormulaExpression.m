function expr=transformFormulaExpression(expression,transform)





















    [matchstart,matchend]=regexp(expression,'[\w]+');
    expr='';

    if(isempty(matchstart))
        expr=expression;
    else
        text_start=1;
        expectedArgs=nargin(transform);
        for ii=1:length(matchstart)
            text_end=matchstart(ii)-1;
            text=expression(text_start:text_end);
            symbol=expression(matchstart(ii):matchend(ii));
            if expectedArgs==1
                symbol=transform(symbol);
            else
                [symbol,text]=transform(symbol,text);
            end
            expr=sprintf('%s%s%s',expr,text,symbol);
            text_start=matchend(ii)+1;
        end
        text_end=length(expression);
        expr=sprintf('%s%s',expr,expression(text_start:text_end));
    end
end
