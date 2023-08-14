function processMatFileInput(matfile,appInstanceID)






    if~isempty(matfile)
        jsonStruct=import2Repository(matfile);

        outdata.arrayOfListItems=jsonStruct;




        fullChannel=sprintf('/sta%s/%s',appInstanceID,'SignalAuthoring/UIModelData');
        message.publish(fullChannel,outdata);
    end
end