function ret=isESBEnabled(obj,varargin)




    if nargin<1


        ret=locIsESBInstalled&&isequal(exist('soc.internal.ESBRegistry','class'),8);
    else

        if isa(obj,'Simulink.ConfigSet')||...
            isa(obj,'Simulink.ConfigSetRef')
            hCS=obj;
        elseif isa(obj,'CoderTarget.SettingsController')
            hCS=obj.getConfigSet;
        else
            hCS=getActiveConfigSet(obj);
        end
        if nargin==1
            reqcaps=1;
        else
            reqcaps=varargin{1};
        end



        if isValidParam(hCS,'UseSoCProfilerForTargets')
            useSoCProfiler=get_param(hCS,'UseSoCProfilerForTargets');
        else
            useSoCProfiler=false;
        end


        ret=locIsESBInstalled&&codertarget.targethardware.isESBCompatible(hCS,reqcaps)||useSoCProfiler;
    end


end


function res=locIsESBInstalled
    res=isequal(exist('esb_task','file'),3);
end


