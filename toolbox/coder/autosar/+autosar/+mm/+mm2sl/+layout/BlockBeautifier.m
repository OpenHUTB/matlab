



classdef BlockBeautifier



    properties(Constant,Access=private)
        ModelBlockMinWidth=200;
        ModelBlockMinHeigth=100;

        CentralBlocks={'SubSystem','ModelReference'};
        BlocksWithPorts={'VariantSource','VariantSink','Merge'};
        BlocksWithText={'Constant','DataStoreMemory','FunctionCaller','Goto',...
        'From','ArgIn','ArgOut','AsynchronousTaskSpecification'};
        FixedSizeBlocks={'Inport','Outport'};

        TextFontSize=10;
        TextScalingConstant=0.7;
    end

    methods(Static)



        function beautifyBlock(block)
            blockType=get_param(block,'BlockType');

            if any(strcmp(blockType,autosar.mm.mm2sl.layout.BlockBeautifier.CentralBlocks))
                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyCentralBlockSize(block);
            elseif any(strcmp(blockType,autosar.mm.mm2sl.layout.BlockBeautifier.BlocksWithPorts))
                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlockSizeUsingPort(block);
            elseif any(strcmp(blockType,autosar.mm.mm2sl.layout.BlockBeautifier.BlocksWithText))
                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlockSizeUsingText(block);
                set_param(block,'ShowName','off');
            elseif any(strcmp(blockType,autosar.mm.mm2sl.layout.BlockBeautifier.FixedSizeBlocks))
                autosar.mm.mm2sl.layout.BlockBeautifier.beautifyBlockSizeUsingType(block);
            end

        end

    end

    methods(Access='private',Static)



        function beautifyCentralBlockSize(block)
            block=getfullname(block);
            blockType=get_param(block,'BlockType');
            switch(blockType)
            case 'ModelReference'
                sysName=get_param(block,'ModelName');
                if~bdIsLoaded(sysName)
                    load_system(sysName);
                end
            case 'SubSystem'
                sysName=block;
            otherwise
                assert(false,'only ModelBlock and SubSystem types are supported.');
            end

            inports=find_system(sysName,'SearchDepth',1,'BlockType','Inport');
            outports=find_system(sysName,'SearchDepth',1,'BlockType','Outport');
            maxInpName=0;
            maxOutpName=0;
            functionCallInports={};




            inportPortNames=cellfun(@(x)get_param(x,'PortName'),inports,'UniformOutput',false);
            for ii=1:numel(inportPortNames)
                blkName=inportPortNames{ii};
                maxInpName=max(maxInpName,length(blkName));
                if strcmp(get_param(inports{ii},'OutputFunctionCall'),'on')
                    functionCallInports=[functionCallInports;blkName];%#ok<AGROW>
                end
            end

            outportPortNames=cellfun(@(x)get_param(x,'PortName'),outports,'UniformOutput',false);
            for ii=1:numel(outportPortNames)
                blkName=outportPortNames{ii};
                maxOutpName=max(maxOutpName,length(blkName));
            end

            if strcmp(get_param(bdroot(block),'SimulinkSubDomain'),'AUTOSARArchitecture')
                numInports=numel(unique(setdiff(inportPortNames,functionCallInports)));
                numOutports=numel(unique(outportPortNames));
            else
                numInports=numel(inportPortNames);
                numOutports=numel(outportPortNames);
            end

            currentPosition=get_param(block,'Position');


            x=currentPosition(1);
            y=currentPosition(2);


            if y>32000
                x=x+150;
                y=33;
            end

            simFunPrototypeLen=0;
            simFunVisibilityLen=0;


            triggerPort=find_system(block,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType','TriggerPort');
            if~isempty(triggerPort)
                triggerPort=triggerPort{1};
                isSimFunc=get_param(triggerPort,'IsSimulinkFunction');
                if strcmp(isSimFunc,'on')
                    funcPrototype=get_param(triggerPort,'FunctionPrototype');
                    simFunPrototypeLen=length(funcPrototype);
                    funVisibilityText=get_param(triggerPort,'FunctionVisibility');




                    if strcmp(funVisibilityText,'global')



                        if(numel(inports)>1)&&(numel(outports)>1)




                            simFunVisibilityLen=15;
                        elseif(numel(inports)>1)||(numel(outports)>1)
                            simFunVisibilityLen=30;
                        end
                    end
                end
            end


            fontSize=autosar.mm.mm2sl.layout.BlockBeautifier.TextFontSize;
            textLength=max(simFunPrototypeLen,maxInpName+maxOutpName+simFunVisibilityLen);
            w=0.6*fontSize*textLength;
            h=(max(numInports,numOutports)+1)*35+30;


            w=max(w,autosar.mm.mm2sl.layout.BlockBeautifier.ModelBlockMinWidth);
            h=max(h,autosar.mm.mm2sl.layout.BlockBeautifier.ModelBlockMinHeigth);


            autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(block,[x,y,x+w,y+h]);
        end



        function beautifyBlockSizeUsingPort(block)
            blockType=get_param(block,'BlockType');
            currentPos=get_param(block,'Position');
            switch(blockType)
            case{'VariantSource','VariantSink'}
                ports=get_param(block,'Ports');
                numPorts=max(ports(1:2));
                h=20*numPorts;
                newPos=[currentPos(1),currentPos(2),currentPos(1)+30,currentPos(2)+h];
            case 'Merge'
                ports=get_param(block,'Ports');
                numPorts=max(ports(1:2));
                h=20*numPorts;
                newPos=[currentPos(1),currentPos(2),currentPos(1)+40,currentPos(2)+h];
            otherwise
                assert(false,['Block ',blockType,' not supported for port based beautification']);
            end
            autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(block,newPos);



            set_param(block,'ShowName','off');
        end



        function beautifyBlockSizeUsingText(block)
            fontSize=autosar.mm.mm2sl.layout.BlockBeautifier.TextFontSize;
            scalingConstant=autosar.mm.mm2sl.layout.BlockBeautifier.TextScalingConstant;

            blockType=get_param(block,'BlockType');
            currentPos=get_param(block,'Position');
            switch(blockType)
            case 'Constant'
                text=get_param(block,'Value');
                w=max(30,scalingConstant*fontSize*length(text));
                newPos=[currentPos(1),currentPos(2),currentPos(1)+w,currentPos(2)+30];
            case 'FunctionCaller'
                if isfield(get_param(block,'DialogParameters'),'ServiceImpl')

                    newPos=[currentPos(1),currentPos(2),currentPos(1)+80,currentPos(2)+51];
                else
                    text=get_param(block,'FunctionPrototype');




                    section1=strsplit(text,'=');
                    if length(section1)>1
                        returnValue=section1{1};
                    else
                        returnValue='';
                    end
                    section2=strsplit(section1{end},'(');
                    if length(section2)>1
                        functionName=section2{1};
                        argument=section2{2};
                    else
                        functionName='';
                        argument='';
                    end





                    textLength=length(functionName)+max(length(returnValue),length(argument));
                    if autosar.blocks.InternalTriggerBlock.isInternalTriggerBlock(block)
                        textLength=textLength+length(autosar.blocks.InternalTriggerBlock.MaskDisplayTextPrefix);
                    end
                    w=max(32,scalingConstant*fontSize*textLength);
                    newPos=[currentPos(1),currentPos(2),currentPos(1)+w,currentPos(2)+40];
                end
            case 'DataStoreMemory'
                text=get_param(block,'DataStoreName');
                w=max(32,scalingConstant*fontSize*(length(text)));
                newPos=[currentPos(1),currentPos(2),currentPos(1)+w,currentPos(2)+30];
            case{'Goto','From'}
                text=get_param(block,'GoToTag');

                w=10+(6*length(text));
                w=(ceil(w/5)+1)*5;
                newPos=[currentPos(1),currentPos(2),currentPos(1)+w,currentPos(2)+13];
            case{'ArgIn','ArgOut'}
                text=get_param(block,'ArgumentName');
                w=max(40,scalingConstant*fontSize*length(text));
                newPos=[currentPos(1),currentPos(2),currentPos(1)+w+10,currentPos(2)+20];
            case 'AsynchronousTaskSpecification'
                newPos=[currentPos(1),currentPos(2),currentPos(1)+40,currentPos(2)+20];
            otherwise
                assert(false,['Block ',blockType,' not supported for text based beautification']);
            end
            autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(block,newPos);
        end





        function beautifyBlockSizeUsingType(block)
            blockType=get_param(block,'BlockType');
            currentPos=get_param(block,'Position');
            switch(blockType)
            case{'Inport','Outport'}
                newPos=[currentPos(1),currentPos(2),currentPos(1)+30,currentPos(2)+13];
            otherwise
                assert(false,['Block ',blockType,' not supported for block beautification']);
            end
            autosar.mm.mm2sl.layout.LayoutHelper.setBlockPosition(block,newPos);
        end

    end

end




