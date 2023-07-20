function strs=createStringsForLegend(p)







    strs=p.pDataLabels;



    N=getNumDatasets(p);
    if N>1

        activeStr='';
        labelStr='';
        nodataflag=~isempty(p.pCurrentDataSetIndex);
        if nodataflag
            labelStr=strs{p.pCurrentDataSetIndex};
        end
        if isvector(labelStr)&&ischar(labelStr)

            labelStr=sprintf('%s%s',labelStr,activeStr);
        else





            t=cellstr(labelStr);
            t{1}=sprintf('%s%s',t{1},activeStr);
            labelStr=char(t);
        end


        if nodataflag
            strs{p.pCurrentDataSetIndex}=labelStr;
        end
    end
