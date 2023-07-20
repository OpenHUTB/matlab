function[fullName,lineage,prefix]=getFullNameUpto(obj,stopAt,sep,addClass,useShortName)








    if nargin<5
        useShortName=false;
    end

    if nargin<4
        addClass=false;
    end

    if nargin<3
        sep='_';
    end

    lineage={};
    if~isempty(obj)
        objName=obj.Name;
        if addClass
            objName=[objName,sep,class(obj)];
        end
        lineage{end+1}=objName;
        parent=obj.Container;
        prefix='';
        while~isa(parent,stopAt)
            if addClass
                parentClass=[sep,class(parent)];
            else
                parentClass='';
            end
            lineage{end+1}=[parent.Name,parentClass];%#ok<AGROW>
            if useShortName
                parentsName=parent.Name;



                prefix=[parentsName(1),prefix];%#ok<AGROW>
            else
                prefix=[parent.Name,parentClass,sep,prefix];%#ok<AGROW>
            end
            parent=parent.Container;
        end
        if useShortName

            if~isempty(prefix)
                fullName=[prefix,sep,objName];
            else
                fullName=objName;
            end
        else
            fullName=[prefix,objName];
        end
    else
        fullName='';
    end
end

