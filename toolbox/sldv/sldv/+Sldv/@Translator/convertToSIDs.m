


function[blkSID,sfSID]=convertToSIDs(obj,blockH,sfId)
    if isKey(obj.mBlk_Hdl_SfId_2_SID,blockH)&&isKey(obj.mBlk_Hdl_SfId_2_SID,sfId)
        blkSID=obj.mBlk_Hdl_SfId_2_SID(blockH);
        sfSID=obj.mBlk_Hdl_SfId_2_SID(sfId);
    else
        if(-1==blockH)
            blkSID='-1';
        else
            blkSID=Simulink.ID.getSID(blockH);
            obj.mBlk_Hdl_SfId_2_SID(blockH)=blkSID;
        end

        if sfId==0
            sfSID='';
        else
            if obj.mTestComp.isArtificialSfId(sfId)
                sfSID=['$Artificial$',num2str(sfId)];
            elseif sf('Private','is_eml_script',sfId)
                sfSID=['$ExternalFcn$',sf('get',sfId,'.name')];
            elseif(sf('get',sfId,'.isa')==sf('get','default','chart.isa'))
                if strcmp(get_param(blockH,'BlockType'),'S-Function')
                    parentBlkSID=Simulink.ID.getSID(get_param(blockH,'Parent'));
                    sfSID=['$SFChart$',parentBlkSID];
                else
                    sfSID=['$SFChart$',blkSID];
                end
            else
                sfSID=Sldv.DataUtils.getSidForSfObj(sfId,blockH);
            end

            obj.mBlk_Hdl_SfId_2_SID(sfId)=sfSID;


        end
    end
end



































































