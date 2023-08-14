function sigId = getSigDfgIds(obj, portH)
%GETSIGDFGIDS
% It would return the DFG Id for a port.

%   Copyright 2020 The MathWorks, Inc.
    import slslicer.internal.*
    ir = obj.ir;
    sigId = [];
    bh = get(portH, 'ParentHandle');
    bt = get(bh, 'BlockType');
    if strcmp(bt, 'SubSystem') && strcmp( ...
            get(bh,'TreatAsAtomicUnit'), 'on')
        % Atomic system

        u = SLCompGraphUtil.Instance;
        pt = get(portH, 'porttype');
        if strcmp(pt, 'outport')
            ports = u.findSrcPortsInChildren(bh, portH);
            sigId = arrayfun(@(x)ir.portHandleToDfgVarIdx(x), ports);
        else
            ports = u.findDstPortsInChildren(bh, portH);
            sigId = arrayfun(@(x)ir.dfgInportHToInputIdx(x), ports);
        end


    elseif strcmp(bt, 'ModelReference') && strcmp(...
            get(bh,'SimulationMode'), 'Normal')
        u = SLCompGraphUtil.Instance;
        %Currently, inport port can be DFG starting, though it should
        %not be selected from user. So we try to get inport dfg id
        %here. 
        if strcmpi(get(portH, 'PortType'), 'inport')
            sigId = ir.dfgInportHToInputIdx(portH);
        else
            ports = u.findSrcPortsInChildren(bh, portH);
            sigId = arrayfun(@(x)ir.portHandleToDfgVarIdx(x), ports);
        end
    elseif strcmp(bt, 'SubSystem') && strcmp( ...
            get(bh,'TreatAsAtomicUnit'), 'off')
        u = SLCompGraphUtil.Instance;
        ports = u.findSrcPortsInChildren(bh, portH);
        sigId = arrayfun(@(x)ir.portHandleToDfgVarIdx(x), ports);

    else
        % Regular block, must be in the map
        if ir.portHandleToDfgVarIdx.isKey(portH)
            sigId = ir.portHandleToDfgVarIdx(portH);
        elseif ir.dfgInportHToInputIdx.isKey(portH) %if it is an inport.
            %before we do not allow the inport port is valid because there
            %is no use case to add inport port as seed. 
            %but inport port is also valid. 
            %sometimes, when we try to get the id of inport port for an
            %outport when calcuate 
            sigId = ir.dfgInportHToInputIdx(portH);
        else

            sigId = [];
        end
    end        
end