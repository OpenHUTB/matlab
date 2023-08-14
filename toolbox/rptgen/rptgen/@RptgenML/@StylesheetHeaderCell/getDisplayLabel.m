function dLabel=getDisplayLabel(this)




    if isempty(this.JavaHandle)
        dLabel=['[[',getString(message('rptgen:RptgenML_StylesheetHeader:undefinedLabel')),']]'];
    else
        dLabel=this.Test;
        specialTest=this.listTestSpecial;

        specialIdx=find(strcmp(dLabel,specialTest(:,1)));
        if isempty(specialIdx)
            dLabel=rptgen.truncateString(dLabel);
        else
            dLabel=specialTest{specialIdx(1),2};
        end
    end
