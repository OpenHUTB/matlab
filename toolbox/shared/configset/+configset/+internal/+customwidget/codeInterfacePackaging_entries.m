function[out,dscr]=codeInterfacePackaging_entries(src,~)

    dscr='CodeInterfacePackaging enum option is changed by TargetLang';

    vals={'C++ class','Nonreusable function','Reusable function'};
    keys={'RTW:configSet:CodeInterfacePackaging_Cpp_class',...
    'RTW:configSet:CodeInterfacePackaging_Nonreusable_function',...
    'RTW:configSet:CodeInterfacePackaging_Reusable_function'};

    cs=src.getConfigSet;
    if~isempty(cs)
        lang=cs.getProp('TargetLang');
        if~strncmpi('C++',lang,3)
            vals=vals(2:3);
            keys=keys(2:3);
        end
    end

    avail_vals=cell(1,length(vals));
    for i=1:length(vals)
        avail_vals{i}.str=vals{i};
        avail_vals{i}.key=keys{i};
    end

    out=cell2mat(avail_vals);

