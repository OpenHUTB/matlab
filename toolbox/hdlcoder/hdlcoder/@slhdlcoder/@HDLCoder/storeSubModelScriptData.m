function storeSubModelScriptData(this,mdlName,fileList)



    if this.mdlIdx~=numel(this.AllModels)
        if this.getParameter('isvhdl')
            if this.getParameter('use_single_library')
                newLibName=this.getParameter('top_level_vhdl_library_name');
            else
                newLibName=[this.getParameter('top_level_vhdl_library_name'),'_',mdlName];
            end
        else
            newLibName=['work','_',mdlName];
        end
        subModelStruct=struct('ModelName',mdlName,...
        'DirName',this.hdlGetCodegendir,...
        'LibName',newLibName,...
        'FileNames',[]);
        subModelStruct.FileNames=fileList;
        this.SubModelData=[this.SubModelData,subModelStruct];
    end
end