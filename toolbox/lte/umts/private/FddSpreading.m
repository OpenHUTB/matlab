







































function[out]=FddSpreading(datain,spreadFactor,spreadCode,matrixOut)


    if isempty(datain)
        out=[];
        return
    end


    if nargin==3
        matrixOut=0;
    end


    spreadFactor=double(spreadFactor);
    [out,datain,channels,orientation]=setupSpread(datain,spreadFactor,spreadCode,matrixOut);





    if(iscell(datain))


        out=cell(1,channels);

        for i=1:channels



            if isempty(datain{i})
                out{i}=[];
            else

                if(size(datain{i},1)==1)


                    Y=double(fdd('OVSFCode',log2(spreadFactor(i)),spreadCode(i)));


                    out{i}=kron(double(datain{i}),Y);

                    if(size(out{i},2)==1)
                        out{i}=out{i}.';
                    end
                elseif(size(datain{i},2)==1)


                    Y=double(fdd('OVSFCode',log2(spreadFactor(i)),spreadCode(i)));


                    out{i}=kron(double(datain{i}).',Y);

                    if(size(out{i},1)==1)
                        out{i}=out{i}.';
                    end

                end;
            end;
        end
        if matrixOut==1
            out=makeMat(out);
        end


    else


        SF=spreadFactor(1);




        if isempty(find(spreadFactor~=SF,1))


            out=[];


            for i=1:channels


                Y=double(fdd('OVSFCode',log2(spreadFactor(i)),spreadCode(i)));


                out(:,i)=kron(double(datain(:,i)).',Y).';

            end;
            if orientation==1
                if size(out,1)~=1
                    out=out.';
                end
            end


        else


            out=cell(1,channels);

            for i=1:channels


                Y=double(fdd('OVSFCode',log2(spreadFactor(i)),spreadCode(i)));



                out{i}=kron(double(datain(:,i)).',Y).';

            end;

            out=makeMat(out);


        end;
    end;
end


function[out,datain,channels,orientation]=setupSpread(datain,spreadFactor,spreadCode,matrixOut)

    if(iscell(datain))

        if size(datain,1)~=1
            error('umts:error','The cell array must be in [1xN] format');
        else
            out=cell(datain);
        end
    else
        out=[];
    end;


    channels=size(datain,2);
    if~iscell(datain)&&size(datain,1)==1
        datain=datain.';
        channels=1;
        orientation=1;
    else
        orientation=0;
    end

    if channels~=length(spreadFactor)
        error('umts:error','Spreading factor vector length does not match number of input channels');
    end;


    if channels~=length(spreadCode)
        error('umts:error','Spreading code vector length does not match number of input channels');
    end;


    for i=1:channels


        if rem(log2(spreadFactor(i)),1)~=0
            error('umts:error','Spreading factor must be a power of 2');
        end;


        validateUMTSParameter('SpreadingCode',spreadCode(i));
        if spreadCode(i)>(spreadFactor(i)-1)||spreadCode(i)<0
            error('umts:error','For the given SlotFormat, the SpreadingCode value must be 0 to %d',spreadFactor-1);
        end;

    end;


    if matrixOut<0||matrixOut>1
        error('umts:error','matrixOut parameter must take value 0 or 1');
    end;

end



function[out]=makeMat(outCA)
    channels=length(outCA);

    matlength=0;
    for i=1:channels

        matlength=max(matlength,length(outCA{i}));
    end


    out=zeros([matlength,channels]);


    for i=1:channels
        if size(outCA{i},2)~=1
            outCA{i}=outCA{i}.';
        end
        out(:,i)=cat(1,outCA{i},zeros(matlength-length(outCA{i}),1));
    end

end
