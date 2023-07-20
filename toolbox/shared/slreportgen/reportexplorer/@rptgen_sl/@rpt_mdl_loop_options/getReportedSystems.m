function reportedSystemList=getReportedSystems(this,varargin)





    [currentModel,startingSystems]=locParseInputArgs(this,varargin{:});

    if(isempty(startingSystems)||isempty(currentModel))
        reportedSystemList={};

    else
        switch this.SysLoopType
        case 'current'
            reportedSystemList=startingSystems;

        case 'currentAbove'
            reportedSystemList={};
            for i=1:length(startingSystems)
                reportedSystemList=[reportedSystemList,locGetAncestorsAndSelf(startingSystems{i})];%#ok
            end

        case 'all'
            reportedSystemList=locGetDescendentsAndSelf(this,currentModel);

        otherwise
            reportedSystemList={};
            for i=1:length(startingSystems)
                reportedSystemList=[reportedSystemList,locGetDescendentsAndSelf(this,startingSystems{i})];%#ok
            end
        end

        reportedSystemList=rptgen_sl.filterNonReportableSystem(reportedSystemList);
    end


    function[currentModel,startingSystems]=locParseInputArgs(this,varargin)

        if(nargin<2)
            currentModel=this.RuntimeMdlName;
        else
            currentModel=varargin{1};
        end

        if(nargin<3)
            currentSystem=gcs;
            if~strcmp(bdroot(currentSystem),currentModel)
                currentSystem=currentModel;
            end
        else
            currentSystem=varargin{2};
        end

        if(nargin<4)
            startingSystems=this.MdlCurrSys;
        else
            startingSystems=varargin{3};
        end

        if iscell(startingSystems)
            for i=1:length(startingSystems)
                resolvedSys=locResolveSystem(startingSystems{i},currentModel,currentSystem);
                startingSystems{i}=resolvedSys{1};
            end
        else
            startingSystems=locResolveSystem(startingSystems,currentModel,currentSystem);
        end



        function resolvedSystem=locResolveSystem(unResolvedSystem,model,system)


            parsedUnResolvedSystem=rptgen.parseExpressionText(unResolvedSystem);




            if~strcmp(parsedUnResolvedSystem,unResolvedSystem)

                if~strcmp(bdroot(parsedUnResolvedSystem),model)
                    unResolvedSystem='$current';
                else
                    unResolvedSystem=parsedUnResolvedSystem;
                end

            end


            if(isempty(unResolvedSystem)||isempty(model)||isempty(system))
                resolvedSystem={};
            else
                resolvedSystem=strrep(unResolvedSystem,'$current',system);
                resolvedSystem=strrep(resolvedSystem,'$top',model);
                resolvedSystem=locReplaceCarriageReturnWithSpace(resolvedSystem);

                if ischar(resolvedSystem)
                    resolvedSystem={resolvedSystem};
                end
            end


            function ancestorsAndSelfList=locGetAncestorsAndSelf(system)

                ancestorsAndSelfList={};
                ancestorsAndSelf={system};

                systemParent=get_param(system,'Parent');
                while~isempty(systemParent)
                    ancestorsAndSelf{end+1,1}=systemParent;%#ok
                    systemParent=get_param(systemParent,'Parent');
                end

                ancestorsAndSelf=locReplaceCarriageReturnWithSpace(ancestorsAndSelf);
                ancestorsAndSelfList=[ancestorsAndSelfList;ancestorsAndSelf(:)];
                ancestorsAndSelfList=unique(ancestorsAndSelfList);


                function[maskSwitch,maskFind]=locGetMaskSearchOptions(this)

                    switch this.isMask
                    case 'none'
                        maskSwitch='none';
                        maskFind={'mask','off'};

                    case 'functional'
                        maskSwitch='functional';
                        maskFind={...
                        'MaskHelp','',...
                        'MaskDescription','',...
                        'MaskVariables',''};

                    case{'all','on',true}
                        maskSwitch='all';
                        maskFind={'type','block'};

                    otherwise

                        maskSwitch='graphical';
                        maskFind={...
                        'MaskHelp','',...
                        'MaskDescription','',...
                        'MaskVariables','',...
                        'MaskInitialization',''};
                    end


                    function[libSwitch,libPostProcess]=locGetLibrarySearchOptions(this)

                        switch this.isLibrary
                        case{'on',true}
                            libSwitch='on';
                            libPostProcess=0;

                        case 'unique'
                            libSwitch='on';
                            libPostProcess=1;

                        otherwise
                            libSwitch='off';
                            libPostProcess=-1;
                        end


                        function descendentsAndSelf=locGetDescendentsAndSelf(this,startSystem)

                            [maskSwitch,maskFind]=locGetMaskSearchOptions(this);
                            [libSwitch,libPostProcess]=locGetLibrarySearchOptions(this);


                            findCell={...
                            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                            'LookUnderMasks',maskSwitch,...
                            'FollowLinks',libSwitch,...
                            'blocktype','SubSystem'};

                            descendentsAndSelf=locFindSystem(startSystem,findCell{:},maskFind{:});
                            descendentsAndSelf=union(descendentsAndSelf,startSystem);

                            if(libPostProcess~=0)
                                descendentsAndSelf=locFilterLibraries(descendentsAndSelf,libPostProcess);
                            else

                                descendentsAndSelf=descendentsAndSelf(:);
                            end


                            function uniqueList=locFilterLibraries(allList,actionType)



                                blockList=locFindSystem(allList,...
                                'SearchDepth',0,...
                                'type','block');

                                noLinkBlocks=locFindSystem(blockList,...
                                'SearchDepth',0,...
                                'LinkStatus','none');

                                inactiveLinkBlocks=locFindSystem(blockList,...
                                'SearchDepth',0,...
                                'LinkStatus','inactive');

                                unlinkedBlocks=union(inactiveLinkBlocks,noLinkBlocks);

                                linkedBlocks=setdiff(blockList,unlinkedBlocks);

                                if~isempty(linkedBlocks)
                                    modelList=setdiff(allList,blockList);
                                    if(actionType>0)
                                        refBlocks=rptgen.safeGet(linkedBlocks,'referenceblock','get_param');
                                        [~,uniqIndex]=unique(refBlocks);
                                        uniqLinkedBlocks=linkedBlocks(uniqIndex);
                                        uniqueList=[modelList(:)
                                        unlinkedBlocks(:)
                                        uniqLinkedBlocks(:)];
                                    else
                                        uniqueList=[modelList(:)
                                        unlinkedBlocks(:)];
                                    end
                                else
                                    uniqueList=allList(:);
                                end


                                function sys=locFindSystem(varargin)

                                    sys=find_system(varargin{:});
                                    sys=locReplaceCarriageReturnWithSpace(sys);


                                    function out=locReplaceCarriageReturnWithSpace(in)

                                        out=strrep(in,newline,' ');
