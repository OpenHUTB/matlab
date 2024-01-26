function[out]=FddConstellationRearranging(inputs,modulation,contver,logical)

    if(isempty(inputs))
        out=[];
        return
    end

    if nargin==3
        logical=0;
    end

    channels=size(inputs,2);

    if iscell(inputs)

        if size(inputs,1)~=1
            error('umts:error','The cell array must be in [1xN] format');
        end

        out=cell(1,channels);

    else
        out=[];
    end

    if((ischar(modulation)||isstring(modulation))&&strcmpi(modulation,'QPSK'))||(isnumeric(modulation)&&(modulation==0))

        out=inputs;
    else

        if(iscell(inputs))

            for i=1:channels
                if isempty(inputs{i})
                    out{i}=[];
                else
                    out{i}=double(fdd('ConstRearranger',inputs{i},modulation,contver,logical));
                end

                if(size(inputs{i},1)==1)
                    if(size(out{i},2)==1)
                        out{i}=out{i}.';
                    end
                elseif(size(inputs{i},2)==1)
                    if(size(out{i},1)==1)
                        out{i}=out{i}.';
                    end
                end
            end
        else

            if size(inputs,1)==1
                out=double(fdd('ConstRearranger',inputs.',modulation,contver,logical));
            else
                for i=1:channels
                    out(:,i)=double(fdd('ConstRearranger',inputs(:,i),modulation,contver,logical)).';
                end
            end

        end
    end

end