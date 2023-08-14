function rows=createTableCellInfo(execCnt,index,minVal,maxVal,tableDims,isJustified)




































    if nargin<6
        isJustified=false;
    end

    if nargin<5
        tableDims=[];
    end
    rows=cell(2,2);

    if isempty(maxVal)

        rows{1,1}=sprintf('%s',getString(message('Slvnv:simcoverage:cvtablecell:BreakPointN',index)));
        rows{2,2}=sprintf('X = %g',minVal);
        rows{2,1}=getString(message('Slvnv:simcoverage:cvtablecell:Value'));

    elseif isempty(minVal)

        rows{1,1}=sprintf('%s',getString(message('Slvnv:simcoverage:cvtablecell:BreakPointN',index)));
        rows{2,2}=sprintf('Y = %g',maxVal);
        rows{2,1}=getString(message('Slvnv:simcoverage:cvtablecell:Value'));

    else

        if any(isNotANum(minVal))||any(isNotANum(maxVal))
            regionStr=getString(message('Slvnv:simcoverage:cvtablecell:ExtrapolationSaturation'));
        else
            regionStr=getString(message('Slvnv:simcoverage:cvtablecell:Interpolation'));
        end


        switch(length(index))
        case 1
            rows{1,1}=sprintf('%s',getString(message('Slvnv:simcoverage:cvtablecell:InterpolationIntervalN',index(1))));



            rows{3,1}=getString(message('Slvnv:simcoverage:cvtablecell:Interval'));
            if isNotANum(maxVal(1))
                rowDispStr=sprintf('X &gt; %g',minVal(1));
            elseif isNotANum(minVal(1))
                rowDispStr=sprintf('X &lt; %g',maxVal(1));
            else







                if abs(minVal(1))<abs(maxVal(1))
                    if(index==2)
                        rowDispStr=sprintf('%g &lt;= X &lt;= %g',minVal(1),maxVal(1));
                    else
                        rowDispStr=sprintf('%g &lt; X &lt;= %g',minVal(1),maxVal(1));
                    end
                else
                    if(~isempty(tableDims)&&(index==(tableDims-1)))
                        rowDispStr=sprintf('%g &lt;= X &lt;= %g',minVal(1),maxVal(1));
                    else
                        rowDispStr=sprintf('%g &lt;= X &lt; %g',minVal(1),maxVal(1));
                    end
                end
            end


        case 2
            rows{1,1}=sprintf('%s',getString(message('Slvnv:simcoverage:cvtablecell:InterpolationIntervalMN',index(1),index(2))));



            rows{3,1}=getString(message('Slvnv:simcoverage:cvtablecell:Row'));
            if isNotANum(maxVal(1))
                rowDispStr=sprintf('X &gt; %g',minVal(1));
            elseif isNotANum(minVal(1))
                rowDispStr=sprintf('X &lt; %g',maxVal(1));
            else
                if(index(1)==2||minVal(1)<0)
                    leftRelation='&lt;=';
                else
                    leftRelation='&lt;';
                end

                if(maxVal(1)>=0||(~isempty(tableDims)&&index(1)==tableDims(1)))
                    rightRelation='&lt;=';
                else
                    rightRelation='&lt;';
                end

                rowDispStr=sprintf('%g %s X %s %g',minVal(1),leftRelation,rightRelation,maxVal(1));
            end



            if isNotANum(maxVal(2))
                colDispStr=sprintf('Y &gt; %g',minVal(2));
            elseif isNotANum(minVal(2))
                colDispStr=sprintf('Y &lt; %g',maxVal(2));
            else
                if(index(2)==2||minVal(2)<0)
                    leftRelation='&lt;=';
                else
                    leftRelation='&lt;';
                end

                if(maxVal(2)>=0||(~isempty(tableDims)&&index(2)==tableDims(2)))
                    rightRelation='&lt;=';
                else
                    rightRelation='&lt;';
                end

                colDispStr=sprintf('%g %s Y %s %g',minVal(2),leftRelation,rightRelation,maxVal(2));
            end
            rows{4,1}=getString(message('Slvnv:simcoverage:cvtablecell:Column'));
            rows{4,2}=colDispStr;

        otherwise
            error(message('Slvnv:simcoverage:cvtablecell:TableWithMoreThan2D'));
        end

        rows{2,1}=getString(message('Slvnv:simcoverage:cvtablecell:Region'));
        rows{2,2}=regionStr;
        rows{3,2}=rowDispStr;
    end

    if isJustified
        rows{end+1,1}=getString(message('Slvnv:simcoverage:cvtablecell:ExecJustified'));
        rows{end,2}=' ';
    else
        rows{end+1,1}=getString(message('Slvnv:simcoverage:cvtablecell:ExecutionCounts'));
        rows{end,2}=sprintf('%g',execCnt);
    end
end

function trueOrFalse=isNotANum(a)
    trueOrFalse=arrayfun(@(x)(isinf(x)||isnan(x)),a);
end