function storeSubProtectedModelScriptData(this,mdlName,protectedModelCodeGenDir,vhdlLibName,fileList)







    if this.getParameter('isvhdl')
        if~isempty(vhdlLibName)
            newLibName=vhdlLibName;
        else
            newLibName=this.getParameter('top_level_vhdl_library_name');
        end



        if~this.getParameter('use_single_library')
            newLibName=[newLibName,'_',mdlName];
        end
    else
        newLibName=['work','_',mdlName];
    end
    subModelStruct=struct('ModelName',mdlName,...
    'DirName',protectedModelCodeGenDir,...
    'LibName',newLibName,...
    'FileNames',[]);
    subModelStruct.FileNames=fileList;
    this.SubModelData=[this.SubModelData,subModelStruct];
end
