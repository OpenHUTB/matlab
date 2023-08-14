function updateProgressBarMessage(obj,messageId)










    msg=message(messageId);
    barMsg=msg.getString();

    if obj.isCalledFromVM()
        if slfeature('VMGRV2UI')<1
            javaMethodEDT('updateProgressBarMessage',obj.FrameHandle,barMsg);
        else
            str=message('Simulink:Variants:ReducerEllipsis');
            sldiagviewer.reportInfo(sprintf('%s',[barMsg,str.getString()]));
        end
    elseif obj.VerboseFlag
        str=message('Simulink:Variants:ReducerEllipsis');
        fprintf('%s',[barMsg,str.getString()]);
    end

end


