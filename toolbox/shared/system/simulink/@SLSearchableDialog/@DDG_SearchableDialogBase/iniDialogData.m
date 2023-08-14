function iniDialogData(this)




    block=this.getBlock();
    maskObj=Simulink.Mask.get(block.Handle);
    paraObj=maskObj.Parameters;
    lstParams={paraObj(:).Name};
    num_params=length(lstParams);


    this.DialogData.Delay=0.3;


    this.DialogData.NumParams=num_params;
    this.DialogData.ListParams=lstParams;
    this.DialogData.ListPrompt={paraObj(:).Prompt};
    this.DialogData.ListType={paraObj(:).Type};
    this.DialogData.ListEnum={paraObj(:).TypeOptions};
    this.DialogData.ListValue={paraObj(:).Value};
    this.DialogData.ListEnabled=this.str2logic({paraObj(:).Enabled});
    this.DialogData.ListVisible=this.str2logic({paraObj(:).Visible});


    this.DialogData.FilterExp='';
    this.DialogData.OldFilterExp=this.DialogData.FilterExp;
    this.DialogData.DefaultNumItem=num_params;
    this.DialogData.NumItemAllowed=this.DialogData.DefaultNumItem;
    this.DialogData.ShowList=this.DialogData.ListVisible;
    this.DialogData.NumItemTotal=sum(this.DialogData.ShowList);
    this.DialogData.hSearchFcn=@regexpi;
    this.DialogData.CaseSensitive=false;
    this.DialogData.RegexpSupport=false;


    this.DialogData.PromptLength=cellfun(@length,this.DialogData.ListPrompt);
    this.DialogData.ValueLength=cellfun(@length,this.DialogData.ListValue);


    for i=1:num_params
        if strcmp(this.DialogData.ListType{i},'checkbox')
            this.DialogData.ValueLength(i)=1;
            if strcmp(this.DialogData.ListValue{i},'off')
                this.DialogData.ListValue{i}=false;
            else
                this.DialogData.ListValue{i}=true;
            end
        elseif strcmp(this.DialogData.ListType{i},'popup')
            this.DialogData.ValueLength(i)=max(cellfun(@length,this.DialogData.ListEnum{i}));
            this.DialogData.ListType{i}='combobox';
            num_enum=size(this.DialogData.ListEnum{i},1);
            for j=1:num_enum
                if strcmp(this.DialogData.ListValue{i},this.DialogData.ListEnum{i}{j})
                    this.DialogData.ListValue{i}=j-1;
                    break;
                end
            end
        end
    end
    this.DialogData.ListOldValue=this.DialogData.ListValue;


    this.DialogData.ShowListIndex=find(this.DialogData.ShowList);
    this.DialogData.ChangeList=zeros(1,num_params);

end
