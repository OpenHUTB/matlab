classdef Report<handle




    properties
        Model ee.internal.billofmaterials.Model;
        ExcludePattern='Reference$';
        Sort='Quantity';
        Directory;
        MaximumBlocksPerTable=4;
    end

    properties(Dependent)
Name
FullFile
    end

    properties(Access=private)
        DefaultName='billofmaterialsreport';
    end

    methods
        function obj=Report(varargin)







            obj.Directory=pwd;


            obj.Model=ee.internal.billofmaterials.Model(varargin{:});
        end

        function value=get.FullFile(obj)

            value=fullfile(obj.Directory,[obj.Name,'.html']);
        end

        function value=get.Name(obj)

            value=[obj.Model.Name,'_BillOfMaterials'];
        end

        function open(obj)

            web(obj.FullFile);
        end

        function publish(obj)

            try
                summary=obj.getSummary;
                summaryHtml=table2html(summary,...
                'LinkToSections',true,...
                'EmptyTableHtml',sprintf('<p>%s</p>',getString(message('physmod:ee:billofmaterials:NoSimscapeBlocks'))));


                details=obj.getDetails(summary.Properties.RowNames);
                detailsHtml=sprintf('%s',details{:});


                obj.Model.prePublishState();



                assignin('base','billofmaterialsModelName',obj.Model.Name);
                assignin('base','billofmaterialsSummaryHtml',summaryHtml);
                assignin('base','billofmaterialsDetailsHtml',detailsHtml);


                code_to_eval='ee.internal.billofmaterials.billofmaterialsreport(billofmaterialsModelName,billofmaterialsSummaryHtml,billofmaterialsDetailsHtml)';
                publish('ee.internal.billofmaterials.billofmaterialsreport','showCode',false,'codeToEvaluate',code_to_eval,'outputDir',obj.Directory);


                evalin('base','clear(''billofmaterials*'');');


                obj.Model.restoreInitialState();


                obj.renameReport();
            catch ME
                throwAsCaller(ME);
            end
        end

        function details=getDetails(obj,componentTypes)

            details={};
            outputIdx=1;
            for componentTypeIdx=1:length(componentTypes)
                thisComponentType=componentTypes{componentTypeIdx};
                blocksOfType=obj.Model.findSimscapeBlocksOfType(thisComponentType);
                parameterTable=blocksOfType.getCombinedParameters(obj.MaximumBlocksPerTable);
                switch class(parameterTable)
                case 'table'
                    details{outputIdx,1}=sprintf('<html><h3 id="%s">%s</h3></html>',...
                    strrep(thisComponentType,' ','%20'),...
                    thisComponentType);%#ok<AGROW>
                    details{outputIdx,2}=table2html(parameterTable);%#ok<AGROW>
                    outputIdx=outputIdx+1;
                case 'cell'
                    for parameterTableIdx=1:length(parameterTable)
                        thisParameterTable=parameterTable{parameterTableIdx};
                        if~isempty(thisParameterTable)


                            switch thisParameterTable.Properties.CustomProperties.TitleConfig
                            case 'TextWithId'
                                configTitleHtml=sprintf('<h3 id="%s">%s</h3>',...
                                strrep(thisComponentType,' ','%20'),...
                                thisComponentType);
                            case 'Text'
                                configTitleHtml=sprintf('<h3>%s</h3>',...
                                thisComponentType);
                            case{'','None'}
                                configTitleHtml='';
                            end
                            switch thisParameterTable.Properties.CustomProperties.InformationConfig
                            case 'Library'
                                thisLibraryPath=thisParameterTable.Properties.CustomProperties.LibraryPath;
                                configInformationHtml=sprintf('%s:\t%s<br>',...
                                getString(message('physmod:ee:billofmaterials:LibraryPath')),...
                                makeHtmlSafe(thisLibraryPath));
                            case 'BlockChoice'
                                thisBlockChoice=thisParameterTable.Properties.CustomProperties.BlockChoice;
                                configInformationHtml=sprintf('%s:\t%s<br>',...
                                getString(message('physmod:ee:billofmaterials:BlockChoice')),...
                                makeHtmlSafe(thisBlockChoice));
                            case{'LibraryAndBlockChoice','BlockChoiceAndLibrary'}
                                thisLibraryPath=thisParameterTable.Properties.CustomProperties.LibraryPath;
                                thisBlockChoice=thisParameterTable.Properties.CustomProperties.BlockChoice;
                                configInformationHtml=sprintf('%s:\t%s<br>%s:\t%s<br>',...
                                getString(message('physmod:ee:billofmaterials:LibraryPath')),...
                                makeHtmlSafe(thisLibraryPath),...
                                getString(message('physmod:ee:billofmaterials:BlockChoice')),...
                                makeHtmlSafe(thisBlockChoice));
                            case{'','None'}
                                configInformationHtml='';
                            end

                            details{outputIdx,1}=sprintf('<html>%s%s</html>',...
                            configTitleHtml,...
                            configInformationHtml);%#ok<AGROW>
                            details{outputIdx,2}=table2html(thisParameterTable);%#ok<AGROW>
                            outputIdx=outputIdx+1;
                        else
                            details{outputIdx,1}=sprintf('<html><h3 id="%s">%s</h3></html>',...
                            strrep(thisComponentType,' ','%20'),...
                            thisComponentType);%#ok<AGROW>
                            details{outputIdx,2}=table2html(table.empty);%#ok<AGROW>
                            outputIdx=outputIdx+1;
                        end
                    end
                end
            end

            details=details';
        end

        function summary=getSummary(obj)



            summary=obj.Model.Summary;


            excludeIdx=cellfun(@isempty,regexp(summary.Properties.RowNames,obj.ExcludePattern));
            summary=summary(excludeIdx,:);


            switch obj.Sort
            case 'Type'

            case 'Quantity'
                summary=sortrows(summary,'Quantity','descend');
            otherwise

            end
        end

        function renameReport(obj)


            defaultReportName=fullfile(obj.Directory,[obj.DefaultName,'.html']);
            defaultPngWildcard=fullfile(obj.Directory,[obj.DefaultName,'*.png']);


            movefile(defaultReportName,obj.FullFile,'f');

            fid=fopen(obj.FullFile,'r+');
            html=fread(fid,'*char')';
            fclose(fid);

            pngFiles=dir(defaultPngWildcard);
            for pngIdx=1:length(pngFiles)
                thisPngFile=pngFiles(pngIdx).name;
                newPngFile=regexprep(thisPngFile,['^',obj.DefaultName],obj.Name);
                html=strrep(html,['"',thisPngFile,'"'],['"',newPngFile,'"']);
                movefile(fullfile(obj.Directory,thisPngFile),fullfile(obj.Directory,newPngFile),'f');
            end

            fid=fopen(obj.FullFile,'w');
            fprintf(fid,'%s',html);
            fclose(fid);
        end
    end
end
