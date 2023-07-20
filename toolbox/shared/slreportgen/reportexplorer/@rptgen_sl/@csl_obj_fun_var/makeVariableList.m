function vList=makeVariableList(this,wList)%#ok













    if isempty(wList)
        vList=cell(0,5);
        return
    end





    prevWarnState=warning('query','all');
    warning('off','all');


    [prevWarnMsg,prevWarnID]=lastwarn;


    numWList=size(wList,1);
    valueList=cell(numWList,1);
    valueIndex=zeros(numWList,1);
    nValidIndex=0;

    for i=1:numWList

        [variable,isExist]=slResolve(wList{i,1},wList{i,4}{1},'variable');
        if isExist
            valueList{nValidIndex+1,1}=variable;
            valueIndex(nValidIndex+1,1)=i;
            nValidIndex=nValidIndex+1;

        elseif evalin('base',['exist(''',wList{i,1},''', ''var'')'])
            valueList{nValidIndex+1,1}=evalin('base',wList{i,1});
            valueIndex(nValidIndex+1,1)=i;
            nValidIndex=nValidIndex+1;
        end

    end


    valueList(nValidIndex+1:end)=[];
    valueIndex(nValidIndex+1:end)=[];


    warning(prevWarnState);


    lastwarn(prevWarnMsg,prevWarnID);

    if isempty(valueIndex)

        vList=cell(0,5);
    else
        vList=[wList(valueIndex,:),valueList];
    end

