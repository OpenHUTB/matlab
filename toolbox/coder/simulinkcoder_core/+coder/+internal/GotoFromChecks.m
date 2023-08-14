classdef GotoFromChecks<handle




    methods(Static,Access=public)

        function isChild=isChildOfBlk(blkH,ssH,mdlH)
            workH=blkH;

            while(workH~=ssH&&workH~=mdlH)
                workH=get_param(get_param(workH,'Parent'),'Handle');
            end

            isChild=(workH==ssH);
        end


        function fromBlks=findFromBlks(mdlH,tagName)
            persistent lFromBlks;
            persistent lGotoTags;
            fromBlks=[];

            if isempty(lFromBlks)||isempty(lGotoTags)


                lFromBlks=find_system(mdlH,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','BlockType','From');
                if~isempty(lFromBlks)
                    lGotoTags=get_param(lFromBlks,'GotoTag');
                    if~iscell(lGotoTags)
                        lGotoTags={lGotoTags};
                    end

                    for i=1:length(lGotoTags)
                        lGotoTags{i}=sscanf(lGotoTags{i},'%s');
                    end
                end
            end

            if~isempty(lFromBlks);
                i=strcmp(tagName,lGotoTags);
                fromBlks=lFromBlks(i);
            end
        end


        function fromBlkH=getFromBlkForGoto(blkH)
            fromBlkH=arrayfun(@(item)item.handle,get_param(blkH,'FromBlocks'));
        end


        function gotoInportH=getGotoInportH(fromBlkH)
            gotoBlk=get_param(fromBlkH,'GotoBlock');
            portH=get_param(gotoBlk.handle,'PortHandles');
            gotoInportH=portH.Inport;
        end


        function fromOutPortH=getFromOutportH(gotoBlkH)
            fromBlks=get_param(gotoBlkH,'FromBlocks');
            fromOutPortH=cell(1,length(fromBlks));
            for i=1:length(fromBlks)
                portH=get_param(fromBlks(i).handle,'PortHandles');
                fromOutPortH{i}=portH.Outport;
            end
        end


        function strFromGoto=checkFromBlks(blkH)
            mdlH=get_param(coder.internal.Utilities.localBdroot(blkH),'Handle');




            strFromGoto.NumFromBlks=0;
            strFromGoto.fromBlks=[];
            strFromGoto.NumGotoBlks=0;
            strFromGoto.gotoBlks=[];
            strFromGoto.NumScopeBlks=0;
            strFromGoto.scopeBlks=[];




            mdlGotoBlks={};
            visibility={'local','scoped','global'};

            for i=1:length(visibility);


                tmpGotoBlks=find_system(mdlH,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','BlockType','Goto',...
                'TagVisibility',visibility{i});
                if~isempty(tmpGotoBlks)
                    tmpGotoBlks=get_param(tmpGotoBlks,'Handle');
                    if~iscell(tmpGotoBlks);tmpGotoBlks={tmpGotoBlks};end
                else
                    tmpGotoBlks={};
                end
                mdlGotoBlks=[mdlGotoBlks;tmpGotoBlks];%#ok<AGROW>
            end



            if~isempty(mdlGotoBlks)
                for i=1:length(mdlGotoBlks)
                    tagName=sscanf(get_param(mdlGotoBlks{i},'GotoTag'),'%s');
                    tagVisibil=get_param(mdlGotoBlks{i},'TagVisibility');
                    fromBlk=[];%#ok
                    scopeBlk=[];
                    bScoped=0;
                    bLocalScope=0;




                    switch tagVisibil
                    case 'local'



                        fromBlk=coder.internal.GotoFromChecks.getFromBlkForGoto(mdlGotoBlks{i});
                        bLocalScope=1;

                    case 'scoped'




                        bScoped=1;
                        parentBlock=get_param(mdlGotoBlks{i},'Parent');

                        while(~isempty(parentBlock))
                            parentBlkH=get_param(parentBlock,'Handle');
                            scopeBlk=find_system(parentBlkH,'LookUnderMasks','all',...
                            'FollowLinks','on','SearchDepth',1,...
                            'BlockType','GotoTagVisibility',...
                            'GotoTag',tagName);


                            if(~isempty(scopeBlk))
                                break;
                            end
                            parentBlock=get_param(parentBlock,'Parent');
                        end



                        if isempty(scopeBlk)||iscell(scopeBlk)
                            DAStudio.error('RTW:buildProcess:slbusScopeInconsistency',tagName);
                        else
                            parentBlkH=get_param(get_param(scopeBlk,'Parent'),...
                            'Handle');
                            fromBlk=coder.internal.GotoFromChecks.getFromBlkForGoto(mdlGotoBlks{i});



                        end
                        if length(fromBlk)>1
                            scopeSys=parentBlkH;
                            tempFromBlk=[];
                            for j=1:length(fromBlk)
                                tmpScopeBlk=[];
                                parentBlkH=get_param(fromBlk(j),'Handle');
                                while(parentBlkH~=scopeSys&&isempty(tmpScopeBlk))
                                    parentBlkH=get_param(get_param(parentBlkH,'Parent'),'Handle');
                                    tmpScopeBlk=find_system(parentBlkH,'LookUnderMasks','all',...
                                    'FollowLinks','on','SearchDepth',1,...
                                    'BlockType','GotoTagVisibility',...
                                    'GotoTag',tagName);
                                end
                                if(parentBlkH==scopeSys)
                                    tempFromBlk(end+1)=fromBlk(j);%#ok<AGROW>
                                end
                            end
                            fromBlk=tempFromBlk;
                        end
                    case 'global'
                        fromBlk=coder.internal.GotoFromChecks.getFromBlkForGoto(mdlGotoBlks{i});
                    otherwise
                        DAStudio.error('RTW:buildProcess:slbusGoToTagVisibility',tagVisibil);
                    end

                    gotoBlkIsChild=coder.internal.GotoFromChecks.isChildOfBlk(mdlGotoBlks{i},blkH,mdlH);
                    bSkipFrom=0;bSkipGoto=0;bSkipScope=0;
                    for j=1:length(fromBlk)
                        if bLocalScope
                            continue;
                        end




                        if~bSkipFrom
                            fromBlkIsChild=coder.internal.GotoFromChecks.isChildOfBlk(fromBlk(j),blkH,mdlH);
                            if fromBlkIsChild&&~gotoBlkIsChild
                                strFromGoto.NumFromBlks=strFromGoto.NumFromBlks+1;
                                strFromGoto.fromBlks(end+1)=fromBlk(j);
                                bSkipFrom=1;
                            end
                        end
                        if gotoBlkIsChild&&~fromBlkIsChild

                            if~bSkipGoto
                                strFromGoto.NumGotoBlks=strFromGoto.NumGotoBlks+1;
                                strFromGoto.gotoBlks(end+1)=mdlGotoBlks{i};
                                bSkipGoto=1;
                            end
                        end
                        if bScoped&&~bSkipScope
                            scopeBlkIsChild=coder.internal.GotoFromChecks.isChildOfBlk(scopeBlk,blkH,mdlH);
                            if(gotoBlkIsChild||fromBlkIsChild)&&~scopeBlkIsChild
                                strFromGoto.NumScopeBlks=strFromGoto.NumScopeBlks+1;
                                strFromGoto.scopeBlks(end+1)=scopeBlk;
                                bSkipScope=1;
                            end
                        end
                    end
                end
            end
        end
    end
end
