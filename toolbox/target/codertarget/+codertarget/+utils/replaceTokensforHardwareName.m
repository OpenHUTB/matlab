function dstStr=replaceTokensforHardwareName(hardware,srcStr,tokenArray,warnIfBadToken)


    if nargin<3
        tokenArray={};
    end
    if nargin<4
        warnIfBadToken=false;
    end

    if iscell(srcStr)
        dstStr=cell(1,numel(srcStr));
        for i=1:numel(srcStr)
            dstStr{i}=i_replace(hardware,srcStr{i},tokenArray,warnIfBadToken);
        end
    else
        dstStr=i_replace(hardware,srcStr,tokenArray,warnIfBadToken);
    end

end

function dstStr=i_replace(hardware,dstStr,tokenArray,warnIfBadToken)


    knownTokens={'$(TARGET_ROOT)','$(MATLAB_ROOT)'};
    for j=1:length(knownTokens)
        token=knownTokens{j};
        switch token
        case '$(TARGET_ROOT)'
            if ischar(hardware)
                hwInfo=codertarget.targethardware.getTargetHardware(hardware);
            else
                hwInfo=hardware;
            end
            dstStr=strrep(dstStr,token,hwInfo.TargetFolder);
        case '$(MATLAB_ROOT)'
            dstStr=strrep(dstStr,token,matlabroot);
        end
    end


    [dstStr,hadErrors]=codertarget.utils.replaceTokensFromTokenArray(dstStr,tokenArray,hardware);
    if warnIfBadToken&&hadErrors
        warning(message('codertarget:build:HardwareSelectError',hwName,hwName));
    end


    for j=1:length(tokenArray)
        tokenName=tokenArray{j}.Name;
        tokenValue=getenv(tokenName);
        if~isempty(tokenValue)
            expToken=['$(',tokenName,')'];
            dstStr=strrep(dstStr,expToken,tokenValue);
        end
    end
end
