function spstring=convDARadix2String(~,dr)






    spstring=['[',num2str(dr),']'];

    while~isempty(findstr(spstring,'  '))
        spstring=strrep(spstring,'  ',' ');
    end
    lensp=length(spstring);
    if lensp>20
        lsameones=length(find(dr/max(dr)==1));
        nonsameones=dr(find(dr/max(dr)~=1));
        if sum(dr)==numel(dr)
            spstring=['ones(1,',num2str(length(dr)),')'];
        else
            if isempty(nonsameones)
                spstring=['ones(1,',num2str(lsameones),')*',num2str(max(dr))];
            else
                spstring=['[ones(1,',num2str(lsameones),')*',num2str(max(dr)),', ',num2str(nonsameones),']'];
            end
        end
    end



