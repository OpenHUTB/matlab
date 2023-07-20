function[oldDriver,oldMode,oldAutosaveState]=inithdlmake(this,mdlName,commitParams)



    if nargin<3
        commitParams=true;
    end

    if nargin<2
        mdlName=this.ModelName;
    end


    oldDriver=hdlcurrentdriver;
    hdlcurrentdriver(this);




    oldMode=hdlcodegenmode;
    hdlcodegenmode('slcoder');

    if commitParams
        try
            this.commitParams(mdlName);



            if isempty(this.AllModels)||strcmp(mdlName,this.AllModels(end).modelName)
                this.createConnection(this.getStartNodeName);
            end












            if Simulink.internal.useFindSystemVariantsMatchFilter()&&~this.ModelConnection.isModelCompiled



                if(~isempty(find_system(mdlName,'FirstResultOnly','on','LookUnderMasks',...
                    'all','FollowLinks','on','BlockType','SubSystem','Variant','on')))
                    this.ModelConnection.initModel();
                end
            end

        catch me

            hdlcodegenmode(oldMode);
            hdlcurrentdriver(oldDriver);
            rethrow(me);
        end
    end



    oldAutosaveState=get_param(0,'AutoSaveOptions');
    newAutosaveState=oldAutosaveState;
    newAutosaveState.SaveOnModelUpdate=0;
    set_param(0,'AutoSaveOptions',newAutosaveState);


    hINI=this.getINI;
    codegendir=getProp(hINI,'codegendir');
    if~ispc&&~isempty(strfind(codegendir,'\'))
        codegendir=strrep(codegendir,'\',filesep);
        this.setParameter('codegendir',codegendir);
    elseif ispc&&~isempty(strfind(codegendir,'/'))
        codegendir=strrep(codegendir,'/',filesep);
        this.setParameter('codegendir',codegendir);
    end
end
