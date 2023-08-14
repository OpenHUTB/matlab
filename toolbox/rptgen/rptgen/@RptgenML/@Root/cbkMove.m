function cbkMove(this,moveDirection)






    ime=DAStudio.imExplorer(this.Editor);
    currentNode=ime.getCurrentTreeNode;
    if isempty(currentNode)
        return
    end

    switch moveDirection(1)
    case 'd'
        wasMoved=currentNode.moveDown;
    case 'u'
        wasMoved=currentNode.moveUp;
    case 'r'
        wasMoved=currentNode.moveRight;
    case 'l'
        wasMoved=currentNode.moveLeft;
    otherwise
        wasMoved=false;
    end

    if(wasMoved&&isa(this.Editor,'DAStudio.Explorer'))
        ed=DAStudio.EventDispatcher;
        ed.broadcastEvent('HierarchyChangedEvent',currentNode.up);
        this.Editor.view(currentNode);


        set([this.Actions.MoveUp],...
        'Enabled',locOnOff(moveUp(currentNode,true)));

        set([this.Actions.MoveDown],...
        'Enabled',locOnOff(moveDown(currentNode,true)));

        set([this.Actions.MoveLeft],...
        'Enabled',locOnOff(moveLeft(currentNode,true)));

        set([this.Actions.MoveRight],...
        'Enabled',locOnOff(moveRight(currentNode,true)));

    end


    function oo=locOnOff(tf)

        if tf
            oo='on';
        else
            oo='off';
        end
