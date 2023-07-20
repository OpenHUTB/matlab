classdef StatusDependency









    properties
StatusLimit
ParentList
License
    end

    methods
        function obj=StatusDependency(status,parentNodes,licenses,negate)
            obj.StatusLimit=status;
            n=length(parentNodes);
            for i=1:n
                pNode=parentNodes{i};
                obj.ParentList{i}=loc_createParent(pNode,negate);
            end
            if isempty(licenses)
                obj.License=[];
            else
                obj.License=configset.internal.dependency.LicenseDependency(licenses);
            end
        end

        out=getStatus(obj,cs,varargin)
        out=getInfo(obj)
    end
end

function out=loc_createParent(node,negate)
    out.Name='';
    out.ValueSet={};

    name=strtrim(node.getFirstChild.getNodeValue);
    out.Name=name;
    out.Negate=~isempty(node.getAttribute('invert'));
    if negate
        out.Negate=~out.Negate;
    end

    vs=node.getElementsByTagName('value');
    for i=1:vs.getLength
        v=vs.item(i-1);
        if isempty(v.getFirstChild)
            out.ValueSet{end+1}='';
        else
            out.ValueSet{end+1}=v.getFirstChild.getNodeValue;
        end
    end
end
