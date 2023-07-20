function dstStr=replaceTokens(hObj,srcStr,tokenArray,warnIfBadToken)





    if nargin<3
        tokenArray={};
    end
    if nargin<4
        warnIfBadToken=false;
    end

    if isempty(hObj)
        assert(false,'Model or config set object passed to replaceTokens is empty.');
    elseif ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    elseif isa(hObj,'CoderTarget.SettingsController')||...
        isa(hObj,'Simulink.HardwareCC')
        hObj=hObj.getConfigSet();
    elseif~isa(hObj,'coder.CodeConfig')&&...
        ~isa(hObj,'Simulink.ConfigSet')&&...
        ~isa(hObj,'Simulink.ConfigSetRef')
        assert(false,'Model or config set object passed to replaceTokens is of invalid type.');
    end

    if iscell(srcStr)
        dstStr=cell(1,numel(srcStr));
        for i=1:numel(srcStr)
            dstStr{i}=i_replace(hObj,srcStr{i},tokenArray,warnIfBadToken);
        end
    else
        dstStr=i_replace(hObj,srcStr,tokenArray,warnIfBadToken);
    end
end


function dstStr=i_replace(hObj,dstStr,tokenArray,warnIfBadToken)

    knownTokens={'$(TARGET_ROOT)','$(MATLAB_ROOT)'};
    for j=1:length(knownTokens)
        token=knownTokens{j};
        switch token
        case '$(TARGET_ROOT)'
            hwInfo=codertarget.targethardware.getTargetHardware(hObj);
            dstStr=strrep(dstStr,token,hwInfo.TargetFolder);
        case '$(MATLAB_ROOT)'
            dstStr=strrep(dstStr,token,matlabroot);
        end
    end


    [dstStr,hadErrors]=codertarget.utils.replaceTokensFromTokenArray(dstStr,tokenArray,hObj);
    if warnIfBadToken&&hadErrors
        hwName=codertarget.target.getTargetName(hObj);
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
