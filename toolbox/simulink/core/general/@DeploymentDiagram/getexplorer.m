function me=getexplorer(varargin)




    ID={};
    name={};
    if strcmp(varargin{1},'ID')
        ID=varargin{2};
    elseif strcmp(varargin{1},'name')
        name=varargin{2};
    end

    daRoot=DAStudio.Root;
    me={};
    m=daRoot.find('-isa','DeploymentDiagram.explorer');
    if~isempty(ID)
        for i=1:length(m)
            if strcmp(m(i).explorerID,ID)
                me=m(i);
                break;
            end

        end
    elseif~isempty(name)
        for i=1:length(m)
            if strcmp(m(i).getRoot.ParentDiagram,name)
                me=m(i);
                break;
            end

        end
    end

