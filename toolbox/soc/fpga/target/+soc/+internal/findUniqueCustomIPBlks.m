function[cstmIPBlks,internalCstmIPBlks]=findUniqueCustomIPBlks(modelName)


    [cstmIPBlks,internalCstmIPBlks]=soc.internal.findAllCustomIPBlks(modelName);

    if numel(internalCstmIPBlks)>1







        [~,idx,~]=unique(get_param(internalCstmIPBlks,'ipInstanceName'),'stable');
        cstmIPBlks=cstmIPBlks(idx);
        internalCstmIPBlks=internalCstmIPBlks(idx);

    end

end