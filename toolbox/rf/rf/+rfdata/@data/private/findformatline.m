function[format_line,format_lnum]=findformatline(h,a_section,lcounter,blocktype,exp_num)





    if nargin<5
        exp_num=1;
    end
    format_lnum=strmatch('%',a_section);
    if isempty(format_lnum)
        error(message('rf:rfdata:data:findformatline:missformatline',blocktype,lcounter));
    end

    if(isfinite(exp_num)&&numel(format_lnum)~=exp_num)
        error(message('rf:rfdata:data:findformatline:wrongnumberofformatline',exp_num,blocktype,lcounter));
    end
    format_line=strtok(a_section(format_lnum),'!');