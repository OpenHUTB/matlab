function sighier=oldFormat2NewFormat(this,busstruct)





    if isempty(busstruct)
        sighier=[];
        return;
    elseif(isfield(busstruct(1),'SignalName'))

        sighier=busstruct;
        return;
    else
        for ct=1:numel(busstruct)
            sighier(ct,1).SignalName=busstruct(ct).name;
            sighier(ct,1).BusObject='';
            sighier(ct,1).Children=oldFormat2NewFormat(this,busstruct(ct).signals);%#ok<*AGROW>
        end
    end