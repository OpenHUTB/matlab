classdef MLFBEditor<handle



    properties(Dependent)
Name
    end
    properties
type
objectId
chartId
blkH
eid
    end

    properties(Hidden)
studio
ed
h
context
focusService
focusListener
        prevActiveEditor=[];
        focusFcnCallCounter=0;




listener
        hasSelection=false
        enableNextPrevious=false
functionList
        closed=false
        ready=false
editorCloseCBId
activeEditorChangeCBId
dsMenuStatus
        isLocked=false;
        highlightedRanges=[];
    end

    properties(SetAccess=private)
        SelectedText=''
    end
    properties(Dependent)
Text
Selection
Cursor
Index
    end
    properties(Access=private)
fText
fSelection
fCursor
fIndex
    end

    methods
        function obj=MLFBEditor(objectId,blkH,studio)
            obj.objectId=objectId;
            obj.blkH=blkH;
            obj.studio=studio;
            obj.init();

            m=slmle.internal.slmlemgr.getInstance;
            if m.debug
                fprintf('create MLFB_%d (objId:%d, blkH:%f) for %s \n',...
                obj.eid,obj.objectId,obj.blkH,obj.Name);
            end
        end

        function delete(obj)
            m=slmle.internal.slmlemgr.getInstance;
            if m.debug
                fprintf('delete MLFB_%d (objId:%d, blkH:%f)\n',...
                obj.eid,obj.objectId,obj.blkH);
            end
        end

        function val=get.Name(obj)
            val=obj.getName();
        end

        function val=get.Text(obj)
            val=obj.fText;
        end
        function set.Text(obj,val)
            obj.setText(val);
        end
        function val=get.Selection(obj)
            val=obj.fSelection;
        end
        function set.Selection(obj,val)
            obj.selectTextLineColumn(val(1),val(2),val(3),val(4));
        end
        function val=get.Cursor(obj)
            val=obj.fCursor;
        end
        function set.Cursor(obj,val)
            obj.setCursor(val(1),val(2));
        end
        function val=get.Index(obj)
            val=obj.fIndex;
        end
        function set.Index(obj,val)
            [line,column]=obj.indexToPositionInLine(val);
            obj.setCursor(line,column);
        end
        function st=getStudio(obj)
            st=obj.studio;
        end
    end

    methods(Access=public)
        url=getUrl(obj)
        open(obj)
        close(obj)
    end

    methods(Access=public)
        init(obj)


        action(obj,msg)
        callback(obj,source,data)
        publish(obj,action,data)
        refresh(obj,uid)
        lock(obj,flag)
        insertText(obj,text,line,column)
        updateID(obj)


        setCursor(obj,line,col)
        bool=goToLine(obj,lineNum)


        selectText(obj,sPos,ePos)
        selectTextLineColumn(obj,sLine,sCol,eLine,eCol)
        clearSelection(obj)


        highlight(obj,sPos,ePos)
        highlightLineColumn(obj,sLine,sCol,eLine,eCol)
        highlightMultiRanges(obj,ranges)
        highlightMultiRangesNoColorChange(obj,ranges)
        clearHighlight(obj)


        createToolStripContext(obj)
        enable=enableNextPreviousButton(obj,set)


        status=getContextMenuStatus(obj)
        navigateToCode(obj,line,type)


        ret=getInputArgs(obj)
        ret=evalM(obj,data)
        update(obj,text,objectId,uid)
        updateTextProperty(obj,data,eid)
        makeActive(obj)
        onEditorClose(obj,cbinfo)
        handleActiveEditorChanged(obj,cbinfo)
        name=getName(obj)
        [line,col]=indexToPositionInLine(obj,index)
        index=positionInLineToIndex(obj,line,col)
        status=getDSMenuStatus(obj);
        executeDebugContextMenuAction(obj,actionId);
        registerFocusListener(obj);
        unregisterFocusListener(obj);
        onFocusChange(obj);
        deleteAllBPsForBlock(obj,objectId);
    end

end

