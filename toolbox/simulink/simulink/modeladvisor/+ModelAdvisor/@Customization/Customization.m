classdef Customization
    properties(Hidden)

        GUITitle='';


        GUICloseCallback={};


        GUIReportTabName='';


        ReportTitle='';


        ReportPageTitleCallback={};


        MenuFile={};


        MenuRun={};


        MenuSettings={};


        MenuHelp={};


        MenuAbout={};


        ShowAccordion=false;


        AccordionInfo={};


        LoadRestorePointCallback={};
    end

    methods
        function obj=Customization
            mlock;
        end
    end
end