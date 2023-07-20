
classdef SkeletonModelBeautifier<handle






    properties(Constant,Access=private)
        VerticalGapBetweenRelatedPortBlocks=30;
        VerticalGapBetweenNonRelatedPortBlocks=60;
        InportBlockStartingPosition=[100,35,110,45];
        OutportBlockStartingPosition=[440,35,450,45];
        AreaBoxPosition=[-145,-30,345,70];
        RelHyperlinkPosition=[5,70,200,-30];
    end

    methods(Static)
        function beautifyModel(model)



            import autosar.mm.mm2sl.layout.SkeletonModelBeautifier


            model=get_param(model,'handle');
            options=Simulink.FindOptions('SearchDepth',1);
            inportBlocks=Simulink.findBlocks(model,'BlockType','Inport','OutputFunctionCall','off',options);
            outportBlocks=Simulink.findBlocks(model,'BlockType','Outport',options);



            inportBlocks=SkeletonModelBeautifier.sortAccordingToPortNumber(inportBlocks);
            outportBlocks=SkeletonModelBeautifier.sortAccordingToPortNumber(outportBlocks);


            SkeletonModelBeautifier.stackPortBlocksVertically(...
            inportBlocks,...
            SkeletonModelBeautifier.InportBlockStartingPosition);


            SkeletonModelBeautifier.stackPortBlocksVertically(...
            outportBlocks,...
            SkeletonModelBeautifier.OutportBlockStartingPosition);


            SkeletonModelBeautifier.addAreaBoxWithHyperlink(model);


            addterms(model);
        end
    end

    methods(Static,Access='private')
        function stackPortBlocksVertically(portBlocks,firstBlockPosition)
            import autosar.mm.mm2sl.layout.SkeletonModelBeautifier

            lastBlockPosition=firstBlockPosition;
            for i=1:length(portBlocks)



                verticalGap=SkeletonModelBeautifier.VerticalGapBetweenNonRelatedPortBlocks;
                if((i>1)&&strcmp(get_param(portBlocks(i-1),'PortName'),...
                    get_param(portBlocks(i),'PortName')))
                    verticalGap=SkeletonModelBeautifier.VerticalGapBetweenRelatedPortBlocks;
                end
                lastBlockPosition(2)=lastBlockPosition(2)+verticalGap;
                lastBlockPosition(4)=lastBlockPosition(4)+verticalGap;
                set_param(portBlocks(i),'Position',lastBlockPosition);
            end
        end

        function blocks=sortAccordingToPortNumber(blocks)
            portNumbers=str2double(get_param(blocks,'Port'));
            [~,sortIndex]=sort(portNumbers);
            blocks=blocks(sortIndex);
        end

        function addAreaBoxWithHyperlink(model)
            import autosar.mm.mm2sl.layout.SkeletonModelBeautifier

            modelName=get_param(model,'Name');
            add_block('built-in/Area',[modelName,'/',DAStudio.message('autosarstandard:editor:SkeletonModelAreaText')],...
            'Position',SkeletonModelBeautifier.AreaBoxPosition,...
            'FontSize','16','BackgroundColor','White');

            absHyperlinkPosition=SkeletonModelBeautifier.AreaBoxPosition+SkeletonModelBeautifier.RelHyperlinkPosition;
            Simulink.Annotation([modelName,'/',DAStudio.message('autosarstandard:editor:SkeletonModelAreaHyperlinkText')],...
            'Position',absHyperlinkPosition,...
            'FontSize','16',...
            'ClickFcn','helpview([docroot ''/autosar/helptargets.map''], ''autosar_model_reentrancy'');');
        end
    end
end


