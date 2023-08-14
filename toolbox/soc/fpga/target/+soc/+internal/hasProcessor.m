
function result=hasProcessor(sys)
    cs=getActiveConfigSet(sys);
    if~codertarget.data.isValidParameter(cs,'FPGADesign.IncludeProcessingSystem')
        result=true;
    else
        result=codertarget.data.getParameterValue(cs,'FPGADesign.IncludeProcessingSystem');
        if ischar(result)
            if strcmpi(result,'0')
                result=false;
            else
                result=true;
            end
        end
    end
end


