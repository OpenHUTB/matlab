



function tid=tsToTid(sampleTime,tsTable)

    j=cellfun(@(x)(ismatch(sampleTime.getPeriod(),x(1))...
    &&ismatch(sampleTime.getOffset(),x(2))),...
    tsTable);




    if(sum(j)==0)
        tid=-1;
        return
    end


    assert(sum(j)==1,...
    'No matching discrete sample time found in sample time table.');

    tid=find(j==1)-1;
end

function out=ismatch(a,b)
    if isinf(a)&&isinf(b)
        out=true;
    else
        if abs(a-b)==0
            out=true;
        else
            out=abs(a-b)<=eps(min(abs(a),abs(b)));
        end
    end
end