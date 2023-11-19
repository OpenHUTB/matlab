function dialog=simrfV2_find_dialog(block)

    dialog=[];
    toolroot=DAStudio.ToolRoot;
    dv=toolroot.getOpenDialogs;


    for kk=1:numel(dv)
        temph=dv(kk);
        this=temph.getSource;
        if isa(this,'simrfV2dialog.simrfV2dialog')

            if strcmp([this.Block.Path,'/',this.Block.Name],block)
                dialog=temph;
                return
            end
        elseif isa(this,'Simulink.SLDialogSource')


            imd=DAStudio.imDialog.getIMWidgets(temph);
            if isa(imd,'DAStudio.imDialog')
                DescGroupVarWidget=imd.find('tag','DescGroupVar');



                if isa(DescGroupVarWidget,'DAStudio.imGroup')&&...
                    ~isempty(strfind(DescGroupVarWidget.name,'(mask)'))&&...
                    strcmp([this.getBlock.Path,'/',this.getBlock.Name],block)
                    dialog=temph;
                    return
                end
            end
        end
    end