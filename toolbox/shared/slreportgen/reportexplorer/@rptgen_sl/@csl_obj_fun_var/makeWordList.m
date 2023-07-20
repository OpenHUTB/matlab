function wList=makeWordList(c,allBlocks,d)













    isUnmasked=cellfun('isempty',...
    rptgen.safeGet(allBlocks,'MaskType','get_param'));

    wList=cell(0,4);
    for i=1:length(allBlocks)
        currBlk=allBlocks{i};
        wList=[wList;locFindVars(currBlk)];
        if isUnmasked(i)
            wList=[wList;locBlock(currBlk)];
        else
            wList=[wList;locMask(currBlk)];
        end
    end

    wList=locCollapse(wList,d);


    function wList=locMask(currBlk)





        wList=cell(0,4);

        maskValues=get_param(currBlk,'MaskValues');
        maskStyles=get_param(currBlk,'MaskStyles');
        maskVisbility=get_param(currBlk,'MaskVisibilities');




        maskVarTypes=regexp(get_param(currBlk,'MaskVariables'),...
        '=([^;]*)\d+;','tokens');

        for i=1:length(maskValues)
            if strcmp(maskStyles{i},'edit')&&...
                strcmpi(maskVisbility{i},'on')&&...
                ~isempty(maskVarTypes)&&...
                strcmpi(maskVarTypes{i}{1},'@')
                allValues=LocParseString(maskValues{i});
                if~isempty(allValues)
                    oldEnd=size(wList,1);
                    numVals=length(allValues);
                    wList(oldEnd+1:oldEnd+numVals,1)=allValues(:);
                    [wList{oldEnd+1:oldEnd+numVals,3}]=deal(maskValues{i});
                    [wList{oldEnd+1:oldEnd+numVals,4}]=deal(currBlk);

                end
            end
        end


        function wList=locFindVars(currBlk)
            wList=cell(0,4);

            try
                variableUsages=Simulink.findVars(currBlk,'SearchMethod','cached');
            catch ME
                if strcmp(ME.identifier,'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate')

                    variableUsages=Simulink.findVars(currBlk,'SearchMethod','compiled');
                else
                    rethrow(ME);
                end
            end
            nVars=numel(variableUsages);
            for i=1:nVars
                name=variableUsages(i).Name;

                wList{i,1}=name;
                wList{i,2}=[];
                wList{i,3}=name;
                wList{i,4}=currBlk;
            end


            function wList=locBlock(currBlk)

                wList=cell(0,4);

                if slprivate('is_stateflow_based_block',currBlk)
                    return;
                end

                try
                    myType=get_param(currBlk,'blocktype');
                catch
                    myType='';
                end


                switch myType
                case{'Scope','ToWorkspace','ToFile','Display',''}
                    dPara={};
                otherwise
                    dPara=get_param(currBlk,'intrinsicdialogparameters');
                    if isstruct(dPara)
                        pNames=fieldnames(dPara);
                        cleanNames={};
                        for j=1:length(pNames)
                            pInfo=dPara.(pNames{j});
                            if strcmp(pInfo.Type,'string')...
                                &&~any(strcmp(pInfo.Attributes,'dont-eval'))
                                cleanNames{end+1}=pNames{j};
                            end
                        end
                        dPara=cleanNames;
                    else
                        dPara={};
                    end
                end

                for j=1:length(dPara)
                    try
                        myValue=get_param(currBlk,dPara{j});
                    catch ME %#ok
                        myValue='';
                    end
                    if~isempty(myValue)&&ischar(myValue)&&~strcmp(myValue,'inf')
                        allValues=LocParseString(myValue);
                        if~isempty(allValues)
                            oldEnd=size(wList,1);
                            numVals=length(allValues);
                            wList(oldEnd+1:oldEnd+numVals,1)=allValues(:);
                            [wList{oldEnd+1:oldEnd+numVals,3}]=deal(myValue);
                            [wList{oldEnd+1:oldEnd+numVals,4}]=deal(currBlk);
                        end
                    end
                end



                function tightList=locCollapse(looseList,d)









                    ps=rptgen_sl.propsrc_sl;



                    [~,idx]=unique(strcat(looseList(:,1),looseList(:,2),looseList(:,3),looseList(:,4)));
                    looseList=looseList(idx,:);

                    [tightList,aIndex,bIndex]=unique(looseList(:,1));

                    if isempty(tightList)
                        tightList=cell(0,4);
                    else
                        for i=1:length(tightList)
                            origIndex=find(bIndex==bIndex(aIndex(i)));

                            tightList{i,4}=looseList(origIndex,4);
                            tightList{i,3}=looseList(origIndex,3);
                        end
                    end

                    for i=1:size(tightList,1)

                        tightList{i,2}=makeLink(ps,...
                        tightList{i,4},...
                        '',...
                        'link',...
                        d);


                        listRoot=createElement(d,'simplelist');
                        listRoot.setAttribute('columns','1');

                        for j=1:length(tightList{i,3})
                            memberEl=createElement(d,'member');
                            listRoot.appendChild(memberEl);
                            codeEl=createElement(d,'computeroutput',tightList{i,3}{j});
                            memberEl.appendChild(codeEl);
                        end
                        tightList{i,3}=listRoot;
                    end



                    function allWords=LocParseString(valStr)

                        allWords={};

                        if~isempty(valStr)

                            absStr=abs(valStr);
                            alphanumericIndices=(...
                            (absStr>=abs('0')&...
                            absStr<=abs('9'))|...
                            (absStr>=abs('a')&...
                            absStr<=abs('z'))|...
                            (absStr>=abs('A')&...
                            absStr<=abs('Z'))|...
                            absStr==abs('_')|...
                            absStr==abs('.'));

                            valStr(~alphanumericIndices)=' ';

                            valStr=strread(valStr,'%s','delimiter',' ');
                            for i=1:length(valStr)
                                wordToken=valStr{i};
                                if isempty(wordToken)||abs(wordToken(1))=='.'||...
                                    (abs(wordToken(1))>=abs('0')&&abs(wordToken(1))<=abs('9'))

                                else
                                    dotLoc=find(wordToken=='.');
                                    if~isempty(dotLoc)
                                        wordToken=wordToken(1:dotLoc-1);
                                    end
                                    allWords{end+1,1}=wordToken;
                                end
                            end
                        end

                        allWords=unique(allWords);

