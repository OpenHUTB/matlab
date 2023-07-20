function chooser=imageFileChooser(filePath,callback)








    chooserSrc=Simulink.Mask.IconImageCreatorDialog;
    chooserSrc.BasePath=fileparts(filePath);
    chooserSrc.ApplyFcn=@(obj)callback(filePath,obj.ImageFile);


    chooser=DAStudio.Dialog(chooserSrc);
