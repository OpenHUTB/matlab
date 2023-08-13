classdef RegionMapping<handle


    properties(Access=private)
        Mapping;
        LineNumberArray;
        NumberOfCodeLines;
        StartPosition;
        ExecutionLength;
        LineToRegionNumberMap;
        CodeBlockBoundaries;
        IsAcceptableFileType;
    end

    methods(Access=public)
        function obj=RegionMapping(regionList,fullText,deoptomizedLineArray)
            import matlab.internal.editor.RegionMapping


            tree=mtree(fullText);

            obj.IsAcceptableFileType=tree.FileType==mtree.Type.ScriptFile||tree.FileType==mtree.Type.Unknown;
            if~obj.IsAcceptableFileType
                return;
            end

            numRegions=numel(regionList);
            obj.Mapping=struct('regionNumber',cell(1,numRegions),...
            'sectionNumber',cell(1,numRegions),...
            'isSectionBreak',cell(1,numRegions),...
            'firstLineNumberInRegion',cell(1,numRegions));

            obj.NumberOfCodeLines=RegionMapping.getNumberOfLinesInText(fullText);

            obj.LineNumberArray=zeros(1,numRegions);

            if numRegions~=0
                lastRegionNum=regionList(end).regionNumber;
                lastRegionNumber=double(lastRegionNum)+1;
                lineToRegionMap=lastRegionNumber.*ones(1,obj.NumberOfCodeLines);
            else
                lineToRegionMap=[];
            end

            lastStart=1;
            previousRegionNumber=-1;
            for i=1:numRegions
                regionNumber=regionList(i).regionNumber;
                obj.Mapping(i).regionNumber=regionNumber;
                obj.Mapping(i).sectionNumber=regionList(i).sectionNumber;
                obj.Mapping(i).isSectionBreak=regionList(i).endOfSection;
                line=regionList(i).regionLineNumber;
                obj.Mapping(i).firstLineNumberInRegion=line;

                if i~=1
                    lineToRegionMap(lastStart:(line-1))=previousRegionNumber+1;
                    lastStart=line;
                end
                previousRegionNumber=regionNumber;
                obj.LineNumberArray(i)=line;
            end

            obj.LineToRegionNumberMap=lineToRegionMap;

            [startPosition,executionLength]=RegionMapping.calculateExecutionBounds(regionList,fullText);

            obj.StartPosition=startPosition;
            obj.ExecutionLength=executionLength;

            linesToAdd=[];
            if~isempty(deoptomizedLineArray)
                linesToAdd=[deoptomizedLineArray.line];
            end
            obj.CodeBlockBoundaries=RegionMapping.calculateCodeBlockBoundaries(tree,linesToAdd);

        end

        function[startPosition,executionLength]=getExecutionBounds(obj)
            startPosition=obj.StartPosition;
            executionLength=obj.ExecutionLength;
        end

        function bounds=getExecutionBoundsArray(obj)
            bounds(1)=obj.StartPosition;
            bounds(2)=obj.ExecutionLength;
        end

        function data=getRegionMappingData(obj,regionNumber)
            data=obj.Mapping([obj.Mapping.regionNumber]==(regionNumber-1));

        end

        function mapping=getLineToRegionNumberMapping(obj)
            mapping=obj.LineToRegionNumberMap;
        end

        function codeBlockBoundaries=getCodeBlockBoundaries(obj)
            codeBlockBoundaries=obj.CodeBlockBoundaries;
        end

        function isAcceptable=isAcceptableFileType(obj)
            isAcceptable=obj.IsAcceptableFileType;
        end

        function regionNumber=getAllRegionNumbers(obj)
            regionNumber=[obj.Mapping.regionNumber];
        end

    end

    methods(Static,Hidden)






        function lineNumbers=calculateCodeBlockBoundaries(tree,linesToAlwaysInclude)
            lineNumbers=[];


            if tree.isnull||tree.anykind('ERR')
                return
            end




            curNode=tree.root;
            nextNode=curNode.Next;
            while~nextNode.isnull&&~nextNode.iskind('FUNCTION')
                curNode=nextNode;
                nextNode=curNode.Next;
            end
            lastValidNode=curNode;

            endLine=tree.pos2lc(lastValidNode.rightposition);


            lineNumbers=1:endLine;


            lineNumbersNotToAdd=getLineNumbersWithinLoops(tree);
            lineNumbersNotToAdd=lineNumbersNotToAdd(lineNumbersNotToAdd<=endLine);


            lineNumbers(lineNumbersNotToAdd)=[];


            lineNumbers=includeCodeBlocksContainingLines(lineNumbers,linesToAlwaysInclude,endLine);
        end

        function numberOfLinesInRegion=getNumberOfLinesInText(regionText)
            if isempty(regionText)
                numberOfLinesInRegion=0;
            else
                numberOfLinesInRegion=1+sum(regionText==10);
            end
        end

        function[startPosition,executionLength]=calculateExecutionBounds(regionList,fullText)
            import matlab.internal.editor.RegionMapping;
            import matlab.internal.editor.CodeUtilities;


            startPosition=1;
            executionLength=0;

            numRegions=numel(regionList);

            if numRegions==0


                return;
            end

            firstRegion=regionList(1);
            regionLineNumber=firstRegion.regionLineNumber;
            numberOfCharactersBeforeStart=CodeUtilities.findNumberOfCharactersToPriorToLine(fullText,regionLineNumber);
            startPosition=numberOfCharactersBeforeStart+1;



            lastRegion=regionList(end);
            regionLineNumber=lastRegion.regionLineNumber;
            numberOfCharactersBeforeLastRegion=CodeUtilities.findNumberOfCharactersToPriorToLine(fullText,regionLineNumber);


            regionLength=length(lastRegion.regionString)+1;



            endPosition=numberOfCharactersBeforeLastRegion+regionLength;


            endPosition=min(endPosition,length(fullText));


            executionLength=endPosition-startPosition+1;

        end
    end

