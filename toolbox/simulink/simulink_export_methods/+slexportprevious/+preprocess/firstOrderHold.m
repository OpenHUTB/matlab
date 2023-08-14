function firstOrderHold(obj)








    if isR2019aOrEarlier(obj.ver)


        fohBlks=find_system(obj.modelName,'LookUnderMasks','on',...
        'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'BlockType','FirstOrderHold');
        nb=length(fohBlks);
        if(nb>0)



            libModel=getTempLib(obj);
            blkName=createTempMdl(obj);
            libBlock=strcat(libModel,'/',blkName);




            add_block('built-in/SubSystem',libBlock);
            add_block('built-in/Inport',strcat(libBlock,'/In1'));
            add_block('built-in/Outport',strcat(libBlock,'/Out1'));



            set_param(libBlock,...
            'Mask','on',...
            'MaskType','First-Order Hold',...
            'MaskPromptString','Sample time:',...
            'MaskStyleString','edit',...
            'MaskVariables','Ts=@1;',...
            'MaskSelfModifiable','off',...
            'MaskTunableValueString','on');
            save_system(libModel);



            for i=1:nb
                blk=fohBlks{i};
                blkName=get_param(blk,'Name');
                pos=get_param(blk,'Position');
                orient=get_param(blk,'Orientation');

                delete_block(blk);

                add_block(libBlock,blk,'Ts','0.1','Orientation',orient,'Position',pos);
            end



            newReference='simulink/Discrete/First-Order Hold';
            obj.appendRules(slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock',libBlock,newReference));
        end



        newReference='simulink/Discrete/First-Order\nHold';
        obj.appendRules(slexportprevious.rulefactory.replaceInSourceBlock('SourceBlock','simulink_need_slupdate/First-Order Hold',newReference));
    end
