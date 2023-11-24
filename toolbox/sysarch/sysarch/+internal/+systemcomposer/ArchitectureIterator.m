classdef ArchitectureIterator<internal.systemcomposer.HierarchyIterator

    properties
        IncludeArchitecturePorts=false;
        FollowConnectivity=false;
    end

    methods(Static,Access=private)
        function retComps=orderByConnectivity(comps)
            retComps=cell(1,length(comps));

            for k=1:length(comps)

                comps(k).Processed=false;
                comps(k).Visited=true;
            end
            compStack.nodes=cell(1,length(comps));
            compStack.used=0;

            nProc=1;
            for k=1:length(comps)
                thisComp=comps(k);

                if thisComp.Processed
                    continue;
                end


                compStack.used=0;
                compStack=internal.systemcomposer.ArchitectureIterator.visitNode(thisComp,compStack);

                for m=compStack.used:-1:1
                    thisNode=compStack.nodes{m};
                    if thisNode.Visited
                        retComps{nProc}=compStack.nodes{m};
                        nProc=nProc+1;
                    end
                end

            end

            for k=1:length(comps)

                comps(k).Visited=false;
                comps(k).Processed=false;
            end
            retComps=[retComps{:}];
        end

        function compStack=visitNode(thisComp,compStack)
            if thisComp.Processed


                return
            end

            compStack.used=compStack.used+1;
            compStack.nodes{compStack.used}=thisComp;
            thisComp.Processed=true;

            if isa(thisComp,'systemcomposer.arch.BaseComponent')
                compPorts=thisComp.Ports;
                for k=1:length(compPorts)
                    thisPort=compPorts(k);
                    if thisPort.Direction==systemcomposer.arch.PortDirection.Input
                        conn=thisPort.Connectors;
                        for m=1:length(conn)
                            thisConn=conn(m);
                            if isa(thisConn.SourcePort,'systemcomposer.arch.ComponentPort')
                                compStack=internal.systemcomposer.ArchitectureIterator.visitNode(thisConn.SourcePort.Parent,compStack);
                            else
                                assert(isa(thisConn.SourcePort,'systemcomposer.arch.ArchitecturePort'));
                                compStack=internal.systemcomposer.ArchitectureIterator.visitNode(thisConn.SourcePort,compStack);
                            end
                        end
                    end
                end
            elseif isa(thisComp,'systemcomposer.arch.ArchitecturePort')
                if thisComp.Direction==systemcomposer.arch.PortDirection.Output
                    conn=thisComp.Connectors;
                    for m=1:length(conn)
                        thisConn=conn(m);
                        if isa(thisConn.SourcePort,'systemcomposer.arch.ComponentPort')
                            compStack=internal.systemcomposer.ArchitectureIterator.visitNode(thisConn.SourcePort.Parent,compStack);
                        else
                            assert(isa(thisConn.SourcePort,'systemcomposer.arch.ArchitecturePort'));
                            compStack=internal.systemcomposer.ArchitectureIterator.visitNode(thisConn.SourcePort,compStack);
                        end
                    end
                end
            end
        end
    end

    methods(Access=private)
        function b=isComponent(~,elem)
            b=isa(elem,'systemcomposer.arch.BaseComponent');
        end

        function b=isArchitecture(~,elem)
            b=isa(elem,'systemcomposer.arch.Architecture');
        end
        function b=isArchitecturePort(~,elem)
            b=isa(elem,'systemcomposer.arch.ArchitecturePort');
        end

    end
    methods(Access=protected)

        function arch=validateStartNode(this,componentElem)
            arch=componentElem;
            if this.isComponent(componentElem)
                arch=componentElem.Architecture;
            end
            assert(this.isArchitecture(arch),...
            'systemcomposer:iterator:invalidStart',...
            message('SystemArchitecture:Iterators:InvalidBegin').getString);
            if this.FollowConnectivity&&...
                ~(this.Direction==systemcomposer.IteratorDirection.BottomUp||...
                this.Direction==systemcomposer.IteratorDirection.TopDown)

                this.Direction=systemcomposer.IteratorDirection.TopDown;
            end

        end

        function comps=getChildComponents(this,elem)
            comps=[];
            if this.isArchitecturePort(elem)
                return;
            end

            arch=elem;
            assert(this.isArchitecture(elem)||this.isComponent(elem),...
            'systemcomposer:iterator:invalidType',...
            message('SystemArchitecture:Iterators:InvalidType').getString);

            if~this.isArchitecture(elem)
                arch=elem.Architecture;
            end
            comps=arch.Components;
            if this.IncludeArchitecturePorts
                comps=[comps,arch.Ports];
            end
            if this.FollowConnectivity
                comps=this.orderByConnectivity(comps);
            end
        end
    end
end
