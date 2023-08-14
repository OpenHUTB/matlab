






















function[out]=FddScrambling(input,direction,code,scramOffset)


    if(isempty(input))
        out=[];
        return
    end

    if nargin==3
        scramOffset=0;
    end


    if direction<0||direction>1
        error('umts:error','Direction parameter must be 0 or 1');
    end;

    if scramOffset<0||scramOffset>38399
        error('umts:error','Scrambling sequence offset must be in range 0 38399 inclusive');
    end;

    vecpoint=fdd('Scrambler',0,direction,code,scramOffset);
    out=fdd('Scrambler',1,vecpoint,input);
    fdd('Scrambler',2,vecpoint);


    if(size(input,1)==1)
        if(size(out,2)==1)
            out=out.';
        end
    elseif(size(input,2)==1)
        if(size(out,1)==1)
            out=out.';
        end
    end;
end