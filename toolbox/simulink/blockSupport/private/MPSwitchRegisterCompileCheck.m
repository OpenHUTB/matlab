function MPSwitchRegisterCompileCheck(block,h)




    appendCompileCheck(h,block,@CollectMPSwitchContigData,...
    @ReplaceMPSwitchContigDataPortToEnum,...
    @MPSwitchNoCompileCallBack);

    set_param(h.MyModel,'ModelUpgradeActive','on');

end
