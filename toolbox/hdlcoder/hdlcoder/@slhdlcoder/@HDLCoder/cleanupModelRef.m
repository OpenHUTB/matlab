function cleanupModelRef(this)




    if this.DUTMdlRefHandle>0


        if strcmp(get_param(this.OrigStartNodeName,'BlockType'),'SubSystem')
            [subMdlName,delName]=getModelName(this);
            if exist(delName,'file')>0




                mdlIdxSave=this.mdlIdx;
                this.mdlIdx=numel(this.AllModels);
                codegenDir=this.hdlGetCodegendir;
                this.mdlIdx=mdlIdxSave;


                if~isempty(find_system(subMdlName,'type','block_diagram'))&&...
                    exist(codegenDir,'dir')
                    save_system(subMdlName,fullfile(codegenDir,delName),...
                    'OverWriteIfChangedOnDisk',true,'SaveModelWorkspace',false);
                end
                delete(delName);
            end


            delName=[subMdlName,'_bus.m'];
            if exist(delName,'file')>0
                delete(delName);
            end
            delName=[this.getParameter('generatedmodelnameprefix')...
            ,this.OrigModelName,'_conversion_data.mat'];
            if exist(delName,'file')>0
                delete(delName);
            end
        end
    end
end

function[subMdlName,delName]=getModelName(this)

    subMdlName=get_param(this.DUTMdlRefHandle,'Name');
    subMdlName=hdlcoder.pirctx.legalizeName(subMdlName,'');
    delName=[subMdlName,'.slx'];
end
