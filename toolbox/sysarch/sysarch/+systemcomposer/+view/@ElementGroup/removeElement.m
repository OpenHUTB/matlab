function removeElement(this,elementsToRemove)









    parser=inputParser;
    parser.addRequired('elementsToAdd',@(x)validateattributes(x,...
    {'char','string','cell','systemcomposer.arch.BaseComponent'},{}));
    parser.parse(elementsToRemove);

    if ischar(elementsToRemove)||iscell(elementsToRemove)
        elementsToRemove=string(elementsToRemove);
    end

    if~isempty(this.getImpl.getView.getRoot.p_Query)

        systemcomposer.internal.throwAPIError('CantModifyQueryView');
    end

    zcMdl=systemcomposer.internal.getWrapperForImpl(this.getImpl.getView.p_Model);

    txn=this.MFModel.beginTransaction;
    for i=1:numel(elementsToRemove)
        elem=getElementToRemove(zcMdl,elementsToRemove(i));
        this.getImpl.removeElement(elem.getImpl);
    end
    txn.commit;

end

function elemToRemove=getElementToRemove(zcModel,elem)

    if isstring(elem)
        elemToRemove=zcModel.lookup('Path',elem);
    else
        elemToRemove=elem;
    end

end

