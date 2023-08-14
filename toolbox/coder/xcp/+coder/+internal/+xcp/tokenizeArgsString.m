function tokens=tokenizeArgsString(extModeMexArgs)

















    tokens={};

    remainingArgs=strip(convertStringsToChars(extModeMexArgs));
    assert(isa(remainingArgs,'char'),'Invalid type');
    while~isempty(remainingArgs)
        [token,remainingArgs]=splitToken(remainingArgs);
        if isempty(token)
            token='''''';
        end
        tokens{end+1}={token};%#ok<AGROW>
    end

    function[token,remaining]=splitToken(str)










        remaining=strip(str,'left');
        if remaining(1)==''''
            tokenLen=regexp(remaining(2:end),'['']','once');
            if isempty(tokenLen)

                DAStudio.error(...
                'coder_xcp:host:ExtModeMexArgsUnbalancedQuote',...
                extModeMexArgs);
            end
            tokenLen=tokenLen+1;
        else
            tokenLen=regexp(remaining,'[\s,'']','once');
            if isempty(tokenLen)
                tokenLen=numel(remaining);
            else
                tokenLen=tokenLen-1;
            end
        end
        token=remaining(1:tokenLen);

        remaining=strip(remaining(tokenLen+1:end),'left');


        if~isempty(remaining)&&remaining(1)==','
            remaining=remaining(2:end);
        end



        assert(numel(remaining)<numel(str),'Failed to parse token')
    end
end
