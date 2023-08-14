classdef List<serdes.internal.ibisami.ami.format.ListCommon




    properties(Constant)
        Name="List"
        List_Tip="List_Tip"
    end

    properties
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

ListTips
    end

    methods
        function format=List(varargin)
...
...
...
...
...
            format.ListTips={};
            if nargin>0
                if nargin==1
                    values=varargin{1};
                    if~isempty(values)
                        format.Values=values;
                        format.Default=values(1);
                    else
                        error(message('serdes:ibis:InvalidConstructor'))
                    end
                elseif nargin>1
                    format.Values=varargin;
                    format.Default=format.Values(1);
                else
                    error(message('serdes:ibis:InvalidConstructor'))
                end



            end
        end
        function setListTip(format,listTips)
            format.ListTips=listTips;
        end
    end
    methods

        function branch=getListTipBranch(format)
            if~isempty(format.ListTips)
                stringType=serdes.internal.ibisami.ami.type.String;
                branch="("+format.List_Tip;
                for idx=1:length(format.ListTips)
                    value=stringType.convertToAmiValue(format.ListTips{idx});
                    branch=branch+" "+value;
                end
                branch=branch+")";
            else
                branch="";
            end
        end
    end
end

