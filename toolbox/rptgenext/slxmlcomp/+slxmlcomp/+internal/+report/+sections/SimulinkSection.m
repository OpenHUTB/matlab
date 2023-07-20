classdef SimulinkSection<mlreportgen.dom.LockedDocumentPart





    properties(Access=private)
        JDriverFacade;
        SectionRootDiff;
        ReportFormat;
        TempDir;
        ComparisonSources;
        LeftHighlightWindow;
        RightHighlightWindow;
    end


    methods(Access=public)

        function obj=SimulinkSection(jDriverFacade,sectionRootDiff,rptFormat,tempDir,comparisonSources)
            obj=obj@mlreportgen.dom.LockedDocumentPart(...
            rptFormat.RPTGenType,...
            getfield(rptFormat,'RPTGenSectionTemplate'),...
            "Section");%#ok<GFLD>

            obj.JDriverFacade=jDriverFacade;
            obj.SectionRootDiff=sectionRootDiff;
            obj.ReportFormat=rptFormat;
            obj.TempDir=tempDir;
            obj.ComparisonSources=comparisonSources;

        end

        function fillSectionTitle(obj)
            sectionTitle='Simulink';
            obj.append(sectionTitle);
        end

        function fillSectionContents(obj)
            if obj.highlightReportImages()
                styleCleanup=obj.applyDiffStylingToModels();%#ok<NASGU>
            end
            obj.runTestingHook();
            import slxmlcomp.internal.report.sections.SubsystemSection;
            section=SubsystemSection(...
            obj.JDriverFacade,...
            obj.SectionRootDiff,...
            obj.ReportFormat,...
            obj.TempDir,...
            obj.ComparisonSources...
            );
            if strcmp(section.Type,'PDF')
                section.open(obj.ReportFormat.RPTGenTemplateKey);
            else
                section.TemplateName='';
                section.open(obj.ReportFormat.RPTGenTemplateKey);
            end
            section.fill();
            obj.append(section);
        end
    end

    methods(Access=private)
        function highlight=highlightReportImages(obj)
            opts=slxmlcomp.options;
            highlight=opts.ReportHighlightImages;
        end

        function styleCleanup=applyDiffStylingToModels(obj)
            import slxmlcomp.internal.highlight.window.SLEditorHighlightWindow;
            import slxmlcomp.internal.highlight.ContentId;

            leftHighlightWindow=SLEditorHighlightWindow.newPlainInstance(...
            createBDLocation(obj.ComparisonSources{1}),...
            obj.JDriverFacade.getLocationStyleFactory(),...
            obj.createTraversalFactory(),...
            ContentId.Left...
            );
            rightHighlightWindow=SLEditorHighlightWindow.newPlainInstance(...
            createBDLocation(obj.ComparisonSources{2}),...
            obj.JDriverFacade.getLocationStyleFactory(),...
            obj.createTraversalFactory(),...
            ContentId.Right...
            );

            leftHighlightWindow.applyDiffStyles(...
            obj.JDriverFacade.getResult()...
            );
            rightHighlightWindow.applyDiffStyles(...
            obj.JDriverFacade.getResult()...
            );

            styleCleanup.Left=leftHighlightWindow;
            styleCleanup.Right=rightHighlightWindow;
        end

        function factory=createTraversalFactory(obj)
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.gui.highlight.SLEditorTraversalFactory;
            factory=SLEditorTraversalFactory();
        end

        function runTestingHook(obj)
            import slxmlcomp.internal.report.sections.SimulinkSection;
            hook=SimulinkSection.getSetTestingHook();
            if~isempty(hook)
                hook();
            end
        end
    end

    methods(Access=public,Static)
        function hook=getSetTestingHook(varargin)
            persistent testingHook;

            hook=testingHook;

            if nargin>0
                testingHook=varargin{1};
            end

            return
        end
    end
end

function location=createBDLocation(source)
    import slxmlcomp.internal.highlight.window.BDLocation

    isTestHarness=false;
    harnessName="";
    allowRename=true;
    [modelFile,modelName]=getFileToUseInMemory(source);
    location=BDLocation.from(...
    "System",...
    "",...
    isTestHarness,...
    modelName,...
    harnessName,...
    modelFile,...
allowRename...
    );
end

function[file,modelName]=getFileToUseInMemory(source)
    jModelData=source.getModelData();
    jMemFile=jModelData.getFileToUseInMemory();
    file=char(jMemFile.getPath());
    [~,modelName,~]=fileparts(file);
end
