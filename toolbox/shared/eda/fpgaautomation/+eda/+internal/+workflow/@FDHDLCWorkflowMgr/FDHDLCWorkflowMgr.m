classdef FDHDLCWorkflowMgr<eda.internal.workflow.WorkflowManager




    properties
    end

    methods
        function h=FDHDLCWorkflowMgr(varargin)

            h@eda.internal.workflow.WorkflowManager(varargin{:});

        end


        function validate(h,varargin)


            h.getHDLParameters;

            userParam=h.mWorkflowInfo.userParam;

            if strcmpi(userParam.workflow,'Project generation')
                if strcmpi(userParam.projectGenOutput,'ISE project')
                    if strcmpi(userParam.projectType,'Create new project')
                        h.validateCreateProject;
                    else
                        h.validateAddExistingProject;
                    end
                else
                    h.validateGenerateTcl;
                end

                h.validateGenerateDCM;
            else
                h.validateUSRP;
            end
        end

        function run(h,varargin)


            persistent isDeprecationWarningIssued;
            if isempty(isDeprecationWarningIssued)
                isDeprecationWarningIssued=1;
                warning(message('EDALink:WorkflowManager:WorkflowManager:deprecation'));
            end


            h.checkLicense;

            disp(' ');
            hdldisp('Begin FPGA Workflow');
            disp(' ');


            h.getHDLCodeInfo;


            userParam=h.mWorkflowInfo.userParam;
            if strcmpi(userParam.workflow,'Project generation')
                h.generateDCM;
            end


            if strcmpi(userParam.workflow,'Project generation')
                if strcmpi(userParam.projectGenOutput,'ISE project')
                    if strcmpi(userParam.projectType,'Create new project')
                        status=h.createProject;
                    else
                        status=h.addExistingProject;
                    end
                else
                    status=h.generateTclScript;
                end
            else
                status=h.runUSRP;
            end

            if~status
                hdldisp('FPGA Workflow Complete.');
                disp(' ');
            end
        end

        function checkSupportedOS(h)




            b=hdlcoderui.isedasimlinksinstalled;
            if~b
                error(message('EDALink:WorkflowManager:WorkflowManager:noEDALinksInstalled'));
            end
        end

    end
end
