function refMdlPrefix=getReferenceModelPrefix(this,impl,refMdlName,blockPath)



    implMap=impl.getImplParamInfo;
    implInfo=implMap('referencemodelprefix');
    defaultPrefix=implInfo.DefaultValue;
    refMdlPrefix=impl.getImplParams('referencemodelprefix');

    if isfloat(refMdlPrefix)
        refMdlPrefix=defaultPrefix;
    end







    if(numel(this.HDLCoder.AllModels)>0)&&...
        (~isfield(this.HDLCoder.AllModels(1),'refModelPrefix'))
        this.HDLCoder.AllModels(1).refModelPrefix=0;
    end

    for ii=1:numel(this.HDLCoder.AllModels)

        if strcmp(this.HDLCoder.AllModels(ii).modelName,refMdlName)
            if~isfield(this.HDLCoder.AllModels(ii),'refModelPrefix')||...
                isfloat(this.HDLCoder.AllModels(ii).refModelPrefix)

                this.HDLCoder.AllModels(ii).refModelPrefix=refMdlPrefix;


                if isempty(this.HDLCoder.AllModels(ii).refModelPrefix)
                    msg=message('hdlcoder:validate:RefModelPrefixEmpty',blockPath);
                    this.updateChecks(blockPath,'block',msg,'Warning');
                end
            else

                existingPrefix=this.HDLCoder.AllModels(ii).refModelPrefix;
                if~strcmp(existingPrefix,refMdlPrefix)
                    msg=message('hdlcoder:validate:RefModelPrefixMismatch',...
                    blockPath,refMdlPrefix,existingPrefix);
                    this.updateChecks(blockPath,'block',msg,'Error');
                end
            end
        end
    end
end


