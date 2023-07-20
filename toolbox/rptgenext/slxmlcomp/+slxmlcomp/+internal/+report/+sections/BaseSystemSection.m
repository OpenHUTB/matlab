classdef BaseSystemSection<mlreportgen.dom.LockedDocumentPart



    properties(Access=private)
        SectionFactories={...
        slxmlcomp.internal.report.sections.SubsystemSectionFactory(),...
        slxmlcomp.internal.report.sections.ChartSectionFactory()...
        };
    end


    properties(Access=protected)
        JDriverFacade;
        SectionRootDiff;
        ReportFormat;
        TempDir;
        ComparisonSources;
    end


    methods(Access=public)

        function obj=BaseSystemSection(jDriverFacade,sectionRootDiff,rptFormat,template,tempDir,comparisonSources)
            obj=obj@mlreportgen.dom.LockedDocumentPart(rptFormat.RPTGenType,getfield(rptFormat,template),"SubsystemSection");%#ok<GFLD>
            obj.JDriverFacade=jDriverFacade;
            obj.SectionRootDiff=sectionRootDiff;
            obj.ReportFormat=rptFormat;
            obj.TempDir=tempDir;
            obj.ComparisonSources=comparisonSources;
        end

        function fillSubsystemTitle(obj)
            import mlreportgen.dom.TableEntry;
            import mlreportgen.dom.TableRow;
            import mlreportgen.dom.Table;

            titles={};
            import slxmlcomp.internal.report.sections.Util;
            import com.mathworks.comparisons.util.Side;
            sides=Side.values();
            for sideIndex=1:numel(sides)
                side=sides(sideIndex);
                comparisonSource=obj.SectionRootDiff.getSource(side);
                snippet=obj.SectionRootDiff.getSnippet(side);
                if~isempty(snippet)
                    titles{sideIndex}=char(Util.getOriginalSimulinkPath(...
                    snippet,...
comparisonSource...
                    ));%#ok<*AGROW>
                else
                    titles{sideIndex}='';
                end
            end

            titlesTable=Table(numel(obj.ComparisonSources));
            titlesTable.Width='100%';

            obj.evenlyDistributeTableColumnWidths(titlesTable,numel(sides));

            titleRow=TableRow();

            for titleIndex=1:numel(titles)
                titleRow.append(...
                TableEntry(titles{titleIndex})...
                );
            end
            titlesTable.append(titleRow);
            titlesTable.StyleName='SubsystemTitle';
            obj.append(titlesTable);

        end

        function fillSubsystemContents(obj)
            import slxmlcomp.internal.report.sections.Util;
            import com.mathworks.toolbox.rptgenslxmlcomp.plugins.slx.plugins.blockdiagram.units.model.ModelNodeCustomization;

            obj.addSystemImages(obj.SectionRootDiff);
            customization=ModelNodeCustomization();
            isSimulinkSystem=Util.isDiffBySnippetCondition(obj.SectionRootDiff,...
            @(snippet)customization.canHandle(snippet));
            if isSimulinkSystem
                obj.fillParameters(obj.SectionRootDiff)
            end

            obj.fillContents(obj.SectionRootDiff)
        end

    end


    methods(Access=protected,Abstract)
        image=createImage(obj,snippet,comparisonSource);
    end


    methods(Access=protected)

        function graph=getGraphModel(obj)
            graph=obj.JDriverFacade.getResult().getDifferenceGraphModel();
        end

    end


    methods(Access=private)

        function fillContents(obj,rootDiff)
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.difference.TwoSourceDifferenceUtils;
            import com.mathworks.toolbox.rptgenslxmlcomp.report.ReportUtils;

            import slxmlcomp.internal.report.sections.SubsysDifference;
            import slxmlcomp.internal.report.sections.SubsystemSection;

            childCollection=obj.getGraphModel().getChildren(rootDiff);
            if isempty(childCollection)
                return
            end
            children=childCollection.iterator();
            subsectionDiffs={};

            while children.hasNext()
                diff=children.next();

                if ReportUtils.isChanged(diff,obj.JDriverFacade.getResult())||...
                    TwoSourceDifferenceUtils.isInserted(diff)
                    docPart=SubsysDifference(...
                    obj.JDriverFacade,...
                    diff,...
                    obj.SectionRootDiff,...
                    obj.ReportFormat...
                    );
                    if strcmp(docPart.Type,'PDF')
                        docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                    else
                        docPart.TemplateName='';
                        docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                    end
                    docPart.fill();
                    obj.append(docPart);
                end




                if(~obj.requiresSubsection(diff))
                    obj.fillContents(diff);
                else
                    subsectionDiffs{end+1}=diff;%#ok<*AGROW>
                end
            end

            for childIndex=1:numel(subsectionDiffs)
                subSectionDiff=subsectionDiffs{childIndex};

                subSecFactory=obj.getSubsectionFactory(subSectionDiff);
                section=subSecFactory.create(...
                obj.JDriverFacade,...
                subSectionDiff,...
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

        function needsSubSection=requiresSubsection(obj,diff)
            needsSubSection=~isempty(obj.getSubsectionFactory(diff));
        end

        function subSectionFactory=getSubsectionFactory(obj,diff)
            subSectionFactory=[];
            for factory=obj.SectionFactories
                if(factory{1}.appliesToDiff(diff))
                    subSectionFactory=factory{1};
                    return
                end
            end
        end

        function addSystemImages(obj,systemDiff)
            import mlreportgen.dom.TableEntry;
            import mlreportgen.dom.TableRow;
            import mlreportgen.dom.Table;
            import mlreportgen.dom.Text;
            import mlreportgen.dom.Image;

            import slxmlcomp.internal.report.sections.SystemImage;
            import slxmlcomp.internal.report.sections.Util;

            import com.mathworks.comparisons.util.Side;

            images={};

            sides=Side.values();
            for sideIndex=1:numel(sides)
                side=sides(sideIndex);
                comparisonSource=systemDiff.getSource(side);
                snippet=systemDiff.getSnippet(side);

                if isempty(snippet)
                    imageToAdd=[];
                else
                    try
                        imageToAdd=obj.createImage(snippet,comparisonSource);
                    catch e


                        warningMessage=[e.identifier,newline,e.message];
                        warning(e.identifier,'%s',warningMessage)
                        imageToAdd=Text(warningMessage);
                        imageToAdd.WhiteSpace='preserve';
                    end
                end
                images{end+1}=imageToAdd;
            end

            if isempty(images)
                return
            end

            imageTable=Table(numel(obj.ComparisonSources));
            imageTable.Width='100%';
            obj.evenlyDistributeTableColumnWidths(imageTable,numel(images));

            imageRow=TableRow();

            for imageIndex=1:numel(images)
                if~isempty(images{imageIndex})
                    if isa(images{imageIndex},'mlreportgen.dom.Text')

                        image=images{imageIndex};
                    else
                        if exist(images{imageIndex}.ImageFile,'file')~=0
                            image=Image(images{imageIndex}.ImageFile);
                            Util.scaleImageToWidthInCM(image,7);
                        else
                            image='';
                        end
                    end

                else
                    image='';
                end

                imageRow.append(TableEntry(image));
            end
            imageTable.append(imageRow);
            obj.append(imageTable);
        end

        function evenlyDistributeTableColumnWidths(~,table,ncols)
            import mlreportgen.dom.TableColSpecGroup;
            import mlreportgen.dom.TableColSpec;
            import mlreportgen.dom.Width;

            columnGroup=TableColSpecGroup();
            columnGroup.Span=ncols;

            columnSpec=TableColSpec;
            columnSpec.Span=ncols;
            widthStr=sprintf('%2.0f%s',100*1/ncols,'%');
            columnSpec.Style={Width(widthStr)};
            columnGroup.ColSpecs=columnSpec;
            table.ColSpecGroups=columnGroup;
        end

        function fillParameters(obj,diff)
            import slxmlcomp.internal.report.sections.SubsysDifference;

            if obj.hasParameters(diff)
                docPart=SubsysDifference(...
                obj.JDriverFacade,...
                diff,...
                obj.SectionRootDiff,...
                obj.ReportFormat...
                );
                if strcmp(docPart.Type,'PDF')
                    docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                else
                    docPart.TemplateName='';
                    docPart.open(obj.ReportFormat.RPTGenTemplateKey);
                end
                docPart.fill();
                obj.append(docPart);
            end
        end

        function hasPars=hasParameters(~,diff)
            import com.mathworks.comparisons.util.Side;

            sides={Side.LEFT,Side.RIGHT};

            for sideIndex=1:numel(sides)
                snippet=diff.getSnippet(sides{sideIndex});
                if~isempty(snippet)&&~snippet.getParameters().isEmpty()
                    hasPars=true;
                    return
                end
            end

            hasPars=false;
        end

    end

end
