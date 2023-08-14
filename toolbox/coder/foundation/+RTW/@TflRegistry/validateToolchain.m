function[isSupported,exception]=validateToolchain(h,tr,selectedToolchain,returnValidationError)






    nothrow=~returnValidationError;
    exception=[];
    isSupported=true;


    tcSrcCrl=h;
    while(isempty(tcSrcCrl.TargetToolchain)&&~isempty(tcSrcCrl.BaseTfl))
        try
            tcSrcCrl=coder.internal.getTfl(tr,tcSrcCrl.BaseTfl);
        catch ME
            if(strcmp(ME.identifier,'RTW:targetRegistry:noNameMatch'))

                break;
            else
                rethrow(ME);
            end
        end
    end
    targetToolchain=tcSrcCrl.TargetToolchain;


    suppTC={};
    unsuppTC={};
    for i_tc=1:numel(targetToolchain)
        tc=targetToolchain{i_tc};
        [suppTC,unsuppTC]=parseAndUpdate(tc,suppTC,unsuppTC);
    end


    assert(isempty(suppTC)||isempty(unsuppTC));

    if(~isempty(selectedToolchain))
        if(~isempty(suppTC))
            isSupported=any(strcmp(selectedToolchain,suppTC));
        elseif(~isempty(unsuppTC))
            isSupported=~any(strcmp(selectedToolchain,unsuppTC));
        end
    end



    if(~nothrow&&~isSupported)
        if(~isempty(suppTC))
            exception=MSLException('CoderFoundation:tfl:TargetToolchainNotListed',...
            h.Name,...
            strjoin(suppTC));
        else
            exception=MSLException('CoderFoundation:tfl:TargetToolchainMatchedExcludeList',...
            h.Name,...
            strjoin(unsuppTC));
        end
    end


end




function[suppTC,unsuppTC]=parseAndUpdate(tcStr,suppTC,unsuppTC)

    if(tcStr(1)=='-')
        unsuppTC{end+1}=getToolchainNameFromRegistry(tcStr(2:end));
    else
        suppTC{end+1}=getToolchainNameFromRegistry(tcStr);
    end

end

function tcName=getToolchainNameFromRegistry(tcStr)


    tc=coder.make.internal.getToolchainNameFromRegistry(tcStr);
    if~isempty(tc)
        tcName=tc;
    else
        tcName=tcStr;
    end
end

