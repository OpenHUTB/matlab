function ti=getTypeInfo(adSF,objType,varargin)













    if nargin<2
        ti=adSF.TypeTable;

        return;
    end

    if ischar(objType)
        idx=find(strcmpi({adSF.TypeTable.Name},objType));
        if isempty(idx)
            error(message('RptgenSL:rsf_appdata_sf:invalidType',objType));
        else
            ti=adSF.TypeTable(idx);
            if length(varargin)>0
                ti=getfield(ti,varargin{1});
            end
        end
    elseif ishandle(objType)
        objType=strsplit(class(objType),'.');
        objType=objType{end};
        ti=getTypeInfo(adSF,objType,varargin{:});
    else
        error(message('RptgenSL:rsf_appdata_sf:invalidInput'));
    end
