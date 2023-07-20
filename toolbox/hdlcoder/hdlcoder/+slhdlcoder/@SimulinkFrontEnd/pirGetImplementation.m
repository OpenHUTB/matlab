function impl=pirGetImplementation(this,slbh,configManager)




    blockName=this.validateAndGetName(get_param(slbh,'Name'));
    blockParent=get(slbh,'Parent');
    if isempty(blockParent)
        blockParent=this.HDLCoder.ModelName;
    end
    blockPath=[blockParent,'/',blockName];

    if slhdlcoder.SimulinkFrontEnd.isSyntheticBlock(slbh)
        debug=this.HDLCoder.getParameter('debug')>2;
        if debug
            msgobj=message('hdlcoder:engine:syntheticBlock',blockPath);
            this.updateChecks(blockPath,'block',msgobj,'Warning');
        end




        impl=[];
        typ=get_param(slbh,'BlockType');
        if strcmp(typ,'Ground')
            impl=hdldefaults.Constant;
        elseif(slfeature('STVariantsInHDL')>0&&strcmp(typ,'VariantMerge'))
            impl=hdldefaults.VariantMerge;
        else
            if isprop(get_param(blockParent,'Handle'),'BlockType')
                expSS=slInternal('busDiagnostics','handleToExpandedSubsystem',...
                get_param(blockParent,'Handle'));

                isExpansionSS=false;


                if~isempty(expSS)&&slhdlcoder.SimulinkFrontEnd.isBusExpansionSubsystem(expSS)
                    isExpansionSS=true;




                elseif isempty(expSS)&&~isempty(blockParent)&&...
                    slhdlcoder.SimulinkFrontEnd.isBusExpansionSubsystem(get_param(blockParent,'handle'))
                    isExpansionSS=true;
                end

                if isExpansionSS
                    if strcmp(typ,'BusCreator')


                        impl=...
                        configManager.localGetImplementation(configManager.DefaultTable,...
                        'built-in/BusCreator',configManager.ModelName);
                    elseif strcmp(typ,'BusSelector')


                        impl=...
                        configManager.localGetImplementation(configManager.DefaultTable,...
                        'built-in/BusSelector',configManager.ModelName);


                    elseif strcmp(typ,'SignalSpecification')
                        impl=...
                        configManager.localGetImplementation(configManager.DefaultTable,...
                        'built-in/SignalSpecification',configManager.ModelName);
                    elseif strcmp(typ,'SignalConversion')
                        impl=...
                        configManager.localGetImplementation(configManager.DefaultTable,...
                        'built-in/SignalConversion',configManager.ModelName);
                    else


                        impl=configManager.getImplementationForBlock(blockParent);
                    end
                    impl=checkImplError(this,impl,blockParent);
                end
            end
        end
        if isempty(impl)
            impl=hdlimplbase.NoOpEmission;
        end
    else

        impl=configManager.getImplementationForBlock(blockPath);
        impl=checkImplError(this,impl,blockPath);
    end
end



function newimpl=checkImplError(this,impl,blockPath)
    if~isempty(impl)
        newimpl=impl;
        return;
    end

    msgobj=message('hdlcoder:engine:missingImplementation',strrep(blockPath,newline,' '));
    this.updateChecks(blockPath,'block',msgobj,'Error');
    newimpl=hdlimplbase.NoOpEmission;
end
