classdef ReqProfileChecker<handle


    properties(GetAccess=public,SetAccess=private)
        mdl;
        prfChecker;
        prfNamespace;
    end

    methods
        function checkProfiles(this,artifact)
            this.mdl=mf.zero.Model;
            [this.prfChecker,this.prfNamespace]=slreq.internal.ProfileReqType.areProfilesOutdated(artifact,this.mdl);
        end
    end

end