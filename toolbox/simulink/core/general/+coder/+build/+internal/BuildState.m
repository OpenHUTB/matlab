classdef BuildState<handle





    properties(GetAccess=public)
mMdlRefPrms
configSet
preserve_dirty
RTWGenSettings
origConfigSet
tmpConfigSet
mModel
ConfiguredForProtectedModel
buildResult
mMdlsToClose
binfoBackup
mCurrentSystem
mWarning
    end

    methods

        function retVal=isempty(this)
            props=properties(this);
            for iprop=1:length(props)
                propValue=this.(props{iprop});
                if~isempty(propValue)
                    retVal=false;
                    return;
                end
            end
            retVal=true;
        end
    end
end
