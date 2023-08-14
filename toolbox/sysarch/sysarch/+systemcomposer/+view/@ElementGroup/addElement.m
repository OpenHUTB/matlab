function addElement(this,elementsToAdd)









    parser=inputParser;
    parser.addRequired('elementsToAdd',@(x)validateattributes(x,...
    {'char','string','cell','systemcomposer.arch.BaseComponent'},string.empty(1,0)));
    parser.parse(elementsToAdd);

    if ischar(elementsToAdd)||iscell(elementsToAdd)
        elementsToAdd=string(elementsToAdd);
    end

    if~isempty(this.getImpl.getView.getRoot.p_Query)

        systemcomposer.internal.throwAPIError('CantModifyQueryView');
    end

    zcMdl=systemcomposer.internal.getWrapperForImpl(this.getImpl.getView.p_Model);

    txn=this.MFModel.beginTransaction;
    for i=1:numel(elementsToAdd)
        elem=getElementToAdd(zcMdl,elementsToAdd(i));
        this.getImpl.addElement(elem.getImpl);
    end
    txn.commit;

end

function elemToAdd=getElementToAdd(zcModel,elem)

    if isstring(elem)
        elemToAdd=zcModel.lookup('Path',elem);
    else
        elemToAdd=elem;
    end

end

