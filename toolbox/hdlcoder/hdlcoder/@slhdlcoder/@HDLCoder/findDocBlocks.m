

function dBlock=findDocBlocks(this,hC)




    dBlock=[];


    systems=find_system(hC.SimulinkHandle,'LookUnderMasks','all','FollowLinks','On',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'MaskType','DocBlock');


    if(length(systems)>1)
        systems=cell2mat(get_param(sort(getfullname(systems)),'handle'));
    end

    hDrv=this;
    current_language=hDrv.getParameter('Target_Language');


    verbatim_systems=[];
    for sys_itr=1:length(systems)
        blkh=systems(sys_itr);
        blkName=getfullname(blkh);


        if~strcmpi(hdlget_param(blkName,'Architecture'),'HDLText')
            continue;
        end

        archImpl_TargetLanguage=hdlget_param(blkName,'TargetLanguage');

        if any(strcmpi(archImpl_TargetLanguage,current_language))
            verbatim_systems(end+1)=sys_itr;%#ok<AGROW>
        end
    end
    systems=systems(verbatim_systems);

    parent=strsplit(getfullname(hC.SimulinkHandle),'/');
    parent=parent{end};



    if(length(systems)>1)
        errMsg=message('hdlcoder:validate:noverbatimtextOnlyOneBlackBox',getfullname(hC.SimulinkHandle));
        this.addCheck(this.ModelName,'Error',errMsg,'model',getfullname(hC.SimulinkHandle));
        error(errMsg)
    end



    for sys_itr=1:length(systems)
        blkh=systems(sys_itr);
        user_data=get_param(blkh,'UserData');
        blkpath=getfullname(blkh);

        if isempty(user_data)
            isMasked=strcmpi(get_param(hC.SimulinkHandle,'mask'),'on');
            if isMasked
                ref_handle=hC.Owner.SimulinkHandle;
            else
                ref_handle=hC.SimulinkHandle;
            end

            errMsg=message('hdlcoder:validate:noverbatimtextDocBlockEditAndSave',getfullname(ref_handle),getfullname(blkh));
            this.addCheck(this.ModelName,'Error',errMsg,'model',getfullname(hC.SimulinkHandle));
            error(errMsg);
        end

        if(isfield(user_data,'format'))
            doc_type=user_data.format;
        else
            doc_type='text';
        end
        switch(upper(doc_type))
        case 'RTF_ZIP'
            raw_data=user_data.content;
            char_data=docblock('uncompressRTFData',raw_data);
        otherwise
            char_data=user_data.content;
        end

        prefix=parent;
        dBlock=[dBlock(:);struct('content',char_data,'PreferredNamePrefix',prefix,'BlockPath',blkpath)];
    end
    return
end
