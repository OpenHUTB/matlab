classdef StudentPortConnectivity<learning.assess.assessments.StudentAssessment




    properties(Constant)
        type='PortConnectivity';
    end

    properties
Block
    end

    properties(Hidden,Access=protected)



        BlockStruct=struct('BlockType','',...
        'ReferenceBlock','',...
        'Connection',[]);
        ConnectionStruct=struct('portType','',...
        'portNumber','','portLabel','');
    end

    methods
        function obj=StudentPortConnectivity(propStruct)
            blockStruct=propStruct.Block;
            if~obj.isBlockStructValid(blockStruct)
                error(message('learning:simulink:resources:InvalidInput'));
            end
            blockStruct=obj.addPortLabelField(blockStruct);
            obj.Block=blockStruct;
        end

        function isCorrect=assess(obj,userModelName)
            isCorrect=false;

            if~obj.isBlockStructValid(obj.Block)
                error(message('learning:simulink:resources:InvalidAssessmentObject'));
            end






            blockIndex=1;
            blockStruct=obj.Block(blockIndex);


            possibleBlockHandles=find_system(userModelName,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType',blockStruct.BlockType,...
            'ReferenceBlock',blockStruct.ReferenceBlock);
            if isempty(possibleBlockHandles)


                if~isempty(obj.Block(blockIndex).ReferenceBlock)
                    learning.assess.throwWarningIfUsingWrongLibrary(userModelName,obj.Block(blockIndex).ReferenceBlock);
                end
                return;
            end




            for i=1:length(possibleBlockHandles)


                if~obj.hasCorrectSelfConnections(possibleBlockHandles(i),blockStruct)
                    continue;
                end




                connectionIndex=1;
                blockConnection=obj.Block(blockIndex).Connection(connectionIndex);
                currentBlockPorts=get_param(possibleBlockHandles(i),'PortHandles');
                if length(currentBlockPorts.(blockConnection.portType))<str2double(blockConnection.portNumber)
                    continue;
                end
                portHandle=currentBlockPorts.(blockConnection.portType)(str2double(blockConnection.portNumber));




                correctBlockConnected=true;
                for j=2:length(obj.Block)
                    currentBlockStruct=obj.Block(j);
                    correctBlockConnected=obj.blockTypeIsConnected(userModelName,currentBlockStruct,portHandle);



                    if~correctBlockConnected
                        break
                    end
                end





                if correctBlockConnected
                    isCorrect=true;
                    break;
                end
            end



            if~isCorrect
                for i=1:length(obj.Block)
                    if~isempty(obj.Block(i).ReferenceBlock)
                        learning.assess.throwWarningIfUsingWrongLibrary(userModelName,obj.Block(i).ReferenceBlock);
                    end
                end
            end
        end

        function correctBlockConnected=blockTypeIsConnected(obj,modelName,blockStruct,portHandle)




            correctBlockConnected=false;




            possibleBlockHandles=find_system(modelName,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'BlockType',blockStruct.BlockType,...
            'ReferenceBlock',blockStruct.ReferenceBlock);


            for i=1:length(possibleBlockHandles)
                connectionIndex=1;
                blockConnection=blockStruct.Connection(connectionIndex);
                currentBlockPorts=get_param(possibleBlockHandles(i),'PortHandles');


                if length(currentBlockPorts.(blockConnection.portType))<str2double(blockConnection.portNumber)
                    continue;
                end
                currentBlockPortHandle=currentBlockPorts.(blockConnection.portType)(str2double(blockConnection.portNumber));
                isInConnection=obj.isInSameConnection(portHandle,currentBlockPortHandle);


                if isInConnection&&obj.hasCorrectSelfConnections(possibleBlockHandles(i),blockStruct)



                    correctBlockConnected=true;
                    return
                end
            end
        end

        function isInConnection=isInSameConnection(~,firstPort,secondPort)


            isInConnection=false;

            if isequal(firstPort,secondPort)
                return;
            end


            firstLine=get_param(firstPort,'Line');
            secondLine=get_param(secondPort,'Line');


            if isequal(firstLine,-1)||isequal(secondLine,-1)
                return
            end


            if isequal(firstLine,secondLine)
                isInConnection=true;
                return;
            end



            m3iFirstLine=SLM3I.SLDomain.handle2DiagramElement(firstLine);
            m3iFirstLineParent=m3iFirstLine.container;
            m3iLineParentSegments=m3iFirstLineParent.segment;
            for i=1:m3iLineParentSegments.size
                currentLineSegment=m3iLineParentSegments.at(i);
                if isequal(currentLineSegment.handle,secondLine)
                    isInConnection=true;
                end
            end
        end

        function hasCorrectSelfConnections=hasCorrectSelfConnections(obj,blockHandle,blockStruct)



            hasCorrectSelfConnections=true;
            hasSelfConnections=length(blockStruct.Connection)>1;
            if hasSelfConnections
                currentBlockSelfConnections=obj.getBlockSelfConnections(blockHandle);



                connections=blockStruct.Connection;
                for j=1:length(connections)


                    if~any(arrayfun(@(x)isequal(x,connections(j)),currentBlockSelfConnections))
                        hasCorrectSelfConnections=false;
                        break;
                    end
                end
            end
        end

        function requirementString=generateRequirementString(obj)
            blockNamesString='';
            for i=1:length(obj.Block)
                for j=1:length(obj.Block(i).Connection)
                    portLabelText=obj.getPortLabelReqText(obj.Block(i).Connection(j).portLabel);
                    blockNamesString=[blockNamesString,newline,'     ',obj.getBlockNameFromStruct(obj.Block(i)),portLabelText];
                end
            end
            requirementString=message('learning:simulink:genericRequirements:portConnectivity',blockNamesString).getString();
        end
    end

    methods(Access=protected,Static)
        function blockConnectionArray=getBlockSelfConnections(blockHandle)



            blockConnectionArray=struct([]);

            isSimscapeBlock=isequal(get_param(blockHandle,'BlockType'),'SimscapeBlock');




            if isSimscapeBlock
                portNumIndex=6;
                inportName='LConn';
                outportName='RConn';
            else
                portNumIndex=1;
                inportName='Inport';
                outportName='Outport';
            end
            ports=get_param(blockHandle,'Ports');
            numInports=ports(portNumIndex);
            blockPorts=get_param(blockHandle,'PortConnectivity');


            inports=blockPorts(1:numInports);
            outports=blockPorts(numInports+1:end);



            for i=1:length(inports)


                isConnected=false;
                for j=1:length(inports(i).SrcBlock)
                    if isequal(inports(i).SrcBlock(j),blockHandle)
                        isConnected=true;
                        break;
                    end
                end
                if isConnected
                    newPortStruct=struct('portType',inportName,...
                    'portNumber',inports(i).Type);
                    blockConnectionArray=[blockConnectionArray,newPortStruct];
                end
            end



            for i=1:length(outports)


                isConnected=false;
                for j=1:length(outports(i).DstBlock)
                    if isequal(outports(i).DstBlock(j),blockHandle)
                        isConnected=true;
                        break;
                    end
                end
                if isConnected
                    newPortStruct=struct('portType',outportName,...
                    'portNumber',outports(i).Type);
                    blockConnectionArray=[blockConnectionArray,newPortStruct];
                end
            end
        end

        function blockName=getBlockNameFromStruct(blockStruct)
            if~isempty(blockStruct.ReferenceBlock)
                fullSimscapePath=blockStruct.ReferenceBlock;
                fullSimscapePath=strsplit(fullSimscapePath,'/');
                blockName=fullSimscapePath{end};
            else
                blockName=learning.assess.getDefaultBlockName(blockStruct.BlockType);
            end
            blockName=strrep(blockName,newline,' ');
        end

        function isValid=isBlockStructValid(blockStruct)
            isValid=true;
            if~isstruct(blockStruct)
                isValid=false;
                return
            end













            for i=1:length(blockStruct)

                isSimscapeBlock=isequal(blockStruct(i).BlockType,'SimscapeBlock');
                if isempty(blockStruct(i).BlockType)||...
                    (isSimscapeBlock&&isempty(blockStruct(i).ReferenceBlock))||...
                    isempty(blockStruct(i).Connection)
                    isValid=false;
                    return
                end


                blockConnection=blockStruct(i).Connection;
                for j=1:length(blockConnection)
                    if isempty(blockConnection(j).portType)||...
                        isempty(blockConnection(j).portNumber)
                        isValid=false;
                        return
                    end
                end
            end
        end

        function portLabelText=getPortLabelReqText(portLabel)


            portLabelText='';
            if~isempty(portLabel)
                portLabelText=[': (',portLabel,')'];
            end
        end

        function finalBlockStruct=addPortLabelField(blockStruct)

            finalBlockStruct=blockStruct;
            for i=1:length(blockStruct)
                for j=1:length(blockStruct(i).Connection)
                    if~isfield(blockStruct(i).Connection(j),'portLabel')
                        finalBlockStruct(i).Connection(j).portLabel='';
                    end
                end
            end
        end
    end
end
