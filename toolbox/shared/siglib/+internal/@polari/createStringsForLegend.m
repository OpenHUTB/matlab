function strs=createStringsForLegend(p)





    strs=p.pDataLabels;



    N=getNumDatasets(p);
    if N>1




        activeStr=[' ',internal.polariCommon.getUTFCircleChar('A')];

        labelStr=strs{p.pCurrentDataSetIndex};
        if isvector(labelStr)&&ischar(labelStr)

            labelStr=sprintf('%s%s',labelStr,activeStr);
        else





            t=cellstr(labelStr);
            t{1}=sprintf('%s%s',t{1},activeStr);
            labelStr=char(t);
        end


        strs{p.pCurrentDataSetIndex}=labelStr;
    end
