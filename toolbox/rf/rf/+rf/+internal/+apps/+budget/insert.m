function insert(parentLayout,dimension,varargin)














    validDimensions=@(x)validatestring(x,{'row',...
    'column'},...
    'dimension','insert');
    p=inputParser;
    p.addRequired('Parent',...
    @(x)isa(x,'matlab.ui.container.GridLayout'));
    p.addRequired('Dimension',@(x)~isempty(validDimensions(x)));
    p.addOptional('Index',getLastIndex(parentLayout,dimension)+1,@isnumeric);
    p.addOptional('Size','1x',@isnumeric);
    parse(p,parentLayout,validDimensions(dimension),varargin{:});

    parentLayout=p.Results.Parent;
    location=p.Results.Index;
    dimension=p.Results.Dimension;
    insertingSize=p.Results.Size;
    switch dimension
    case 'row'
        accessDimension='Row';
        accessSize='RowHeight';
    case 'column'
        accessDimension='Column';
        accessSize='ColumnWidth';
    end

    if location<=getLastIndex(parentLayout,dimension)
        parentLayout.(accessSize)=...
        [parentLayout.(accessSize)(1:location-1)...
        ,{insertingSize}...
        ,parentLayout.(accessSize)(location:end)];
        for i=location:getLastIndex(parentLayout,dimension)

            for j=1:length(parentLayout.Children)
                fellowIndex=parentLayout.Children(j).Layout.(accessDimension);
                if isscalar(fellowIndex)

                    if fellowIndex>=location
                        parentLayout.Children(j).Layout.(accessDimension)=fellowIndex+1;
                    end
                else

                    if~isempty(find(fellowIndex==location,1))
                        parentLayout.Children(j).Layout.(accessDimension)=fellowIndex+1;
                    end
                end

            end
            break;
        end
    else
        parentLayout.(accessSize){end+1}='1x';
    end
    function idx=getLastIndex(parentLayout,dimension)










        parser=inputParser;
        parser.addRequired('Parent',...
        @(x)isa(x,'matlab.ui.container.GridLayout'));
        parser.addRequired('Dimension',@(x)~isempty(validDimensions(x)));
        parse(parser,parentLayout,validDimensions(dimension));

        parentLayout=parser.Results.Parent;
        dimension=parser.Results.Dimension;
        switch dimension
        case 'row'
            idx=numel(parentLayout.RowHeight);
        case 'column'
            idx=numel(parentLayout.ColumnWidth);
        end
    end
end


