function SetParamValueFromAnimationSpeed(bdHandle,speedString)
    switch speedString
    case 'simulink_ui:studio:resources:animationLightningFast'
        set_param(bdHandle,'AnimationSpeed','lightningfast');
    case 'simulink_ui:studio:resources:animationFast'
        set_param(bdHandle,'AnimationSpeed','fast');
    case 'simulink_ui:studio:resources:animationMedium'
        set_param(bdHandle,'AnimationSpeed','medium');
    case 'simulink_ui:studio:resources:animationSlow'
        set_param(bdHandle,'AnimationSpeed','slow');
    case 'simulink_ui:studio:resources:animationNone'
        set_param(bdHandle,'AnimationSpeed','none');
    otherwise
        set_param(bdHandle,'AnimationSpeed','none');
    end
end