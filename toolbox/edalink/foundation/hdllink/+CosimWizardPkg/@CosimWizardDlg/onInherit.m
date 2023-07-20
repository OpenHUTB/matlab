function onInherit(this,dialog)



    try
        numOutPorts=numel(this.UserData.UsedOutPortList);
        for m=1:numOutPorts
            this.UserData.UsedOutPortList{m}.SampleTime='-1';
            this.UserData.UsedOutPortList{m}.DataType=0;
        end
        dialog.refresh;
    catch ME
        displayErrorMessage(this,dialog,ME.message);
    end