classdef RangeUtils<handle


















    properties

    end

    methods
        function this=RangeUtils()

        end
    end

    methods(Static=true)


        function[starts,ends,ids]=appendRange(starts,ends,ids,position,id)
            [startPositions,endPositions,idStrings]=rmiut.RangeUtils.convert(starts,ends,ids);
            startPositions(end+1)=position(1);
            endPositions(end+1)=position(2);
            idStrings{end+1}=id;
            [starts,ends,ids]=rmiut.RangeUtils.convert(startPositions,endPositions,idStrings);
        end


        function range=idToRange(starts,ends,ids,id)
            [startPositions,endPositions,idStrings]=rmiut.RangeUtils.convert(starts,ends,ids);
            match=strcmp(idStrings,id);
            if any(match)
                range=[startPositions(match),endPositions(match)];
            else
                warning(message('Slvnv:rmiml:UnmatchedID',id));
                range=[];
            end
        end


        function[id,start,stop]=rangeToId(starts,ends,ids,position)
            head=position(1);
            tail=position(end);
            [startPositions,endPositions,idStrings]=rmiut.RangeUtils.convert(starts,ends,ids);
            fallsInRange=(head>=startPositions&tail<=endPositions);
            switch sum(fallsInRange)
            case 1

                id=idStrings{fallsInRange};
                start=startPositions(fallsInRange);
                stop=endPositions(fallsInRange);
            case 0

                hasOverlap=(head>=startPositions&head<endPositions)|...
                (tail>startPositions&tail<=endPositions);
                if any(hasOverlap)
                    start=startPositions(hasOverlap);
                    stop=endPositions(hasOverlap);
                    if sum(hasOverlap)>1

                        mismatch=abs(start-head)+abs(stop-tail);
                        [~,sortIdx]=sort(mismatch);
                        start=start(sortIdx);
                        stop=stop(sortIdx);
                        overlappedIds=idStrings(hasOverlap);
                        sortedIds=overlappedIds(sortIdx);
                        id=cell(size(sortedIds));
                        for i=1:length(sortedIds)
                            id{i}=sprintf('%s=%d:%d',sortedIds{i},start(i),stop(i));
                        end
                    else

                        id=sprintf('%s=%d:%d',idStrings{hasOverlap},start,stop);
                    end
                else
                    id='';
                    start=head;
                    stop=tail;
                end
            otherwise

                start=startPositions(fallsInRange);
                stop=endPositions(fallsInRange);
                distance=stop-start;
                [~,sortIdx]=sort(distance);
                start=start(sortIdx);
                stop=stop(sortIdx);
                matchedIds=idStrings(fallsInRange);
                id=matchedIds(sortIdx);
            end
        end


        function selection=completeToWordOrLine(fPath,position)
            selection=[position-1,position-1];
            editor=rmiut.RangeUtils.findEditor(fPath);
            fullText=rmiut.RangeUtils.getText(editor);
            while selection(1)>0&&isWordChar(rmiut.RangeUtils.getCharAt(fullText,selection(1)-1))
                selection(1)=selection(1)-1;
            end
            while selection(2)<rmiut.RangeUtils.getLength(fullText)&&isWordChar(rmiut.RangeUtils.getCharAt(fullText,selection(2)))
                selection(2)=selection(2)+1;
            end
            if selection(1)==selection(2)
                while selection(1)>0&&rmiut.RangeUtils.getCharAt(fullText,selection(1)-1)~=10
                    selection(1)=selection(1)-1;
                end
                while selection(2)<rmiut.RangeUtils.getLength(fullText)&&rmiut.RangeUtils.getCharAt(fullText,selection(2))~=10
                    selection(2)=selection(2)+1;
                end
            end
            selection=selection+1;
            function result=isWordChar(ch)
                if ch==46||ch==95
                    result=true;
                elseif ch>=48&&ch<=57
                    result=true;
                elseif ch>=97&&ch<=122
                    result=true;
                elseif ch>=65&&ch<=90
                    result=true;
                else
                    result=false;
                end
            end
        end


        function selection=completeToLines(fPath,selection)
            editor=rmiut.RangeUtils.findEditor(fPath);
            if isempty(editor)





                if~rmisl.isSidString(fPath)
                    return;
                elseif rmisl.isHarnessIdString(fPath)

                    fPath=rmisl.harnessIdToEditorName(fPath);
                    editor=rmiut.RangeUtils.findEditor(fPath);
                    shouldClose=false;
                else




                    fPath=rmiml.openMFunctionCode(fPath);
                    editor=rmiut.RangeUtils.findEditor(fPath);
                    shouldClose=true;
                end
                if isempty(editor)

                    return;
                else
                    fullText=rmiut.RangeUtils.getText(editor);
                    if shouldClose
                        editor.close();
                    end
                end
            else
                fullText=rmiut.RangeUtils.getText(editor);
            end
            selection=selection-1;
            if selection(1)>=rmiut.RangeUtils.getLength(fullText)


                selection=[];
                return;
            end



            if rmiut.RangeUtils.getCharAt(fullText,selection(1))==10&&selection(2)>selection(1)
                selection(1)=selection(1)+1;
            else
                while selection(1)>0&&rmiut.RangeUtils.getCharAt(fullText,selection(1)-1)~=10
                    selection(1)=selection(1)-1;
                end
            end



            if selection(2)>selection(1)&&rmiut.RangeUtils.getCharAt(fullText,selection(2)-1)==10...
                &&selection(2)+1<=rmiut.RangeUtils.getLength(fullText)
                selection(2)=selection(2)-1;
            else
                while selection(2)+1<=rmiut.RangeUtils.getLength(fullText)&&rmiut.RangeUtils.getCharAt(fullText,selection(2))~=10
                    selection(2)=selection(2)+1;
                end
            end
            selection=selection+1;
        end


        function setSelection(srcName,selectionRange)
            if selectionRange(2)==0
                return;
            end



            if rmisl.isSidString(srcName)
                srcKey=srcName;
            else

                srcKey=rmiut.absolute_path(srcName);
                if isempty(srcKey)
                    warning(message('Slvnv:rmiml:FileNotFound',srcName));
                    return;
                end
            end
            if rmiml.enable()

                rmiut.RangeUtils.setSelectionInJSEditor(srcKey,selectionRange);
            else
                rmiut.RangeUtils.setSelectionInLegacyEditor(srcKey,selectionRange);
            end
        end

        function[yesno,editor]=isOpenInEditor(fPath)
            editor=rmiut.RangeUtils.findEditor(fPath);
            yesno=~isempty(editor);
        end

        function allPaths=getOpenFilePaths()
            allPaths={};
            editorApp=com.mathworks.mlservices.MLEditorServices.getEditorApplication();
            allEditors=editorApp.getOpenEditors();
            if isempty(allEditors)
                return;
            else
                for i=1:allEditors.size
                    srcKey=allEditors.get(i-1).getUniqueKey;
                    if any(srcKey(3:end)==':')
                        continue;
                    else
                        allPaths{end+1}=srcKey;%#ok<AGROW>
                    end
                end
            end
        end

        function[starts,ends,ids,removedId]=removeId(starts,ends,ids,id)
            [startPositions,endPositions,idStrings]=rmiut.RangeUtils.convert(starts,ends,ids);
            matched=strcmp(idStrings,id);
            if any(matched)
                removedId=id;
                startPositions(matched)=[];
                endPositions(matched)=[];
                idStrings(matched)=[];
                [starts,ends,ids]=rmiut.RangeUtils.convert(startPositions,endPositions,idStrings);
            else
                removedId='';
            end
        end



        [a,b,c]=convert(a,b,c)
        newRanges=textRangeRemap(newCode,oldCode,oldRanges)
        [newStarts,newEnds,remainingIds,lostIds]=remapRanges(contents,cached,starts,ends,ids)

    end


    methods(Static=true,Access='private')

        function setSelectionInJSEditor(srcKey,selectionRange)
            if rmisl.isSidString(srcKey)&&feature('openMLFBInSimulink')
                sidH=Simulink.ID.getHandle(srcKey);
                mlfbManager=slmle.internal.slmlemgr.getInstance;
                if isnumeric(sidH)
                    slName=Simulink.ID.getFullName(srcKey);
                    objId=mlfbManager.getObjectId(slName);
                else

                    objId=slmle.internal.convertToObjectId(sidH.Id);
                end
                editor=mlfbManager.getMLFBEditor(objId);
            else
                editor=matlab.desktop.editor.findOpenDocument(srcKey);
            end
            if~isempty(editor)
                [startLine,startPos]=editor.indexToPositionInLine(selectionRange(1)-1);
                [endLine,endPos]=editor.indexToPositionInLine(selectionRange(2)-1);
                editor.goToLine(startLine);
                editor.Selection=[startLine,startPos,endLine,endPos];
            end
        end

        function setSelectionInLegacyEditor(srcKey,selectionRange)
            editor=rmiut.RangeUtils.findEditor(srcKey);
            if~isempty(editor)
                editor.setSelection(selectionRange(1,1)-1,selectionRange(1,2)-1);
                if size(selectionRange,1)==2&&~all(selectionRange(1,:)==selectionRange(2,:))
                    pause(0.333);
                    editor.setSelection(selectionRange(2,1)-1,selectionRange(2,2)-1);
                end
            end
        end

        function[editor,isFile]=findEditor(srcStr)
            srcStr=char(srcStr);
            if any(srcStr(3:end)==':')

                editor=rmiut.RangeUtils.sidToEditor(srcStr);
                isFile=false;
            else

                editor=rmiut.RangeUtils.pathToEditor(srcStr);
                isFile=true;
            end
        end

        function editor=pathToEditor(fPath)
            if~rmiut.isCompletePath(fPath)
                editor=rmiut.RangeUtils.shortNameToEditor(fPath);
            elseif rmiml.enable()
                editor=matlab.desktop.editor.findOpenDocument(fPath);
            else
                storageLocation=com.mathworks.widgets.datamodel.FileStorageLocation(fPath);
                editorApp=com.mathworks.mlservices.MLEditorServices.getEditorApplication();
                editor=editorApp.findEditor(storageLocation);
            end
        end

        function editor=shortNameToEditor(fPath)
            whichFile=which(fPath);
            [~,shortName,fExt]=fileparts(fPath);
            if rmiml.enable()
                allEditors=matlab.desktop.editor.getAll();
                for i=numel(allEditors):-1:1
                    editorFile=allEditors(i).Filename;
                    if strcmp(editorFile,whichFile)
                        editor=allEditors(i);
                        return;
                    end
                    if endsWith(editorFile,[filesep,shortName,fExt])
                        editor=allEditors(i);
                        return;
                    end
                end
            else
                editorApp=com.mathworks.mlservices.MLEditorServices.getEditorApplication();
                openEditors=editorApp.getOpenEditors();
                totalEditors=size(openEditors);
                for i=totalEditors-1:-1:0
                    editorKey=char(openEditors.get(i).getUniqueKey());
                    [~,shortKey]=fileparts(editorKey);
                    if strcmp(shortKey,shortName)
                        editor=openEditors.get(i);
                        return;
                    end
                end
            end
            editor=[];
        end

        function editor=sidToEditor(sid)
            if feature('openMLFBInSimulink')


                slsfObj=Simulink.ID.getHandle(sid);
                if isa(slsfObj,'Stateflow.Object')
                    editor=slmle.api.openEditor(slsfObj.Id);
                else
                    editor=slmle.api.openEditor(sid);
                end
            else



                editorApp=com.mathworks.mlservices.MLEditorServices.getEditorApplication();
                openEditors=editorApp.getOpenEditors();
                totalEditors=size(openEditors);
                for i=totalEditors-1:-1:0
                    editorKey=char(openEditors.get(i).getUniqueKey());
                    possibleSID=rmiut.RangeUtils.editorKeyToSid(editorKey);
                    if~isempty(possibleSID)&&strcmp(possibleSID,sid)
                        editor=openEditors.get(i);
                        return;
                    end
                end
                editor=[];
            end
        end

        function possibleSID=editorKeyToSid(editorKey)
            if(filesep=='\')
                pattern='(\.slx|\.mdl)([^\\]+)';
            else
                pattern='(\.slx|\.mdl)([^/]+)';
            end
            matched=regexp(editorKey,pattern,'tokens');
            if isempty(matched)
                possibleSID='';
            else
                possibleSID=matched{1}{2};
            end
        end

        function text=getText(editor)
            if~isa(editor,'com.mathworks.mde.editor.MatlabEditor')
                text=editor.Text;
            else
                text=editor.getText();
            end
        end

        function result=getLength(text)
            if ischar(text)
                result=length(text);
            else
                result=text.length;
            end
        end

        function result=getCharAt(text,idx)
            if ischar(text)
                result=text(idx+1);
            else
                result=text.charAt(idx);
            end
        end
    end
end
