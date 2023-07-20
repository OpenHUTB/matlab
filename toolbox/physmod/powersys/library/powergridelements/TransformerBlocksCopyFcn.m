function TransformerBlocksCopyFcn(block,NumberOfInternalModels)
















    IsLibrary=strcmp(get_param(bdroot(block),'BlockDiagramType'),'library');

    for i=1:NumberOfInternalModels

        i_str=num2str(i);


        if~strcmp(get_param([block,'/From',i_str],'BlockType'),'Ground');
            SetNewGotoTag([block,'/From',i_str],IsLibrary);
        end


        if~strcmp(get_param([block,'/I_exc',i_str],'BlockType'),'Ground');
            SetNewGotoTag([block,'/I_exc',i_str],IsLibrary);
        end


        if~strcmp(get_param([block,'/Goto1',i_str],'BlockType'),'Terminator');
            SetNewGotoTag([block,'/Goto1',i_str],IsLibrary);
        end


        if~strcmp(get_param([block,'/Goto2',i_str],'BlockType'),'Terminator');
            SetNewGotoTag([block,'/Goto2',i_str],IsLibrary);
        end
    end