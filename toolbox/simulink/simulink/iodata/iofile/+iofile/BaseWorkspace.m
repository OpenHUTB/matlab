classdef BaseWorkspace<iofile.File














    methods

        function theBaseWorkspace=BaseWorkspace(varargin)

            theBaseWorkspace=theBaseWorkspace@iofile.File(varargin{:});


            theBaseWorkspace.FileName=getString(message('sl_iofile:matfile:BaseWorkspace'));
        end


        function validateFileName(~,~)

        end

        function varOut=loadAVariable(~,varName)
            varOut.(varName)=evalin('base',varName);
        end

        function workSpaceData=load(~)
            baseWorkspaceVars=evalin('base','who');
            workSpaceData=struct;
            for id=1:length(baseWorkspaceVars)
                varName=baseWorkspaceVars{id};
                workSpaceData.(varName)=evalin('base',varName);
            end
        end


        function aList=whos(~)

            aList=evalin('base','whos');

        end


    end

end
