function status=convertDvoToDvel(file,dir)




    converter=fullfile(matlabroot,'bin',computer('arch'),'dvotool');
    if ispc
        converter=[converter,'.exe'];
    end

    input=fullfile(dir,[file,'.dvo']);

    cmd=['"',converter,'" -c dvel "',input,'"'];
    cmdStatus=system(cmd);
    status=cmdStatus==0;
end
