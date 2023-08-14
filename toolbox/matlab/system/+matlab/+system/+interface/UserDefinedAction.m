classdef UserDefinedAction<matlab.system.interface.ActorAction







    properties(Access=public,Hidden=false)
        Name(1,:)char
        DefaultValue(1,1)struct
        ValueType(1,:)char
        BusName(1,:)char
    end

    methods
        function obj=UserDefinedAction(name,varargin)
            if(~isstring(name)&&~ischar(name))||strlength(name)==0
                error('Error in parsing name: action name must be nonempty string or char array.');
            end
            obj.Name=name;

            if nargin>3
                error('Too many input arguments');
            end

            if nargin<2
                error('Not enough input arguments');
            end

            if isa(varargin{1},'struct')


                obj.ValueType='struct';
                obj.DefaultValue=varargin{1};
            elseif isa(varargin{1},'char')||isa(varargin{1},'string')



                obj.ValueType='bus';
                obj.BusName=varargin{1};
                if nargin==3

                    obj.DefaultValue=varargin{2};
                end
            else
                error('Error in parsing action elements: action elements must be specified by a struct of the name of a bus object.');
            end
        end

    end
end