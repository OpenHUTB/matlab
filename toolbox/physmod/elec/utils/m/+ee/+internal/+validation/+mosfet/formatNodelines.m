function newNodeLines=formatNodelines(nodeLines)










    for index=1:length(nodeLines)
        nodeLines(index)=strtok(nodeLines(index),'%');
    end
    i=1;
    j=1;
    loop=0;
    while(i<=length(nodeLines))
        z=0;
        while(contains(nodeLines(i),'...'))
            nodeLines(i)=strrep(nodeLines(i),'...','%');
            nodeLines(i)=strtok(nodeLines(i),'%');
            z=z+1;
            loop=1;
            k=i+z;
            nodeLines(i)=strcat(nodeLines(i),nodeLines(k));
            newNodeLines(j)=nodeLines(i);%#ok<AGROW>
        end
        if(loop==1)
            loop=0;
            i=i+z+1;
            j=j+1;
        else
            newNodeLines(j)=nodeLines(i);
            i=i+1;
            j=j+1;
        end
    end
end