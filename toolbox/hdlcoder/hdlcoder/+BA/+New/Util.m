classdef Util
    methods(Static,Access=private)





        function newLayer=bfsLayer(keyExtractor,getNeighbors,ignoreNode,dest,layer,parentMap_mut)
            import BA.New.Util;

            destKey=Util.ifElse(dest==-1,@()'',@()keyExtractor(dest));

            newLayer={};

            for i=1:length(layer)
                node=layer{i};
                nodeKey=keyExtractor(node);


                if strcmp(nodeKey,destKey)
                    return;

                else
                    neighbors=getNeighbors(node);
                    toConsider=Util.filter(@(n)~ignoreNode(n),neighbors);
                    unvisited=Util.filter(@(n)~parentMap_mut.isKey(keyExtractor(n)),toConsider);
                    newLayer=num2cell(vertcat(newLayer{:},unvisited{:}));
                    for i=1:length(unvisited)
                        child=unvisited{i};
                        childKey=keyExtractor(child);
                        parentMap_mut(childKey)=nodeKey;
                    end
                end
            end
        end




















        function[path_mut,reachableNodes_mut]=bfs(keyExtractor,getNeighbors,ignoreNode,source,dest)
            import BA.New.Util;



            parentMap_mut=containers.Map('KeyType','char','ValueType','char');

            layer_mut={source};

            sourceKey=keyExtractor(source);
            destKey=Util.ifElse(dest==-1,@()'',@()keyExtractor(dest));

            reachableNodes_mut={source};

            while~parentMap_mut.isKey(destKey)&&~isempty(layer_mut)

                newLayer=Util.bfsLayer(...
                keyExtractor,...
                getNeighbors,...
                ignoreNode,...
                dest,...
                layer_mut,...
parentMap_mut...
                );

                layer_mut=newLayer;


                for i=1:length(newLayer)
                    reachableNodes_mut{end+1}=newLayer{i};
                end
            end

            path_mut={};

            if parentMap_mut.isKey(destKey)

                node=destKey;
                while~strcmp(node,sourceKey)
                    path_mut{end+1}=node;
                    node=parentMap_mut(node);
                end
                path_mut{end+1}=sourceKey;
                path_mut=flip(path_mut);
            end
        end








        function flattened=flatten(arr)
            import BA.New.Util;
            arr=Util.safecast2cell(arr);

            numElements=sum(cell2mat(Util.map(@length,arr)));
            flattened=cell(1,numElements);

            index=1;
            for i=1:length(arr)
                innerArray=Util.safecast2cell(arr{i});
                for j=1:length(innerArray)
                    innerElem=innerArray{j};
                    flattened{index}=innerElem;
                    index=index+1;
                end
            end
        end









        function i=arrayEqUpto(array1,array2)

            for i=1:min(length(array1),length(array2))

                if array1(i)~=array2(i)
                    i=i-1;
                    return;
                end
            end
        end


    end

    methods(Static)








        function asCell=safecast2cell(elems)









            if iscell(elems)
                asCell=elems;
            elseif length(elems)==1
                asCell={elems};
            else
                asCell=num2cell(elems);
            end
        end








        function timestamp=modified(filepath)
            if isfile(filepath)
                d=dir(filepath);
                timestamp=posixtime(datetime(d.date));
            else
                timestamp=-1;
            end
        end

        function n=editDistance(str1,str2,memo)
            import BA.New.Util;
            memoKey=sprintf('%d%d',numel(str1),numel(str2));

            if numel(str1)==0
                n=numel(str2);
            elseif numel(str2)==0
                n=numel(str1);
            elseif strcmp(str1(1),str2(1))
                n=Util.editDistance(str1(2:end),str2(2:end),memo);
            else
                n_insert=Util.editDistance(str1,str2(2:end),memo);
                n_remove=Util.editDistance(str1(2:end),str2,memo);
                n_replace=Util.editDistance(str1(2:end),str2(2:end),memo);

                n=1+min([n_insert,n_remove,n_replace]);
            end

            memo(memoKey)=n;
        end

















        function[success,debugStrings]=highlight(gmPrefixOpt,component)
            import BA.New.Util;

            componentPath=Util.componentPath(component);
            [success,debugStrings]=Util.highlight_with_path(gmPrefixOpt,componentPath);
        end















        function[success,debugStrings]=highlight_with_path(gmPrefixOpt,componentPath)
            debugStrings={};
            try
                hilite_system([gmPrefixOpt.unwrapOr(''),componentPath],'find');
                success=true;
                debugStrings{end+1}=sprintf('highlighted with path: `%s`',componentPath);
            catch err
                success=false;
                debugStrings{end+1}='';
            end
        end
















        function uniqElements=uniq(eq,arr)
            import BA.New.Util;
            arr=Util.safecast2cell(arr);

            uniqElements=Util.uniqAccumulate(eq,@(a,b)a,arr);
        end






        function uniqElements=uniqAccumulate(eq,accumulator,arr)
            import BA.New.Util;
            arr=Util.safecast2cell(arr);

            uniqElements={};
            lastElement=-1;

            for i=1:length(arr)
                element=arr{i};
                if i==1||~eq(element,lastElement)
                    uniqElements{end+1}=element;
                    lastElement=element;
                else
                    uniqElements{end}=accumulator(uniqElements{end},element);
                end
            end
        end








        function path=componentPath(comp)
            try
                path=[comp.Owner.FullPath,'/',comp.Name];
            catch err

                path=comp.FullPath;
            end
        end

















        function criticalPath=approximateCP(components)
            import BA.New.Util;


            componentsAreEqual=@(a,b)strcmp(a.Name,b.Name)&&strcmp(a.RefNum,b.RefNum);

            nodes=Util.uniq(componentsAreEqual,components);

            criticalPath={};

            keyExtractor=@Util.componentPath;

            switch length(nodes)
            case 0
                fprintf('ERROR: cannot approximate CP because `components` is empty')
                return;
            case 1
                criticalPath=Util.map(keyExtractor,nodes);
            otherwise

                for i=1:length(nodes)-1

                    node=nodes{i};

                    nextNode=nodes{i+1};


                    getNeighbors=@(node)Util.map(...
                    @(recv)recv.Owner,...
                    Util.flatMap(...
                    @(pos)pos.getReceivers,...
                    node.PirOutputSignals...
                    )...
                    );

                    [pathSegment,~]=Util.bfs(...
                    keyExtractor,...
                    getNeighbors,...
                    @(node)false,...
                    node,...
nextNode...
                    );





                    criticalPath{end+1}=keyExtractor(node);
                    for j=1:length(pathSegment)
                        criticalPath{end+1}=pathSegment{j};
                    end
                    criticalPath{end+1}=keyExtractor(nextNode);
                end
                criticalPath=Util.uniq(@strcmp,criticalPath);
            end
        end








        function reachableNodes_mut=reachableNICs(rootPIR)
            import BA.New.Util;

            topNetwork=rootPIR.getTopNetwork;
            components=num2cell(topNetwork.Components);
            nodes=Util.filter(@(c)c.isAbstractNetworkReference,components);

            reachableNodes_mut={};
            for i=1:length(nodes)
                node=nodes{i};
                [~,thisReachableNodes]=Util.bfs(...
                @Util.componentPath,...
                @(node)num2cell(node.ReferenceNetwork.Components),...
                @(node)~node.isAbstractNetworkReference,...
                node,...
                -1...
                );

                for i=1:length(thisReachableNodes)
                    reachableNodes_mut{end+1}=thisReachableNodes{i};
                end
            end
        end









        function[maxMatchDriver,lineHandle,debugString]=findMatchingDriver(isGM,signals,componentName)
            import BA.New.Util;
            lineHandle=-1;

            debugString='';


            compBasename=strsplit(componentName,'/');
            compBasename=compBasename{end};




            matchScores=cell2mat(Util.map(@(n)Util.arrayEqUpto(n.Name,compBasename),signals));

            positiveScoreIndices=arrayfun(@(i)0<matchScores(i),1:length(matchScores));
            positiveScores=matchScores(positiveScoreIndices);

            positiveSignals=signals(positiveScoreIndices);


            [~,idx]=sort(positiveScores);


            sortedPositiveSignalsDesc=flip(positiveSignals(idx));

            maxMatchDriver=-1;
            for i=1:length(sortedPositiveSignalsDesc)
                curBestSignal=sortedPositiveSignalsDesc(i);
                curBestDrivers_mut=curBestSignal.getDrivers;








                while~isempty(curBestDrivers_mut)&&isempty(curBestDrivers_mut.Owner.Name)
                    inputSignals=curBestDrivers_mut.Owner.PirInputSignals;
                    if length(inputSignals)>1
                        inputSignals=inputSignals(1);
                    end
                    curBestDrivers_mut=inputSignals.getDrivers;
                end




                if~isempty(curBestDrivers_mut)...
                    &&~strcmp(curBestDrivers_mut.Owner.ClassName,'network')...
                    &&~isempty(curBestDrivers_mut.Owner.Name)

                    maxMatchDriver=curBestDrivers_mut.Owner;


                    outPortIndex=hdlcoder.SimulinkData.getOriginalIdx(curBestDrivers_mut)+1;
                    modelHandle=Util.ifElse(isGM,@()maxMatchDriver.getGMHandle(),@()maxMatchDriver.origModelHandle);
                    if modelHandle~=-1
                        portHandles=Util.ifElse(...
                        modelHandle==-1,...
                        @()[],...
                        @()get_param(modelHandle,'porthandles')...
                        );
                        outport=Util.ifElse(...
                        isnumeric(portHandles.Outport),...
                        @()portHandles.Outport,...
                        @()portHandles.Outport(outPortIndex)...
                        );
                        lineHandle=get_param(outport,'line');
                    end

                    debugString=sprintf(...
                    'TVR name: %-32s -> best signal = %-16s -> best driver = %-16s',...
                    compBasename,...
                    curBestSignal.Name,...
                    maxMatchDriver.Name...
                    );
                    return;
                end
            end
        end
















        function parts_mut=partitionByBeginEnd(isBegin,isEnd,array)
            import BA.New.Util;
            beginTagIndices=find(isBegin(array));
            endTagIndices=find(isEnd(array));

            assert(length(beginTagIndices)==length(endTagIndices));


            parts_mut=num2cell(zeros(1,length(beginTagIndices)));

            for i=1:length(beginTagIndices)
                beginTagIndex=beginTagIndices(i);
                endTagIndex=endTagIndices(i);

                middle=array(beginTagIndex+1:endTagIndex-1);
                parts_mut{i}=middle;
            end
        end


        function lines=readlines(filename)
            fid=fopen(filename,'r');
            if fid==-1
                error(message('hdlcoder:backannotate:InvalidTimingFile'));
            else
                cbuf=textscan(fid,'%s','delimiter','\n');
                fclose(fid);
                lines=cbuf{1};
            end
        end

        function map=extractKeyValuePairs(array)
            assert(mod(numel(array),2)==0,'mod not 0');
            arrayLength=length(array);


            keyIndices=mod((1:arrayLength),2)==1;
            valIndices=mod((1:arrayLength),2)==0;

            keysExtracted=array(keyIndices);
            valsExtracted=array(valIndices);


            map=containers.Map(keysExtracted,valsExtracted,'UniformValues',false);
        end















        function pairs=extractKeyValuePairsAcc(array)
            import BA.New.Util;
            assert(mod(numel(array),2)==0,'mod not 0');
            arrayLength=length(array);


            keyIndices=mod((1:arrayLength),2)==1;
            valIndices=mod((1:arrayLength),2)==0;

            keysExtracted=array(keyIndices);
            valsExtracted=array(valIndices);


            keyToSum=containers.Map(keysExtracted,zeros(1,length(keysExtracted)),'UniformValues',false);


            for i=1:length(keysExtracted)
                key=keysExtracted{i};
                val=str2double(valsExtracted{i});
                keyToSum(key)=keyToSum(key)+val;
            end

            uniqKeysExtracted=Util.uniq(@(key1,key2)strcmp(key1,key2),keysExtracted);
            sums=Util.map(@(key)keyToSum(key),uniqKeysExtracted);
            pairs={uniqKeysExtracted,sums};
        end














        function out=ifElse(condition,ifTrue,ifFalse)
            if condition
                out=ifTrue();
            else
                out=ifFalse();
            end
        end











        function filtered=filter(predicate,array)
            import BA.New.Util;
            logicalIndices=cell2mat(Util.map(predicate,array));
            filtered=array(logicalIndices);
        end


        function flatMapped=flatMap(mapping,elems)
            import BA.New.Util;

            mapped=Util.map(mapping,elems);
            flatMapped=Util.flatten(mapped);
        end


        function mapped=map(mapping,elems)
            import BA.New.Util;
            mapped=cellfun(mapping,Util.safecast2cell(elems),'UniformOutput',false);
            mapped=Util.safecast2cell(mapped);
        end


        function forEach(closure,elems)
            import BA.New.Util;
            elems=Util.safecast2cell(elems);

            for i=1:length(elems)
                elem=elems{i};
                closure(elem);
            end
        end








        function val=all(closure,elems)
            import BA.New.Util;
            elems=Util.safecast2cell(elems);

            val=true;
            for i=1:length(elems)
                elem=elems{i};
                val=val&&closure(elem);
                if~val
                    return;
                end
            end
        end








        function val=any(closure,elems)
            import BA.New.Util;
            elems=Util.safecast2cell(elems);

            val=false;
            for i=1:length(elems)
                elem=elems{i};
                val=val||closure(elem);
                if val
                    return;
                end
            end
        end


















        function match=grep(string,varargin)
            import BA.New.Util;
            match=string;
            for i=1:length(varargin)
                pattern=varargin(i);
                regexpMatch=regexp(match,pattern,'match');
                match=Util.ifElse(isempty(regexpMatch),@()'',@()regexpMatch{1});
            end
        end


        function tableStr=asTableStr(arr)
            import BA.New.Util;
            dims=size(arr);
            numRows=dims(1);
            numCols=dims(2);


            colMaxLengths=arrayfun(...
            @(colIndex)max(arrayfun(...
            @(rowIndex)length(arr{rowIndex,colIndex}),...
            1:numRows...
            )),...
            1:numCols...
            );


            rows=Util.map(...
            @(rowIndex)Util.map(...
            @(colIndex)sprintf('%-*s',colMaxLengths(colIndex),arr{rowIndex,colIndex}),...
            1:numCols...
            ),...
            1:numRows...
            );


            rowStrs=Util.map(@(row)strjoin(row,' | '),rows);


            maxRowLen=max(cell2mat(Util.map(@(row)length(row),rowStrs)));

            divider=repmat('=',1,maxRowLen);


            rowStrs{1}=sprintf('%s\n%s\n%s',divider,rowStrs{1},divider);
            rowStrs{end+1}=divider;


            tableStr=strjoin(rowStrs,'\n');
        end
    end
end
