function destroyElement(~,designStudy,modelHandle)
    designStudy.destroy();

    simulink.multisim.internal.setRunAllContext(modelHandle);
end