classdef Table<serdes.internal.ibisami.ami.format.AmiFormat

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



    properties(Constant)
        Name="Table";
    end
    properties
Labels
    end
    methods(Access=protected)
        function[ok,values]=validateValues(~,values)

            ok=ndims(values)<=2;
        end
        function[ok,default]=validateDefault(~,default)
            ok=false;
        end
        function setValue(~,~,~)

            warning(message('serdes:ibis:NotImplemented',"setValue "+table.Name))
        end
        function setTableValue(format,value,row,col)

            format.Values(row,col)=string(value);
        end
    end
    methods

        function table=Table(varargin)
            if nargin>0
                if nargin==1
                    values=varargin{1};
                    if~isempty(values)
                        table.Values=values;
                    else
                        error(message('serdes:ibis:InvalidConstructor'))
                    end
                elseif nargin>1
                    table.Values=varargin;
                else
                    error(message('serdes:ibis:InvalidConstructor'))
                end
            end
            table.AllowedTypeNames=[serdes.internal.ibisami.ami.type.Float().Name,...
            serdes.internal.ibisami.ami.type.UI().Name,...
            serdes.internal.ibisami.ami.type.Integer().Name,...
            serdes.internal.ibisami.ami.type.String().Name,...
            serdes.internal.ibisami.ami.type.Boolean().Name];
        end
    end
    methods
        function set.Labels(tableFormat,labels)
            validateattributes(labels,{'string','char'},{'vector'},'set.Labels','labels')
            sLabels(1,length(labels))=string;
            stringType=serdes.internal.ibisami.ami.type.String();
            for idx=1:length(labels)
                sLabels(idx)=stringType.convertToAmiValue(string(labels(idx)));
            end
            tableFormat.Labels=sLabels;
        end
    end
    methods

        function branch=getKeyWordBranch(tableFormat,types,indent)
            if isempty(tableFormat.Values)
                error(message('serdes:ibis:TableNotSet'))
            end
            tableIndent=indent+"  ";
            branch=newline+tableIndent+"("+tableFormat.Name;
            tableIndent=tableIndent+"  ";
            szvalues=size(tableFormat.Values);
            rows=szvalues(1);
            cols=szvalues(2);
            if length(types)~=1&&length(types)~=cols
                warning(message('serdes:ibis:TypeLengthWrong'))
            end
            if~isempty(tableFormat.Labels)
                if length(tableFormat.Labels)~=cols
                    warning(message('serdes:ibis:LabelLengthWrong'))
                end
                branch=branch+newline+tableIndent+"(Labels";
                for label=tableFormat.Labels
                    branch=branch+" "+label;
                end
                branch=branch+")";
            end
            for row=1:rows
                branch=branch+newline+tableIndent+"(";
                for col=1:cols
                    if col<=length(types)
                        type=types{col};
                    else
                        type=types{1};
                    end
                    value=type.convertToAmiValue(tableFormat.Values(row,col));
                    if col==1
                        branch=branch+value;
                    else
                        branch=branch+" "+value;
                    end
                end
                branch=branch+")";
            end
            branch=branch+newline+indent+"  )";
        end
        function verified=verifyValueForType(table,~,~)

            warning(message('serdes:ibis:NotImplemented',"Format "+table.Name))
            verified=false;
        end
    end
end

