function cacheNamedRangesInfo(this,showProgress)





    if nargin<2
        showProgress=false;
    end

    if showProgress
        rmiut.progressBarFcn('set',0.3,getString(message('Slvnv:slreq_import:ProcessingAnchorsOf',this.sName)));
    end





    [hNamedRanges,sheetIdx]=rmidotnet.MSExcel.getNamedRangesInWorkbook(this.hDoc);
    inThisSheet=(sheetIdx==this.iSheet);
    this.namedRanges=[];
    if any(inThisSheet)
        addresses=containers.Map('KeyType','char','ValueType','char');
        for idx=find(inThisSheet')
            hName=hNamedRanges.Item(idx);
            label=hName.NameLocal.char;
            if any(label=='!')
                if contains(label,'!Print_Area')
                    continue;
                end
                if contains(label,'!_Toc')
                    continue;
                end
                [~,name]=strtok(label,'!');
                label=name(2:end);
            end

            try


                hRange=hName.RefersToRange;
            catch ex %#ok<NASGU>
                rmiut.warnNoBacktrace('Slvnv:slreq_import:NamedRangeIsInvalid',hName.NameLocal.char);



                continue;
            end

            address=[hRange.Row,hRange.Column];
            range=[hRange.Rows.Count,hRange.Columns.Count];
            addressHash=sprintf('%d.%d',address(1),address(2));
            if isKey(addresses,addressHash)

                rmiut.warnNoBacktrace('Slvnv:slreq_import:NamedRangeIsSameAddress',label,addresses(addressHash));
            else
                addresses(addressHash)=label;
                this.namedRanges(end+1).label=label;
                this.namedRanges(end).address=address;
                this.namedRanges(end).range=range;
            end
        end
    end
end

