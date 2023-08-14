
























function[out]=FddULModulation(datain,modulation,iqed)


    if(isempty(datain))
        out=[];
        return
    end

    if ischar(modulation)||isstring(modulation)
        switch upper(modulation)
        case 'BPSK',modulation=0;
        case '4PAM',modulation=1;
        otherwise
            error('umts:error','The modulation parameter is not one of (''BPSK'',''4PAM'')');
        end
    end

    channels=size(datain,2);
    orientation=0;

    if iscell(datain)

        if size(datain,1)~=1
            error('umts:error','The cell array must be in [1xN] format');
        end

        out=cell(1,channels);

    else
        if size(datain,1)==1
            datain=datain.';
            channels=1;
            orientation=1;
        end
        out=zeros(size(datain));
    end
    if modulation==0
        if(iscell(datain))
            for i=1:channels
                if isempty(datain{i})
                    out{i}=[];
                else
                    out{i}=datain{i}.*(-2)+1;
                end
            end
        else
            out=datain.*(-2)+1;
        end
    else
        if(iscell(datain))
            for i=1:channels
                if isempty(datain{i})
                    out{i}=[];
                else
                    out{i}=double(fdd('ULModulation',datain{i},1));
                end
            end
        else
            out=zeros(length(datain(:,1))/(modulation+1),channels);
            for i=1:channels
                out(:,i)=double(fdd('ULModulation',datain(:,i),1));
            end
        end
    end


    if nargin==3
        for jj=1:length(iqed)
            if iqed(jj)~=1&&iqed(jj)~=j
                error('umts:error','IQ mapping parameter (1 maps to I, j maps to Q)');
            end
        end
        out=ULMapping(out,iqed,modulation);
    end
    if orientation==1
        if size(out,1)~=1
            out=out.';
        end
    end
end


function[out]=ULMapping(datain,iqed,modulation)
    channels=size(datain,2);
    if(iscell(datain))
        out=cell(1,channels);
        for i=1:channels
            out{i}=datain{i}.*iqed(i);
        end

    else
        out=zeros(length(datain(:,1))/(modulation+1),channels);
        for i=1:channels
            out(:,i)=datain(:,i).*iqed(i);
        end
    end
end
