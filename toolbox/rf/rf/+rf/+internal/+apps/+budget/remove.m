function remove(parentLayout,dimension,varargin)












    validDimensions=@(x)validatestring(x,{'row',...
    'column'},...
    'dimension','remove');
    p=inputParser;
    p.addRequired('Parent',...
    @(x)isa(x,'matlab.ui.container.GridLayout'));
    p.addRequired('Dimension',@(x)~isempty(validDimensions(x)));
    p.addRequired('Index',@isnumeric);
    parse(p,parentLayout,validDimensions(dimension),varargin{:});

    parentLayout=p.Results.Parent;
    location=p.Results.Index;
    dimension=p.Results.Dimension;
    switch dimension
    case 'row'
        accessDimension='Row';
        accessSize='RowHeight';
    case 'column'
        accessDimension='Column';
        accessSize='ColumnWidth';
    end

    controlCellArray={};
    for k=1:length(parentLayout.Children)
        fellowIndex=parentLayout.Children(k).Layout.(accessDimension);
        if fellowIndex==location
            controlCellArray{end+1}=parentLayout.Children(k);%#ok<AGROW>
        end
    end
    cellfun(@(x)removeParent(x,[]),controlCellArray,...
    'UniformOutput',false);


    if location<=getLastIndex(parentLayout,dimension)
        for i=location:getLastIndex(parentLayout,dimension)

            for j=1:length(parentLayout.Children)
                fellowIndex=parentLayout.Children(j).Layout.(accessDimension);
                if fellowIndex>location
                    parentLayout.Children(j).Layout.(accessDimension)=fellowIndex-1;
                end
            end
            break
        end
    else
        parentLayout.(accessSize){end+1}='1x';
    end
    parentLayout.(accessSize)(location)=[];
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

    function removeParent(item1,item2)
        item1.Parent=item2;
    end
end


