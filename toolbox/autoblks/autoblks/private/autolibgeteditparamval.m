function[val]=autolibgeteditparamval(block,param)



    MaskObj=get_param(block,'MaskObject');
    BlkH=get_param(block,'Handle');



    dlgs=DAStudio.ToolRoot.getOpenDialogs;
    for i=1:length(dlgs)
        if class(dlgs(i).getSource)=="Simulink.SLDialogSource"
            dlgsH=dlgs(i).getSource.getBlock.Handle;
            if dlgsH==BlkH
                d1=dlgs(i);
                break;
            end
        end
    end


    if(exist('d1','var')&&d1.hasUnappliedChanges)
        var=MaskObj.Parameters(strcmp({MaskObj.Parameters.Name},param)).Value;
        try
            tmp=slResolve(var,block);
        catch error_msg

            if(error_msg.identifier=='Simulink:Data:SlResolveNotResolved')
                error(message('autoblks:autoerrEditParam:invalidFind',block,var));
            else
                error(error_msg.message);
            end
        end
    else

        WsVars=MaskObj.getWorkspaceVariables;
        tmp=WsVars(strcmp({WsVars.Name},param)).Value;
    end


    if(isempty(tmp))
        error(message('autoblks:autoerrEditParam:invalidFind',block,param));
    end


    if isa(tmp,'mpt.Parameter')||isa(tmp,'Simulink.Parameter')
        switch tmp.DataType
        case{'double'}
            val=tmp.Value;
        case 'single'
            val=single(tmp.Value);
        otherwise
            error(message('autoblks:autoerrEditParam:invalidType',block,param));
        end
    else
        switch class(tmp)
        case{'double'}
            val=tmp;
        case 'single'
            val=single(tmp);
        otherwise
            error(message('autoblks:autoerrEditParam:invalidType',block,param));
        end
    end

end