end


function lineNumbers=getLineNumbersWithinLoops(tree)
    lineNumbers=[];

    for k=["FOR","WHILE","PARFOR"]

        lineNumbers=[lineNumbers,getLineNumbersWithinLoopType(tree,k)];%#ok<AGROW>
    end
    lineNumbers=unique(lineNumbers);

end

function lineNumbers=getLineNumbersWithinLoopType(tree,kind)
    lineNumbers=[];

    nodesOfSpecifiedKind=tree.mtfind('Kind',kind);
    indicesOfSpecifiedKind=nodesOfSpecifiedKind.indices;

    for i=1:numel(indicesOfSpecifiedKind)
        subTree=tree.select(indicesOfSpecifiedKind(i));





        endLine=subTree.lastone;
        startLine=subTree.lineno+1;
        lineNumbers=[lineNumbers,(startLine:endLine)];
    end
end






function lineNumbers=includeCodeBlocksContainingLines(lineNumbers,linesToAdd,maxLine)
    extraLines=[];


    if isempty(linesToAdd)
        return;
    end

    if isempty(lineNumbers)
        return;
    end

    linesToAdd=sort(linesToAdd);


    linesToAdd=linesToAdd(linesToAdd<=maxLine);
    numLines=numel(lineNumbers);







    for lineToAdd=linesToAdd






        prevIndex=find(lineNumbers<=lineToAdd,1,'last');



        if isempty(prevIndex)

            extraLines=1:(lineNumbers(1)-1);
            continue;
        end

        prev=lineNumbers(prevIndex);



        if prev==lineToAdd
            continue;
        end





        if prevIndex==numLines

            extraLines=[extraLines,prev:maxLine];%#ok<AGROW>
            continue;
        end



        next=lineNumbers(prevIndex+1);

        extraLines=[extraLines,(prev+1):(next-1)];%#ok<AGROW>
    end


    lineNumbers=unique(sort([lineNumbers,extraLines]));
end
