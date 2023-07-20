function out=getStateflowSID(h,blockHandle)



























































    import Simulink.ID.internal.getReferenceBlock
    import Simulink.ID.internal.getStateflowSID_helper

    if~isa(h,'Stateflow.Object')&&~isa(h,'Stateflow.DDObject')
        DAStudio.error('Simulink:utility:invalidHandle');
    end

    [ssid,blockH,blockLibH]=getStateflowSID_helper(h);
    if~isempty(blockLibH)

        blockH=blockLibH;
    end

    if nargin<=1
        blockHandle=[];
    end
    if~isempty(blockHandle)
        if ischar(blockHandle)
            blockHandle=get_param(blockHandle,'handle');
        end



        if blockHandle~=blockH
            refH=blockHandle;
            while refH~=blockH
                try
                    refH=getReferenceBlock(refH);
                catch
                    refH=[];
                end
                if isempty(refH)
                    throw(MSLException([],message('Simulink:utility:invalidHandle')));
                end
            end
        end
        blockH=blockHandle;
    end

    out=strcat(get_param(blockH,'SIDFullString'),ssid);
