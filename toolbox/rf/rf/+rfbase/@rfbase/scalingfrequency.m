function[fname,freq,funit,sfactor]=scalingfrequency(h,in,funit)





    fname='Freq';
    freq=[];
    if nargin<3
        funit='Auto';
    end
    sfactor=1;

    if isempty(in)
        return
    end

    if~iscell(in)
        switch upper(funit)
        case 'AUTO'

            if in(end)>=1e+12
                funit='[THz]';
                sfactor=1e-12;
            elseif in(end)>=1e+9
                funit='[GHz]';
                sfactor=1e-9;
            elseif in(end)>=1e+6
                funit='[MHz]';
                sfactor=1e-6;
            elseif in(end)>=1e+3
                funit='[KHz]';
                sfactor=1e-3;
            else
                funit='[Hz]';
            end
        case 'HZ'
            funit='[Hz]';
        case 'KHZ'
            funit='[KHz]';
            sfactor=1e-3;
        case 'MHZ'
            funit='[MHz]';
            sfactor=1e-6;
        case 'GHZ'
            funit='[GHz]';
            sfactor=1e-9;
        case 'THZ'
            funit='[THz]';
            sfactor=1e-12;
        otherwise
            funit='[Hz]';
        end
        freq=in*sfactor;
    else
        freq=cell(size(in));
        n_in=numel(in);
        for ii=1:n_in
            [temp_fname,freq{ii},temp_funit]=...
            scalingfrequency(h,in{ii},funit);
        end
        fname=temp_fname;
        funit=temp_funit;
    end