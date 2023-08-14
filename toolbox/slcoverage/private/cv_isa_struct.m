function isaStruct=cv_isa_struct




    persistent isas;

    if isempty(isas)

        allclasses={'condition','decision','formatter','mcdcentry','message',...
        'modelcov','relation','root','sigranger','slsfobj',...
        'table','testdata'};

        isas=struct;

        for className=allclasses
            isas=setfield(isas,className{1},...
            eval(['cv(''get'',''default'',''',className{1},'.isa'');']));
        end
    end

    isaStruct=isas;

