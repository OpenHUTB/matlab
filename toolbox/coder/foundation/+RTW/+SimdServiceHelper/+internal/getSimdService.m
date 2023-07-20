function y=getSimdService(instructionSetString)
    y=target.internal.get('SoftwareService',@(x)RTW.SimdServiceHelper.internal.isSimdService(x,instructionSetString));
end