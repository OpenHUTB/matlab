function setIOBlocksMode(hCS,val)




    validateattributes(hCS,{'Simulink.ConfigSet','Simulink.ConfigSetRef'},{'nonempty'});
    assert(hCS.isValidParam('CoderTargetData'),'No CoderTargetData');
    codertarget.data.setParameterValue(hCS,'IOBlocksMode',val);
end