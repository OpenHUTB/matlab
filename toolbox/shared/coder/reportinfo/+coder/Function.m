classdef Function<matlab.mixin.Heterogeneous&matlab.mixin.CustomDisplay&coder.Location

























































    properties(SetAccess=private)
        Name char=''
        Specialization double=0
        File coder.File
        Variables coder.Variable=coder.Variable.empty()
        Callees coder.Function=coder.Function.empty()
        ShowVariableTypeInfo=false
    end

    methods(Access={?codergui.internal.CodegenInfoBuilder,?coder.Method})
        function obj=Function(name,specialization,file,variables,showVariableTypeInfo)
            if nargin==0
                return
            end
            narginchk(5,5);
            obj.Name=name;
            obj.Specialization=specialization;
            obj.File=file;
            obj.Variables=variables;
            obj.ShowVariableTypeInfo=showVariableTypeInfo;
        end

        function setCallees(obj,callees)
            obj.Callees=callees;
        end
    end

    methods(Sealed,Access=protected)
        function propgrp=getPropertyGroups(obj)
            proplist={'Name','Specialization','File'};

            for i=1:numel(obj)
                if obj(i).ShowVariableTypeInfo
                    proplist{end+1}='Variables';%#ok<AGROW> 
                    break;
                end
            end
            proplist=[proplist,{'Callees','StartIndex','EndIndex'}];
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end


        function displayEmptyObject(obj)
            displayEmptyObject@matlab.mixin.CustomDisplay(obj);
        end

        function displayNonScalarObject(obj)
            displayNonScalarObject@matlab.mixin.CustomDisplay(obj);
        end

        function displayScalarObject(obj)
            displayScalarObject@matlab.mixin.CustomDisplay(obj);
        end

        function displayScalarHandleToDeletedObject(obj)
            displayScalarHandleToDeletedObject@matlab.mixin.CustomDisplay(obj);
        end

        function header=getHeader(obj)
            header=getHeader@matlab.mixin.CustomDisplay(obj);
        end

        function footer=getFooter(obj)
            footer=getFooter@matlab.mixin.CustomDisplay(obj);
        end
    end
end
