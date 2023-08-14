






function varargout=hdlmodelchecker(DUT,varargin)
    if(nargin<1)
        error(message('HDLShared:hdlmodelchecker:hdlmodelchecker_invalid_pv_pairs'));
    elseif(nargin>=2)

        if~isempty(DUT)
            DUT=convertStringsToChars(DUT);
        end

        [varargin{:}]=convertStringsToChars(varargin{:});

        if~strcmpi(varargin{1},'-cli')
            error(message('HDLShared:hdlmodelchecker:hdlmodelchecker_invalid_pv_pairs'));
        end
        silence_results=false;

        checker=hdlcoder.ModelChecker(DUT);
        checker.runChecks(silence_results);

        if(nargout>0)
            varargout{1}=checker.m_Checks;
        end
        return;
    end


    if~isempty(DUT)
        DUT=convertStringsToChars(DUT);
    end

    try
        mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(DUT,'new','com.mathworks.HDL.ModelChecker');
    catch me
        error(message('HDLShared:hdlmodelchecker:hdlmodelchecker_modeladvisor_error',me.message))
    end
    CustomObj=ModelAdvisor.Customization;



    CustomObj.GUITitle='hdlmodelchecker';
    CustomObj.GUICloseCallback={};
    CustomObj.MenuFile.Visible=false;
    CustomObj.MenuRun.Visible=false;
    CustomObj.MenuSettings.Visible=false;

    mdladvObj.CustomObject=CustomObj;

    hdlcoder.ModelChecker.setAdvisor(mdladvObj);
    mdladvObj.displayExplorer();
    mdladvObj.MAExplorer.title=[DAStudio.message('HDLShared:hdlmodelchecker:cat_Model_Checker'),' - ',getfullname(DUT)];
    if(nargout>0)
        varargout{1}=mdladvObj;
    end
end
