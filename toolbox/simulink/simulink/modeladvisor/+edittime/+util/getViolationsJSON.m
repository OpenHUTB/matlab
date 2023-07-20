function json=getViolationsJSON(system,blkHandle,varargin)






    if Simulink.ID.isValid(blkHandle)
        blkHandle=get_param(blkHandle,'Handle');
    elseif ischar(blkHandle)
        blkHandle=str2double(blkHandle);
    end
    optargs={0,edittime.ViolationType.MAError};
    numvarargs=length(varargin);



    optargs(1:numvarargs)=varargin;
    violations=edittime.util.getViolations(system,blkHandle,optargs{1},optargs{2});
    json='';
    for i=1:length(violations)
        json=[json,violations{i}.getJSON(blkHandle,system)];
    end

