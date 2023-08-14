classdef ReportGenerator<handle





    properties(Access=private,Constant)
        Title='Hardware Mapping Summary Report';
        FileName='SummaryReport';
    end

    properties(Access=private)
        TableData={};
PublishFile
    end

    methods
        function obj=ReportGenerator(folder)



            obj.PublishFile=fullfile(folder,[obj.FileName,'.m']);
        end

        function addTable(obj,tableData)
            validateattributes(tableData,{'table'},{'nonempty'});
            obj.TableData{end+1}=tableData;
        end

        function generate(obj,showReport)



            fid=fopen(obj.PublishFile,'w');

            fprintf(fid,'%%%% %s \n',obj.Title);
            fprintf(fid,'%% This report was automatically generated on %s.\n',datetime);


            for i=1:numel(obj.TableData)
                tableData=obj.TableData{i};
                columnNames=tableData.Properties.VariableNames;
                fprintf(fid,'%%%% %s \n',tableData.Properties.Description);
                fprintf(fid,'%% <html>\n');
                fprintf(fid,'%% <table border=1 width=100% style="border-collapse:collapse;">\n');%#ok<CTPCT>
                fprintf(fid,'%% <tr>\n');
                for col=1:numel(columnNames)
                    fprintf(fid,'%% <th style="background-color:#F5F5F5">%s</th>\n',columnNames{col});
                end
                fprintf(fid,'%% </tr>\n');
                for row=1:height(tableData)
                    fprintf(fid,'%% <tr>\n');

                    entry=tableData.(columnNames{1}){row};
                    if endsWith(entry,'GROUP')
                        fprintf(fid,'%% <th style="background-color:#F5F5F5" colspan="2">%s</th>\n',extractBefore(entry,'GROUP'));
                    else
                        for col=1:numel(columnNames)
                            fprintf(fid,'%% <td>%s</td>\n',tableData.(columnNames{col}){row});
                        end
                    end
                    fprintf(fid,'%% </tr>\n');
                end
                fprintf(fid,'%% </table><br><br>\n');
                fprintf(fid,'%% </html>\n');
            end

            startYear='2022';
            currYear=datestr(version('-date'),'YYYY');
            if strcmpi(startYear,currYear)
                copyright=startYear;
            else
                copyright=sprintf('%s-%s',startYear,currYear);
            end
            fprintf(fid,'%% \n %% \n');
            fprintf(fid,'%% (C) %s The MathWorks, Inc.  All Rights Reserved.\n',copyright);
            fprintf(fid,'%% \n %%\n');
            fclose(fid);

            publish(obj.PublishFile,'evalCode',false);



            w=warning('off','MATLAB:DELETE:Permission');
            delete(obj.PublishFile);
            warning(w);

            if showReport
                open(fullfile(fileparts(obj.PublishFile),'html',[obj.FileName,'.html']));
            end
        end
    end

end