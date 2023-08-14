classdef SDPModelNode<handle



    properties
id
name
path
        refMdls={}

CodeGen
CoderDictionary
Platform
DeploymentType
    end

    methods
        function obj=SDPModelNode(id)
            list=strsplit(id,'/');
            model=list{end};

            obj.id=id;
            obj.name=model;
            obj.path=list;
            obj.init();
        end
    end
end

