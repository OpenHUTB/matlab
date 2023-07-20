function rows=createTableCellInfoNoBreakValue(execCnt,index,hasMin,hasMax,intervalMin,intervalMax,tableDims,isJustified)



































    try
        rows={};

        if isempty(hasMax)||isempty(hasMin)
            brkpIndex=index;


            dimIndex=tableDims;
            [minStr,maxStr]=getMinMaxStr(dimIndex,brkpIndex,intervalMin,brkpIndex,intervalMax);
            if isempty(hasMax)
                bpName=minStr;
            else
                bpName=maxStr;
            end
            rows{1,1}=sprintf('%s',getString(message('Slvnv:simcoverage:cvtablecell:BreakName',bpName)));

        else

            if all(hasMin)&&all(hasMax)
                regionStr=getString(message('Slvnv:simcoverage:cvtablecell:Interpolation'));
            else
                regionStr=getString(message('Slvnv:simcoverage:cvtablecell:ExtrapolationSaturation'));
            end



            switch(length(index))
            case 1
                rows{1,1}=sprintf('%s',getString(message('Slvnv:simcoverage:cvtablecell:InterpolationIntervalN',index(1))));

                brkpIndexMin=index(1)-1;
                brkpIndexMax=index(1);
                [minStr,maxStr]=getMinMaxStr(1,brkpIndexMin,intervalMin,brkpIndexMax,intervalMax);


                rows{3,1}=getString(message('Slvnv:simcoverage:cvtablecell:Interval'));
                if~any(hasMax(1))
                    rowDispStr=sprintf('u &gt; %s',minStr);
                elseif~any(hasMin(1))

                    rowDispStr=sprintf('u &lt; %s',maxStr);
                else






                    brkpIndexMin=index(1)-1;
                    brkpIndexMax=index(1);


                    rowDispStr=minStr;


                    if hasMin(1)*brkpIndexMin<hasMax(1)*brkpIndexMax
                        if(index==2)
                            rowDispStr=[rowDispStr,' &lt;= u &lt;= '];
                        else
                            rowDispStr=[rowDispStr,' &lt; u &lt;= '];
                        end
                    else
                        if(~isempty(tableDims)&&(index==(tableDims-1)))
                            rowDispStr=[rowDispStr,' &lt;= u &lt;= '];
                        else
                            rowDispStr=[rowDispStr,' &lt;= u &lt; '];
                        end
                    end

                    rowDispStr=[rowDispStr,maxStr];
                end

            case 2
                rows{1,1}=sprintf('%s',getString(message('Slvnv:simcoverage:cvtablecell:InterpolationIntervalMN',index(1),index(2))));



                brkpIndexMin=index(1)-1;
                brkpIndexMax=index(1);
                [minStr,maxStr]=getMinMaxStr(1,brkpIndexMin,intervalMin(1),brkpIndexMax,intervalMax(1));
                if~any(hasMax(1))
                    rowDispStr=sprintf('u1 &gt; %s',minStr);
                elseif~any(hasMin(1))
                    rowDispStr=sprintf('u1 &lt; %s',maxStr);
                else
                    if(index(1)==2||hasMin(1)<0)
                        leftRelation='&lt;=';
                    else
                        leftRelation='&lt;';
                    end

                    if(hasMax(1)>=0||(~isempty(tableDims)&&index(1)==tableDims(1)))
                        rightRelation='&lt;=';
                    else
                        rightRelation='&lt;';
                    end

                    rowDispStr=sprintf('%s %s u1 %s %s',minStr,leftRelation,rightRelation,maxStr);
                end



                brkpIndexMin=index(2)-1;
                brkpIndexMax=index(2);
                [minStr,maxStr]=getMinMaxStr(2,brkpIndexMin,intervalMin(2),brkpIndexMax,intervalMax(2));

                if~any(hasMax(2))
                    colDispStr=sprintf('u2 &gt; %s',minStr);
                elseif~any(hasMin(2))
                    colDispStr=sprintf('u2 &lt; %s',maxStr);
                else
                    if(index(2)==2||hasMin(2)<0)
                        leftRelation='&lt;=';
                    else
                        leftRelation='&lt;';
                    end

                    if(hasMax(2)>=0||(~isempty(tableDims)&&index(2)==tableDims(2)))
                        rightRelation='&lt;=';
                    else
                        rightRelation='&lt;';
                    end

                    colDispStr=sprintf('%s %s u2 %s %s',minStr,leftRelation,rightRelation,maxStr);
                end
                rows{4,1}=getString(message('Slvnv:simcoverage:cvtablecell:Column'));
                rows{4,2}=colDispStr;

            otherwise
                error(message('Slvnv:simcoverage:cvtablecell:TableWithMoreThan2D'));
            end

            rows{2,1}=getString(message('Slvnv:simcoverage:cvtablecell:Region'));
            rows{2,2}=regionStr;
            rows{3,1}=getString(message('Slvnv:simcoverage:cvtablecell:Row'));
            rows{3,2}=rowDispStr;
        end

        if isJustified
            rows{end+1,1}=getString(message('Slvnv:simcoverage:cvtablecell:ExecJustified'));
            rows{end,2}=' ';
        else
            rows{end+1,1}=getString(message('Slvnv:simcoverage:cvtablecell:ExecutionCounts'));
            rows{end,2}=sprintf('%g',execCnt);
        end
    catch MEx
        rethrow(MEx);
    end
end

function[minStr,maxStr]=getMinMaxStr(idx,brkpIndexMin,intervalMin,brkpIndexMax,intervalMax)
    if isnan(intervalMax)
        maxStr=sprintf('B%g(%g)',idx,brkpIndexMax);
    else
        maxStr=sprintf('%g',intervalMax);
    end
    if isnan(intervalMin)
        minStr=sprintf('B%g(%g)',idx,brkpIndexMin);
    else
        minStr=sprintf('%g',intervalMin);
    end
end

