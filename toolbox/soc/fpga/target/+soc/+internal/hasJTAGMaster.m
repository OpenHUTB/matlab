
function result=hasJTAGMaster(sys)
    cs=getActiveConfigSet(sys);
    result=codertarget.data.getParameterValue(cs,'FPGADesign.IncludeJTAGMaster');
    if ischar(result)
        if strcmpi(result,'0')
            result=false;
        else
            result=true;
        end
    end
end