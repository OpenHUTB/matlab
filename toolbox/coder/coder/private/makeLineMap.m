function M=makeLineMap(text,unicodemap)










    stride=128;
    lines=[];
    cols=[];

    function buildMap()

        lines=zeros(1,floor(numel(text)/stride)+1,'int32');
        cols=zeros(1,floor(numel(text)/stride)+1,'int32');



        lineBegins=[0,emcLinePositions(text),numel(text)]+1;

        positions=1:stride:numel(text);
        line=1;
        for i=1:numel(positions)


            pos=positions(i);


            for k=line+1:numel(lineBegins)



                if lineBegins(k)>pos
                    line=k-1;
                    break;
                end
            end

            col=pos-lineBegins(line)+1;
            lines(i)=line;
            cols(i)=col;
        end
    end

    function[line,col]=lookup(pos,needUnicodeConversion)

        if numel(text)==0
            line=int32(1);
            col=int32(1);
            return;
        end

        if isempty(lines)

            buildMap();
        end

        if nargin<2
            needUnicodeConversion=true;
        end

        if pos<0
            pos=0;
        elseif needUnicodeConversion
            pos=uniposition(unicodemap,pos,pos);
        end


        pos=pos+1;




        pos=min(pos,numel(text)+1);

        offset=floor(double(pos-1)/stride)+1;

        line=lines(offset);
        col=cols(offset);
        actualPos=(offset-1)*stride+1;




        subText=text(actualPos:(pos-1));
        lineBegins=emcLinePositions(subText)+1;

        line(:)=line+numel(lineBegins);
        if isempty(lineBegins)

            col(:)=col+(pos-actualPos);
        else
            actualPos=actualPos+lineBegins(end)-1;
            col(:)=pos-actualPos+1;
        end

    end

    M=@lookup;

end

