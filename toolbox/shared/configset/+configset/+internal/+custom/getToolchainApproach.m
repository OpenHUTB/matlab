function usingToolchainApproach=getToolchainApproach(cs)




    if isa(cs,'Simulink.ConfigSet')
        hSrc=cs.getComponent('Code Generation');
        hConfigSet=cs;
    elseif isa(cs,'Simulink.RTWCC')
        hSrc=cs;
        hConfigSet=hSrc.getConfigSet;
    else


        usingToolchainApproach=0;
        return;
    end

    if isempty(hConfigSet)||(~isempty(hConfigSet)&&hConfigSet.getDialogController.usingToolchainApproach==-1)








        hTarget=hSrc.getComponent('Target');


        usingToolchainApproach=~isempty(hTarget)&&...
        isequal(hTarget.UseToolchainInfoCompliant,'on');


        if usingToolchainApproach

            if isempty(hConfigSet)
                compInfo=coder.make.internal.getMexCompilerInfo();
            else
                adp=configset.internal.getConfigSetAdapter(hConfigSet);

                if isempty(adp.toolchainInfo)
                    configset.internal.customwidget.ToolchainValues(hConfigSet,'Toolchain',0);
                end
                compInfo=adp.toolchainInfo.MexCompInfo;
            end
            if~isempty(compInfo)
                lMexCompilerKey=compInfo.compStr;
            else
                lMexCompilerKey='';
            end
            usingToolchainApproach=...
            coder.make.internal.isConvertibleToToolchainApproachSL(hConfigSet,lMexCompilerKey);
        end

        if~isempty(hConfigSet)
            hConfigSet.getDialogController.usingToolchainApproach=usingToolchainApproach;
        end
    else
        usingToolchainApproach=hConfigSet.getDialogController.usingToolchainApproach;
    end

