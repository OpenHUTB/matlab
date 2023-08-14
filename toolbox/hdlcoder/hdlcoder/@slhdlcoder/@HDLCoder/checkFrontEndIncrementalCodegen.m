function regen=checkFrontEndIncrementalCodegen(this,mdlRef)




    regen=frontEndPredicate(this,mdlRef);


    refMdlName=get_param(mdlRef,'ModelName');
    codegendir=fullfile(this.hdlGetBaseCodegendir,refMdlName);
    folderlink=sprintf('<a href="matlab:uiopen(''%s'');">%s</a>',codegendir,codegendir);
    if regen
        hdldisp(message('hdlcoder:hdldisp:GenReferencedModel',refMdlName,folderlink));
    else
        hdldisp(message('hdlcoder:hdldisp:NoGenReferencedModel',refMdlName,folderlink));
    end
end


function regen=frontEndPredicate(this,mdlRef)
    regen=true;
    refMdlName=get_param(mdlRef,'ModelName');
    blkHandle=get_param(mdlRef,'handle');

    this.getIncrementalCodeGenDriver().init(this);
    this.getIncrementalCodeGenDriver.loadHDLCodeGenStatus(this,refMdlName);
    if~this.getIncrementalCodeGenDriver.frontEndPredicate(this,refMdlName,blkHandle)
        check=~isempty(this.getParameter('module_prefix'))||this.getParameter('ShareAtomicSubsystems')...
        ||this.getParameter('minimizeclockenables')||this.getParameter('EnableTestpoints')...
        ||this.getParameter('GenDUTPortForTunableParam')||this.getParameter('triggerasclock');
        if(check)
            return;
        end

        mrBlocks=find_system(refMdlName,'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'FollowLinks','on','BlockType','ModelReference');
        if~isempty(mrBlocks)
            return;
        end

        if strcmp(get_param(mdlRef,'Mask'),'on')
            return;
        end
        regen=false;
    end
end
