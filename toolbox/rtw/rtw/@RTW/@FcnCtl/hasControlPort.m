
function flag=hasControlPort(~,hModel)
    flag=false;

    triggerPortBlk=find_system(hModel,'SearchDepth',1,'BlockType','TriggerPort');
    if~isempty(triggerPortBlk)
        flag=true;
    end

    enablePortBlk=find_system(hModel,'SearchDepth',1,'BlockType','EnablePort');
    if~isempty(enablePortBlk)
        flag=true;
    end
end