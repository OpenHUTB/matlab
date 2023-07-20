function analyzeReusedSSBlks(this)








    if~strcmp(hdlgetparameter('subsystemreuse'),'off')

        if isempty(this.ReusedSSBlks)
            this.ReusedSSReport=[];
            return
        end


        reusedBlks_map=this.ReusedSSBlks;
        reusedBlks=table(reusedBlks_map.keys',reusedBlks_map.values');
        reusedBlks.Properties.VariableNames={'name','checksum'};
        reusedBlks=sortrows(reusedBlks,{'checksum','name'});


        groups=findgroups(reusedBlks.checksum);
        clonesIdx=false(height(reusedBlks),1);
        for ii=1:max(groups)
            cc=groups==ii;
            if sum(cc)>1
                clonesIdx=clonesIdx|cc;
            end
        end
        reusedBlks=reusedBlks(clonesIdx,:);


        [~,ia,~]=unique(reusedBlks.checksum);
        ia=vertcat(ia,length(reusedBlks.checksum)+1);
        clones={};
        for i=2:length(ia)
            a=ia(i-1);
            b=ia(i);
            if b-a>1
                clones{end+1}=reusedBlks.name(a:(b-1));
            end
        end



        this.ReusedSSReport=clones;

    end

end


