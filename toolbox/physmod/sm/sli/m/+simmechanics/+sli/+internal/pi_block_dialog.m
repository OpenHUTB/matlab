function pi_block_dialog(blockH,cmd)



    import simmechanics.sli.internal.*

    cmd=lower(cmd);
    switch(cmd)

    case 'open'

        if(slfeature('SMPIDialogs')>0)||...
            (slfeature('SMPIDialogsNoGraphics')>0)


            try
                open_system(blockH,'mask');
            catch ME
                if~strcmp(ME.identifier,'Simulink:Masking:OpenMaskDialog')
                    ME.rethrow();
                end
            end
        else
            studios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
            if~isempty(studios)
                activeStudio=studios(1);
                pi=activeStudio.getComponent('GLUE2:PropertyInspector','Property Inspector');
                activeStudio.showComponent(pi);
            end
        end

    otherwise

    end
end
