function utilAdjustVerifyCosim(mdladvObj,hDI)



    taskObj=mdladvObj.getTaskObj('com.mathworks.HDL.VerifyCosim');


    inputParams=mdladvObj.getInputParameters(taskObj.MAC);
    SkipVerifyCosim=utilGetInputParameter(inputParams,DAStudio.message('HDLShared:hdldialog:HDLWAInputSkipThisTask'));


    hDI.SkipVerifyCosim=SkipVerifyCosim.Value;

end
