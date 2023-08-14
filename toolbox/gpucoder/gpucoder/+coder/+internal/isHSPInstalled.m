function status=isHSPInstalled

    status=false;
    hlist=coder.hardware;

    if~isempty(hlist)
        status=any(strcmp(hlist,'NVIDIA Jetson'))&&any(strcmp(hlist,'NVIDIA Drive'));
    end
end