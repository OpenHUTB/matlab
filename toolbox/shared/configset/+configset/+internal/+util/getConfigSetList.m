function list=getConfigSetList(workspace,className)















    list={};
    if nargin<2
        className='Simulink.ConfigSet';
    elseif~any(className==["Simulink.ConfigSet","Simulink.ConfigSetRef"])
        return
    end
    className=convertStringsToChars(className);

    if isempty(workspace)
        all=evalin('base','whos')';
        isConfigSet=strcmp({all.class},className);
        list={all(isConfigSet).name};
    else
        try
            dd=Simulink.data.dictionary.open(workspace);
        catch
            return
        end
        c=onCleanup(@()dd.close);
        section=getSection(dd,'Configurations');
        entries=section.find('-value','-isa',className);
        list={entries.Name};
    end
