function inportHandles=getInportSrcHandles(this)

    subsystemName=this.System;

    hSubsystem=get_param(subsystemName,'handle');
    ul={'TriggerPort','EnablePort','ActionPort'};
    ulh=cellfun(@(x)(find_system(hSubsystem,...
    'SearchDepth',1,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType',x)),...
    ul,'UniformOutput',false);
    if(~isempty([ulh{:}]))
        error(message('HDLLink:SimulinkConnection:UnsupportedSubsysType'));
    end

    iph=find_system(hSubsystem,...
    'SearchDepth',1,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Inport');
    inportHandles=zeros(1,numel(iph));

    for ii=1:numel(iph)
        curH=get_param(iph(ii),'PortHandles');

        inportHandles(ii)=curH.Outport;
    end

end
