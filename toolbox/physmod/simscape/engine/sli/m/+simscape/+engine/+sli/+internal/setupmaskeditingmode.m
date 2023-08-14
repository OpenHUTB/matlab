function setupmaskeditingmode(mo,mode,theProduct)





    if~isempty(theProduct)
        if strcmp(mode,'Restricted')
            readOnlySetting='on';
            enableSetting='off';
        else
            readOnlySetting='off';
            enableSetting='on';
        end

        p=mo.Parameters;
        readOnly={p.ReadOnly};
        diffSetting=~strcmp(readOnly,readOnlySetting);
        if any(diffSetting)
            iDif=find(diffSetting);
            for idx=1:numel(iDif)
                p(iDif(idx)).ReadOnly=readOnlySetting;
            end
        end

        enables=get_param(mo.getOwner().handle,'MaskEnables');
        if any(~strcmp(enables,enableSetting))
            enables=repmat({enableSetting},size(enables));
            set_param(mo.getOwner().handle,'MaskEnables',enables);
        end
    end

end
