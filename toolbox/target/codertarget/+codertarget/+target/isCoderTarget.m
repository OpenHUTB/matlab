function ret=isCoderTarget(obj)




    if isa(obj,'Simulink.ConfigSet')||...
        isa(obj,'Simulink.ConfigSetRef')
        ret=obj.isValidParam('CoderTargetData')&&...
        ~isempty(obj.get_param('CoderTargetData'))&&...
        codertarget.data.getParameterValue(obj,'UseCoderTarget');
    else
        hCS=getActiveConfigSet(obj);
        ret=hCS.isValidParam('CoderTargetData')&&...
        ~isempty(hCS.get_param('CoderTargetData'))&&...
        codertarget.data.getParameterValue(hCS,'UseCoderTarget');
    end
end