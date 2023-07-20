
function generate_table(varargin)





    options=cvi.CvhtmlSettings;

    tableIdx=varargin{1};
    if ischar(tableIdx)
        tableIdx=str2double(tableIdx);
    end

    tableInfo=cvprivate('html_info_mgr','get','lookupTableInfo',tableIdx);
    if~isempty(tableInfo{1})
        cvprivate('local_browser_mgr','displayFile',tableInfo{1});
    else
        filePath=cvprivate('local_browser_mgr','rootCovFile',varargin);
        filePath=cvi.ReportUtils.file_url_2_path(filePath);
        [path,name,ext]=fileparts(filePath);
        childFileName=fullfile(path,[name,'_t',num2str(tableIdx),ext]);


        if exist(childFileName,'file')
            delete(childFileName);
        end
        outFile=fopen(childFileName,'w','n','utf-8');

        fprintf(outFile,'<html>\n');
        fprintf(outFile,'<head>\n');
        fprintf(outFile,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>\n');
        fprintf(outFile,'%s\n',cvi.ReportUtils.getCSSSection);
        fprintf(outFile,'<title> %s </title>\n',getString(message('Slvnv:simcoverage:cvhtml:LookupTableCoverageDetails')));
        fprintf(outFile,'</head>\n');
        fprintf(outFile,'\n');
        fprintf(outFile,'<body>\n');

        fprintf(outFile,'\n<br/> &#160; <b> %s </b> <br/>\n',getString(message('Slvnv:simcoverage:cvhtml:LookupTableDetails')));
        fprintf(outFile,'<table cellpadding="8" border="0"> <tr> <td>\n');


        tableId=tableInfo{2};
        execCnt=tableInfo{3};
        breakPtValues=tableInfo{4};
        breakPtEquality=tableInfo{5};
        isJustified=tableInfo{6};
        executedIn=tableInfo{7};
        [fileNames,cntThresh]=cvi.ReportScript.prepare_table_mapping_output(execCnt,options,isJustified);

        outStr=cvprivate('table_map',execCnt,...
        breakPtValues,...
        breakPtEquality,...
        options.imageSubDirectory,...
        fileNames,...
        cntThresh,...
        isJustified,...
        executedIn);

        fprintf(outFile,'%s',outStr);
        fprintf(outFile,'\n</td><td>\n');



        fprintf(outFile,'%s',cvi.ReportScript.make_table_map_legend(fileNames,cntThresh,isJustified));
        fprintf(outFile,'\n</td></tr> </table>\n');
        fprintf(outFile,'<br/>\n\n');

        [~,fileName]=fileparts(filePath);
        baseName=[fileName,'.html'];
        fprintf(outFile,'<a href="%s#refobj%d">%s </a>',...
        baseName,tableId,getString(message('Slvnv:simcoverage:cvhtml:BackToMainReport')));
        fprintf(outFile,'</body>\n');
        fprintf(outFile,'</html>\n');
        fprintf(outFile,'\n');

        fclose(outFile);
        cvprivate('html_info_mgr','childpage',tableIdx,childFileName);

        web(childFileName,'-new');
    end

