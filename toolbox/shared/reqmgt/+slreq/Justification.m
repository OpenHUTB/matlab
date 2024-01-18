classdef Justification<slreq.BaseEditableItem

    methods

        function this=Justification(dataObject)
            this@slreq.BaseEditableItem(dataObject);
        end


        function childJustification=add(this,varargin)
            this.errorIfVectorOperation();
            if isempty(varargin)
                reqInfo=[];
            else
                [varargin{:}]=convertStringsToChars(varargin{:});
                reqInfo=slreq.utils.apiArgsToReqStruct(varargin{:});
                slreq.BaseItem.ensureWriteableProps(reqInfo);
            end
            req=this.dataObject.addChildJustification(reqInfo);
            childJustification=slreq.utils.wrapDataObjects(req);
        end


        function tf=isHierarchical(this)
            this.errorIfVectorOperation();
            tf=this.dataObject.isHierarchicalJustification();
        end


        function setHierarchical(this,tf)
            this.errorIfVectorOperation();
            this.dataObject.isHierarchicalJustification=tf;
        end
    end
end
