function[align1,align2,score]=diffcode(seq1,seq2,threshold)












    if nargin<3





        threshold=10000;
    end

    try


        [align1,align2,score]=trydiffcode(seq1,seq2,threshold);
    catch E
        if strcmp(E.identifier,'MATLAB:nomem')

            [align1,align2,score]=feval(mfilename,seq1,seq2,floor(threshold/2));
        else
            rethrow(E);
        end
    end

end




function[align1,align2,score]=trydiffcode(seq1,seq2,THRESHOLD)

    scale=numel(seq1)+numel(seq2);
    if scale>=(THRESHOLD*2)






        MINMATCH=floor(THRESHOLD*3/4);

        i1=1;
        i2=1;
        ialign=1;
        align1=zeros(1,scale);
        align2=zeros(1,scale);
        end1=false;
        end2=false;
        while~end1||~end2

            if numel(seq1)-i1-1>THRESHOLD
                subseq1=seq1(i1:i1+THRESHOLD-1);
            else
                subseq1=seq1(i1:end);
                end1=true;
            end

            if numel(seq2)-i2-1>THRESHOLD
                subseq2=seq2(i2:i2+THRESHOLD-1);
            else
                subseq2=seq2(i2:end);
                end2=true;
            end

            [subalign1,subalign2,score]=diffcode_section(subseq1,subseq2);

            if end1==true&&end2==true

                lastmatch=numel(subalign1);
            else
                lastmatch=find(subalign1~=0&subalign2~=0,1,'last');
                if isempty(lastmatch)||lastmatch<MINMATCH;


                    lastmatch=MINMATCH;
                end
            end



            subalign1(subalign1==0)=1-i1;
            subalign2(subalign2==0)=1-i2;
            align1(ialign:ialign+lastmatch-1)=subalign1(1:lastmatch)+i1-1;
            align2(ialign:ialign+lastmatch-1)=subalign2(1:lastmatch)+i2-1;

            i1=i1+max([0,subalign1(1:lastmatch)]);
            i2=i2+max([0,subalign2(1:lastmatch)]);
            ialign=ialign+lastmatch;
        end

        align1=align1(1:ialign-1);
        align2=align2(1:ialign-1);
    else



        [align1,align2,score]=diffcode_section(seq1,seq2);
    end
end





function[align1,align2,score]=diffcode_section(seq1,seq2)


    north=uint8(1);addseq2=uint8(4);
    west=uint8(2);addseq1=uint8(3);


    if iscell(seq1)
        seq1=hashseq(seq1);
        seq2=hashseq(seq2);
    end

    n=length(seq1);
    m=length(seq2);
    max=n+m+1;
    mapI=mapInd(max);
    shift=max+1;

    [VD,Vmove,D]=myersDiff(seq1,seq2,north,west);






    k=n-m;
    score=0;
    xs=zeros(1,D);ys=zeros(1,D);ms=zeros(1,D);
    for Di=D:-1:1
        nextMove=Vmove{Di+1}(mapI(k+shift));
        if nextMove==west
            k=k-1;
            move=addseq1;
        elseif nextMove==north
            k=k+1;
            move=addseq2;
        end
        xs(Di)=VD{Di+1}(mapI(k+shift));
        ys(Di)=xs(Di)-k;
        ms(Di)=move;
    end



    align_count=0;
    align1=zeros(1,n+m);
    align2=zeros(1,n+m);
    i=0;j=0;
    for d=1:length(ms)
        nextInserti=xs(d);
        nextInsertj=ys(d);
        nextInsertMove=ms(d);
        while i~=nextInserti&&j~=nextInsertj
            i=i+1;j=j+1;
            align_count=align_count+1;
            align1(align_count)=i;
            align2(align_count)=j;
            score=score+1;
        end
        if nextInsertMove==addseq1
            i=i+1;
            align_count=align_count+1;
            align1(align_count)=i;
        elseif nextInsertMove==addseq2
            j=j+1;
            align_count=align_count+1;
            align2(align_count)=j;
        end
    end

    while i<n&&j<m
        i=i+1;j=j+1;
        align_count=align_count+1;
        align1(align_count)=i;
        align2(align_count)=j;
        score=score+1;
    end

    align1=align1(1:align_count);
    align2=align2(1:align_count);

    [align1,align2]=alignModifys(align1,align2);


    function[dOld,dNew]=alignModifys(dOld,dNew)

        symbolDiff={};
        stack={};
        addedLines=[];deletedLines=[];
        p=1;
        while p<=length(dOld)
            if dOld(p)==0
                stack{end+1}='>';
                deletedLines=[deletedLines,p];
            elseif dNew(p)==0
                stack{end+1}='<';
                addedLines=[addedLines,p];
            else
                analyseStack();
            end
            p=p+1;
        end

        analyseStack();






        function analyseStack()


            if length(addedLines)*length(deletedLines)>0

                modLines=min(length(addedLines),length(deletedLines));
                added=length(addedLines)-modLines;
                deleted=length(deletedLines)-modLines;

                stack=repmat({'x'},1,modLines);
                stack=[stack,repmat('>',1,deleted)];
                stack=[stack,repmat('<',1,added)];

                stackLines=sort([deletedLines,addedLines]);

                dOld(stackLines)=zerosLast(dOld(stackLines));
                dNew(stackLines)=zerosLast(dNew(stackLines));

                dOld(stackLines(end-modLines+1:end))=[];
                dNew(stackLines(end-modLines+1:end))=[];
                p=p-modLines;
            end

            symbolDiff=[symbolDiff,stack,'.'];
            stack={};
            addedLines=[];deletedLines=[];
        end


        function order=zerosLast(order)
            zeroIn=find(order==0);
            nonZeroIn=find(order~=0);
            order=order([nonZeroIn,zeroIn]);
        end

    end




    function[VD,Vmove,D]=myersDiff(seq1,seq2,north,west)



        V(mapI(1+shift))=zeros(1,1,'int32');
        for D=0:max


            Vt=zeros(1,2*D+1,'uint8');
            for kk=-D:2:D
                if kk==-D||(kk~=D&&V(mapI(kk-1+shift))<V(mapI(kk+1+shift)))
                    x=V(mapI(kk+1+shift));
                    type=north;
                else
                    x=V(mapI(kk-1+shift))+1;
                    type=west;
                end
                y=x-kk;

                while x<n&&y<m&&seq1(x+1)==seq2(y+1)
                    x=x+1;y=y+1;
                end
                V(mapI(kk+shift))=x;
                Vt(mapI(kk+shift))=type;
                if x>=n&&y>=m
                    Vt=Vt(1:mapI(kk+shift));
                    VD{D+1}=V;%#ok<AGROW>
                    Vmove{D+1}=Vt;%#ok<AGROW>
                    VD=VD(1:D+1);
                    Vmove=Vmove(1:D+1);
                    return
                end
            end
            Vmove{D+1}=Vt;%#ok<AGROW>
            VD{D+1}=V;%#ok<AGROW>
        end
    end

end



function h=hashseq(s)
    h=zeros(size(s));
    s2=regexprep(s,'\W','');
    for i=1:length(s2)
        if isempty(s2{i})

            str=s{i};
            str(str==' ')=[];
            h(i)=hash(str);
        else
            h(i)=hash(s2{i});
        end
    end
end


function h=hash(s)
    if isempty(s)
        h=0;
    else
        h=sum(s.*(1:length(s)));
    end
end



function mapI=mapInd(max)
    mapI=zeros(1,2*max+1);
    for k=-max:max
        if k>=0
            newK=2*k+1;
        else
            newK=2*(-k);
        end
        mapI(k+max+1)=newK;
    end
end
