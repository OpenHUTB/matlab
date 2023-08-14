classdef m2m_IOPortsXform<handle





    properties
fTopMdlHandle
fXformCmd
    end

    methods
        function obj=m2m_IOPortsXform(modelName)


            obj.fTopMdlHandle=get_param(bdroot(modelName),'handle');
            obj.fXformCmd=[];
            result=Simulink.SLPIR.ModelXform_IOPorts.RefactorIOPorts(obj.fTopMdlHandle);
            obj.fXformCmd=result.Xform_Cmds;
        end

        function errMsg=performXformation(this)
            errMsg=[];

            failed_cmd=[];
            ss={};
            for i=1:length(this.fXformCmd)
                cmd=this.fXformCmd{i};
                try
                    sspath=this.extractModelName(cmd);
                    if~isempty(sspath)
                        ss{end+1}=sspath;%#ok<AGROW> 
                    end
                    eval(cmd);
                catch
                    failed_cmd=[failed_cmd,{cmd}];%#ok<AGROW> 
                end
            end
            ss=unique(ss);
            for i=1:length(ss)
                Simulink.BlockDiagram.arrangeSystem(ss{i});
            end
        end

        function out=extractModelName(~,cmd)
            out=[];
            if~isempty(regexp(cmd,'^add_block','once'))
                exp=[bdroot,'[A-Za-z0-9_/]+'')'];
                startIndex=regexp(cmd,exp);
                ss=extractAfter(cmd,startIndex-1);
                indices=strfind(ss,'/');
                out=extractBefore(ss,indices(end));
            end
        end
    end
end


