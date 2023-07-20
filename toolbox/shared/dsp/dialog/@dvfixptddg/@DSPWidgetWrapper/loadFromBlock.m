
function loadFromBlock(this)





    if~isempty(this.Block)
        for ind=1:length(this.PropNames)
            if strcmp(this.PropTypes{ind},'bool')
                this.(this.PropNames{ind})=...
                strcmpi(this.Block.(this.PropNames{ind}),'on');
            else
                this.(this.PropNames{ind})=this.Block.(this.PropNames{ind});
            end
        end
    end
