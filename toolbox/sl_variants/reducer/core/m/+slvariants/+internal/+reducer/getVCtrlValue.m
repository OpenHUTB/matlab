function outVal=getVCtrlValue(inVal)




    cvValue=Simulink.variant.reducer.utils.getCtrlVarValueBasedOnType(inVal);
    if isa(cvValue,'Simulink.Parameter')


        cvValue=cvValue.Value;
    end
    outVal=Simulink.variant.reducer.utils.i_num2str(cvValue);
end
