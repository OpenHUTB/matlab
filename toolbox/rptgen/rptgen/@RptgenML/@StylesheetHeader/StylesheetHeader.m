function this=StylesheetHeader(parentObj,varargin)




    this=feval(mfilename('class'));
    this.init(parentObj,varargin{:});




    chEl=this.getChooseElement;

    if~isempty(chEl)
        try
            if rptgen.use_java
                hdrCellElement=com.mathworks.toolbox.rptgen.xml.StylesheetCustomizationParser.findFirstHeaderCell(this.JavaHandle);
            else
                hdrCellElement=mlreportgen.re.internal.ui.StylesheetCustomizationParser.findFirstHeaderCell(this.JavaHandle);
            end
        catch ME
            warning(ME.message);
            hdrCellElement=[];
        end
        while~isempty(hdrCellElement)
            try
                RptgenML.StylesheetHeaderCell(this,hdrCellElement);
            catch ME
                warning(message('rptgen:RptgenML_StylesheetHeader:unableToCreateHeaderFooterCell',ME.message));
            end
            try
                if rptgen.use_java
                    hdrCellElement=com.mathworks.toolbox.rptgen.xml.StylesheetCustomizationParser.findNextHeaderCell(hdrCellElement);
                else
                    hdrCellElement=mlreportgen.re.internal.ui.StylesheetCustomizationParser.findNextHeaderCell(hdrCellElement);
                end
            catch ME
                warning(ME.message);
                hdrCellElement=[];
            end
        end
    end
