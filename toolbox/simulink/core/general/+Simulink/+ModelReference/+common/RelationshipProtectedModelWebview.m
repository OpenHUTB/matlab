




classdef RelationshipProtectedModelWebview<Simulink.ModelReference.common.Relationship
    methods

        function obj=RelationshipProtectedModelWebview(~)


            obj@Simulink.ModelReference.common.Relationship;
            obj.RelationshipName='webview';
            obj.DirName='webview';
        end


        function populate(obj,~)

            webviewDir=fullfile('slprj','webview');
            webviewDirPattern=fullfile(webviewDir,'*.zip');
            obj.addPartUsingFilePattern(webviewDirPattern,'webview');
        end
    end

    methods(Static)
        function out=getEncryptionCategory()
            out='VIEW';
        end


        function out=getRelationshipYear()
            out='2013';
        end

    end
end

