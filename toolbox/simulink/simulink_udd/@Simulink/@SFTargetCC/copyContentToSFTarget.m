function copyContentToSFTarget(hObj,hSFTarget)



    fields=hObj.fields;

    for i=1:length(fields)

        switch fields{i}
        case{'Components','SelectedCmd','TargetOptionsDlg','CoderOptionsDlg',...
            'Id'}

        case 'CodeFlagsInfo'
            codeFlags=get(hObj,'CodeFlagsInfo');
            for j=1:length(codeFlags)
                codeFlag=codeFlags(j);
                try
                    hSFTarget.setCodeFlag(codeFlag.name,codeFlag.value);
                catch



                end
            end
        otherwise



            prop=findprop(hSFTarget,fields{i});
            if~isempty(prop)
                try
                    set(hSFTarget,fields{i},get(hObj,fields{i}));
                catch



                end
            end
        end
    end




