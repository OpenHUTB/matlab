function getTopPortBlockHandles(this)





    if strcmp(this.ModelName,this.System)


        dutSys=this.System;
    elseif strcmpi(get_param(this.System,'BlockType'),'ModelReference')

        dutSys=get_param(this.System,'ModelName');
        load_system(dutSys);
    else

        dutSys=this.System;
    end


    inputPortBlks=find_system(dutSys,...
    'SearchDepth',1,'LookUnderMasks','all','BlockType','Inport');
    for ii=1:numel(inputPortBlks),
        hP=get_param(inputPortBlks{ii},'porthandles');
        set_param(hP.Outport,'CacheCompiledBusStruct','on');
    end

    outputPortBlks=find_system(dutSys,...
    'SearchDepth',1,'LookUnderMasks','all','BlockType','Outport');
    for ii=1:numel(outputPortBlks),
        hP=get_param(outputPortBlks{ii},'porthandles');
        set_param(hP.Inport,'CacheCompiledBusStruct','on');
    end
end
