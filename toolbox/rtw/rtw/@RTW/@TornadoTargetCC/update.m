function update(hSrc,event)



    if nargin>1
        event=convertStringsToChars(event);
    end

    if strcmp(event,'switch_target')
        hCS=hSrc.getConfigSet;
        if~isempty(hCS)
            hOpt=hCS.getComponent('any','Optimization');
            set(hOpt,'LocalBlockOutputs',false);
        end
    elseif strcmp(event,'attach')


        registerPropList(hSrc,'NoDuplicate','All',[]);
    end

