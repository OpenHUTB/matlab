classdef Format<Rptgen.TitlePage.PDF.Format




    methods

        function this=Format()
            this@Rptgen.TitlePage.PDF.Format('verso');
            this.IncludeElements=...
            {
            Rptgen.TitlePage.PDF.Verso.Title(),...
            Rptgen.TitlePage.PDF.Verso.Subtitle(),...
            Rptgen.TitlePage.PDF.Verso.Author(),...
            Rptgen.TitlePage.PDF.Verso.Image(),...
            Rptgen.TitlePage.PDF.Verso.Copyright(),...
            Rptgen.TitlePage.PDF.Verso.PubDate(),...
            Rptgen.TitlePage.PDF.Verso.LegalNotice(),...
            Rptgen.TitlePage.PDF.Verso.Abstract()
            };

        end

    end

end

