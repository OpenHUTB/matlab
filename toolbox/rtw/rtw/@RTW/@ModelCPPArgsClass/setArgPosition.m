function setArgPosition(hSrc,portName,pos)














    if pos<1||pos>length(hSrc.Data)
        DAStudio.error('RTW:fcnClass:invalidArgPos');
        return;
    end

    namesInArgSpec=get(hSrc.Data,'SLObjectName');
    if isempty(namesInArgSpec)
        DAStudio.error('RTW:fcnClass:noConfigFound',portName);
        return;
    elseif~iscell(namesInArgSpec)
        namesInArgSpec={namesInArgSpec};
    end

    [numOfFound,currPos]=ismember(portName,namesInArgSpec);

    if numOfFound>0
        if currPos==pos
            return;
        end
        argConf=hSrc.Data(currPos);




        [foundCombinedOne,combinedRow,~,~]=...
        hSrc.foundCombinedIO(pos-1,hSrc.Data,hSrc.Data(pos).ArgName);

        if foundCombinedOne&&~strcmp(hSrc.Data(pos).ArgName,argConf.ArgName)

            if pos~=1&&pos~=length(hSrc.Data)
                lowerEnd=min(pos,combinedRow+1);
                higherEnd=max(pos,combinedRow+1);



                moveForward=(pos<currPos);
                if moveForward&&(pos==higherEnd)
                    pos=higherEnd+1;
                elseif~moveForward&&(pos==lowerEnd)
                    pos=higherEnd;
                end

                if pos>length(hSrc.Data)
                    pos=length(hSrc.Data);
                end
            end
        end
        argConf.Position=pos;

        if pos>currPos
            for index=(currPos+1):pos
                temp=hSrc.Data(index);
                temp.Position=temp.Position-1;
                hSrc.Data(index-1)=temp;
            end
            hSrc.Data(pos)=argConf;
        else
            for index=currPos:-1:(pos+1)
                temp=hSrc.Data(index-1);
                temp.Position=temp.Position+1;
                hSrc.Data(index)=temp;
            end
            hSrc.Data(pos)=argConf;
        end
        [foundCombinedOne,combinedRow,~,~]=...
        hSrc.foundCombinedIO(pos-1,hSrc.Data,argConf.ArgName);
        if foundCombinedOne

            theOtherIdx=combinedRow+1;
            theOtherData=hSrc.Data(theOtherIdx);
            if abs(pos-theOtherIdx)>1
                if pos==1
                    theOtherPos=2;
                elseif pos==length(hSrc.Data)
                    theOtherPos=length(hSrc.Data)-1;
                elseif pos>theOtherIdx
                    theOtherPos=pos-1;
                elseif pos<theOtherIdx
                    theOtherPos=pos+1;
                end
                hSrc.setArgPosition(theOtherData.SLObjectName,theOtherPos);
            end
        end
        return;
    else
        DAStudio.error('RTW:fcnClass:noConfigFound',portName);
        return;
    end

