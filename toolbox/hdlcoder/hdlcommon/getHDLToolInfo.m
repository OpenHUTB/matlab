
function[list,defEntry]=getHDLToolInfo(key,varargin)





    if nargin<1
        params={};
    else
        params=varargin;
    end

    list={};
    defEntry='';

    persistent hDDI defaultInfo;
    if isempty(hDDI)
        hDDI=downstream.DownstreamIntegrationDriver('',false,false,'',downstream.queryflowmodesenum.MATLAB,'',true);
        defaultInfo=struct();
        defaultInfo.Workflow=hDDI.get('Workflow');
        defaultInfo.Board=hDDI.get('Board');
        defaultInfo.Tool=hDDI.get('Tool');
        defaultInfo.Family=hDDI.get('Family');
        defaultInfo.Device=hDDI.get('Device');
        defaultInfo.Package=hDDI.get('Package');
        defaultInfo.Speed=hDDI.get('Speed');
    elseif strcmpi(key,'refresh')
        hDDI.hAvailableToolList=downstream.AvailableToolList(hDDI);
        return;
    elseif strcmpi(key,'refreshSimToolList')
        hDDI.hAvailableSimulationToolList=downstream.AvailableSimulationToolList;
        return;
    elseif strcmpi(key,'resetOnClose')
        hDDI.hAvailableToolList=downstream.AvailableToolList(hDDI);
        hDDI.set('Workflow',handleDefEntryNotInList(hDDI.set('Workflow'),defaultInfo.Workflow));
        hDDI.set('Board',handleDefEntryNotInList(hDDI.set('Board'),defaultInfo.Board));
        hDDI.set('Tool',handleDefEntryNotInList(hDDI.set('Tool'),defaultInfo.Tool));
        hDDI.set('Family',defaultInfo.Family);
        hDDI.set('Device',defaultInfo.Device);
        hDDI.set('Package',defaultInfo.Package);
        hDDI.set('Speed',defaultInfo.Speed);
        return;
    elseif strcmpi(key,'reset')
        hDDI.set('Workflow',handleDefEntryNotInList(hDDI.set('Workflow'),defaultInfo.Workflow));
        hDDI.set('Board',handleDefEntryNotInList(hDDI.set('Board'),defaultInfo.Board));
        hDDI.set('Tool',handleDefEntryNotInList(hDDI.set('Tool'),defaultInfo.Tool));
        hDDI.set('Family',defaultInfo.Family);
        hDDI.set('Device',defaultInfo.Device);
        hDDI.set('Package',defaultInfo.Package);
        hDDI.set('Speed',defaultInfo.Speed);
        return;
    end

    if strcmpi(key,'targetFrequency')
        list=num2str(hDDI.getTargetFrequency);
        defEntry=list;
        return
    elseif strcmp(key,'EmbeddedTool')
        defaultEmbeddedTool={'Xilinx PlanAhead with Embedded Design'};
        try
            list={hDDI.hIP.getEmbeddedTool};
            defEntry=hDDI.hIP.getEmbeddedTool;
        catch me %#ok<*NASGU>
            list=defaultEmbeddedTool;
            defEntry=list{1};
        end
        return
    elseif strcmp(key,'EmbeddedToolProjFolder')
        defaultEmbeddedToolProjFolder='codegen/pa_prj';
        try
            list=hDDI.hIP.getEmbeddedToolProjFolder;
        catch me %#ok<*NASGU>
            list=defaultEmbeddedToolProjFolder;
        end
        defEntry=list;
        return
    elseif strcmpi(key,'reloadPlatformList')

        if~isempty(varargin)
            if~hDDI.isIPWorkflow

                hDDI.set('Workflow','IP Core Generation');
            end
            try
                hDDI.hIP.reloadPlatformList;
            catch me %#ok<*NASGU>

            end

        else
            try
                hDDI.hAvailableBoardList.buildCustomBoardList;
            catch me %#ok<*NASGU>

            end
        end
        return
    elseif strcmpi(key,'isGenericIPPlatform')
        list=hDDI.isGenericIPPlatform;
        defEntry=list;
        return
    end



    for ii=1:2:length(params)
        k=params{ii};
        v=params{ii+1};

        if~isempty(k)&&~isempty(v)
            try
                if strcmpi(k,'ReferenceDesign')
                    hDDI.hIP.setReferenceDesign(v);
                else

                    if strcmpi(k,'Workflow')&&contains(v,'option.workflow.')
                        v=v(length('option.workflow.')+1:end);
                        switch v
                        case 'GenericAsicFpga'
                            v='Generic ASIC/FPGA';
                        case 'IpCore'
                            v='IP Core Generation';
                        case 'FpgaTurnkey'
                            v='FPGA Turnkey';
                        case 'HLS'
                            v='High Level Synthesis';
                        end
                    end
                    hDDI.set(k,v);
                end
            catch me %#ok<*NASGU>


            end
        end
    end

    if strcmpi(key,'referenceDesign')
        try

            list=hDDI.hIP.getReferenceDesignAll;
            defEntry=hDDI.hIP.getReferenceDesign;
        catch me %#ok<*NASGU>

            list={''};
        end

        return


    elseif strcmpi(key,'referenceDesignPath')
        try

            list=int2str(hDDI.hIP.needReferenceDesignPath);
        catch me %#ok<*NASGU>

            list='0';
        end
        defEntry=list;
        return
    else
        list=hDDI.set(key);
    end
    if~isempty(list)
        if~iscell(list)
            list={list};
        end
    else
        list={};
    end

    defEntry=hDDI.get(key);
    defEntry=handleDefEntryNotInList(list,defEntry);
end

function newDefEntry=handleDefEntryNotInList(list,defEntry)
    newDefEntry=defEntry;
    isDefEntryInList=find(ismember(list,{defEntry})>0);

    if isempty(isDefEntryInList)



        if~iscell(list)
            newDefEntry=list;
            return
        end
        equivOptionIdx=find(cellfun(@(x)length(x)>2&&strcmpi(x(1:3),'no '),list)>0);
        if~isempty(equivOptionIdx)
            newDefEntry=list{equivOptionIdx};
        else

            newDefEntry=list{1};
        end
    end
end

