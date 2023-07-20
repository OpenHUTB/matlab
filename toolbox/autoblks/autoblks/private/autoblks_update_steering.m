function autoblks_update_steering(mskhndl,callid)



    switch callid
    case 1

        maskSteerKin=get_param(mskhndl,'KinTabMask');
        maskSet=get_param(mskhndl,'MaskVisibilities');

        switch maskSteerKin

        case 'off'
            maskSet(5)=cellstr('on');
            maskSet(6:7)=cellstr('off');
            set_param(mskhndl,'MaskVisibilities',maskSet);

        case 'on'
            maskSet(3)=cellstr('off');
            maskSet(6:7)=cellstr('on');
            set_param(mskhndl,'MaskVisibilities',maskSet);
        end


    case 2


        maskStr=get_param(mskhndl,'SteeringTypeSelect');
        maskSet=get_param(mskhndl,'MaskVisibilities');

        switch maskStr

        case 'Direct - input angle'
            maskSet(9:end)=cellstr('off');
            set_param(mskhndl,'MaskVisibilities',maskSet);
            set_param([mskhndl,'/SteeringKinematics'],'LabelModeActiveChoice','1');

        case 'Simscape free end'
            maskSet(9)=cellstr('on');
            maskSet(10:end)=cellstr('off');
            set_param(mskhndl,'MaskVisibilities',maskSet);
            set_param([mskhndl,'/SteeringKinematics'],'LabelModeActiveChoice','2');

        case 'Simscape dynamic'
            maskSet(9:end)=cellstr('on');
            set_param(mskhndl,'MaskVisibilities',maskSet);
            set_param([mskhndl,'/SteeringKinematics'],'LabelModeActiveChoice','3');

        end
    case 3


        maskTrackType=get_param(mskhndl,'DualTrackMask');
        maskSet=get_param(mskhndl,'MaskVisibilities');

        switch maskTrackType

        case 'off'
            maskSet(2:3)=cellstr('off');
            set_param(mskhndl,'MaskVisibilities',maskSet);

        case 'on'
            maskSet(2:3)=cellstr('on');
            set_param(mskhndl,'MaskVisibilities',maskSet);
        end
    end
end