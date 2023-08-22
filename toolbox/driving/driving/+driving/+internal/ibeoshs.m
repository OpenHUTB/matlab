function ibeoshs(messageType)
    isShared=any(strcmpi(messageType,shareList()));

    if isShared
        msg=getString(message('driving:ibeoReader:lidarToolboxRequired'));
        ltshs(msg);
    end

end


function list=shareList()
    list={'scan','pointCloudPlane'};
end
