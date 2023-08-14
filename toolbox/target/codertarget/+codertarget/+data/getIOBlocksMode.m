function out=getIOBlocksMode(hCS)




    out='';
    validateattributes(hCS,{'Simulink.ConfigSet','Simulink.ConfigSetRef'},{'nonempty'});
    assert(hCS.isValidParam('CoderTargetData'),'No CoderTargetData');
    if codertarget.data.isValidParameter(hCS,'IOBlocksMode')
        out=codertarget.data.getParameterValue(hCS,'IOBlocksMode');
    end
end