classdef ReportPageBase<handle





    properties
        Data=[]
        ReportFileName=''
    end

    properties(Transient)
        ReportFolder=''
        Doc=[]
        Toc=[]
        TocItems=[]
        Introduction=[]
        IntroductionContent=''
JavaScriptLib
JavaScriptHead
JavaScriptBody


        AddSectionToToc=false
        AddSectionNumber=true
        AddSectionShrinkButton=true
        AddDetailedErrorMessage=true
        IsEnMessage=false
    end

    properties(Access=private,Transient)
        sectionNum=0
        TableID=0
        LinkManager=[]
    end

    properties(Access=protected)
AdditionalInformation
    end

    properties(Transient)
        RelativePathToSharedUtilRptFromRpt=''
    end

    methods
        out=getAdditionalInformation(rpt)
        addAdditionalInformation(rpt,varargin)
    end

    methods(Access=protected)
        out=getMetaTag(rpt)
        addHeadItems(rpt)
    end



    methods
    end

    methods(Access=private)
        init(obj)
    end

    methods(Static)
        hyperlink=getMatlabCallHyperlink(cmd)
        out=getDefaultErrorHTML(title,msg,bodyOption)
        out=getRTWTableShrinkButton(id,option)
        table=createTable(contents,option,col_width_vec,align_vec)
        table=createSimpleTable(contents,option,col_width_vec,align_vec)
    end
end


