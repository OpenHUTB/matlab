function paramTargetLibrary(taskobj)



    mdladvObj=taskobj.MAObj;


    inputParams=mdladvObj.getInputParameters(taskobj.MAC);

    setXilinxSimLibPathParam=inputParams{4};
    xilinxSimLibParam=inputParams{5};
    xilinxSimLibParamBrowse=inputParams{6};

    if setXilinxSimLibPathParam.Value
        xilinxSimLibParam.Enable=true;
        xilinxSimLibParamBrowse.Enable=true;
    else
        xilinxSimLibParam.Enable=false;
        xilinxSimLibParam.Value='';
        xilinxSimLibParamBrowse.Enable=false;
    end

end
