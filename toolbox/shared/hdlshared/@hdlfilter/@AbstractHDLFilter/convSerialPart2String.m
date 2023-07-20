function spstring=convSerialPart2String(this,sp)






    spstring=['[',num2str(sp),']'];

    while~isempty(findstr(spstring,'  '))
        spstring=strrep(spstring,'  ',' ');
    end
    lensp=length(spstring);
    zeroones=0;
    if lensp>20
        lsameones=length(find(sp/max(sp)==1));
        nonsameones=sp(find(sp/max(sp)~=1));



        zeroones=length(find(nonsameones==0));
        nonsameones=nonsameones(find(nonsameones));
        if sum(sp)==numel(sp)
            spstring=['ones(1,',num2str(length(sp)),')'];
        else
            if isempty(nonsameones)
                if max(sp)==1
                    if lsameones<5
                        sp1=sp(find(sp));
                        spstring=num2str(sp1);
                    else
                        spstring=['ones(1,',num2str(lsameones),')'];
                    end
                else
                    spstring=['ones(1,',num2str(lsameones),')*',num2str(max(sp))];
                end
            else
                spstring=['[ones(1,',num2str(lsameones),')*',num2str(max(sp)),', ',num2str(nonsameones),']'];
            end
        end
    end

    if zeroones>0
        if zeroones>6
            spstring=strrep(spstring,'[','');
            spstring=strrep(spstring,']','');
            spstring=[spstring,', zeros(1,',num2str(zeroones),')'];
        else
            spstring=[spstring,', ',num2str(zeros(1,zeroones))];
        end
    end


