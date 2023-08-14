function usingNonTopDUT=prelimNonTopDUTChecks(this)


    hierarchyLevels=0;
    blkdiagram=this.getStartNodeName;
    checkObserverCompatibility(blkdiagram);
    if strcmp(hdlfeature('NonTopNoModelReference'),'off')
        while~isempty(get_param(blkdiagram,'Parent'))
            blkdiagram=get_param(blkdiagram,'Parent');
            hierarchyLevels=hierarchyLevels+1;
            if strcmp(get_param(blkdiagram,'Type'),'block')&&...
                strcmp(get_param(blkdiagram,'BlockType'),'SubSystem')&&...
                strcmp(get_param(blkdiagram,'Mask'),'on')
                if~isempty(get_param(blkdiagram,'MaskTunableValues'))||...
                    ~isempty(get_param(blkdiagram,'MaskInitialization'))




                    error(message('hdlcoder:validate:ParentMaskOnNonTopLevel',blkdiagram));
                end
            end




            if~isempty(find_system(blkdiagram,'SearchDepth','1','BlockType','ForEach'))
                error(message('hdlcoder:validate:ParentForEachSubsystem',blkdiagram))
            end
        end

        usingNonTopDUT=logical(hierarchyLevels>1)||this.isDutModelRef;
    else
        immediateParent=get_param(blkdiagram,'Parent');
        usingNonTopDUT=~isempty(immediateParent)&&~isempty(get_param(immediateParent,'Parent'))||this.isDutModelRef;
        while~isempty(get_param(blkdiagram,'Parent'))
            blkdiagram=get_param(blkdiagram,'Parent');
            if~isempty(find_system(blkdiagram,'SearchDepth','1','BlockType','ForEach'))
                error(message('hdlcoder:validate:ParentForEachSubsystem',blkdiagram));
            end
        end
    end
    if usingNonTopDUT
        origSSName=get_param(this.getStartNodeName,'Name');
        if strcmpi(origSSName,this.ModelName)
            error(message('hdlcoder:validate:NonTopDUTNameSameAsModel',this.getStartNodeName));
        end
    end
end

function checkObserverCompatibility(blkdiagram)
    if strcmp(get_param(blkdiagram,'Type'),'block')&&...
        strcmp(get_param(bdroot(blkdiagram),'IsObserverBD'),'on')
        error(message('hdlcoder:validate:ObserverNotSupported',blkdiagram));
    elseif strcmp(get_param(blkdiagram,'Type'),'block_diagram')
        obsBlks=Simulink.observer.internal.getObserverRefBlocksInBD(get_param(blkdiagram,'Handle'));
        if~isempty(obsBlks)
            error(message('hdlcoder:validate:ObserverInModel',blkdiagram));
        end
    end
end
