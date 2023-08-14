function indvars=getindependentvars(h,a_section)




    var_pos=strmatch('VAR',a_section);
    indvars=cell(numel(var_pos),2);

    [temp,var_lines]=strtok(a_section(var_pos));

    [indvars(:,1),temp]=strtok(var_lines,'=');
    indvars(:,1)=strtrim(indvars(:,1));
    indvars(:,2)=strtrim(strtok(strtrim(temp),'='));