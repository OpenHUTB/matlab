function dstStr=replaceTokens(hwObj,srcStr,extraTokens,warnIfBadToken)





    if nargin<3
        extraTokens={};
    end
    if nargin<4
        warnIfBadToken=false;
    end

    if iscell(srcStr)
        dstStr=cell(1,numel(srcStr));
        for i=1:numel(srcStr)
            dstStr{i}=i_replace(hwObj,srcStr{i},extraTokens,warnIfBadToken);
        end
    else
        dstStr=i_replace(hwObj,srcStr,extraTokens,warnIfBadToken);
    end
end


function dstStr=i_replace(hwObj,srcStr,extraTokens,warnIfBadToken)
    knownTokens={'$(TARGET_ROOT)','$(MATLAB_ROOT)'};
    dstStr=srcStr;
    for j=1:length(knownTokens)
        token=knownTokens{j};
        switch token
        case '$(TARGET_ROOT)'
            dstStr=strrep(dstStr,token,hwObj.TargetFolder);
        case '$(MATLAB_ROOT)'
            dstStr=strrep(dstStr,token,matlabroot);
        end
    end

    hardwareName=hwObj.Name;


    for j=1:length(extraTokens)
        tokenName=extraTokens{j}.Name;
        tokenValue=extraTokens{j}.Value;
        if~isempty(tokenValue)
            str=which(tokenValue);
            [~,~,e]=fileparts(str);
            if isequal(e,'.m')||isequal(e,'.p')
                try
                    tokenValue=eval(tokenValue);
                catch
                    tokenValue='';
                    if warnIfBadToken
                        warning(message('codertarget:build:HardwareSelectError',...
                        hardwareName,hardwareName));
                    end
                end
            end
        end
        if~isempty(tokenValue)
            expToken=['$(',tokenName,')'];
            dstStr=strrep(dstStr,expToken,tokenValue);
        end
    end


    for j=1:length(extraTokens)
        tokenName=extraTokens{j}.Name;
        tokenValue=getenv(tokenName);
        if~isempty(tokenValue)
            expToken=['$(',tokenName,')'];
            dstStr=strrep(dstStr,expToken,tokenValue);
        end
    end
end
