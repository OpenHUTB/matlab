function[handles]=getBlockHandles(~,hierarchy)





    handles=getTreeItems(hierarchy);




    function[handles]=getTreeItems(s)
        handles=[];
        for i=1:length(s)
            if isempty(s(i).signals)
                handles=unique([handles,s(i).src]);
            else
                [hdls]=getTreeItems(s(i).signals);
                handles=unique([handles,s(i).src,hdls]);
            end
        end

