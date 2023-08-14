function processRotationMirror(obj)











    modelName=obj.modelName;
    verobj=obj.ver;

    if isR2008bOrEarlier(verobj)
        allBlks=find_system(modelName,'MatchFilter',@Simulink.match.allVariants,'Type','block');
        for i=1:length(allBlks)
            blockRotation=get_param(allBlks{i},'BlockRotation');
            blockMirror=get_param(allBlks{i},'BlockMirror');
            [compatRotation,compatMirror]=LocalGetCompatValues(blockRotation,blockMirror);
            set_param(allBlks{i},'BlockRotation',compatRotation);
            set_param(allBlks{i},'BlockMirror',compatMirror);
        end
    end

end


function[cRotation,cMirror]=LocalGetCompatValues(blkRotation,blkMirror)







    cRotation=0;
    cMirror='off';

    blkMirrorOn=strcmpi(blkMirror,'on');

    doWarn=false;

    if(blkRotation>=0&&blkRotation<=45)

        if(blkMirrorOn)
            cRotation=0;
            cMirror='on';
        else
            cRotation=0;
            cMirror='off';
        end

    elseif(blkRotation>=46&&blkRotation<=135)

        if(blkMirrorOn)
            cRotation=270;
            cMirror='off';
        else
            cRotation=270;
            cMirror='on';
        end

        doWarn=true;

    elseif(blkRotation>=136&&blkRotation<=225)

        if(blkMirrorOn)
            cRotation=0;
            cMirror='off';
        else
            cRotation=0;
            cMirror='on';
        end

        doWarn=true;

    elseif(blkRotation>=226&&blkRotation<=315)

        if(blkMirrorOn)
            cRotation=270;
            cMirror='on';
        else
            cRotation=270;
            cMirror='off';
        end

    elseif(blkRotation>=316&&blkRotation<360)

        if(blkMirrorOn)
            cRotation=0;
            cMirror='on';
        else
            cRotation=0;
            cMirror='off';
        end

    end

    if(doWarn)
        obj.helper.reportWarning('Simulink:utility:incompatRotationMirror',blkRotation,blkMirror);
    end

end


