function[str,istruncated]=truncateString(str,MAXLENDISP)













    if strlength(str)>MAXLENDISP


        str=extractBefore(str,MAXLENDISP+1)+"  ";


        idxOp=regexp(str,'+|-|,|\n');


        if~isempty(idxOp)
            str=extractBefore(str,idxOp(end)+2);
        else



            if strlength(str)>7
                str=extractBefore(str,strlength(str)-7);
            end
        end


        str=str+"...";


        istruncated=true;
    else

        istruncated=false;
    end
