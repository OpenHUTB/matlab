classdef SLSignalLine<handle




    properties(SetAccess=private)
        ParentName(1,:)char
        SrcPort(1,:)char
        DstPort(1,:)char
    end

    methods
        function this=SLSignalLine(parentName,srcPort,dstPort)
            this.ParentName=parentName;
            this.SrcPort=srcPort;
            this.DstPort=dstPort;
        end

        function isEq=isEqual(this,other)
            isEq=strcmp(this.ParentName,other.ParentName)&&...
            strcmp(this.SrcPort,other.SrcPort)&&...
            strcmp(this.DstPort,other.DstPort);
        end

        function lineLabel=getLineLabel(this)
            lineLabel=sprintf('%s --> %s',this.SrcPort,this.DstPort);
        end

        function srcPortH=getSrcPortHandle(this)
            srcPortH=-1;
            [srcBlockName,srcPortNum]=strtok(this.SrcPort,'/');


            srcBlks=find_system(this.ParentName,'FirstResultOnly','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Name',srcBlockName);
            if~isempty(srcBlks)
                srcBlockPath=[this.ParentName,'/',srcBlockName];
                srcPortNum=str2double(srcPortNum(2:end));
                lineHandles=get_param(srcBlockPath,'LineHandles');
                srcPortH=lineHandles.Outport(srcPortNum);
            end
        end

        function dstPortH=getDstPortHandle(this)
            dstPortH=-1;
            [dstBlockName,dstPortNum]=strtok(this.DstPort,'/');


            dstBlks=find_system(this.ParentName,'FirstResultOnly','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'Name',dstBlockName);
            if~isempty(dstBlks)
                dstBlockPath=[this.ParentName,'/',dstBlockName];
                dstPortNum=str2double(dstPortNum(2:end));
                lineHandles=get_param(dstBlockPath,'LineHandles');
                dstPortH=lineHandles.Inport(dstPortNum);
            end
        end

        function lineH=getLineHandle(this)

            lineH=this.getDstPortHandle();
        end

        function hiliteLineCmd=getHiliteLineCommand(this)
            [dstBlockName,dstPortNum]=strtok(this.DstPort,'/');
            dstBlockPath=[this.ParentName,'/',dstBlockName];
            dstPortNum=dstPortNum(2:end);
            hiliteLineCmd=sprintf('autosar.composition.mm2sl.SLSignalLine.hiliteLineCB(''%s'', ''%s'');',...
            dstBlockPath,dstPortNum);
        end

        function deleteLine(this)



            dstLineH=this.getLineHandle();
            srcBlockH=get_param(dstLineH,'SrcBlockHandle');
            delete_line(dstLineH);
            if(srcBlockH~=-1)&&any(strcmp(get_param(srcBlockH,'BlockType'),...
                {'From','FunctionCallFeedbackLatch'}))
                delete_block(srcBlockH);
            end
        end



        function retVal=isLoopbackConnection(this)
            srcBlockName=strtok(this.SrcPort,'/');
            dstBlockName=strtok(this.DstPort,'/');
            retVal=strcmp(srcBlockName,dstBlockName);
        end
    end

    methods(Hidden,Static)

        function hiliteLineCB(blockPath,portNum)
            lineHandles=get_param(blockPath,'LineHandles');
            lineH=lineHandles.Inport(str2double(portNum));
            hilite_system(lineH);
        end
    end
end
