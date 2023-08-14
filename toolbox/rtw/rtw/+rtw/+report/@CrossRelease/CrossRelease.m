classdef CrossRelease<coder.report.ReportPageBase




    properties(Access=private,Transient)
        RepositoryFileName;
        SharedUtilsFolder;
    end

    methods

        function this=CrossRelease(modelName,lRepositoryFileName)

            this=this@coder.report.ReportPageBase;
            this.RepositoryFileName=lRepositoryFileName;
            bDirInfo=RTW.getBuildDir(modelName);
            this.SharedUtilsFolder=fullfile...
            (bDirInfo.CodeGenFolder,bDirInfo.SharedUtilsTgtDir);

        end

        function out=getTitle(~)
            out=DAStudio.message('RTW:report:CrossReleaseTitle');
        end

        function out=getShortTitle(~)
            out=DAStudio.message('RTW:report:CrossReleaseLink');
        end

        function out=getDefaultReportFileName(~)
            out='crossrelease.html';
        end

        function[notResolvedSrcFiles,repositoryResolvedFiles]=...
            getResolvedFiles(this)

            lResolvedFiles=coder.internal.xrel.ResolvedFiles(this.SharedUtilsFolder);

            [srcFiles,lResolveStatus]=getResolveStatus(lResolvedFiles);

            notResolvedSrcFiles=srcFiles...
            (lResolveStatus==coder.internal.xrel.FileResolveStatus.Local);
            repositoryResolvedFiles=srcFiles...
            (lResolveStatus==coder.internal.xrel.FileResolveStatus.Repository);
        end


        function execute(this)
            introText=DAStudio.message...
            ('RTW:report:CrossReleaseIntro',this.RepositoryFileName);
            pIntro=Advisor.Paragraph;
            pIntro.addItem(introText);
            this.IntroductionContent=pIntro;
            this.AddSectionToToc=true;

            [notResolvedSrcFiles,repositoryResolvedFiles]=...
            getResolvedFiles(this);


            if~isempty(repositoryResolvedFiles)
                sectionSummary=DAStudio.message('RTW:report:CrossReleaseSectionFromRepoPara1');
                option.HasHeaderRow=true;
                option.HasBorder=true;
                contents=this.createTable...
                ({[{DAStudio.message('RTW:report:CrossReleaseFileName')};
                repositoryResolvedFiles(:)]},...
                option,1,{'left'});
            else
                sectionSummary=DAStudio.message('RTW:report:CrossReleaseNone');
                contents='';
            end

            pSummary=Advisor.Paragraph;
            pSummary.addItem(sectionSummary);
            sectionTitle=DAStudio.message('RTW:report:CrossReleaseSectionFromRepoTitle');
            addSection(this,'sec_from_repository',sectionTitle,pSummary,contents);


            if~isempty(notResolvedSrcFiles)
                sectionSummary=DAStudio.message('RTW:report:CrossReleaseSectionNotRepoPara1');
                option.HasHeaderRow=true;
                option.HasBorder=true;
                contents=this.createTable...
                ({[{DAStudio.message('RTW:report:CrossReleaseFileName')};
                notResolvedSrcFiles(:)]},...
                option,1,{'left'});
            else
                sectionSummary=DAStudio.message('RTW:report:CrossReleaseNone');
                contents='';
            end

            pSummary=Advisor.Paragraph;
            pSummary.addItem(sectionSummary);
            sectionTitle=DAStudio.message('RTW:report:CrossReleaseSectionNotRepoTitle');
            addSection(this,'sec_not_from_repository',sectionTitle,pSummary,contents);


            pSummary=Advisor.Paragraph;
            sectionSummary=DAStudio.message('RTW:report:CrossReleaseSectionViewText1');
            pSummary.addItem(sectionSummary);

            mainContent=ModelAdvisor.Paragraph;
            cmd=sprintf('matlab: coder.xrel.viewSharedCodeRepository(''%s'')',...
            this.RepositoryFileName);
            link=sprintf...
            ('<a href="%s">%s</a>',...
            cmd,...
            DAStudio.message('RTW:report:CrossReleaseSectionViewHere')...
            );
            viewRepoText=sprintf...
            ('%s ',DAStudio.message('RTW:report:CrossReleaseSectionViewText2',link));
            content=ModelAdvisor.Text(viewRepoText);
            mainContent.addItem(content);

            cmd=sprintf('matlab: coder.xrel.viewSharedCodeRepository(''%s'', ''SharedCodeFolder'', ''%s'')',...
            this.RepositoryFileName,this.SharedUtilsFolder);
            link=sprintf...
            ('<a href="%s">%s</a>',...
            cmd,...
            DAStudio.message('RTW:report:CrossReleaseSectionViewHere')...
            );
            compareRepoText=sprintf...
            ('%s ',DAStudio.message('RTW:report:CrossReleaseSectionViewText3',link));
            content=ModelAdvisor.Text(compareRepoText);
            mainContent.addItem(content);

            sectionTitle=DAStudio.message('RTW:report:CrossReleaseSectionViewTitle');
            addSection(this,'sec_view_update_repository',sectionTitle,pSummary,mainContent);

        end
    end
end


