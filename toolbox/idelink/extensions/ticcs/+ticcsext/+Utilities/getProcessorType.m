function proc=getProcessorType(cc,opt)



































    narginchk(1,2);

    if isa(cc,'ticcsext.autointerface.ticcs')
        icc=info(cc);
    elseif isa(cc,'struct')
        icc=cc;
    else
        error(message('TICCSEXT:autointerface:getProcessorType_InvalidInput'));
    end

    if nargin==1,
        opt='complete';
    end
    if isempty(strmatch(opt,{'complete','subfamily','family'},'exact'))
        DAStudio.error('TICCSEXT:autointerface:getProcessorType_InvalidInput');
    end

    ncc=length(icc);
    for k=1:ncc,

        if icc(k).family==470,
            switch opt
            case 'complete'
                ProcFormat='TMS%03dR%1s';
            case 'subfamily'
                ProcFormat='R%1sx';
            case 'family'
                ProcFormat='Rxx';
            end
        else
            switch opt
            case 'complete'
                ProcFormat='TMS%03dC%2s';
            case 'subfamily'
                ProcFormat='C%2sx';
            case 'family'
                ProcFormat='C%1sx';
                subfamily=dec2hex(icc(k).subfamily);
                proc{k}=sprintf(ProcFormat,subfamily(1));
                ProcFormat=proc{k};
            end
        end

        proc{k}=formatProcName(ProcFormat,icc(k),opt);

    end

    if ncc==1
        proc=proc{1};
    end


    function proc=formatProcName(proc,icc,opt)
        switch opt
        case 'family'
            if isempty(findstr(proc,'%')),

                return;
            else
                proc=sprintf(proc,dec2hex(icc.subfamily));
            end
        case 'subfamily'
            proc=sprintf(proc,dec2hex(icc.subfamily));
        case 'complete'
            proc=sprintf(proc,icc.family,dec2hex(icc.subfamily));
            try
                if icc.revfamily>=0&&icc.revfamily<=99
                    proc=sprintf('%s%02d',proc,icc.revfamily);
                elseif icc.revfamily>=100&&icc.revfamily<=109
                    proc=[proc,dec2hex(icc.revfamily-100),'x'];
                elseif icc.revfamily>=110&&icc.revfamily<=119
                    proc=[proc,'x',dec2hex(icc.revfamily-110)];
                elseif icc.revfamily==127
                    proc=[proc,'xx'];
                else


                    proc=sprintf('%s%02d',proc,icc.revfamily);
                end
            catch


                proc=sprintf('%s%02d',proc,icc.revfamily);
            end
        otherwise

        end


