function theObject=getObject(objH,isSf)

    if nargin<2
        [~,objH,isSf]=rmisl.resolveObj(objH);
    end

    if isSf
        sfRt=Stateflow.Root;
        theObject=sfRt.idToHandle(objH);
    else
        theObject=get_param(objH,'Object');
    end
end
