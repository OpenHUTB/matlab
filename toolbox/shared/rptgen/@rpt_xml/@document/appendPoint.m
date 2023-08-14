function varargout=appendPoint(d,varargin)









    if isempty(d.InsertionPoint)
        d.InsertionPoint=d.getDocumentElement;
    end

    for i=1:length(varargin)
        if isa(varargin{i},'rptgen.rptcomponent')
            varargin{i}=runComponent(varargin{i},d);
        else
            varargin{i}=makeNode(d,varargin{i});
        end

        if d.InsertAtEnd
            appendChild(d.InsertionPoint,varargin{i});
        else
            parentNode=getParentNode(d.InsertionPoint);
            parentNode.insertBefore(varargin{i},d.InsertionPoint);

        end
        varargout{i}=varargin{i};
    end
