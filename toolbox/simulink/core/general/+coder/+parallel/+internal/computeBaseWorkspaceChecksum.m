function checksum=computeBaseWorkspaceChecksum





    checksum=CGXE.Utils.md5();
    baseVars=evalin('base','who');
    for i=1:length(baseVars)

        if strcmp(baseVars{i},'ans')
            continue;
        end

        checksum=CGXE.Utils.md5(checksum,baseVars{i},evalin('base',baseVars{i}));
    end
end

