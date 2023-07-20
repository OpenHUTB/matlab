function PISectionLineInit(block)





    WantPhases=max(1,getSPSmaskvalues(block,{'Phases'}));
    ports=get_param(block,'ports');
    HavePhases=ports(6);

    if WantPhases<HavePhases
        RConnTags=get_param(block,'RConnTags');
        LConnTags=get_param(block,'LConnTags');
        set_param(block,'RConnTags',RConnTags(1:WantPhases));
        set_param(block,'LConnTags',LConnTags(1:WantPhases));
    end

    if WantPhases>HavePhases
        for i=HavePhases+1:WantPhases
            RConnTags=get_param(block,'RConnTags');
            LConnTags=get_param(block,'LConnTags');
            RConnTags{end+1}=['o',num2str(i)];%#ok
            LConnTags{end+1}=['i',num2str(i)];%#ok
            set_param(block,'RConnTags',RConnTags);
            set_param(block,'LConnTags',LConnTags);
        end
    end