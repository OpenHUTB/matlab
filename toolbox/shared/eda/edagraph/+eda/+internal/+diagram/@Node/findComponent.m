function hC=findComponent(this,varargin)











    if nargin<3
        error(message('EDALink:Node:findComponent:RequiredPropertyValue'))
    elseif nargin<4
        Node=this;
    elseif nargin==4
        Node=varargin{3};
    end

    if strcmpi(Node,'treeRoot')
        root=this.findTreeRoot;
    else
        root=this;
    end
    Property=varargin{1};
    Value=varargin{2};


    hC=recursiveSearch(root,Property,Value);


    if strcmpi(Property,'Class')
        if isa(this,Value)
            hC{end+1}=this;
        end
    elseif strcmpi(this.(Property),Value)
        hC{end+1}=this;
    end


end



function hC=recursiveSearch(this,Property,Value)

    hC={};

    children=this.getChildren;

    if~isempty(children)

        for i=1:length(children)
            More=recursiveSearch(children(i),Property,Value);
            for loop=1:length(More)
                hC{end+1}=More{loop};
            end;%#ok<AGROW>

            if strcmpi(Property,'Class')
                if isa(children(i),Value)
                    hC{end+1}=children(i);%#ok<AGROW>
                end
            else
                if strcmpi(children(i).(Property),Value)
                    hC{end+1}=children(i);%#ok<AGROW>
                end
            end
        end
    end
end
