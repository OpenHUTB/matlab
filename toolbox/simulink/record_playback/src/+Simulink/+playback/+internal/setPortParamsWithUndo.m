function setPortParamsWithUndo(blockPath,ports)






    editorPath=blockPath;



    [editor,editorDomain]=locGetEditor(editorPath);
    if isempty(editorDomain)
        locSetParams(blockPath,ports);
    else
        editorDomain.createParamChangesCommand(...
        editor,...
        'record_playback:dialogs:PortSettingGroup',...
        getString(message('record_playback:dialogs:PortSettingGroup')),...
        @locSetPortParams,{blockPath,ports,editorDomain},...
        false,...
        true,...
        false,...
        false,...
        true);
    end
end


function[editor,editorDomain]=locGetEditor(bpath)


    editorDomain=[];
    editor=[];
    try
        editors=GLUE2.Util.findAllEditors(bpath);
        numEditors=length(editors);
        for idx=1:numEditors
            if editors(idx).isVisible
                domain=editors(idx).getStudio.getActiveDomain();
                if ismethod(domain,'createParamChangesCommand')
                    editor=editors(idx);
                    editorDomain=domain;
                    break;
                end
            end
        end
    catch me %#ok<NASGU>
        editor=[];
        editorDomain=[];
    end
end


function[success,noop]=locSetPortParams(blockPath,ports,editorDomain)

    success=false;
    noop=false;
    try
        hBD=get_param(blockPath,'Handle');
        editorDomain.paramChangesCommandAddObject(hBD);
        locSetParams(blockPath,ports);
        success=true;
    catch me %#ok
    end
end


function locSetParams(blockPath,ports)

    numPorts=numel(ports);
    set_param(blockPath,'NumPorts',numPorts);

    dataTypes=arrayfun(@(e)string(e.dataType),ports);
    set_param(blockPath,'OutDataTypeStr',dataTypes);

    dimensions=arrayfun(@(e)str2num(e.dimensions),ports,'UniformOutput',false);%#ok<ST2NM> 
    set_param(blockPath,'PortDimensions',dimensions);

    dimsModes=arrayfun(@(e)string(e.dimsMode),ports);
    set_param(blockPath,'PortDimsModes',dimsModes);

    units=arrayfun(@(e)string(e.units),ports);
    set_param(blockPath,'PortUnits',units);

    complexity=arrayfun(@(e)string(e.complexity),ports);
    set_param(blockPath,'PortComplexity',complexity);

    sampleTimes=arrayfun(@(e)string(e.sampleTime),ports);
    set_param(blockPath,'PortSampleTimes',sampleTimes);
end
