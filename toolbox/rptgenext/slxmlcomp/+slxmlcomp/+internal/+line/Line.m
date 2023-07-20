classdef Line<handle





    properties(GetAccess=public,SetAccess=private)
        Handle;
        Points;
        SrcBlockName;
        SrcBlockSID;
        SrcPortNumber;
        SrcPortNumberStr;
        DstBlockName;
        DstBlockSID;
        DstPortNumber;
        DstPortNumberStr;
        Parent;
        Children;
        ZOrder;
    end


    methods

        function obj=Line(lineHandle)
            obj.Handle=lineHandle;
        end


        function blockName=get.SrcBlockName(obj)
            blockName=obj.getBlockName('Src');
        end

        function blockName=get.DstBlockName(obj)
            blockName=obj.getBlockName('Dst');
        end

        function blockSID=get.SrcBlockSID(obj)
            blockSID=obj.getBlockSID('Src');
        end

        function blockSID=get.DstBlockSID(obj)
            blockSID=obj.getBlockSID('Dst');
        end

        function points=get.Points(obj)



            points='[';
            pts=get_param(obj.Handle,'Points');
            pts=pts';
            startIndex=1;
            endIndex=numel(pts);
            parent=get_param(obj.Handle,'LineParent');
            if(get_param(obj.Handle,'SrcBlockHandle')~=-1)||...
                (parent~=-1&&get_param(parent,'SrcBlockHandle')==-1)
                startIndex=3;
            end
            dstBlocks=get_param(obj.Handle,'DstBlockHandle');
            if(numel(dstBlocks)==1)&&(dstBlocks~=-1)
                endIndex=numel(pts)-2;
            end
            if startIndex>endIndex
                points='';
                return
            end
            for i=startIndex:2:endIndex-1
                if i==1
                    points=[points,num2str(pts(i)),', ',num2str(pts(i+1)),'; '];%#ok<AGROW>
                else
                    points=[points,num2str(pts(i)-pts(max(i-2,1))),', ',num2str(pts(i+1)-pts(max(i-1,1))),'; '];%#ok<AGROW>
                end
            end
            points=points(1:end-2);
            points=[points,']'];
        end

        function parent=get.Parent(obj)
            parentHandle=get_param(obj.Handle,'LineParent');
            if parentHandle<0
                parent=slxmlcomp.internal.line.Line.empty(1,0);
            else
                parent=slxmlcomp.internal.line.Line(parentHandle);
            end
        end

        function children=get.Children(obj)
            children=slxmlcomp.internal.line.Line.empty(1,0);
            childHandles=get_param(obj.Handle,'LineChildren');
            for ii=1:numel(childHandles)
                child=slxmlcomp.internal.line.Line(childHandles(ii));
                children=[children;child];%#ok<AGROW>
            end
        end

        function portNumber=get.SrcPortNumber(obj)
            portNumber=obj.getPortNumber('Src');
        end

        function portNumber=get.SrcPortNumberStr(obj)
            portNumber=num2str(obj.getPortNumber('Src'));
        end

        function portNumber=get.DstPortNumber(obj)
            portNumber=obj.getPortNumber('Dst');
        end

        function portNumber=get.DstPortNumberStr(obj)
            portNumber=num2str(obj.getPortNumber('Dst'));
        end

        function equals=isequal(obj,other)
            equals=isa(other,'slxmlcomp.internal.line.Line')&&...
            isequal(obj.Handle,other.Handle);
        end

        function zOrder=get.ZOrder(obj)
            zOrder=get_param(obj.Handle,'zOrder');
        end

    end


    methods(Access=public)

        function hasParent=hasParent(obj)
            hasParent=~isempty(obj.Parent);
        end

        function hasChildren=hasChildren(obj)
            hasChildren=~isempty(obj.Children);
        end

    end


    methods(Access=private)

        function blockName=getBlockName(obj,srcOrDst)
            blockName=obj.getConnectedBlockParameter(srcOrDst,'Name');
        end

        function blockSID=getBlockSID(obj,srcOrDst)
            blockSID=obj.getConnectedBlockParameter(srcOrDst,'SID');
        end

        function value=getConnectedBlockParameter(obj,srcOrDst,parameterName)
            value='';
            blockHandle=get_param(obj.Handle,[srcOrDst,'BlockHandle']);
            if numel(blockHandle)==1&&ishandle(blockHandle)
                value=get_param(blockHandle,parameterName);
            end
        end

        function portNumber=getPortNumber(obj,srcOrDst)
            portNumber='';
            portHandle=get_param(obj.Handle,[srcOrDst,'PortHandle']);
            if numel(portHandle)==1&&ishandle(portHandle)
                switch get_param(portHandle,'PortType')
                case{'inport','outport'}
                    portNumber=get_param(portHandle,'PortNumber');
                otherwise
                    portNumber=get_param(portHandle,'PortType');
                end
            end
        end

    end

end
