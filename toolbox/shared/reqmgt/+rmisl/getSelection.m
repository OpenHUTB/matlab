function[objH,isSf]=getSelection()





    objH=[];
    isSf=false;

    try

        currentSys=gcs;
        if isempty(currentSys)||rmiut.isBuiltinNoRmi(currentSys)
            return;
        end

        editor=GLUE2.AbstractDomain.findLastActiveEditor();
        if isempty(editor)
            return;
        end
        selection=editor.getSelection();
        if selection.size==0
            if feature('openMLFBInSimulink')
                objH=checkForSelectionInMLFBEditor(editor);
            end
            return;
        end

        if isa(editor.getDiagram,'InterfaceEditor.Diagram')

            return;
        end

        diagramM3I=editor.getDiagram;
        diagramObj=diagram.resolver.resolve(diagramM3I);

        if strcmpi(diagramObj.resolutionDomain,'stateflow')
            isSf=true;
            objH=selectionToSfHandles(selection);
        else
            objH=selectionToSlHandles(selection);
        end

    catch ex
        disp(getString(message('Slvnv:rmi:canlink:FailedToQuerySelection',ex.message)));
    end

end

function result=selectionToSfHandles(sel)
    result=[];
    if slreq.utils.selectionHasMarkup(sel)
        return;
    end
    for i=1:sel.size
        result=[result,double(sel.at(i).backendId)];%#ok<AGROW>
    end
end

function result=selectionToSlHandles(sel)
    result=[];
    if slreq.utils.selectionHasMarkup(sel)
        return;
    end
    for i=1:sel.size
        obj=get_param(sel.at(i).handle,'Object');
        if sysarch.isZCPort(obj.Handle)

        elseif isa(obj,'Simulink.Port')||isa(obj,'Simulink.Segment')

            continue;
        end
        result=[result,obj.Handle];%#ok<AGROW>
    end
end

function selectionInMLFB=checkForSelectionInMLFBEditor(daEditor)
    selectionInMLFB=[];
    mlEditor=slmle.api.getActiveEditor();
    if~isempty(mlEditor)
        jsRangeData=mlEditor.Selection;
        if all(jsRangeData(1:2)==jsRangeData(3:4))
            return;
        else

            selectionInMLFB.srcKey=Simulink.ID.getSID(mlEditor.blkH);
            selectionInMLFB.selectedRange=convertLinePosToAbsRange(mlEditor,jsRangeData);
            selectionInMLFB.selectedText=mlEditor.SelectedText;
        end
    end
end

function absRange=convertLinePosToAbsRange(mlEditor,rangeData)


    firstCharPos=mlEditor.positionInLineToIndex(rangeData(1),rangeData(2));
    lastCharPos=mlEditor.positionInLineToIndex(rangeData(3),rangeData(4));
    absRange=[firstCharPos,lastCharPos];
end
