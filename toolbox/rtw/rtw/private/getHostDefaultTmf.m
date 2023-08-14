function tmf=getHostDefaultTmf(target)




    narginchk(1,1);

    switch(target)
    case 'ert'
        tmf=fullfile(tmffolder,ert_default_tmf);
    case 'grt'
        tmf=fullfile(tmffolder,grt_default_tmf);
    otherwise
        assert(false,'Unsupported target type %s',target);
    end

