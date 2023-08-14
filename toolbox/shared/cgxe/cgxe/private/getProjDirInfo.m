function[projDirInfo]=getProjDirInfo(mdlName)


    projDirInfo.cgxeProjDir=get_cgxe_proj(mdlName,'');
    projDirInfo.cSrcDir=CGXE.Coder.getProjDir;
    projDirInfo.jitDir=CGXE.JIT.getProjDir;

end

