classdef(Enumeration)InheritanceFlags<uint8
    enumeration
        NONE(0),
        HANDLE(1),
        MIXINS(2),
        OTHER(4),
        DISABLEIMMEDIATE(8),
        DISABLEALL(16)
    end

    methods(Static)
        function updateEntities=analyzeInheritance(factory,classNames,G,Gdirect,Gindirect)










            showMixins=factory.GlobalSettingsFcn('ShowDetails');
            updateEntities=classNames;
            classdiagram.app.core.InheritanceFlags.resetFlags(...
            factory,classNames,...
            classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE,...
            classdiagram.app.core.InheritanceFlags.DISABLEALL...
            );

            allnodes=table2array(G.Nodes);
            dirnodes=table2array(Gdirect.Nodes);
            indirnodes=table2array(Gindirect.Nodes);



            indegG=indegree(G);



            noedge=allnodes(indegG==0);
            idx=ismember(noedge,classNames);
            noSuper=noedge(idx);
            classdiagram.app.core.InheritanceFlags.setFlags(factory,noSuper,...
            classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE,...
            classdiagram.app.core.InheritanceFlags.DISABLEALL...
            );
            classNames(ismember(classNames,noedge))=[];

            details=[classdiagram.app.core.utils.Constants.Mixins,'handle'];



            mixinsNodeIds=findnode(G,details);
            mixinsNodes=details(mixinsNodeIds>0);
            if~isempty(mixinsNodes)
                flags=classdiagram.app.core.InheritanceFlags.MIXINS;
                if~showMixins
                    flags=bitor(flags,...
                    classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE);
                    flags=bitor(flags,...
                    classdiagram.app.core.InheritanceFlags.DISABLEALL);
                    for mixin=mixinsNodes
                        sNodes=successors(G,mixin);
                        idx=ismember(sNodes,classNames);

                        fromMixins=sNodes(idx);
                        if isempty(fromMixins)
                            continue;
                        end
                        pNodes=classdiagram.app.core.InheritanceFlags.getNodesAllMixinsPredecessors(G,fromMixins,mixinsNodes);
                        classdiagram.app.core.InheritanceFlags.setFlags(factory,...
                        pNodes,flags);
                    end
                end
            end


            indegGindirect=indegree(Gindirect);
            haveIndirSuper=indirnodes(indegGindirect~=0);


            classdiagram.app.core.InheritanceFlags.resetFlags(...
            factory,haveIndirSuper,...
            classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE,...
            classdiagram.app.core.InheritanceFlags.DISABLEALL...
            );
            classNames(ismember(classNames,haveIndirSuper))=[];
            if isempty(classNames)
                return;
            end




            indegGdirect=indegree(Gdirect);
            havedirsuper=dirnodes(indegGdirect~=0);
            if isempty(havedirsuper)
                return;
            end




            for innode=havedirsuper'
                TR=shortestpathtree(G,'all',innode,'OutputForm','cell');
                TR=[TR{:}];
                if~showMixins
                    TR=setdiff(TR,mixinsNodes);
                end
                dirs=findnode(Gdirect,TR);
                if all(dirs~=0)

                    classdiagram.app.core.InheritanceFlags.setFlags(factory,innode,...
                    classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE,...
                    classdiagram.app.core.InheritanceFlags.DISABLEALL...
                    );
                else

                    pNodes=predecessors(G,innode);
                    if~showMixins
                        pNodes=setdiff(pNodes,mixinsNodes);
                    end
                    dirs=findnode(Gdirect,pNodes);
                    if all(dirs~=0)
                        classdiagram.app.core.InheritanceFlags.setFlags(factory,innode,...
                        classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE...
                        );
                    end
                end

            end
        end

        function setFlags(factory,classNames,varargin)
            if isempty(classNames)
                return;
            end
            flags=0;
            for flag=varargin
                flags=bitor(flags,flag{:});
            end
            if iscolumn(classNames)
                classNames=classNames';
            end
            for name=classNames
                pe=factory.getPackageElement(name{1});
                pe.setInheritanceFlags(flags);
            end
        end

        function resetFlags(factory,classNames,varargin)
            if isempty(classNames)
                return;
            end
            flags=0;
            for flag=varargin
                flags=bitor(flags,flag{:});
            end
            if iscolumn(classNames)
                classNames=classNames';
            end
            for name=classNames
                pe=factory.getPackageElement(name{1});
                pe.resetInheritanceFlags(flags);
            end
        end

        function inherits=fromMixins(flags)
            inherits=logical(bitand(flags,...
            (bitor(classdiagram.app.core.InheritanceFlags.HANDLE,...
            classdiagram.app.core.InheritanceFlags.MIXINS))));
        end

        function inherits=fromHandle(flags)
            inherits=logical(bitand(flags,...
            classdiagram.app.core.InheritanceFlags.HANDLE));
        end

        function bool=isMixin(domainObjectOrName)
            if isa(domainObjectOrName,'classdiagram.app.core.domain.Package')
                bool=contains(domainObjectOrName.getName,'.mixin');
                return;
            end
            if isa(domainObjectOrName,'classdiagram.app.core.domain.PackageElement')
                domainObjectOrName=domainObjectOrName.getName;
            end
            bool=any(['handle',classdiagram.app.core.utils.Constants.Mixins]...
            ==domainObjectOrName);
        end

        function initializeInheritanceFlags(pe)
            inheritanceFlags=classdiagram.app.core.InheritanceFlags.NONE;
            if pe.inheritsFromHandle
                inheritanceFlags=bitor(inheritanceFlags,...
                classdiagram.app.core.InheritanceFlags.HANDLE);
            end
            superclassNames=pe.getSuperclassNames;
            if isempty(superclassNames)
                return;
            end
            superclassNames=split(pe.getSuperclassNames,',');
            if any(ismember(superclassNames,classdiagram.app.core.utils.Constants.Mixins))
                inheritanceFlags=bitor(inheritanceFlags,...
                classdiagram.app.core.InheritanceFlags.MIXINS);
            end
            if any(~ismember(superclassNames,['handle',classdiagram.app.core.utils.Constants.Mixins]))
                inheritanceFlags=bitor(inheritanceFlags,...
                classdiagram.app.core.InheritanceFlags.OTHER);
            end
            pe.setInheritanceFlags(inheritanceFlags);
        end

        function nodes=getNodesAllMixinsPredecessors(G,innodes,mixinsNodes)
            nodes=strings(1,0);
            if isempty(innodes)
                return;
            end
            if numel(innodes)>1&&iscolumn(innodes)
                innodes=innodes';
            end
            for innode=innodes
                pNodes=predecessors(G,innode);

                if all(ismember(pNodes,mixinsNodes))
                    nodes(end+1)=innode;
                end

            end
        end
    end
end