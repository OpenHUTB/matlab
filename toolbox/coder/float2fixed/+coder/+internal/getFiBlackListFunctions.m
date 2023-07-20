function blacklist=getFiBlackListFunctions()



    persistent pblacklist;

    if isempty(pblacklist)
        fid=fopen(fullfile(matlabroot,'toolbox','shared','coder','coder','screener','screener_f2f.txt'));
        output=textscan(fid,'%s');
        fclose(fid);

        if~isempty(output)
            pblacklist=output{1};
        else
            pblacklist={};
        end
    end

    blacklist=pblacklist;
end