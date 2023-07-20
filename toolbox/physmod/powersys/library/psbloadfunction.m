function psbloadfunction(block,flag,statut)






    if isnumeric(block)
        block=getfullname(block);
    end

    system=bdroot(block);
    IsLibrary=strcmp(get_param(system,'BlockDiagramType'),'library');
    if strcmp(system,'powerlib')||strcmp(system,'powerlib2')
        return
    end


    if strcmp(flag,'InitFcnOfSPSBlocks');

        flag=statut;
        ReferenceBlockRoot=bdroot(get_param(block,'ReferenceBlock'));
        ElectricDrivelibBlock=strcmp('electricdrivelib_models',ReferenceBlockRoot)|strcmp('electricdrivelib',ReferenceBlockRoot);
        if~ElectricDrivelibBlock
            warning('SpecializedPowerSystems:UnresolvedLinkBlock',['The library link of the block named ''',block,''' appears to be delinked. Relink this block to powerlib in order to update correctly your model']);
        end
    end

    switch flag

    case 'goto'
        SetNewGotoTag([block,'/Goto'],IsLibrary);

    case 'from'
        SetNewGotoTag([block,'/From'],IsLibrary);

    case 'gotofrom'
        SetNewGotoTag([block,'/Goto'],IsLibrary);
        SetNewGotoTag([block,'/From'],IsLibrary);

    case 'gotofromDSS'
        SetNewGotoTag([block,'/Goto'],IsLibrary);
        if strcmp(get_param([block,'/GotoDSS'],'BlockType'),'Terminator')
            replace_block(block,'Followlinks','on','Name','GotoDSS','BlockType','Terminator','Goto','noprompt');
        end
        SetNewGotoTag([block,'/GotoDSS'],IsLibrary);
        SetNewGotoTag([block,'/From'],IsLibrary);

    case 'gotofromNoDSS'
        SetNewGotoTag([block,'/Goto'],IsLibrary);
        if~strcmp(get_param([block,'/GotoDSS'],'BlockType'),'Terminator')
            replace_block(block,'Followlinks','on','Name','GotoDSS','BlockType','Goto','Terminator','noprompt');
        end
        SetNewGotoTag([block,'/From'],IsLibrary);

    case 'gotogotofrom'

        SetNewGotoTag([block,'/Goto1'],IsLibrary);
        SetNewGotoTag([block,'/From'],IsLibrary);
        if strcmp(get_param([block,'/Goto2'],'BlockType'),'Goto')
            SetNewGotoTag([block,'/Goto2'],IsLibrary);
        end

    case 'configurable bridge'

        if~strcmp(get_param(block,'device'),'Diodes')
            SetNewGotoTag([block,'/Goto'],IsLibrary);
        end

    case 'Measurement Block'

        SetTheOutputTypeParameter(block);

        if strcmp(get_param(block,'MaskType'),'Multimeter')

            if~strcmp(get_param([block,'/Available Measurements'],'GotoTag'),'gotomultimeterPSB')
                set_param([block,'/Available Measurements'],'GotoTag','gotomultimeterPSB');
                set_param(block,'UserData',[]);
            end

        else

            SetNewGotoTag([block,'/source'],IsLibrary);


            if strcmp(get_param(block,'PhasorSimulation'),'on')
                set_param(block,'MaskEnables',{'on','on','on'});
            else
                set_param(block,'MaskEnables',{'off','off','off'});
            end

        end

    case 'StoreDataBlock'

        CurrentTag=get_param([block,'/To Workspace'],'VariableName');
        if~IsLibrary&&strcmp(CurrentTag,'LibraryTag')
            statut='UpdateVariableName';
        end


        switch statut
        case 'UpdateVariableName'
            tag=SetNewGotoTag([block,'/To Workspace'],-3);
            set_param([block,'/To Workspace'],'VariableName',tag);
        end
    end

    function SetTheOutputTypeParameter(block)





        PowerguiInfo=getPowerguiInfo(bdroot(block),block);

        if PowerguiInfo.Phasor||PowerguiInfo.DiscretePhasor
            PhasorMode='on';
        else
            PhasorMode='off';
        end
        try
            set_param(block,'PhasorSimulation',PhasorMode);
        catch
        end