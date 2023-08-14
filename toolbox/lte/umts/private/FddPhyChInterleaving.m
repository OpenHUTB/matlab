


























function[out]=FddPhyChInterleaving(inputs,modulation)


    if(isempty(inputs))
        out=[];
        return
    end


    if nargin==1
        modulation=0;
    end


    channels=size(inputs,2);


    if iscell(inputs)


        if size(inputs,1)~=1
            error('umts:error','The cell array must be in [1xN] format');
        end

        out=cell(1,channels);

    else

        if size(inputs,1)==1
            channels=1;
        end
        out=[];
    end


    if(iscell(inputs))
        for i=1:channels
            if isempty(inputs{i})
                out{i}=[];
            else
                isrl=isreal(inputs{i});
                out{i}=fdd('SecInterleaver',inputs{i},modulation,isrl);
            end


            if(size(inputs{i},1)==1)
                if(size(out{i},2)==1)
                    out{i}=out{i}.';
                end
            elseif(size(inputs{i},2)==1)
                if(size(out{i},1)==1)
                    out{i}=out{i}.';
                end
            end;
        end
    else
        if channels==1
            isrl=isreal(inputs);
            out=fdd('SecInterleaver',inputs,modulation,isrl);
        else

            for i=1:channels
                isrl=isreal(inputs(:,i));
                out(:,i)=fdd('SecInterleaver',inputs(:,i),modulation,isrl).';
            end
        end
        if~(isequal(size(inputs),size(out)))
            out=out.';
        end
    end
end