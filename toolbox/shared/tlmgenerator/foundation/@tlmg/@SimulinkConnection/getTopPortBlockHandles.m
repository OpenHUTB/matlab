function[iph,oph]=getTopPortBlockHandles(this)






    iph={};
    oph={};




    inputPortBlks=find_system(this.System,...
    'SearchDepth',1,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Inport');

    outputPortBlks=find_system(this.System,...
    'SearchDepth',1,...
    'FollowLinks','on',...
    'LookUnderMasks','all',...
    'BlockType','Outport');

    for ii=1:numel(inputPortBlks),
        iph{ii}=get_param(inputPortBlks{ii},'porthandles');
    end

    for jj=1:numel(outputPortBlks),
        oph{jj}=get_param(outputPortBlks{jj},'porthandles');
    end

