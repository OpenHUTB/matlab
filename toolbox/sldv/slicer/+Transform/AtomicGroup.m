




classdef AtomicGroup<handle




    properties

        toChildren=containers.Map('KeyType','double','ValueType','any');

        toParent=containers.Map('KeyType','double','ValueType','any');









        toProtectedChildren=containers.Map('KeyType','double','ValueType','any');

        toProtectedParent=containers.Map('KeyType','double','ValueType','any');


        mdlH;

        mdlBlkH;

        allMdlH;
    end

    methods
        function obj=AtomicGroup(mdl,opts)
            import Transform.*;

            obj.mdlH=get_param(mdl,'Handle');
            if exist('opts','var')
                options=opts;
            else
                options=SlicerConfiguration.getDefaultOptions();
            end


            lumOpt=AtomicGroup.msLookUnderMasks(options);
            fllOpt=AtomicGroup.msFollowLinks(options);
            fssrefOpt=AtomicGroup.msLookInsideSubsystemReference(options);


            [allModelHs,modelBlockHs]=AtomicGroup.searchModelBlocks(obj.mdlH);
            retainH=[];

            if options.InlineOptions.ModelBlocks
                obj.allMdlH=allModelHs;
                obj.mdlBlkH=modelBlockHs;
            else

                obj.allMdlH=obj.mdlH;
            end



            retainH=[retainH;AtomicGroup.getSigBuilders(obj.allMdlH,lumOpt,fllOpt,fssrefOpt)];
            retainH=[retainH;AtomicGroup.getSLDVBlocks(obj.allMdlH,lumOpt,fllOpt,fssrefOpt)];
            retainH=[retainH;AtomicGroup.getSelfModifiableMasks(obj.allMdlH,fllOpt,fssrefOpt)];
            retainH=[retainH;AtomicGroup.getForeachSubsystems(obj.allMdlH,lumOpt,fllOpt,fssrefOpt)];
            retainH=[retainH;AtomicGroup.getStateflow(obj.allMdlH)];
            retainH=[retainH;AtomicGroup.getNoReadOrWriteSystem(obj.allMdlH,lumOpt,fllOpt,fssrefOpt)];

            protectedH=retainH;

            if~options.InlineOptions.Libraries
                retainH=[retainH;AtomicGroup.getLibraries(obj.allMdlH,lumOpt,fssrefOpt)];
            else
                retainH=[retainH;AtomicGroup.getBuiltinLibraries(obj.allMdlH,lumOpt,fssrefOpt)];
            end

            if~options.InlineOptions.Masks
                retainH=[retainH;AtomicGroup.getMasks(obj.allMdlH,fllOpt,fssrefOpt)];
            end

            if~options.InlineOptions.Variants
                retainH=[retainH;AtomicGroup.getVariantSubsystems(obj.allMdlH,lumOpt,fllOpt,fssrefOpt)];
            end

            if~options.InlineOptions.SubsystemReferences
                retainH=[retainH;AtomicGroup.getSubsystemReferences(obj.allMdlH,lumOpt,fllOpt)];
            end
            retainH=unique(retainH);


            createGroupMapping(obj,unique(retainH));


            createProtectedMapping(obj,unique(protectedH));
        end

        function createGroupMapping(obj,retainH)
            [parentKeys,childrenKeys,parentVals,childrenVals]=createMapping(retainH);
            if isempty(parentKeys)
                return;
            elseif numel(parentKeys)>1
                obj.toChildren=containers.Map(parentKeys,childrenVals);
            else

                obj.toChildren=containers.Map(parentKeys,childrenVals{1});
            end
            obj.toParent=containers.Map(childrenKeys,parentVals);
        end

        function createProtectedMapping(obj,protectedH)
            [parentKeys,childrenKeys,parentVals,childrenVals]=createMapping(protectedH);
            if isempty(parentKeys)
                return;
            elseif numel(parentKeys)>1
                obj.toProtectedChildren=containers.Map(parentKeys,childrenVals);
            else

                obj.toProtectedChildren=containers.Map(parentKeys,childrenVals{1});
            end
            obj.toProtectedParent=containers.Map(childrenKeys,parentVals);
        end

        function union(this,that)
            toChildrenkeys=[this.toChildren.keys,that.toChildren.keys];
            toChildrenvaluess=[this.toChildren.values,that.toChildren.values];
            if~isempty(toChildrenkeys)
                this.toChildren=containers.Map(toChildrenkeys,toChildrenvaluess);
            end
            toParentkeys=[this.toParent.keys,that.toParent.keys];
            toParentvalues=[this.toParent.values,that.toParent.values];
            if~isempty(toParentkeys)
                this.toParent=containers.Map(toParentkeys,toParentvalues);
            end
        end

        function h=filterChildren(this,c,options)
            if isempty(this.toParent)
                h=c;
            else
                filt=arrayfun(@(x)~this.toParent.isKey(x),c);
                h=c(filt);
            end
            if~options.InlineOptions.ModelBlocks
                h(bdroot(h)~=this.mdlH)=[];
            end
        end

        function h=filterProtectedChildren(this,c,options)
            if isempty(this.toProtectedParent)
                h=c;
            else
                filt=arrayfun(@(x)~this.toProtectedParent.isKey(x),c);
                h=c(filt);
            end
            if~options.InlineOptions.ModelBlocks
                h(bdroot(h)~=this.mdlH)=[];
            end
        end

        function h=getNVChildren(this,p)
            if~isempty(this.toChildren)
                c=this.toChildren(p);

                if~isempty(c)
                    filt=arrayfun(@(x)hasRTI(x),c);
                    h=c(filt);
                else
                    h=[];
                end
            else
                h=[];
            end
            function yesno=hasRTI(bh)
                try
                    yesno=~isempty(get(bh,'RuntimeObject'));
                catch
                    yesno=false;
                end
            end
        end
    end
    methods(Static)
        function[allMdlH,mdlBlkH]=searchModelBlocks(mdlH)






            [refMdls,mdlBlks]=find_mdlrefs(mdlH,...
            'IncludeProtectedModels',false,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
            refMdlH=[];
            mdlBlkH=[];
            for i=1:length(refMdls)
                if~bdIsLoaded(refMdls{i})
                    load_system(refMdls{i})
                end
                refMdlH(i)=get_param(refMdls{i},'Handle');
            end
            for i=1:length(mdlBlks)
                mdlBlkH(i)=get_param(mdlBlks{i},'Handle');
            end
            allMdlH=unique([mdlH,refMdlH]);
        end

        function sigH=getSigBuilders(mdlH,lumOpt,fllOpt,fssrefOpt)


            sigH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'BlockType','SubSystem','MaskType','Sigbuilder block');
        end
        function blkH=getSLDVBlocks(mdlH,lumOpt,fllOpt,fssrefOpt)


            blkH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'Regexp','on',...
            'BlockType','SubSystem','MaskType',...
            'Design Verifier (Test Objective|Proof Objective|Assumption|Test Condition)');
            vssH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'Regexp','on',...
            'BlockType','SubSystem','MaskType','VerificationSubsystem',...
            'MaskDisplay','image.*');
            blkH=[blkH;vssH];
        end
        function blkH=getSelfModifiableMasks(mdlH,fllOpt,fssrefOpt)


            blkH=find_system(mdlH,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','none',...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'MaskSelfModifiable','on');
        end
        function blkH=getMasks(mdlH,fllOpt,fssrefOpt)


            blkH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','none',...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'Mask','on');
        end
        function blkH=getLibraries(mdlH,lumOpt,fssrefOpt)


            libblks=libinfo(mdlH,'LookUnderMasks',lumOpt,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookInsideSubsystemReference',fssrefOpt);
            tblkH=[];
            for i=1:length(libblks)
                tblkH(i)=get_param(libblks(i).Block,'Handle');
            end
            blkH=tblkH';
        end
        function blkH=getBuiltinLibraries(mdlH,lumOpt,fssrefOpt)


            libblks=libinfo(mdlH,'LookUnderMasks',lumOpt,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookInsideSubsystemReference',fssrefOpt);
            blkH=[];
            for i=1:length(libblks)
                toAdd=false;
                if strcmp(libblks(i).LinkStatus,'resolved')
                    if any(strcmp(libblks(i).Library,{'simulink','simulink_extras','sldvlib'}))
                        toAdd=true;
                    else
                        toolboxPath=fullfile(matlabroot,'toolbox');
                        libPath=which(libblks(i).Library);
                        if strncmp(libPath,toolboxPath,numel(toolboxPath))

                            toAdd=true;
                        end
                    end
                end
                if toAdd
                    blkH=[blkH;get_param(libblks(i).Block,'Handle')];
                end
            end
        end
        function blkH=getVariantSubsystems(mdlH,lumOpt,fllOpt,fssrefOpt)


            blkH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'Variant','on');
        end
        function blkH=getInactiveVariantBlocks(mdlH,lumOpt,fllOpt,fssrefOpt)
            blkH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'IncludeCommented','off',...
            'CompiledIsActive','off');
        end
        function[sourceH,sinkH]=getVariantSourceSinkBlocks(mdlH,lumOpt,fllOpt,fssrefOpt)


            sourceH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'FindAll','on',...
            'BlockType','VariantSource');
            sinkH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'FindAll','on',...
            'BlockType','VariantSink');
        end
        function sysH=getForeachSubsystems(mdlH,lumOpt,fllOpt,fssrefOpt)


            blkH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'FindAll','on',...
            'BlockType','ForEach');
            sysH=zeros(size(blkH));
            for i=1:length(blkH)
                sysH(i)=get_param(get_param(blkH(i),'Parent'),'Handle');
            end
        end
        function sysH=getStateflow(mdlH)
            sysH=[];
            for i=1:length(mdlH)


                allSysH=find_system(mdlH(i),...
                'FindAll','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on',...
                'LookUnderMasks','on',...
                'BlockType','SubSystem');
                if~isempty(allSysH)
                    filt=slprivate('is_stateflow_based_block',allSysH);
                    sysH=[sysH;allSysH(filt)];
                end
            end
        end
        function sysH=getNoReadOrWriteSystem(mdlH,lumOpt,fllOpt,fssrefOpt)


            sysH=find_system(mdlH,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks',lumOpt,...
            'FollowLinks',fllOpt,...
            'LookInsideSubsystemReference',fssrefOpt,...
            'BlockType','SubSystem','Permissions','NoReadOrWrite');
        end

        function sysH=getSubsystemReferences(mdlH,lumOpt,fllOpt)
            sysH=Simulink.findBlocksOfType(mdlH,'SubSystem',...
            'ReferencedSubsystem','.',...
            Simulink.FindOptions('LookUnderMasks',lumOpt,...
            'FollowLinks',strcmpi(fllOpt,'on'),'RegExp',1));
        end

        function out=msLookUnderMasks(opts)
            if opts.InlineOptions.Masks
                out='all';
            else
                out='none';
            end
        end
        function out=msFollowLinks(opts)
            if opts.InlineOptions.Libraries
                out='on';
            else
                out='off';
            end
        end

        function out=msLookInsideSubsystemReference(opts)
            if opts.InlineOptions.SubsystemReferences
                out='on';
            else
                out='off';
            end
        end
    end
end


function[parentKeys,childrenKeys,parentVals,childrenVals]=createMapping(handles)


    childrenKeys=[];
    parentVals=[];
    parentKeys=[];
    childrenVals={};
    findOpts=Simulink.FindOptions('FollowLinks',true);
    for i=1:length(handles)
        if~any(childrenKeys==handles(i))
            try
                children=Simulink.findBlocks(handles(i),findOpts);
                children(children==handles(i))=[];
                if~isempty(children)
                    parentKeys=[parentKeys;handles(i)];%#ok<*AGROW>
                    childrenVals=[childrenVals;children];
                    n=length(children);
                    childrenKeys=[childrenKeys;reshape(children,n,1)];
                    parentVals=[parentVals;repmat(handles(i),n,1)];
                end
            catch Mex %#ok<NASGU>

            end
        end
    end
end
