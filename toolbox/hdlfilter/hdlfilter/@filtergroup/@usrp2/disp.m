function disp(this)





    disp(['     FilterGroup: ',this.FilterStructure]);
    disp(['         RxChain: ',this.RxChain.FilterStructure]);
    if strcmp(this.RxChain.FilterStructure,'Cascade')
        for stg=1:length(this.RxChain.Stage)
            disp(['            Stage(',num2str(stg),'):',this.RxChain.Stage(stg).FilterStructure]);
        end
    end
    disp(['         TxChain: ',this.TxChain.FilterStructure]);
    if strcmp(this.TxChain.FilterStructure,'Cascade')
        for stg=1:length(this.TxChain.Stage)
            disp(['            Stage(',num2str(stg),'):',this.TxChain.Stage(stg).FilterStructure]);
        end
    end
    disp(' ');

