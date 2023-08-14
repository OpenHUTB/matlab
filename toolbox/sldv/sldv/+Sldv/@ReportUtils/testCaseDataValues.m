function dataValues=testCaseDataValues(data,tc,io,funTs)




    switch lower(io)
    case 'in'
        dataValues=testCaseInValues(data,tc,funTs);
    case 'out'
        dataValues=testCaseExpectedOutput(data,tc,funTs);
    end
end

function dataValues=testCaseInValues(data,tc,funTs)

    flatData=flatCell({},tc.dataValues,data.AnalysisInformation.InputPortInfo);
    if strcmp(data.AnalysisInformation.Options.RandomizeNoEffectData,'off')
        flatNoEffect=flatCell({},tc.dataNoEffect,data.AnalysisInformation.InputPortInfo);
    else
        flatNoEffect={};
    end




    inputLabels=genIOportLabel({},data.AnalysisInformation.InputPortInfo);


    dataValues=buildValueTable(inputLabels,...
    tc.timeValues,...
    flatData,...
    flatNoEffect,...
    funTs,...
    true);
end

function expectedOutput=testCaseExpectedOutput(data,tc,funTs)

    flatOutData=flatCell({},tc.expectedOutput,data.AnalysisInformation.OutputPortInfo);

    outputLabels=genIOportLabel({},data.AnalysisInformation.OutputPortInfo);

    timeExpanded=...
    Sldv.DataUtils.expandTimeForTimeseries(tc.timeValues,funTs);

    expectedOutput=buildValueTable(outputLabels,...
    timeExpanded,...
    flatOutData,...
    [],...
    funTs,...
    false);
end


function dataValues=buildValueTable(labels,timeValues,flatData,flatNoEffect,funTs,compressed)
    nTs=length(timeValues);


    if~compressed
        breakIdx=findBreakPoints(flatData,flatNoEffect,nTs);
    else
        breakIdx=1:nTs;
    end

    if length(breakIdx)>1
        okToSkipLast=true;
        numPorts=length(flatData);
        for i=1:numPorts
            port_i=flatData{i};
            dim_port_i=size(port_i);
            raw_port_i=reshape(port_i,[prod(dim_port_i(1:end-1)),dim_port_i(end)]);
            if any(raw_port_i(:,breakIdx(end-1))~=raw_port_i(:,breakIdx(end)))
                okToSkipLast=false;
                break;
            end
        end
        if okToSkipLast
            breakIdx=breakIdx(1:end-1);
        end
    end

    startTimes=timeValues(breakIdx);
    stopTimes=[timeValues(breakIdx(2:end))-funTs,timeValues(end)];


    rowCnt=2+length(flatData);
    colCnt=1+length(breakIdx);
    dataValues=cell(rowCnt,colCnt);


    dataValues{1,1}=getString(message('Sldv:RptGen:Time'));
    dataValues{2,1}=getString(message('Sldv:RptGen:Step'));


    for i=1:length(labels)
        dataValues{i+2,1}=labels{i};
    end


    for c=2:colCnt
        startT=startTimes(c-1);
        endT=stopTimes(c-1);
        stepStart=round(startT/funTs)+1;
        stepStop=round(endT/funTs)+1;
        if stepStart==stepStop
            dataValues{1,c}=sprintf('%g',startT);
            dataValues{2,c}=sprintf('%d',stepStart);
        else
            dataValues{1,c}=sprintf('%g-%g',startT,endT);
            dataValues{2,c}=sprintf('%d-%d',stepStart,stepStop);
        end

        for r=3:rowCnt
            dataValues{r,c}=strData(flatData,flatNoEffect,r-2,breakIdx(c-1),nTs);
        end
    end
end

function str=strData(flatData,flatNoEffect,r,c,nTs)
    row=flatData{r};
    dims=size(row);
    if~isempty(flatNoEffect)
        rowNE=flatNoEffect{r};
    else
        rowNE=false(size(row));
    end
    if nTs==1
        d=reshape(row,[prod(dims),1]);
        n=reshape(rowNE,[prod(dims),1]);
    else
        if length(dims)>2
            cellDims=dims(1:end-1);
            flatRow=reshape(row,[prod(cellDims),dims(end)]);
            d=flatRow(:,c);
            d=reshape(d,cellDims);
            flatRowNE=reshape(rowNE,[prod(cellDims),dims(end)]);
            n=reshape(flatRowNE(:,c),cellDims);
        else
            d=row(:,c);
            n=rowNE(:,c);
        end
    end
    nElem=prod(size(d));%#ok<PSIZE> - numel doesn't handle fixed-point
    if nElem==1
        str=strElem(d,n);
    else
        str='[';
        for i=1:nElem
            str=[str,' ',strElem(d(i),n(i))];%#ok<AGROW>
        end
        str=[str,' ]'];
    end
end

