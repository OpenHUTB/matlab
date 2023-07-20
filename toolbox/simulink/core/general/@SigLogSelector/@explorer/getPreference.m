function value=getPreference(~,prefname)




    value='';
    slsPrefFile=fullfile(prefdir,'SigLogSelector.prf');
    if exist(slsPrefFile,'file')
        prefstruct=load(slsPrefFile,'-mat');
        if~isempty(strcmp(prefname,fieldnames(prefstruct)))
            value=prefstruct.(prefname);
        end
    end

end


