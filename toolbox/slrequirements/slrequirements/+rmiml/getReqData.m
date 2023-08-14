function table=getReqData(srcKey)







    table={};

    allIdsAndLabels=slreq.utils.getRangesAndLabels(srcKey);

    if isempty(allIdsAndLabels)
        return;

    else

        if builtin('_license_checkout','Simulink_Requirements','quiet')
            disp(getString(message('Slvnv:rmiml:NoCodegenCommentsWithoutLicense')));
            return;

        else








            totalBookmarks=size(allIdsAndLabels,1);
            [sortedStarts,index]=sort(cell2mat(allIdsAndLabels(:,2)));
            sortedEnds=allIdsAndLabels(index,3);
            sortedIDs=allIdsAndLabels(index,1);
            table=cell(totalBookmarks,3);
            hasNoLinks=strcmp('__NOLINKS__',allIdsAndLabels(index,4));
            fullText=rmiml.getText(srcKey);
            crPositions=find(fullText==10);
            for i=1:totalBookmarks
                table{i,1}=sortedIDs{i};
                table{i,2}=[sortedStarts(i),sortedEnds{i}];
                bookmarkText=rmiml.getText(srcKey,table{i,2});
                myCRs=find(bookmarkText==10);
                numberOfLinesBefore=sum(crPositions<sortedStarts(i));
                table{i,3}=[numberOfLinesBefore+1,numberOfLinesBefore+length(myCRs)+1];
            end
            table(hasNoLinks,:)=[];
        end
    end
end


