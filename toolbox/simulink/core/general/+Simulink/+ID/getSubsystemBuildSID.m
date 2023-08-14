function out=getSubsystemBuildSID(sid,sourceSubsystem,varargin)












































    import Simulink.ID.internal.getSubsystemBuildSIDHelper

    narginchk(2,3);

    if sid==""


        out=sid;
        return
    end

    out=getSubsystemBuildSIDHelper(sid,sourceSubsystem,varargin{:});


