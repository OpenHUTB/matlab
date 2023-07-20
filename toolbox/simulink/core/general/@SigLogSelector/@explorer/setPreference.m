function status=setPreference(~,prefname,prefvalue)




    status=true;
    slsPrefFile=fullfile(prefdir,'SigLogSelector.prf');
    try
        if exist(slsPrefFile,'file')
            prefstruct=load(slsPrefFile,'-mat');
        end
        prefstruct.(prefname)=prefvalue;
        save(slsPrefFile,'-struct','prefstruct');
    catch ME
        rethrow(ME);
    end

end


