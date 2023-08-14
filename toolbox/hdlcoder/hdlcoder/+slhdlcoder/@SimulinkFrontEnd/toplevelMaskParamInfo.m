function toplevelMaskParamInfo(this,slName,configManager,hTopNetwork)



    slbh=get_param(slName,'handle');


    if strcmp(hdlgetparameter('subsystemreuse'),'Atomic and Virtual')

        generateGenerics=hdlgetparameter('MaskParameterAsGeneric');

        if generateGenerics

            if(strcmp(get(slbh,'Type'),'block_diagram')==0)
                [maskParamInfo,unsupportedParam]=this.collectMaskParamInfo(slbh,configManager);
                if~unsupportedParam
                    this.annotateMaskParamInfo(maskParamInfo,hTopNetwork);
                end
            end
        end
    else


        handleReusable=this.HandleReusableSubsystem;
        generateGenerics=hdlgetparameter('MaskParameterAsGeneric')&&handleReusable;

        if generateGenerics

            if(strcmp(get(slbh,'Type'),'block_diagram')==0)

                if this.isReusableSS(slbh)
                    [maskParamInfo,unsupportedParam]=this.collectMaskParamInfo(slbh,configManager);
                    if~unsupportedParam
                        this.annotateMaskParamInfo(maskParamInfo,hTopNetwork);
                    end
                end
            end
        end
    end

end