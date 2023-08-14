function s=getStylesheetID(o,varargin)











    propName=o.getStylesheetProperty(varargin{:});
    if isempty(propName)
        s='';
    else
        s=get(o,propName);

        if isempty(s)

            s=['default-',lower(propName(11:end))];
        end

        if ischar(s)

        elseif isa(s,'java.lang.String')
            s=char(s);
        elseif isa(s,'com.mathworks.toolbox.rptgencore.tools.StylesheetMaker')
            s=char(s.getID);
        elseif isa(s,'javax.xml.transform.Source')
            s=char(s.toString);
        else
            s=[];
        end
    end