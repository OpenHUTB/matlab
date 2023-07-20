function v=validateImplParams(this,hC)



    v=baseValidateImplParams(this,hC);

    driver=hdlcurrentdriver;
    ramstyle=driver.getCLI.RAMArchitecture;
    if strcmpi(ramstyle,'WithoutClockEnable')

        if hC.Owner.hasEnabledInstances||hC.Owner.hasTriggeredInstances
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:illegalparamsinenabledss'));
        end
    end
    if hC.Owner.hasResettableInstances
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:ramcannotbereset'));
    end
end


