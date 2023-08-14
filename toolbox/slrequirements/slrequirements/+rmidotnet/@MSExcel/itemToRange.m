function hRange=itemToRange(this,item,option)

    switch item.type
    case 'bookmark'
        try
            hName=this.hSheetNames.Item(item.label);
            hRange=hName.RefersToRange;
        catch



            rageString=rmidotnet.MSExcel.itemToRangeString(item,'all');
            hRange=this.hSheet.Range(rageString);
        end

    otherwise

        if nargin<3


            option='all';
        end
        rangeString=rmidotnet.MSExcel.itemToRangeString(item,option);
        hRange=this.hSheet.Range(rangeString);
    end

end


