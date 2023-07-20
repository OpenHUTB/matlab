function lookForDeprecatedChecks(this,bCheckConfig)











    if this.isUserLoaded



        this.isUserLoaded=false;


        if bCheckConfig
            checkList=cellfun(@(x)x.MAC,this.ConfigUICellArray,'UniformOutput',false);
        else
            checkList=this.AtticData.CheckIDsSelectedForExecution;
        end

        bShowHISMMessage=false;
        bShowMAABMessage=false;

        for ii=1:numel(checkList)
            if isempty(checkList{ii})
                continue;
            end

            [isDep,~,type]=ModelAdvisor.internal.isCheckDeprecated(checkList{ii});

            if isDep
                bShowHISMMessage=strcmp(type,'highintegrity');
                bShowMAABMessage=strcmp(type,'maab');
            end
        end


        if bShowHISMMessage
            disp(DAStudio.message('ModelAdvisor:engine:CheckHISMDeprecationMessage'));
        end

        if bShowMAABMessage
            disp(DAStudio.message('ModelAdvisor:engine:CheckMAABDeprecationMessage'));
        end
    end
end