function optimize=optimizeForModelGen(this,~,~)







    autoPipelineMode=getImplParams(this,'DistributedPipelining');
    if isempty(autoPipelineMode)||strcmpi(autoPipelineMode,'off')
        optimize=true;
    else
        optimize=false;
    end
end
