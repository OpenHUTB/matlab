function[variables,expressions,varCounter,exprCounter,mxValueIdMap]=processInfoLocations(locations,varLocIds,exprLocIds,...
    script,mxInfoOffset,mxArrayOffset,varCounter,exprCounter,mxValueIdMap)


    if nargin<4
        mxArrayOffset=0;
        if nargin<3
            mxInfoOffset=0;
        end
    end

    persistent emptyLocStruct;
    if isempty(emptyLocStruct)
        emptyLocStruct=cell2struct(cell(0,3),{'LocationID','TextStart',...
        'TextLength'},2);
    end

    exprLocs=locations(exprLocIds);
    exprCount=numel(exprLocs);

    if exprCount>0
        expressions=cell2struct(cell(exprCount,8),{'LocationID','LocationType',...
        'MxInfoID','MxValueID','TextStart','TextLength','GlobalID','ImpexDims'},2);
        for i=1:exprCount
            exprLoc=exprLocs(i);
            exprMxInfoId=exprLoc.MxInfoID;
            exprMxValueId=exprLoc.MxValueID;
            exprImpexInfo=exprLoc.ImplicitExpansionInfo;
            exprCounter=exprCounter+1;
            expressions(i).LocationID=exprLocIds(i);
            expressions(i).LocationType=exprLoc.NodeTypeName;
            expressions(i).MxInfoID=exprMxInfoId+mxInfoOffset;
            expressions(i).MxValueID=exprMxValueId+mxArrayOffset;
            expressions(i).TextStart=exprLoc.TextStart;
            expressions(i).TextLength=exprLoc.TextLength;
            expressions(i).GlobalID=exprCounter;
            expressions(i).ImpexDims=or(exprImpexInfo(:,1),exprImpexInfo(:,2));

            if exprMxValueId>0
                mxValueIdMap{exprMxValueId}=...
                unique([mxValueIdMap{exprMxValueId},exprMxInfoId]);
            end
        end
        if isscalar(expressions)
            expressions={expressions};
        end
    else
        expressions=[];
    end


    varLocs=locations(varLocIds);
    varCount=numel(varLocs);






    records=cell(varCount,5);
    for i=1:varCount
        variable=varLocs(i);
        posStart=variable.TextStart+1;
        posEnd=variable.TextStart+variable.TextLength;
        records{i,1}=script.ScriptText(posStart:posEnd);

        varMxValueId=variable.MxValueID;
        if varMxValueId>0
            mxValueIdMap{varMxValueId}=...
            unique([mxValueIdMap{varMxValueId},variable.MxInfoID]);
        end
    end
    tempCell=num2cell([varLocs.MxInfoID]+mxInfoOffset);
    [records{:,2}]=tempCell{:};
    tempCell={varLocs.TextStart};
    [records{:,3}]=tempCell{:};
    tempCell=num2cell(varLocIds);
    [records{:,4}]=tempCell{:};
    tempCell=num2cell([varLocs.MxValueID]+mxArrayOffset);
    [records{:,5}]=tempCell{:};

    records=sortrows(records,[1,2,3]);

    variables=cell(0,9);
    prevInfoId=0;
    specCounter=0;
    rangeStart=1;
    prevName='';
    flushStart=1;


    for i=1:varCount
        varRecord=records(i,:);

        if strcmp(varRecord{1},prevName)

            if prevInfoId==varRecord{2}

            else
                if specCounter==0

                    rangeEnd=size(variables,1);
                    padSpecializationId(rangeStart,rangeEnd);
                    rangeStart=rangeEnd+1;
                    specCounter=1;
                end

                specCounter=specCounter+1;
                appendVariable(i);
            end
        else


            specCounter=0;
            rangeStart=size(variables,1)+1;


            prevName=varRecord{1};
            appendVariable(i);
        end
    end


    flushLocations(varCount);


    variables=sortrows(variables,9);
    variables=cell2struct(variables(:,1:end-1),{'Name','Specialization','MxInfoID',...
    'MxValueID','VariableType','Locations','GlobalID','Majority'},2);

    if isscalar(variables)
        variables={variables};
    end


    function appendVariable(idx)


        flushLocations(idx-1);
        flushStart=idx;

        prevInfoId=varRecord{2};
        varCounter=varCounter+1;
        varIdx=size(variables,1)+1;

        variables(varIdx,:)={...
        prevName,...
        specCounter,...
        prevInfoId,...
        varRecord{5},...
        0,...
        emptyLocStruct,...
        varCounter,...
        '',...
        -1,...
        };
    end

    function flushLocations(inclusiveEnd)
        flushLen=inclusiveEnd-flushStart+1;
        if flushLen<=0
            return;
        end

        flushLocs=cell2struct(cell(flushLen,4),{'LocationID','TextStart','TextLength','MxValueID'},2);
        import coder.report.VariableType;
        varType=VariableType.Local;
        varMajority='';
        examineVarType=true;

        for relIdx=1:flushLen
            locId=records{relIdx+flushStart-1,4};
            mxInfoLoc=locations(locId);

            flushLocs(relIdx).LocationID=locId;
            flushLocs(relIdx).TextStart=mxInfoLoc.TextStart;
            flushLocs(relIdx).TextLength=mxInfoLoc.TextLength;
            flushLocs(relIdx).MxValueID=mxInfoLoc.MxValueID;

            if examineVarType
                if varType==VariableType.Local
                    switch mxInfoLoc.NodeTypeName
                    case 'inputVar'
                        varType=VariableType.Input;
                    case 'outputVar'
                        varType=VariableType.Output;
                    case 'persistentVar'
                        varType=VariableType.Persistent;
                    case 'globalVar'
                        varType=VariableType.Global;

                    end
                    if varType==VariableType.Local


                        examineVarType=false;
                    end
                elseif varType==VariableType.Input&&strcmp(mxInfoLoc.NodeTypeName,'outputVar')
                    varType=VariableType.InputOutput;
                    examineVarType=false;
                elseif varType==VariableType.Output&&strcmp(mxInfoLoc.NodeTypeName,'inputVar')
                    varType=VariableType.InputOutput;
                    examineVarType=false;
                elseif varType==VariableType.InputOutput
                    examineVarType=false;
                end
            end

            if~isempty(mxInfoLoc.Majority)
                varMajority=mxInfoLoc.Majority;
            end
        end

        varIdx=size(variables,1);
        if isscalar(flushLocs)
            variables{varIdx,6}={flushLocs};
        else
            variables{varIdx,6}=flushLocs;
        end
        variables{varIdx,9}=flushLocs(1).TextStart;
        variables{varIdx,5}=uint8(varType);
        variables{varIdx,8}=varMajority;
    end

    function padSpecializationId(padStart,padEnd)
        specCounter=specCounter+1;
        for padIdx=padStart:padEnd
            variables{padIdx,2}=specCounter;
        end
    end
end