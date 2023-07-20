function configInfo=preprocessConfigInfo(configInfo,ctrlVarsSpecifiedAsStruct)



    if ctrlVarsSpecifiedAsStruct
        if isstruct(configInfo)
            configInfo=arrayfun(@(X){X},configInfo(:)');
            configInfo=cellfun(@(X)(i_convertCtrlVarNameValues(X)),configInfo,'UniformOutput',false);
        elseif iscell(configInfo)&&(numel(configInfo)>0)
            for i=1:numel(configInfo)
                thisConfigInfoStruct=configInfo{i};
                if isstruct(thisConfigInfoStruct)
                    thisConfigInfoStruct=arrayfun(@(X){X},thisConfigInfoStruct(:)');
                    configInfo{i}=cellfun(@(X)(i_convertCtrlVarNameValues(X)),thisConfigInfoStruct,'UniformOutput',false);
                end
            end
            configInfo=[configInfo{:}];
        elseif iscell(configInfo)&&(isempty(configInfo)||~iscell(configInfo{1}))
            configInfo={configInfo};
        else
            configInfo=configInfo(:)';
        end
    else
        if iscell(configInfo)&&(isempty(configInfo)||~iscell(configInfo{1}))
            configInfo={configInfo};
        end
    end



    if~isstruct(configInfo)
        cfgStruct=struct('Name','Configuration','VariantControls',{{}});
        cfgStruct=repmat(cfgStruct,1,numel(configInfo));

        for cfgId=1:numel(configInfo)
            cfgStruct(cfgId).Name=['Configuration',num2str(cfgId)];
            if isempty(configInfo{cfgId})




                continue;
            end
            cfgStruct(cfgId).VariantControls=configInfo{cfgId};
        end
        configInfo=cfgStruct;
    end

end


function ctrlVarNameValues=i_convertCtrlVarNameValues(ctrlVarNameValues)
    fieldnamesConfigInfo=fieldnames(ctrlVarNameValues);
    ctrlVarNameValues=cellfun(@(X)({X,ctrlVarNameValues.(X)}),fieldnamesConfigInfo,'UniformOutput',false);
    ctrlVarNameValues=[ctrlVarNameValues{:}];
end


