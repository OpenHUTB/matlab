function products=identifyProducts(varargin)

    products=i_makeStr(cell(0,1),cell(0,1));
    if nargin==0
        return;
    end

    tbf=dependencies.internal.analysis.toolbox.ToolboxFinder;

    for basecode=varargin
        toolbox=tbf.fromBaseCode(basecode{1});
        if~isempty(toolbox)&&~toolbox.IsInstalled
            name=toolbox.Name;
            products(end+1,1)=i_makeStr(basecode,name);%#ok<AGROW>
        end
    end

    [~,idx]=sort({products.name});
    products=products(idx);

end


function str=i_makeStr(basecode,name)
    str=struct("basecode",basecode,"name",name);
end
