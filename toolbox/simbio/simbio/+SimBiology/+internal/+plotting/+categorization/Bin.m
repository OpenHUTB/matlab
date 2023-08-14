classdef Bin<handle&matlab.mixin.SetGet


    properties(Access=public)
categoryVariable
binValue
    end

    methods
        function obj=Bin(varargin)
            if nargin>0

                if isempty(varargin{1})
                    obj=SimBiology.internal.plotting.categorization.Bin.empty;

                elseif isstruct(varargin{1})||isa(varargin{1},'SimBiology.internal.plotting.categorization.Bin')
                    inputs=varargin{1};
                    numObj=numel(inputs);
                    obj(numObj,1)=SimBiology.internal.plotting.categorization.Bin;
                    arrayfun(@(bin,in)bin.configureSingleObjectFromStruct(in),obj,inputs);

                else
                    categoryVariable=varargin{1};
                    binValue=varargin{2};
                    set(obj,'categoryVariable',categoryVariable,...
                    'binValue',binValue);
                end
            end
        end
    end

    methods(Access=private)
        function configureSingleObjectFromStruct(obj,input)

            set(obj,'categoryVariable',SimBiology.internal.plotting.categorization.CategoryVariable(input.categoryVariable),...
            'binValue',SimBiology.internal.plotting.categorization.binvalue.BinValue.createBinValues(input.binValue));
        end
    end

    methods(Access=public)
        function bins=getStruct(obj)
            bins=arrayfun(@(bin)struct('categoryVariable',bin.categoryVariable.getStruct,...
            'binValue',bin.binValue.getStruct),...
            obj);
        end
    end
end
