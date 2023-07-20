function setupHDLParams(this,slbh,configManager)




    if strcmp(get(slbh,'Type'),'block_diagram')

        return;
    end

    impl=configManager.getImplementationForBlock(getfullname(slbh));
    if~isempty(impl)
        chd=getHDLImplInfo(impl);
    else
        chd=struct;
    end

    if numel(this.HDLCoder.AllModels)>1&&isa(impl,'hdldefaults.ModelReference')


        blackBoxModel=isprop(slbh,'ProtectedModel')&&isequal(get_param(slbh,'ProtectedModel'),'on');
        if~blackBoxModel&&strcmp(hdlgetparameter('compilestrategy'),'CompileChanged')
            refMdlName=get_param(slbh,'ModelName');
            check=arrayfun(@(x)strcmp(x.modelName,refMdlName),...
            this.HDLCoder.AllModels);
            blackBoxModel=isempty(find(check,1));
        end
        if blackBoxModel
            checksum='';
        else
            modelName=get_param(slbh,'ModelName');
            modelInfo=this.HDLCoder.getModelInfo(modelName);
            checksum=modelInfo.slFrontEnd.ModelCheckSum;
        end
        chd.ImplProps=[chd.ImplProps,'ModelChecksum',checksum];
    end

    generateGenerics=this.HDLCoder.getParameter('MaskParameterAsGeneric');
    isgenerateGenerics=~isempty(generateGenerics)&&generateGenerics;
    if~isgenerateGenerics&&strcmpi(get_param(slbh,'Mask'),'on')

        if~strcmp(hdlgetparameter('SubsystemReuse'),'Atomic and Virtual')
            chd.MaskParams=get_param(slbh,'MaskValueString');
        end
    end

    set_param(slbh,'CompiledHDLData',chd);
end



function h=getHDLImplInfo(impl)






    h=struct;
    h.ImplName=impl.ArchitectureNames;
    h.ImplProps=impl.implParams;
end
