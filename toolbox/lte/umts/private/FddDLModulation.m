




















function[out]=FddDLModulation(inputs,modulation)


    if(isempty(inputs))
        out=[];
        return
    end


    channels=size(inputs,2);
    orientation=0;

    if iscell(inputs)


        if size(inputs,1)~=1
            error('umts:error','The cell array must be in [1xN] format');
        end

        out=cell(1,channels);

    else

        if size(inputs,1)==1
            inputs=inputs.';
            channels=1;
            orientation=1;
        end
        out=[];
    end


    if(iscell(inputs))
        for i=1:channels
            if isempty(inputs{i})
                out{i}=[];
            else
                out{i}=double(fdd('DLModulation',inputs{i},modulation));
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
        for i=1:channels
            out(:,i)=double(fdd('DLModulation',inputs(:,i),modulation)).';
        end
        if orientation==1
            if size(out,1)~=1
                out=out.';
            end
        end
    end
end