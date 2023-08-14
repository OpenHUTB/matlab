function prevEna=enableMouseHandlers(pList,ena,prevEna)






    if ena

        for i=1:numel(pList)
            lis=pList(i).hListeners.WindowButtonEvents;
            prev_i=prevEna{i};
            for j=1:numel(lis)
                lis(j).Enabled=prev_i(j);
            end
        end
    else

        prevEna=cell(size(pList));
        for i=1:numel(pList)

            lis=pList(i).hListeners.WindowButtonEvents;
            prevEna{i}=[lis.Enabled];



            for j=1:numel(lis)
                lis(j).Enabled=false;
            end
        end
    end
