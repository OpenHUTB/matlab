




classdef(Sealed)Expression<matlab.io.savevars.internal.Serializable&matlab.mixin.CustomDisplay
    properties
ExpressionString
    end

    methods(Access=private)
        function obj=Expression(str)
            obj.ExpressionString=str;
        end
    end

    methods
        function obj=set.ExpressionString(obj,expr)
            if ischar(expr)||isstring(expr)
                obj.ExpressionString=string(expr);
            else
                id='MATLAB:class:MustBeString';
                except=MException(message(id));
                throw(except);
            end
        end
    end

    methods(Access=protected)


        function str=generateElementStrArray(obj)
            str=strings(numel(obj),1);
            for k=1:numel(obj)
                str(k,1)="slexpr"+"("+"#"+obj(k).ExpressionString+"#"+")";
            end
            str=reshape(str,size(obj));
        end

        function displayScalarObject(obj)
            str=generateElementStrArray(obj);
            str=replace(str,'#','"');
            disp(str);
        end

        function displayNonScalarObject(obj)
            str=generateElementStrArray(obj);%#ok
            sdisp=evalc('disp(str)');
            sdisp=replace(sdisp,'"','');
            sdisp=replace(sdisp,'#','"');
            disp(sdisp);
        end
    end

    methods(Static)
        function obj=CreateInstance(str)
            obj=Simulink.data.Expression(str);
        end
    end

    methods(Static,Hidden)
        function str=getConstructionStringForSaveVars(obj,~)
            str="slexpr"+"("+""""+obj.ExpressionString+""""+")";
            str=char(str);
        end
    end

end
