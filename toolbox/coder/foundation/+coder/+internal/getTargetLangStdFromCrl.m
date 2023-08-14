function tgtLangStd=getTargetLangStdFromCrl(crlName,varargin)











    tgtLangStd='';


    if(isempty(crlName)||strcmpi(crlName,'none')||...
        contains(crlName,coder.internal.getCrlLibraryDelimiter))
        return;
    end


    persistent p
    if isempty(p)
        p=inputParser;
        p.addOptional('LoadSL',false,@(x)islogical(x));
    end
    p.parse(varargin{:});

    if(p.Results.LoadSL)
        tr=RTW.TargetRegistry.get;
    else
        tr=emlcprivate('emcGetTargetRegistry');
    end
    crl=coder.internal.getTfl(tr,crlName);
    while~isempty(crl)
        if crl.IsLangStdTfl
            switch crl.TableList{1}
            case 'ansi_tfl_table_tmw.mat'
                tgtLangStd='C89/C90 (ANSI)';
            case 'iso_tfl_table_tmw.mat'
                tgtLangStd='C99 (ISO)';
            case 'iso_cpp_tfl_table_tmw.mat'
                tgtLangStd='C++03 (ISO)';
            end
            break;
        end
        crl=coder.internal.getTfl(tr,crl.BaseTfl);
    end


