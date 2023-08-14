function varargout=validateLabelDefEntry(columnNames,varargin)

    numArgs=numel(varargin);

    varargout=cell(1,numArgs);

    for argNum=1:numArgs

        switch(columnNames{argNum})
        case 'Name'

            varargout{argNum}=isvarname(varargin{argNum});

        case 'Type'

            varargout{argNum}=isa(varargin{argNum},'labelType')&&isscalar(varargin{argNum});

        case 'LabelType'

            varargout{argNum}=isa(varargin{argNum},'labelType')&&isscalar(varargin{argNum});

        case 'SignalType'

            varargout{argNum}=isa(varargin{argNum},'vision.labeler.loading.SignalType')&&isscalar(varargin{argNum});

        case 'PixelLabelID'

            labelTypeCol=find((columnNames=="LabelType")|(columnNames=="Type"),1);
            isPixelLabelType=varargin{labelTypeCol}==labelType.PixelLabel;
            id=varargin{argNum};

            if isPixelLabelType
                varargout{argNum}=isValidPixelLabelID(id);
            else
                varargout{argNum}=(isnumeric(id)||ischar(id))&&isempty(id);
            end

        case 'Description'
            varargout{argNum}=isValidDescription(varargin{argNum});

        case 'Hierarchy'
            varargout{argNum}=isValidHierarchy(varargin{argNum});

        case 'Group'

            varargout{argNum}=isvarname(varargin{argNum});

        case 'LabelColor'
            varargout{argNum}=isValidColor(varargin{argNum});
        end
    end

end

function TF=isValidHierarchy(in)
    TF=isempty(in)||isstruct(in);
end

function TF=isValidDescription(in)
    TF=ischar(in)&&(isempty(in)||ismatrix(in));
end

function TF=isValidPixelLabelID(id)
    try


        validateattributes(id,{'numeric'},{'integer','real','finite','nonsparse','>=',0,'<=',255});
        TF=iscolumn(id)||(ismatrix(id)&&size(id,2)==3);
    catch
        TF=false;
    end
end

function TF=isValidColor(in)



    TF=isequal(size(in),[1,3])||isempty(in);
end