classdef VirtualFeature<matlab.mixin.SetGet&matlab.mixin.Heterogeneous



    properties

        Feature=''

        Type='Mandatory'

        FeatureVariant=[]

        FeatureParameter=[]


        Label=[]


        Icon=[]
        Image=[];
    end

    methods
        function obj=VirtualFeature(varargin)
            set(obj,varargin{:});
        end
    end

    methods
        function dataout=tocelldata(obj,index)

            n=length(obj.FeatureParameter{index});
            dataout=cell(n,8);
            pp=obj.FeatureParameter{index};
            for i=1:n
                dataout(i,:)=pp{i}.tocelldata;
            end
        end
    end
end
