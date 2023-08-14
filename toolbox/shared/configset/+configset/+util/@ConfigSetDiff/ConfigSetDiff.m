classdef ConfigSetDiff<handle



    properties
CS1
CS2
IsEqual
Diff
Number
ModelName
    end

    methods
        function obj=ConfigSetDiff(cs1,cs2,name)
            if isa(cs1,'Simulink.ConfigSet')
                obj.CS1=cs1;
            else
                obj.CS1=cs1.getRefConfigSet;
            end

            if isa(cs2,'Simulink.ConfigSet')
                obj.CS2=cs2;
            else
                obj.CS2=cs2.getRefConfigSet;
            end

            if~exist('name','var')
                name='';
            end
            obj.ModelName=name;

            [obj.IsEqual,nameList]=isequal(obj.CS1,obj.CS2);
            obj.Number=length(nameList);
            obj.Diff=cell(obj.Number,3);
            if~obj.IsEqual
                for i=1:obj.Number
                    paramName=nameList{i};
                    obj.Diff{i,1}=paramName;
                    if cs1.isValidParam(paramName)
                        p1=obj.CS1.get_param(paramName);
                    else
                        p1='[N/A]';
                    end
                    if cs2.isValidParam(paramName)
                        p2=obj.CS2.get_param(paramName);
                    else
                        p2='[N/A]';
                    end

                    if isa(p1,'cell')
                        p1='{cell...}';
                    end
                    if isa(p2,'cell')
                        p2='{cell...}';
                    end

                    if isa(p1,'struct')
                        p1='{struct...}';
                    end
                    if isa(p2,'struct')
                        p2='{struct...}';
                    end

                    if isa(p1,'double')
                        p1=num2str(p1);
                    end
                    if isa(p2,'double')
                        p2=num2str(p2);
                    end

                    obj.Diff{i,2}=p1;
                    obj.Diff{i,3}=p2;
                end
            end
        end


    end

end
