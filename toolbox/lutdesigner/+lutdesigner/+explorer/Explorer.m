classdef Explorer<lutdesigner.service.RemotableObject




    properties(Access=private)
LookupTableFinder
        RootAccesses(:,1)cell={}
        FocusAccess(:,1)cell={}
    end

    methods
        function this=Explorer(lutFinder)
            this.LookupTableFinder=lutFinder;
        end

        function refresh(this)
            this.RootAccesses(cellfun(@(a)~isAvailable(a),this.RootAccesses))=[];
            if isscalar(this.FocusAccess)
                if~(this.FocusAccess{1}.isAvailable()&&any(cellfun(@(a)a.contains(this.FocusAccess{1}),this.RootAccesses)))
                    this.FocusAccess={};
                end
            end
        end

        function clearProjectRootAccesses(this)
            this.refresh();

            this.RootAccesses={};

        end

        function rootAccessesChange=addAccessToProject(this,accessDesc)
            this.refresh();

            import lutdesigner.access.Access
            access=Access.fromDesc(accessDesc);
            assert(access.isAvailable());

            rootAccessesChange=struct;
            if any(cellfun(@(ra)contains(ra,access),this.RootAccesses))
                return;
            end
            subAccessIndex=find(cellfun(@(ra)access.contains(ra),this.RootAccesses));
            if isempty(subAccessIndex)
                this.RootAccesses{end+1}=access;
                rootAccessesChange.addedAccess=access.toDesc();
            else
                rootAccessesChange.replacedAccess=struct(...
                'old',this.RootAccesses{subAccessIndex(1)}.toDesc(),...
                'new',access.toDesc());
                this.RootAccesses{subAccessIndex(1)}=access;
                if numel(subAccessIndex)>1
                    rootAccessesChange.removedAccesses=Access.createDescArray([0,1]);
                    for i=2:numel(subAccessIndex)
                        rootAccessesChange.removedAccesses(end+1,1)=this.RootAccesses{subAccessIndex(i)}.toDesc();
                    end
                    this.RootAccesses(subAccessIndex(2:end))=[];
                end
            end
        end

        function removeRootAccessFromProject(this,accessDesc)
            this.refresh();

            access=lutdesigner.access.Access.fromDesc(accessDesc);

            this.RootAccesses(cellfun(@(ra)isequal(ra,access),this.RootAccesses))=[];
        end

        function tf=isAccessOpened(this,accessDesc)
            this.refresh();

            access=lutdesigner.access.Access.fromDesc(accessDesc);

            tf=access.isAvailable();
            if tf
                tf=tf&&any(cellfun(@(ra)contains(ra,access),this.RootAccesses));
            end
        end

        function rootAccessDescs=getProjectRootAccessDescs(this)
            this.refresh();

            rootAccessDescs=cellfun(@(access)toDesc(access),this.RootAccesses);
            if isempty(rootAccessDescs)
                rootAccessDescs=lutdesigner.access.Access.createDescArray([0,1]);
            end
        end

        function subAccessDescs=getSubAccessDescs(~,parentAccessDesc)
            parentAccess=lutdesigner.access.Access.fromDesc(parentAccessDesc);
            assert(parentAccess.isAvailable());
            subAccessDescs=parentAccess.getSubAccessDescs();
        end

        function accessDesc=getReferencedAccessDesc(~,refAccessDesc)
            refAccess=lutdesigner.access.Access.fromDesc(refAccessDesc);
            switch refAccess.Type
            case 'modelBlock'
                referencedSystem=get_param(refAccess.Path,'ModelName');
            case 'subsystemReference'
                referencedSystem=get_param(refAccess.Path,'ReferencedSubsystem');
            end
            load_system(referencedSystem);
            accessDesc=lutdesigner.access.Access.createDesc('model',referencedSystem);
        end

        function clearFocusAccess(this)
            this.refresh();


            this.FocusAccess={};
        end

        function setFocusAccess(this,accessDesc)
            this.refresh();

            access=lutdesigner.access.Access.fromDesc(accessDesc);
            assert(access.isAvailable());
            this.addAccessToProject(accessDesc);
            this.FocusAccess={access};

        end

        function focusInfo=getFocusInfo(this)
            import lutdesigner.access.Access

            this.refresh();

            focusInfo=struct(...
            'focusAccess',Access.createDescArray([0,0]),...
            'owningRootAccess',Access.createDescArray([0,0])...
            );
            if isscalar(this.FocusAccess)
                rootAccess=this.RootAccesses{cellfun(@(a)a.contains(this.FocusAccess{1}),this.RootAccesses)};
                focusInfo.focusAccess=this.FocusAccess{1}.toDesc();
                focusInfo.owningRootAccess=rootAccess.toDesc();
            end
        end

        function showAccessInSimulink(~,accessDesc)
            access=lutdesigner.access.Access.fromDesc(accessDesc);
            access.show();
        end
    end
end
