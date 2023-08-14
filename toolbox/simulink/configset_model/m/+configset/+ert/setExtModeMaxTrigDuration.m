function newvalue=setExtModeMaxTrigDuration(~,value)




    if value<=0
        DAStudio.error('Simulink:Engine:ExtModeInvalidPositiveValue','ExtModeMaxTrigDuration');
    end
    newvalue=value;

end
