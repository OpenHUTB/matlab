function strFromGoto=getGotoFromInfo(blkH)




    if isempty(blkH)||~isnumeric(blkH)
        DAStudio.error('Simulink:Harness:InvalidSSHandle');
    end





    strFromGoto.NumFromBlks=0;
    strFromGoto.fromBlks=[];
    strFromGoto.fromSrcBlks=[];
    strFromGoto.NumGotoBlks=0;
    strFromGoto.gotoBlks=[];
    strFromGoto.NumScopeBlks=0;
    strFromGoto.scopeBlks=[];

    blkObj=get_param(blkH,'Object');
    if isa(blkObj,'Simulink.BlockDiagram')


        return;
    end

    mdlH=get_param(bdroot(blkH),'Handle');





    mdlGotoBlks={};
    visibility={'local','scoped','global'};

    for i=1:length(visibility)


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
        mdlGotoBlks=[mdlGotoBlks;tmpGotoBlks];%#ok

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



                fromBlk=getFromBlkForGoto(mdlGotoBlks{i});
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
                    DAStudio.error('Simulink:Harness:ScopeInconsistency',tagName);
                else
                    parentBlkH=get_param(get_param(scopeBlk,'Parent'),...
                    'Handle');
                    fromBlk=getFromBlkForGoto(mdlGotoBlks{i});



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
                fromBlk=getFromBlkForGoto(mdlGotoBlks{i});
            otherwise
                DAStudio.error('Simulink:Harness:GoToTagVisibility',tagVisibil);
            end

            gotoBlkIsChild=isChildOfBlk(mdlGotoBlks{i},blkH,mdlH);
            bSkipFrom=0;bSkipGoto=0;bSkipScope=0;
            for j=1:length(fromBlk)
                if bLocalScope
                    continue;
                end




                if~bSkipFrom
                    fromBlkIsChild=isChildOfBlk(fromBlk(j),blkH,mdlH);
                    if fromBlkIsChild&&~gotoBlkIsChild
                        strFromGoto.NumFromBlks=strFromGoto.NumFromBlks+1;
                        strFromGoto.fromBlks(end+1)=fromBlk(j);
                        strFromGoto.fromSrcBlks(end+1)=mdlGotoBlks{i};
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
                    scopeBlkIsChild=isChildOfBlk(scopeBlk,blkH,mdlH);
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

function isChild=isChildOfBlk(blkH,ssH,mdlH)
    workH=blkH;



    ps2SMaskType=sprintf('PS-Simulink\nConverter');
    S2psMaskType=sprintf('Simulink-PS\nConverter');
    solverCfgMaskType=sprintf('Solver\nConfiguration');
    while(workH~=ssH&&workH~=mdlH)
        workH=get_param(get_param(workH,'Parent'),'Handle');
        try
            maskType=get_param(workH,'MaskType');
            if strcmp(maskType,ps2SMaskType)||...
                strcmp(maskType,S2psMaskType)||...
                strcmp(maskType,solverCfgMaskType)
                isChild=false;
                return;
            end
        catch
        end
    end

    isChild=(workH==ssH);
end

function fromBlkH=getFromBlkForGoto(blkH)
    fromBlkH=[];
    fromBlk=get_param(blkH,'FromBlocks');
    for i=1:length(fromBlk)
        fromBlkH(i)=fromBlk(i).handle;%#ok<AGROW>
    end
end