function str=strElem(d,n)
    if n
        str='-';
    elseif isa(d,'embedded.fi')
        str=d.Value;
    elseif isobject(d)
        str=sldvshareprivate('util_num2str',d);
    else
        if isreal(d)
            str=num2str(d);
        else
            if imag(d)>=0
                str=[num2str(real(d)),'+',num2str(imag(d)),'i'];
            else
                str=[num2str(real(d)),num2str(imag(d)),'i'];
            end
        end
    end
end


function portLabels=genIOportLabel(portLabels,portInfo,signalPath,depth)
    if nargin<4
        depth=0;
    end

    if nargin<3
        signalPath='';
    end

    if iscell(portInfo)
        if depth==0
            for i=1:length(portInfo)
                portLabels=genIOportLabel(portLabels,portInfo{i},signalPath,depth+1);
            end
        else


            myDim=1;
            if isfield(portInfo{1},'Dimensions')
                myDim=portInfo{1}.Dimensions;
            end

            if depth==1




                elemsInBlockPath=regexp(portInfo{1}.BlockPath,'/','split');
                blockNameInModel=elemsInBlockPath{end};
                blockNameInModelWithoutDot=strrep(blockNameInModel,'.','_');
                signalPathWithDot=portInfo{1}.SignalPath;
                signalPathWithoutDot=strrep(signalPathWithDot,blockNameInModel,blockNameInModelWithoutDot);
                splitSignalPath=regexp(signalPathWithoutDot,'\.','split');
                for j=1:length(splitSignalPath)
                    splitSignalPath{j}=strrep(splitSignalPath{j},blockNameInModelWithoutDot,blockNameInModel);
                end
            else
                splitSignalPath=regexp(portInfo{1}.SignalPath,'\.','split');
            end

            if all(myDim==1)


                updatedSignalPath=strcat(signalPath,splitSignalPath(end),'.');
                for i=2:length(portInfo)
                    portLabels=genIOportLabel(portLabels,portInfo{i},updatedSignalPath,depth+1);
                end
            else




                allDims=sldvprivate('util_gen_all_combinations',myDim);
                for index=1:numel(allDims)
                    dim=allDims{index};
                    updatedSignalPath=strcat(signalPath,splitSignalPath(end),'(',regexprep(int2str(dim),' +',','),').');
                    for i=2:length(portInfo)
                        portLabels=genIOportLabel(portLabels,portInfo{i},updatedSignalPath,depth+1);
                    end
                end
            end
        end
    else
        if isfield(portInfo,'SignalLabels')&&portInfo.Used
            if strcmp(signalPath,'')==1
                portLabels{end+1}=portInfo.SignalLabels;
            else
                splitLabel=regexp(portInfo.SignalLabels,'\.','split');
                portLabels{end+1}=strcat(signalPath,splitLabel(end));
            end
        end
    end
end


function out=flatCell(out,dt,portInfo,depth,isBusArray)
    if nargin<5
        isBusArray=false;
    end

    if nargin<4
        depth=0;
    end

    if iscell(dt)
        for i=1:numel(dt)
            if depth==0
                isChildBusArray=false;
                if iscell(portInfo{i})&&isfield(portInfo{i}{1},'Dimensions')&&...
                    any(portInfo{i}{1}.Dimensions~=1)

                    isChildBusArray=true;
                end
                out=flatCell(out,dt{i},portInfo{i},depth+1,isChildBusArray);
            else
                if isBusArray



                    pInfo=portInfo;
                    isChildBusArray=false;
                else





                    pInfo=portInfo{i+1};
                    isChildBusArray=false;
                    if iscell(pInfo)&&isfield(pInfo{1},'Dimensions')&&...
                        any(pInfo{1}.Dimensions~=1)
                        isChildBusArray=true;
                    end
                end
                out=flatCell(out,dt{i},pInfo,depth+1,isChildBusArray);
            end
        end
    else
        if portInfo.Used
            out{end+1}=dt;
        end
    end
end



function breakIdx=findBreakPoints(dt,ne,numCol)
    r=length(dt);
    c=numCol;
    okToRemove=false(r,c);
    for i=1:r
        rowi=dt{i};
        dimi=size(rowi);
        rdt=reshape(rowi,[prod(dimi(1:end-1)),dimi(end)]);
        if~isempty(ne)
            rne=reshape(ne{i},[prod(dimi(1:end-1)),dimi(end)]);
        else
            rne=false(size(rdt));
        end
        for j=2:c
            nchanged=rdt(:,j)==rdt(:,j-1);
            nnechanged=rne(:,j)==rne(:,j-1);
            okToRemove(i,j)=all(nchanged&nnechanged);
        end
    end
    removeCol=false(1,c);
    for i=1:c
        removeCol(i)=all(okToRemove(:,i));
    end
    breakIdx=find(~removeCol);
end
