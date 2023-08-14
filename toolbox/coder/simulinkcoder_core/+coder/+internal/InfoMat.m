classdef InfoMat<handle




    properties(SetAccess=private,Transient=true)
modelName
mdlRefTgtType
minfo_or_binfo
anchorDir
markerFile
fullMatFileName
matFileDir
targetDirName
    end

    methods
        function this=InfoMat(modelName,mdlRefTgtType,minfo_or_binfo,...
            anchorDir,markerFile,fullMatFileName,...
            matFileDir,targetDirName)

            this.modelName=modelName;
            this.mdlRefTgtType=mdlRefTgtType;
            this.minfo_or_binfo=minfo_or_binfo;
            this.anchorDir=anchorDir;
            this.markerFile=markerFile;
            this.fullMatFileName=fullMatFileName;
            this.matFileDir=matFileDir;
            this.targetDirName=targetDirName;
        end
    end
end
