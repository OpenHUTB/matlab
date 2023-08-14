function hexCharVector=shaHex(input)























    hexCharVector='';
    try
        if isempty(input)
            return;
        end

        if isnumeric(input)
            input=num2str(input);
        end

        digester=matlab.internal.crypto.BasicDigester("DeprecatedSHA1");
        digestStr=digester.computeDigest(input);
        hexCharVector=char(matlab.internal.crypto.hexEncode(digestStr));
    catch ex %#ok<NASGU>
    end
end

