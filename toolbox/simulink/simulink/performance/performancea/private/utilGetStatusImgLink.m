function imgStr=utilGetStatusImgLink(status,strToAttachToImage)






    matlabDir=matlabroot;
    switch status
    case-1
        imgName='toolbox/simulink/simulink/modeladvisor/private/task_failed.png';
    case 0
        imgName='toolbox/simulink/simulink/modeladvisor/private/task_warning.png';
    case 1
        imgName='toolbox/simulink/simulink/modeladvisor/private/task_passed.png';
    otherwise
        imgName='toolbox/simulink/simulink/modeladvisor/private/task_failed.png';
    end
    imgName=fullfile(matlabDir,imgName);

    imgStr=strcat(' <img src =','" ','file:///',imgName,'"','/>');

    if nargin>1
        imgStr=strcat(imgStr,strToAttachToImage);
    end

    imgStr=ModelAdvisor.Text(imgStr);

end

