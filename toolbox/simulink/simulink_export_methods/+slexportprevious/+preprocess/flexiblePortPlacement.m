function flexiblePortPlacement(obj)









    if~isR2019bOrEarlier(obj.ver)
        return;
    end










    assert(slfeature('EquallySpacingBetweenPorts')==0)



    blocksThatUseFPP=find_system(obj.modelName,...
    'RegExp','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'IncludeCommented','on',...
    'BlockType','^(SubSystem|ModelReference)$',...
    'PortSchema','\S'...
    );














    refBlock=get_param(blocksThatUseFPP,'ReferenceBlock');
    hasRefBlock=cellfun(@(r)~isempty(r),refBlock);
    blocksThatUseFPP(hasRefBlock)=[];



    if~isR2018bOrEarlier(obj.ver)











        if Simulink.internal.isArchitectureModel(get_param(obj.modelName,'Handle'))
            return;
        end






        socLibraries={...
'hwlogicconnlib'...
        ,'hwlogictestlib'...
        ,'prociodatalib'...
        ,'prociolib'...
        ,'proclib_internal'...
        ,'socmemlib'...
        ,'socsharedlib_internal'...
        };

        ancestorBlock=get_param(blocksThatUseFPP,'AncestorBlock');

        blockLib=strtok(ancestorBlock,'/');

        isSocBlock=cellfun(@(lib)any(strcmp(lib,socLibraries)),blockLib);

        blocksThatUseFPP(isSocBlock)=[];
    end


    if~isempty(blocksThatUseFPP)





        cellfun(@(b)set_param(b,'PortSchema',''),blocksThatUseFPP);



        lhStruct=get_param(blocksThatUseFPP,'LineHandles');
        lh=struct2array(cell2mat(lhStruct));
        lh=unique(lh);




        lh=lh(lh~=-1);

        Simulink.BlockDiagram.routeLine(lh);
    end

end




