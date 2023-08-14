function[vectorStr,numParens,compact]=getVectorString(vec,contiguous,respectOrientation,expandNonCompact)





























    scalar=isscalar(vec);
    if nargin<4
        expandNonCompact=true;
        if nargin<3
            respectOrientation=false;
        end
    end
    if nargin<2||isempty(contiguous)

        contiguous=scalar||...
        ((vec(2)==vec(1)+1)&&...
        isequal(vec(:)',vec(1):vec(end)));
    end

    if respectOrientation
        colonVec=size(vec,1)>1;
    else


        colonVec=false;
    end


    numParens=0;

    compact=true;

    if scalar

        vectorStr=string(vec);
    elseif contiguous

        vectorStr=vec(1)+":"+vec(end);
        if colonVec
            vectorStr="("+vectorStr+")'";
            numParens=1;
        end
    elseif all(vec==vec(1),'all')

        if vec(1)==1
            vec1Str="";
        else
            vec1Str=vec(1)+"*";
        end
        if colonVec
            vectorStr=vec1Str+"ones("+numel(vec)+",1)";
        else
            vectorStr=vec1Str+"ones(1,"+numel(vec)+")";
        end
        numParens=1;
    else

        compact=false;
        if expandNonCompact
            vectorStr="["+strjoin(string(vec))+"]";
            if colonVec
                vectorStr=vectorStr+"'";
            end
            numParens=1;
        else
            vectorStr="";
            numParens=0;
        end
    end
