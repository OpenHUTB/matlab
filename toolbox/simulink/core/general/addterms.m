function addterms(sys)









    sys=get_param(sys,'Handle');






    b=find_system(sys,'LookUnderMasks','on','MatchFilter',@Simulink.match.allVariants,'SearchDepth',1,'Type','block');
    b=b(b~=sys);




    l=get_param(sys,'Lines');


    isVariantSubSystemBlock=false;
    if strcmp(get_param(sys,'Type'),'block')
        if strcmp(get_param(sys,'BlockType'),'SubSystem')
            if strcmp(get_param(sys,'Variant'),'on')
                isVariantSubSystemBlock=true;
            end
        end
    end






    for i=1:size(b,1)


        if~isVariantSubSystemBlock
            portHandles=get_param(b(i),'PortHandles');


            inputPortHandles=portHandles.Inport;
            triggerPortHandles=portHandles.Trigger;
            enablePortHandles=portHandles.Enable;
            actionPortHandles=portHandles.Ifaction;
            resetPortHandles=portHandles.Reset;
            inputPortHandles=[inputPortHandles,triggerPortHandles,enablePortHandles,actionPortHandles,resetPortHandles];%#ok
            numInputs=size(inputPortHandles,2);

            statePortHandles=portHandles.State;
            outputPortHandles=portHandles.Outport;
            outputPortHandles=[outputPortHandles,statePortHandles];%#ok
            numOutputs=size(outputPortHandles,2);

            for port=1:numInputs
                if~BlockInputIsConnected(b(i),inputPortHandles(port),l)
                    AddGroundToInputPort(b(i),inputPortHandles(port));
                end
            end

            for port=1:numOutputs
                if~BlockOutputIsConnected(b(i),outputPortHandles(port),l)
                    AddTerminatorToOutputPort(b(i),outputPortHandles(port));
                end
            end
        end





        if strcmp(get_param(b(i),'BlockType'),'SubSystem')
            addterms(b(i));
        end

    end










    function connected=BlockInputIsConnected(block,blockPortHandle,lines)

        connected=~isempty(get_param(blockPortHandle,'siggenportname'));
        if connected
            return;
        end

        for i=1:size(lines,1)
            lineInfo=lines(i).Handle;
            line=get_param(blockPortHandle,'Line');






            if isempty(lines(i).Branch)

                if((~isempty(lines(i).DstBlock))&&(lines(i).DstBlock==block)&&...
                    lineInfo==line)
                    connected=1;
                end
            else
                connected=BlockInputIsConnected(block,blockPortHandle,lines(i).Branch);
            end

            if connected
                break;
            end
        end









        function AddGroundToInputPort(block,portHandle)




            sys=get_param(block,'Parent');





            portPos=get_param(portHandle,'Position');





            position=[0,0,10,10];





            Port=GetPortLocation(block,portPos,'input');




            DefOrient=get_param(block,'Orientation');

            switch get_param(block,'Orientation')

            case 'left'
                if Port.Down
                    DefOrient='up';
                end
                position(1)=position(1)+portPos(1)+5-15*Port.Down;
                position(2)=position(2)+portPos(2)-10+15*Port.Down;
                position(3)=position(3)+portPos(1)+15-15*Port.Down;
                position(4)=position(4)+portPos(2)-0+15*Port.Down;

            case 'right'
                if Port.Top
                    DefOrient='down';
                end
                position(1)=position(1)+portPos(1)-30+15*Port.Top;
                position(2)=position(2)+portPos(2)-10-15*Port.Top;
                position(3)=position(3)+portPos(1)-20+15*Port.Top;
                position(4)=position(4)+portPos(2)-0-15*Port.Top;

            case 'up'
                if Port.Left
                    DefOrient='right';
                end
                position(1)=position(1)+portPos(1)-10-15*Port.Left;
                position(2)=position(2)+portPos(2)+0-15*Port.Left;
                position(3)=position(3)+portPos(1)-0-15*Port.Left;
                position(4)=position(4)+portPos(2)+10-15*Port.Left;

            case 'down'
                if Port.Right
                    DefOrient='left';
                end
                position(1)=position(1)+portPos(1)-10+15*Port.Right;
                position(2)=position(2)+portPos(2)-20+15*Port.Right;
                position(3)=position(3)+portPos(1)-0+15*Port.Right;
                position(4)=position(4)+portPos(2)-10+15*Port.Right;

            end



            numGrounds=size(find_system(sys,'LookUnderMasks','on','SearchDepth',1,'BlockType','Ground'),1);
            blocknumber=numGrounds+1;
            ground=sprintf('Ground_%d',blocknumber);

            while~isempty(find_system(sys,'LookUnderMasks','on','SearchDepth',1,'Name',ground))


                blocknumber=blocknumber+1;
                ground=sprintf('Ground_%d',blocknumber);
            end


            [isBus,dataTypeStr,portDimsStr]=isBlockUsingBusType(block,portHandle);






            groundParams={'Position',position,'ShowName','off','Orientation',DefOrient};
            if isBus
                portDims=str2double(portDimsStr);
                isBusArray=prod(portDims)>1;
                if isBusArray

                    if(max(size(portDims))==1)
                        constValueStr=mat2str(zeros(portDims,1));
                    else
                        constValueStr=['zeros(',portDimsStr,')'];
                    end
                    add_block('simulink/Sources/Constant',[sys,'/',ground],...
                    groundParams{:},...
                    'Value',constValueStr,...
                    'OutDataTypeStr',dataTypeStr);
                    GroundPortHandles=get_param([sys,'/',ground],'PortHandles');
                else

                    groundH=add_block('simulink/Sources/Ground',[sys,'/',ground],groundParams{:});
                    Simulink.BlockDiagram.createSubSystem(groundH);
                    subSysH=get_param(get_param(groundH,'Parent'),'Handle');
                    set_param(subSysH,groundParams{:},'Name',get_param(groundH,'Name'));
                    outportH=find_system(subSysH,'LookUnderMasks','on','SearchDepth',1,'BlockType','Outport');
                    assert(length(outportH)==1,'%s should contain one outport from createSubsystem API!',getfullname(subSysH));
                    set_param(outportH,'OutDataTypeStr',dataTypeStr,'PortDimensions',portDimsStr);
                    GroundPortHandles=get_param(subSysH,'PortHandles');
                end
            else

                add_block('built-in/Ground',[sys,'/',ground],groundParams{:});
                GroundPortHandles=get_param([sys,'/',ground],'PortHandles');
            end

            GroundPortPos=get_param(GroundPortHandles.Outport,'Position');
            add_line(sys,[GroundPortPos;portPos]);









            function[isBus,dataTypeStr,portDimsStr]=isBlockUsingBusType(block,portHandle)
                isBus=false;
                dataTypeStr='';
                portDimsStr='';


                blockType=get_param(block,'BlockType');
                if any(strcmp(blockType,{'Outport','ArgOut','ModelReference','SignalInvalidation'}))


                    dstBlock='';
                    if strcmp(blockType,'ModelReference')
                        isProtected=strcmp(get_param(block,'ProtectedModel'),'on');
                        if~isProtected
                            refModel=get_param(block,'ModelName');
                            if~bdIsLoaded(refModel)
                                load_system(refModel);
                            end
                            inportBlock=find_system(refModel,'LookUnderMasks','on','SearchDepth',1,'BlockType','Inport',...
                            'Port',num2str(get_param(portHandle,'PortNumber')));
                            if isempty(inportBlock)


                            else
                                dstBlock=inportBlock{1};
                            end
                        end
                    elseif strcmp(blockType,'SignalInvalidation')


                        if(get_param(portHandle,'PortNumber')==1)
                            lh=get_param(block,'LineHandles');
                            if(lh.Outport~=-1)
                                dstBlockH=get_param(lh.Outport,'DstBlockHandle');
                                if isscalar(dstBlockH)&&(dstBlockH~=-1)&&...
                                    strcmp(get_param(dstBlockH,'BlockType'),'Outport')
                                    dstBlock=dstBlockH;
                                end
                            end
                        end
                    else
                        dstBlock=block;
                    end

                    if~isempty(dstBlock)



                        isBusElementPort=any(strcmp(get_param(dstBlock,'BlockType'),{'Inport','Outport'}))&&...
                        strcmp(get_param(dstBlock,'IsBusElementPort'),'on');
                        dataTypeStr=get_param(dstBlock,'OutDataTypeStr');
                        isBus=strncmp(dataTypeStr,'Bus: ',5)&&~isBusElementPort;
                        portDimsStr=get_param(dstBlock,'PortDimensions');
                    end
                end








                function connected=BlockOutputIsConnected(block,blockPortHandle,lines)
                    connected=0;
                    for i=1:size(lines,1)
                        lineInfo=lines(i).Handle;
                        line=get_param(blockPortHandle,'Line');







                        if((~isempty(lines(i).SrcBlock))&&(lines(i).SrcBlock==block)&&...
                            isequal(line,lineInfo))
                            connected=1;
                        end
                    end









                    function AddTerminatorToOutputPort(block,portHandle)




                        sys=get_param(block,'Parent');





                        portPos=get_param(portHandle,'Position');





                        Port=GetPortLocation(block,portPos,'output');





                        position=[0,0,10,10];




                        DefOrient=get_param(block,'Orientation');
                        switch get_param(block,'Orientation')

                        case 'left'
                            if Port.Down
                                DefOrient='down';
                            end
                            position(1)=position(1)+portPos(1)-30+15*Port.Down;
                            position(2)=position(2)+portPos(2)-10+15*Port.Down;
                            position(3)=position(3)+portPos(1)-25+15*Port.Down;
                            position(4)=position(4)+portPos(2)-0+15*Port.Down;

                        case 'right'
                            if Port.Top
                                DefOrient='up';
                            end
                            position(1)=position(1)+portPos(1)+15-15*Port.Top;
                            position(2)=position(2)+portPos(2)-10-15*Port.Top;
                            position(3)=position(3)+portPos(1)+20-15*Port.Top;
                            position(4)=position(4)+portPos(2)-0-15*Port.Top;

                        case 'up'
                            if Port.Left
                                DefOrient='left';
                            end
                            position(1)=position(1)+portPos(1)-10-15*Port.Left;
                            position(2)=position(2)+portPos(2)-30+15*Port.Left;
                            position(3)=position(3)+portPos(1)-0-15*Port.Left;
                            position(4)=position(4)+portPos(2)-25+15*Port.Left;

                        case 'down'
                            if Port.Right
                                DefOrient='right';
                            end
                            position(1)=position(1)+portPos(1)-10+15*Port.Right;
                            position(2)=position(2)+portPos(2)+15-15*Port.Right;
                            position(3)=position(3)+portPos(1)-0+15*Port.Right;
                            position(4)=position(4)+portPos(2)+20-15*Port.Right;

                        end

                        numTerms=size(find_system(sys,'LookUnderMasks','on','SearchDepth',1,'BlockType','Terminator'),1);
                        blocknumber=numTerms+1;
                        term=sprintf('Terminator_%d',blocknumber);

                        while~isempty(find_system(sys,'LookUnderMasks','on','SearchDepth',1,'Name',term))


                            blocknumber=blocknumber+1;
                            term=sprintf('Terminator_%d',blocknumber);
                        end

                        add_block('built-in/Terminator',[sys,'/',term],...
                        'Position',position,...
                        'ShowName','off',...
                        'Orientation',DefOrient);


                        TermPortHandles=get_param([sys,'/',term],'PortHandles');
                        TermPortPos=get_param(TermPortHandles.Inport,'Position');

                        add_line(sys,[portPos;TermPortPos]);



                        function Port=GetPortLocation(block,portPos,side)



                            BlockPos=get_param(block,'Position');

                            if strcmp(side,'input')
                                offset=5;
                            else
                                offset=-5;
                                BlockPos=BlockPos([3,4,1,2]);
                            end

                            if(BlockPos(1)==(portPos(1)+offset))
                                Port.Top=0;
                            else
                                Port.Top=1;
                            end
                            if(BlockPos(2)==(portPos(2)+offset))
                                Port.Right=0;
                            else
                                Port.Right=1;
                            end
                            if(BlockPos(3)==(portPos(1)-offset))
                                Port.Down=0;
                            else
                                Port.Down=1;
                            end
                            if(BlockPos(4)==(portPos(2)-offset))
                                Port.Left=0;
                            else
                                Port.Left=1;
                            end



