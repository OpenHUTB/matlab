classdef Parameters<matlab.mixin.SetGet&matlab.mixin.Heterogeneous



    properties

        Name=''

        Description=''

        Unit=''

        Value=''

        Editable=false

        Plotable=[]

        DataSource=''


        VarName=''
    end

    methods
        function obj=Parameters(varargin)
            set(obj,varargin{:});
        end
    end

    methods(Access=public)
        function data=tocelldata(obj)

            data=cell(1,8);
            data{1,1}=obj.Name;
            data{1,2}=obj.Description;
            data{1,3}=obj.Unit;
            data{1,4}=obj.Value;
            data{1,5}=obj.Editable;
            data{1,6}=obj.Plotable;
            data{1,7}=obj.DataSource;
            data{1,8}=obj.VarName;
        end
    end

end