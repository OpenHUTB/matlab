


classdef SLCIToolstripContext<dig.CustomContext
    properties(GetAccess=public,SetAccess=public,SetObservable=true)
        isTopModel;
        isFollowModelLinks=false;
        isInspectSharedUtils;
        isDisableNonInlinedFuncBodyVerification=false;
        isSingleFolderCodePlacement=false;
        isTerminateOnIncompatibility=false;
        isEditTimeCheck=false;
        isCompatibilityOn=false;
        fCodeFolder='';
        fReportFolder='';
        fModelAdvisorReportFolder='';
        fReviewMode='AutomaticReview';
        codeLanguage='hdl';
    end

    methods

        function obj=SLCIToolstripContext(app)
            obj@dig.CustomContext(app);
            obj.init();
            if(~ispref('slci_toolstrip','SLCIEditTime'))
                addpref('slci_toolstrip','SLCIEditTime',obj.isEditTimeCheck);
            else
                obj.isEditTimeCheck=getpref('slci_toolstrip','SLCIEditTime');
            end
        end


        function out=getTopModel(obj)
            out=obj.isTopModel;
        end


        function out=getFollowModelLinks(obj)
            out=obj.isFollowModelLinks;
        end


        function out=getInspectSharedUtils(obj)
            out=obj.isInspectSharedUtils;
        end


        function out=getDisableNonInlinedFuncBodyVerification(obj)
            out=obj.isDisableNonInlinedFuncBodyVerification;
        end


        function out=getSingleFolderCodePlacement(obj)
            out=obj.isSingleFolderCodePlacement;
        end


        function out=getTerminateOnIncompatibility(obj)
            out=obj.isTerminateOnIncompatibility;
        end


        function out=getCodeFolder(obj)
            out=obj.fCodeFolder;
        end


        function out=getReportFolder(obj)
            out=obj.fReportFolder;
        end


        function out=getModelAdvisorReportFolder(obj)
            out=obj.fModelAdvisorReportFolder;
        end


        function out=getReviewMode(obj)
            out=obj.fReviewMode;
        end


        function out=getEditTimeCheck(obj)
            out=obj.isEditTimeCheck;
        end


        function setTopModel(obj,value)
            obj.isTopModel=value;
        end


        function setFollowModelLinks(obj,value)
            obj.isFollowModelLinks=value;
        end


        function setInspectSharedUtils(obj,value)
            obj.isInspectSharedUtils=value;
        end


        function setDisableNonInlinedFuncBodyVerification(obj,value)
            obj.isDisableNonInlinedFuncBodyVerification=value;
        end


        function setSingleFolderCodePlacement(obj,value)
            obj.isSingleFolderCodePlacement=value;
        end


        function setTerminateOnIncompatibility(obj,value)
            obj.isTerminateOnIncompatibility=value;
        end


        function setCodeFolder(obj,value)
            obj.fCodeFolder=value;
        end


        function setReportFolder(obj,value)
            obj.fReportFolder=value;
        end


        function setModelAdvisorReportFolder(obj,value)
            obj.fModelAdvisorReportFolder=value;
        end


        function setAssistedReviewMode(obj)
            obj.fReviewMode='AssistedReview';
        end


        function setAutomaticReviewMode(obj)
            obj.fReviewMode='AutomaticReview';
        end


        function setEditTimeCheck(obj,value)
            obj.isEditTimeCheck=value;
            setpref('slci_toolstrip','SLCIEditTime',value);
        end


        function setCodeLanguage(obj,value)
            assert(strcmpi(value,'c')...
            ||strcmpi(value,'hdl')||strcmpi(value,'cuda'));
            obj.codeLanguage=value;
        end


        function out=getCodeLanguage(obj)
            out=obj.codeLanguage;
        end


        function updateAutomaticReviewTypeChain(obj)
            obj.TypeChain={'slciAppContext','slciAutomaticReviewContext'};
        end


        function updateAssistedReviewTypeChain(obj)
            obj.TypeChain={'slciAppContext','slciAssistedReviewContext'};
        end


        function setCompatibilityOn(obj,value)
            obj.isCompatibilityOn=value;
        end


        function out=getCompatibilityOn(obj)
            out=obj.isCompatibilityOn;
        end
    end

    methods(Sealed)

        function openApp(~,cbinfo)


            studio=cbinfo.studio;


            vm=slci.view.Manager.getInstance;
            if vm.isAvailable(studio)
                vm.open(studio);
            end
        end
    end

    methods(Access=private)

        function init(aObj)
            aObj.setTopModel(true);

            aObj.setInspectSharedUtils(slci.Configuration.getInspectSharedUtils);

            fileGenCfg=Simulink.fileGenControl('getConfig');
            rootBDir=fileGenCfg.CodeGenFolder;
            reportFolder=fullfile(rootBDir,'slprj','slci');
            aObj.setReportFolder(reportFolder);
        end
    end

end
