function dialogCallback(hObj,hDlg,tag)




    numOfitems=hObj.numOfObjs;
    generateHighlightObjDescription(hObj,hDlg);

    switch tag
    case 'tag_downbutton'



        priorityArray=sort(hDlg.getWidgetValue('tag_Selected'));

        selectedArrayUI=priorityArray;

        sizes=size(priorityArray);
        arraySize=sizes(2);

        rhsObjs=hObj.selectedObjs;

        if arraySize==0
            return;
        elseif arraySize==1
            if priorityArray(1)==length(rhsObjs)-1
                hObj.rhsChosenItem=priorityArray;
                return;
            else
                hObj.rhsChosenItem=priorityArray+1;
            end
        end


        for nth=arraySize:-1:1
            rhsObjPriority=priorityArray(nth)+1;

            if(rhsObjPriority>=1&&rhsObjPriority<numOfitems)
                thisPriority=rhsObjPriority;
                nextPriority=rhsObjPriority+1;

                temp=rhsObjs(thisPriority);
                rhsObjs(thisPriority)=rhsObjs(nextPriority);
                rhsObjs(nextPriority)=temp;


                selectedArrayUI(nth)=selectedArrayUI(nth)+1;
            end
        end

        hObj.selectedObjs=rhsObjs;

    case 'tag_upbutton'

        priorityArray=sort(hDlg.getWidgetValue('tag_Selected'));

        selectedArrayUI=priorityArray;

        sizes=size(priorityArray);
        arraySize=sizes(2);

        rhsObjs=hObj.selectedObjs;

        if arraySize==0
            return;
        elseif arraySize==1
            if priorityArray(1)==0
                hObj.rhsChosenItem=priorityArray;
                return;
            else
                hObj.rhsChosenItem=priorityArray-1;
            end
        end


        for nth=1:arraySize
            rhsObjPriority=priorityArray(nth)+1;

            if(rhsObjPriority>1&&rhsObjPriority<=numOfitems)
                thisPriority=rhsObjPriority;
                previousPriority=rhsObjPriority-1;
                temp=rhsObjs(thisPriority);
                rhsObjs(thisPriority)=rhsObjs(previousPriority);
                rhsObjs(previousPriority)=temp;


                selectedArrayUI(nth)=selectedArrayUI(nth)-1;
            end
        end

        hObj.selectedObjs=rhsObjs;


    case{'tag_rightbutton','tag_Available'}

        positionArray=sort(hDlg.getWidgetValue('tag_Available'));

        selectedArrayUIOneIndex=[];
        temp=size(positionArray);
        arraySize=temp(2);
        if arraySize==0
            return;
        end

        lhsObjs=hObj.availableObjs;
        rhsObjs=hObj.selectedObjs;
        numSelected=length(rhsObjs);


        for arrayIdx=1:arraySize
            lhsPosition=positionArray(arrayIdx)+1;


            numSelected=numSelected+1;
            rhsObjs(numSelected)=lhsObjs(lhsPosition);%#ok<AGROW>


            selectedArrayUIOneIndex(arrayIdx)=numSelected;%#ok<AGROW>
        end


        lhsPositionsToRemove=positionArray+1;
        lhsObjs(lhsPositionsToRemove)=[];

        hObj.selectedObjs=rhsObjs;
        hObj.availableObjs=lhsObjs;

    case{'tag_leftbutton','tag_Selected'}
        positionArray=sort(hDlg.getWidgetValue('tag_Selected'));
        temp=size(positionArray);
        arraySize=temp(2);
        if arraySize==0
            return;
        end

        lhsObjs=hObj.availableObjs;
        rhsObjs=hObj.selectedObjs;
        numAvailable=length(lhsObjs);

        for arrayIdx=1:arraySize
            rhsPosition=positionArray(arrayIdx)+1;



            objToMove=rhsObjs(rhsPosition);
            if isempty(lhsObjs)
                tempObjsBefore=[];
                tempObjsAfter=[];
            elseif objToMove.Id>lhsObjs(end).Id
                tempObjsBefore=lhsObjs(1:end);
                tempObjsAfter=[];
            elseif objToMove.Id<lhsObjs(1).Id
                tempObjsBefore=[];
                tempObjsAfter=lhsObjs(1:end);
            else
                for pos=2:numAvailable
                    if(objToMove.Id<lhsObjs(pos).Id)
                        tempObjsBefore=lhsObjs(1:pos-1);
                        tempObjsAfter=lhsObjs(pos:end);
                        break;
                    end
                end
            end
            lhsObjs=[tempObjsBefore,objToMove,tempObjsAfter];
            numAvailable=numAvailable+1;
        end


        rhsPositionsToRemove=positionArray+1;
        rhsObjs(rhsPositionsToRemove)=[];

        hObj.selectedObjs=rhsObjs;
        hObj.availableObjs=lhsObjs;

    otherwise


        hDlg.refresh();
    end
end





