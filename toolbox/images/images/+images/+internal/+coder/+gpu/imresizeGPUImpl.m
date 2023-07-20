function[finalOut]=imresizeGPUImpl(im,scale,outputSize,kernel,kwidth,antialiasing)%#codegen




    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    in_rows=size(im,1);
    in_cols=size(im,2);


    out_rows=outputSize(1);
    out_cols=outputSize(2);


    rowDimScale=scale(1);
    colDimScale=scale(2);




    auxLength1=(in_rows*2);
    aux1=zeros(1,auxLength1);
    for i=1:auxLength1
        if(i<=in_rows)
            aux1(i)=i;
        else
            aux1(i)=(auxLength1-i+1);
        end
    end



    auxLength2=(in_cols*2);
    aux2=zeros(1,auxLength2);
    for i=1:auxLength2
        if(i<=in_cols)
            aux2(i)=i;
        else
            aux2(i)=(auxLength2-i+1);
        end
    end


    if(rowDimScale<1)&&(antialiasing)


        kwidthRow=kwidth/rowDimScale;
    else
        kwidthRow=kwidth;
    end


    ipRowIndices=zeros(out_rows,ceil(kwidthRow));
    rowWeights=zeros(out_rows,ceil(kwidthRow));







    if~coder.internal.isConst(size(im))&&coder.internal.isConst(outputSize)&&~antialiasing
        coder.varsize('ipRowIndices',[out_rows,kwidth],[true,true]);
        coder.varsize('rowWeights',[out_rows,kwidth],[true,true]);
    end


    for rowIdx=1:out_rows
        for k=1:ceil(kwidthRow)



            ipRowIdx=rowIdx/rowDimScale+0.5*(1-1/rowDimScale);

            left=ipRowIdx-kwidthRow/2;

            rowIndices=floor(left);


            distance=ipRowIdx-double(rowIndices+k);
            if(rowDimScale<1)&&(antialiasing)


                x=rowDimScale*distance;
            else
                x=distance;
            end

            switch kernel
            case 'cub'



                absx=abs(x);
                absx2=absx^2;
                absx3=absx^3;
                R=(1.5*absx3-2.5*absx2+1)*(absx<=1)+...
                (-0.5*absx3+2.5*absx2-4*absx+2)*...
                ((1<absx)&(absx<=2));
            case 'box'
                R=double((-0.5<=x)&(x<0.5));
            case 'tri'
                R=(x+1)*((-1<=x)&(x<0))+(1-x)*((0<=x)&(x<=1));
            case 'la2'


                R=(sin(pi*x)*sin(pi*x/2)+eps)/((pi^2*x^2/2)+eps);
                R=R*(abs(x)<2);
            case 'la3'


                R=(sin(pi*x)*sin(pi*x/3)+eps)/((pi^2*x^2/3)+eps);
                R=R*(abs(x)<3);
            otherwise
                R=x;
            end
            if(rowDimScale<1)&&(antialiasing)


                xout=rowDimScale*R;
            else
                xout=R;
            end

            auxLength=(in_rows*2);
            oldIdx=double(rowIndices+k);

            l=mod(oldIdx-1,double(auxLength));


            ipRowIndices(rowIdx,k)=aux1(l+1);


            rowWeights(rowIdx,k)=xout;
        end
    end


    if(colDimScale<1)&&(antialiasing)


        kwidthCol=kwidth/colDimScale;
    else
        kwidthCol=kwidth;
    end


    ipColIndices=zeros(out_cols,ceil(kwidthCol));
    colWeights=zeros(out_cols,ceil(kwidthCol));







    if~coder.internal.isConst(size(im))&&coder.internal.isConst(outputSize)&&~antialiasing
        coder.varsize('ipColIndices',[out_cols,kwidth],[true,true]);
        coder.varsize('colWeights',[out_cols,kwidth],[true,true]);
    end


    for colIdx=1:out_cols
        for k=1:ceil(kwidthCol)



            ipColIdx=colIdx/colDimScale+0.5*(1-1/colDimScale);

            left=ipColIdx-kwidthCol/2;

            colIndices=floor(left);


            distance=ipColIdx-double(colIndices+k);
            if(colDimScale<1)&&(antialiasing)


                x=colDimScale*distance;
            else
                x=distance;
            end

            switch kernel
            case 'cub'



                absx=abs(x);
                absx2=absx^2;
                absx3=absx^3;
                C=(1.5*absx3-2.5*absx2+1)*(absx<=1)+...
                (-0.5*absx3+2.5*absx2-4*absx+2)*...
                ((1<absx)&(absx<=2));
            case 'box'
                C=double((-0.5<=x)&(x<0.5));
            case 'tri'
                C=(x+1)*((-1<=x)&(x<0))+(1-x)*((0<=x)&(x<=1));
            case 'la2'


                C=(sin(pi*x)*sin(pi*x/2)+eps)/((pi^2*x^2/2)+eps);
                C=C*(abs(x)<2);
            case 'la3'


                C=(sin(pi*x)*sin(pi*x/3)+eps)/((pi^2*x^2/3)+eps);
                C=C*(abs(x)<3);
            otherwise
                C=x;
            end
            if(colDimScale<1)&&(antialiasing)


                xout=colDimScale*C;
            else
                xout=C;
            end

            auxLength=(in_cols*2);
            oldIdx=double(colIndices+k);

            l=mod(oldIdx-1,double(auxLength));


            ipColIndices(colIdx,k)=aux2(l+1);


            colWeights(colIdx,k)=xout;
        end
    end


    rowWeightsTotal=sum(rowWeights,2);
    colWeightsTotal=sum(colWeights,2);


    ROWS=true;
    if(rowDimScale>colDimScale)
        ROWS=false;
    end

    size_in=size(im);



    if(ndims(im)>3)
        dimSize=prod(size_in(3:end));
    else
        dimSize=size(im,3);
    end


    if ROWS

        partialResize=coder.nullcopy(zeros([out_rows,in_cols,dimSize],'like',im));

        for colIdx=1:in_cols
            for rowIdx=1:out_rows
                for dimIdx=1:dimSize
                    if(isreal(im))
                        sumVal=0.0;
                    else
                        sumVal=0.0+0.0i;
                    end

                    for l=1:ceil(kwidthRow)
                        sumVal=sumVal+double(im(ipRowIndices(rowIdx,l),colIdx,dimIdx))*(rowWeights(rowIdx,l)/double(rowWeightsTotal(rowIdx)));
                    end
                    partialResize(rowIdx,colIdx,dimIdx)=sumVal;
                end
            end
        end

        out=coder.nullcopy(zeros([out_rows,out_cols,dimSize],'like',im));

        for colIdx=1:out_cols
            for rowIdx=1:out_rows
                for dimIdx=1:dimSize
                    if(isreal(im))
                        sumVal=0.0;
                    else
                        sumVal=0.0+0.0i;
                    end

                    for l=1:ceil(kwidthCol)
                        sumVal=sumVal+double(partialResize(rowIdx,ipColIndices(colIdx,l),dimIdx))*(colWeights(colIdx,l)/colWeightsTotal(colIdx));
                    end
                    out(rowIdx,colIdx,dimIdx)=sumVal;
                end
            end
        end
    else

        partialResize=coder.nullcopy(zeros([in_rows,out_cols,dimSize],'like',im));

        for rowIdx=1:in_rows
            for colIdx=1:out_cols
                for dimIdx=1:dimSize
                    if(isreal(im))
                        sumVal=0.0;
                    else
                        sumVal=0.0+0.0i;
                    end

                    for l=1:ceil(kwidthCol)
                        sumVal=sumVal+double(im(rowIdx,ipColIndices(colIdx,l),dimIdx))*(colWeights(colIdx,l)/colWeightsTotal(colIdx));
                    end
                    partialResize(rowIdx,colIdx,dimIdx)=sumVal;
                end
            end
        end

        out=coder.nullcopy(zeros([out_rows,out_cols,dimSize],'like',im));

        for colIdx=1:out_cols
            for rowIdx=1:out_rows
                for dimIdx=1:dimSize
                    if(isreal(im))
                        sumVal=0.0;
                    else
                        sumVal=0.0+0.0i;
                    end

                    for l=1:ceil(kwidthRow)
                        sumVal=sumVal+double(partialResize(ipRowIndices(rowIdx,l),colIdx,dimIdx))*(rowWeights(rowIdx,l)/rowWeightsTotal(rowIdx));
                    end
                    out(rowIdx,colIdx,dimIdx)=sumVal;
                end
            end
        end
    end


    if(ndims(im)>3)

        size_out=size_in;

        size_out(1)=out_rows;
        size_out(2)=out_cols;
        finalOut=reshape(out,size_out);
    else
        finalOut=out;
    end