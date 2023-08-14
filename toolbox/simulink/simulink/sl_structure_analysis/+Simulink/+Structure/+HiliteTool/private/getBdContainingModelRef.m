




function[parentBDs,refBlks]=getBdContainingModelRef(BD)

    import Simulink.Structure.HiliteTool.internal.*

    parentBDs=[];
    refBlks=[];

    if(~isempty(BD)&&BD~=-1)



        refBlkNames=find_system('MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','ModelReference','ModelName',get_param(BD,'name'));

        if(~isempty(refBlkNames))
            nRefBlks=length(refBlkNames);
            refBlks=zeros(nRefBlks,1);
            parentBDs=zeros(nRefBlks,1);

            for j=1:nRefBlks
                refBlks(j)=get_param(refBlkNames{j},'handle');
                parentBDs(j)=getBlockDiagram(refBlks(j));
            end
        end
    end

end