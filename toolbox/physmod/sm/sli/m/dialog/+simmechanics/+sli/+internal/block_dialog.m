function block_dialog(blockH,cmd)



    import simmechanics.sli.internal.*

    cmd=lower(cmd);

    hasGfx=hasGraphics(blockH);
    showPI=(slfeature('SMPIDialogs')>0||...
    (slfeature('SMPIDialogsNoGraphics')>0&&...
    ~hasGfx));
    dlgFunction=@sm_block_dialog;
    if(showPI)
        dlgFunction=@sm_block_dialog_pi;
    elseif(isNoJava(blockH)&&strcmp(cmd,'open'))
        dlgFunction=@simmechanics.sli.internal.pi_block_dialog;
    end

    if showPI||is_gui_possible()
        switch(cmd)

        case 'open'
            if((showPI&&hasGfx)||(~showPI))
                simStatus=get_param(bdroot(blockH),'SimulationStatus');
                dlgFunction(blockH,cmd);
                if(strcmpi(simStatus,'running')||strcmpi(simStatus,'paused')||...
                    strcmpi(simStatus,'compiled')||strcmpi(simStatus,'restarting'))
                    dlgFunction(blockH,'freeze');
                end
            else


                try
                    open_system(blockH,'mask');
                catch ME
                    if~strcmp(ME.identifier,'Simulink:Masking:OpenMaskDialog')
                        ME.rethrow();
                    end
                end
            end
        case 'simfreeze'
            hasChanges=dlgFunction(blockH,'haschanges');
            if(hasChanges)

                blkname=pmsl_sanitizename(getfullname(blockH));
                pm_error('sm:sli:setup:compile:dialog:BlockHasUnappliedChanges',blkname);
            else
                dlgFunction(blockH,'freeze');
            end

        case 'simunfreeze'
            dlgFunction(blockH,'unfreeze');

        otherwise
            dlgFunction(blockH,cmd);
        end
    else
        if strcmpi(cmd,'open')
            pm_error('sm:blocks:JavaNotAvailable');
        end
    end
end

function val=hasGraphics(blockH)
    persistent className;
    if(isempty(className))
        className=pm_message('mech2:messages:parameters:block:className:ParamName');
    end
    blkInfoMap=simmechanics.sli.internal.getTypeIdBlockInfoMap;
    blkType=get_param(blockH,className);
    blkInfo=blkInfoMap(blkType);
    val=blkInfo.HasDialogGraphics;
end

function val=isNoJava(blockH)
    persistent className;
    if(isempty(className))
        className=pm_message('mech2:messages:parameters:block:className:ParamName');
    end
    val=false;
    blkType=get_param(blockH,className);
    if(strcmp(blkType,'InfinitePlane')||strcmp(blkType,'Point')...
        ||strcmp(blkType,'PointCloud'))
        val=true;
    end
end
