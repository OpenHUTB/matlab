classdef(Abstract)AmiFormat<serdes.internal.ibisami.ami.Keyword
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



    properties
        Default=[]
Values
    end

    properties(Access=protected)


        AllowedTypeNames=[]
    end
    methods(Access=protected)


        function[ok,values]=validateValues(~,values)



            ok=isvector(values);
        end
        function[ok,default]=validateDefault(~,default)
            ok=true;
        end
        function setValue(format,value,idx)

            format.Values(idx)=string(value);
        end
    end
    methods
        function set.Values(format,values)
            [ok,values]=validateValues(format,values);
            if ok

                szvalues=size(values);
                rows=szvalues(1);
                cols=szvalues(2);



                sValues(rows,cols)=string;
                for row=1:rows
                    for col=1:cols
                        sValues(row,col)=string(values(row,col));
                    end
                end
                format.Values=sValues;
            end
        end
        function set.Default(format,value)
            if ischar(value)
                value=string(value);
            end
            if isscalar(value)&&(~isnumeric(value)||isreal(value))
                sValue=string(value);
                if strcmp(sValue,"true")
                    sValue="True";
                elseif strcmp(sValue,"false")
                    sValue="False";
                end
                [ok,sValue]=validateDefault(format,sValue);
                if ok
                    format.Default=sValue;
                end
            end
        end
    end
    methods
        function ok=validateFormatAndType(format,type)
            ok=true;
            if isempty(format.AllowedTypeNames)
                return
            end
            for allowedTypeName=format.AllowedTypeNames
                if strcmp(allowedTypeName,type.Name)
                    return
                end
            end
            ok=false;
        end
    end
    methods

        function branch=getKeyWordBranch(format,type,~)
            branch="("+format.Name;
            for idx=1:length(format.Values)
                value=type.convertToAmiValue(format.Values{idx});
                branch=branch+" "+value;
            end
            branch=branch+")";
        end
    end
    methods(Abstract)


        verificationResult=verifyValueForType(type,value)
    end
end

