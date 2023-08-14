function h=ssc_new_private(varargin)






    persistent DOMAINS
    if isempty(DOMAINS)
        DOMAINS={
'electrical'
'gas'
'hydraulic'
'isothermal_liquid'
'magnetic'
'moist_air'
'rotational'
'thermal'
'thermal_liquid'
'translational'
        'two_phase_fluid'};
    end











    modelName='';
    domain='generic';

    narginchk(0,2)


    if nargin>0
        modelName=lValidateArg(varargin{1},"MODELNAME",modelName,@isvarname,"InvalidModelName");
    end


    if nargin>1
        domain=lValidateArg(varargin{2},"DOMAIN",domain,@(x)any(strcmp(x,DOMAINS)),"InvalidDomain");
    end

    eventDispatcher=[];

    try


        eventDispatcher=DAStudio.EventDispatcher;
        eventDispatcher.broadcastEvent('MESleepEvent')


        h=new_system(modelName,'FromTemplate',domain);
        open_system(h)

    catch ME

        if~isempty(eventDispatcher)
            eventDispatcher.broadcastEvent('MEWakeEvent')
        end
        rethrow(ME);

    end

    eventDispatcher.broadcastEvent('MEWakeEvent')

end

function arg=lValidateArg(arg,argName,default,validityCheck,validityWarningIdTail)
    if isempty(arg)
        arg=default;
        return;
    end
    arg=pm_charvector(arg,@lCheckValid,@lNotCharVector);
    function out=lCheckValid(in)
        out=in;
        if~validityCheck(in)
            pm_warning("physmod:simscape:simscape:ssc_new:"+validityWarningIdTail,"'"+string(arg)+"'");
            out=default;
        end
    end
    function out=lNotCharVector(~)
        pm_warning('physmod:simscape:simscape:ssc_new:IsCharOrStringScalar',argName);
        out=default;
    end
end

