function plotEnum(ts,pHandle)






    if(isenum(ts.Data))
        if(~isempty(ts.Data))
            val=ts.Data(1);
            enums=enumeration(val);


            enums=sort(enums);


            totalNumOfTicks=length(enums)+2;

            labels=cell(1,totalNumOfTicks);
            yticks=zeros(1,totalNumOfTicks);


            labels{1}='';

            for i=1:length(enums)
                labels{i+1}=enums(i).char;
                yticks(i+1)=enums(i).double;
            end


            labels{totalNumOfTicks}='';
            yticks(1)=yticks(2)-1;
            yticks(totalNumOfTicks)=yticks(totalNumOfTicks-1)+1;


            ylims=[yticks(1),yticks(totalNumOfTicks)];


            ax=pHandle.get('parent');


            ax.set('YLim',ylims);
            labels=regexprep(labels,'_','\\_');
            ax.set('YTickLabels',labels);
            ax.set('YTick',yticks);
        end
    end
end