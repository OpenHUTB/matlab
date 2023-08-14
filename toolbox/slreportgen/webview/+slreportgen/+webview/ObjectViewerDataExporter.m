classdef ObjectViewerDataExporter<slreportgen.webview.DataExporter



    properties(Access=private)
        m_addedImages;
    end

    methods
        function h=ObjectViewerDataExporter()
            h=h@slreportgen.webview.DataExporter();

            h.bind('DocBlock',@exportDocBlock);
            h.bind('Stateflow.EMChart',@exportMatlabFcn);
            h.bind('Stateflow.EMFunction',@exportMatlabFcn);
            h.bind('Stateflow.ReactiveTestingTableChart',@exportStateflowReactiveTestingTableChart);
            h.bind('Stateflow.StateTransitionTableChart',@exportStateflowStateTransitionTableChart);
            h.bind('Simulink.Annotation',@exportSimulinkAnnotation);

            h.bind('Simulink.SubSystem',@exportSimulinkSubSystem);

            h.bind('Stateflow.TruthTable',@exportStateflowTruthTable);
            h.bind('Stateflow.TruthTableChart',@exportStateflowTruthTableChart);
            h.bind('Stateflow.Chart',@exportStateflowReqTable);
        end

        function preExport(h,varargin)
            preExport@slreportgen.webview.DataExporter(h,varargin{:});
            h.m_addedImages=containers.Map();
        end

        function postExport(h)
            h.m_addedImages=[];
        end
    end

    methods(Access=protected)
        function ret=exportSimulinkSubSystem(h,obj)
            ret=[];
            if~strcmp(obj.SfBlockType,'NONE')&&~strcmp(obj.MaskHideContents,'on')
                chartId=sfprivate('block2chart',getFullName(obj));
                chartObj=idToHandle(slroot,chartId);
                ret=export(h,chartObj);
            end
        end

        function data=exportDocBlock(h,obj)
            docType=lower(obj.DocumentType);
            objFullName=getFullName(obj);
            docblock('save_document',objFullName);

            if strcmp(docType,'text')
                data=struct(...
                'html',['<pre>',docblock('getContent',obj.Handle),'</pre>']...
                );
            else
                outFile=[getObjectBaseName(h,obj),'.',docType];
                outUrl=[getObjectBaseUrl(h,obj),'.',docType];
                docblock('blk2file',objFullName,outFile,'UTF-8');
                addFile(h,outFile);
                data=struct(...
                'href',outUrl...
                );
            end
        end

        function data=exportMatlabFcn(~,obj)
            [ssId,blockH]=sfprivate('handleTossId',obj);
            codeSid=[get_param(blockH,'SIDFullString'),ssId];

            data=struct(...
            'code',obj.Script,...
            'code_sid',codeSid...
            );
        end

        function data=exportStateflowStateTransitionTableChart(h,obj)


            [oPath,oName]=fileparts(getObjectBaseName(h,obj));
            objBaseDir=fullfile(oPath,[oName,'_files']);
            objBaseName=fullfile(objBaseDir,oName);
            objBaseUrl=getObjectBaseUrl(h,obj);
            if~exist(objBaseDir,'dir')
                mkdir(objBaseDir)
            end

            outFile=[objBaseName,'.html'];
            outUrl=[objBaseUrl,'.html'];


            d=rpt_xml.document();
            mgr=Stateflow.STTUtils.STTUtilMan.getManager(...
            obj,...
            struct('forPrinting',1,'printLocation',objBaseDir));
            out=generateDocBook(mgr,d,rptgen_sf.csf_statetransitiontable());
            appendChild(d,out);


            if rptgen.use_java
                xmlwrite(outFile,java(d));
            else
                writer=matlab.io.xml.dom.DOMWriter;
                writeToURI(writer,d.Document,outFile);
            end


            rptconvert(outFile,'html','-noview','-quiet');


            fid=fopen(outFile,'r','n','utf-8');
            content=fread(fid,inf,'*char');
            fclose(fid);
            content=content(:)';


            imgFiles=dir(fullfile(objBaseDir,'*.png'));
            for i=1:length(imgFiles)
                imgFileName=imgFiles(i).name;
                if~isKey(h.m_addedImages,imgFileName)
                    addFile(h,fullfile(objBaseDir,imgFileName));
                    h.m_addedImages(imgFileName)=true;
                end
                content=strrep(content,...
                ['src="',imgFileName,'"'],...
                ['src="',h.BaseUrl,'/',imgFileName,'"']);
            end


            templateFile=fullfile(...
            slreportgen.webview.TemplatesDir,'slwebview_stt_html.template');
            fid=fopen(templateFile,'r','n','utf-8');
            template=fread(fid,inf,'*char');
            fclose(fid);
            template=template(:)';


            tableIdx=strfind(content,'<table');
            endIdx=strfind(content,'</div></div></body></html>');
            content=content(tableIdx:endIdx-1);


            content=strrep(template,'%<STT_CONTENT>',content);


            snap=SLPrint.Snapshot;
            snap.Format='PNG';
            snap.Target=obj;
            snap.SizeMode='UseScaledSize';
            snap.Scale=1;
            snap.FileName=[objBaseName,'.png'];
            snap.snap();


            imageTag=sprintf('<image src="%s">',[objBaseUrl,'.png']);
            content=strrep(content,'%<STT_IMAGE>',imageTag);


            fid=fopen(outFile,'w','n','utf-8');
            fprintf(fid,'%s',content);
            fclose(fid);

            addFile(h,outFile);
            addFile(h,snap.FileName);

            data=struct(...
            'href',outUrl...
            );
        end

        function data=exportStateflowReactiveTestingTableChart(h,obj)


            [oPath,oName]=fileparts(getObjectBaseName(h,obj));
            objBaseDir=fullfile(oPath,[oName,'_files']);
            objBaseName=fullfile(objBaseDir,oName);
            objBaseUrl=getObjectBaseUrl(h,obj);
            if~exist(objBaseDir,'dir')
                mkdir(objBaseDir)
            end

            outFile=[objBaseName,'.html'];
            outUrl=[objBaseUrl,'.html'];


            d=rpt_xml.document();
            mgr=Stateflow.STTUtils.STTUtilMan.getManager(...
            obj,...
            struct('forPrinting',1,'printLocation',objBaseDir));
            out=generateDocBook(mgr,d,rptgen_sf.csf_statetransitiontable());
            appendChild(d,out);


            xmlwrite(outFile,java(d));


            rptconvert(outFile,'html','-noview','-quiet');


            fid=fopen(outFile,'r','n','utf-8');
            content=fread(fid,inf,'*char');
            fclose(fid);
            content=content(:)';


            imgFiles=dir(fullfile(objBaseDir,'*.png'));
            for i=1:length(imgFiles)
                imgFileName=imgFiles(i).name;
                if~isKey(h.m_addedImages,imgFileName)
                    addFile(h,fullfile(objBaseDir,imgFileName));
                    h.m_addedImages(imgFileName)=true;
                end
                content=strrep(content,...
                ['src="',imgFileName,'"'],...
                ['src="',h.BaseUrl,'/',imgFileName,'"']);
            end


            templateFile=fullfile(...
            slreportgen.webview.TemplatesDir,'slwebview_stt_html.template');
            fid=fopen(templateFile,'r','n','utf-8');
            template=fread(fid,inf,'*char');
            fclose(fid);
            template=template(:)';


            tableIdx=strfind(content,'<table');
            endIdx=strfind(content,'</div></div></body></html>');
            content=content(tableIdx:endIdx-1);


            content=strrep(template,'%<STT_CONTENT>',content);


            content=strrep(content,'%<STT_IMAGE>','');


            fid=fopen(outFile,'w','n','utf-8');
            fprintf(fid,'%s',content);
            fclose(fid);

            addFile(h,outFile);

            data=struct(...
            'href',outUrl...
            );
        end

        function data=exportSimulinkAnnotation(~,obj)
            data=[];
            clickFcn=obj.ClickFcn;
            if~isempty(clickFcn)
                tokens=regexp(clickFcn,'web\(''(\S+)''\)','tokens');
                if~isempty(tokens)
                    url=tokens{1}{1};
                    if~isempty(url)
                        data=struct(...
                        'href',url...
                        );
                    end
                end
            end
        end

        function data=exportStateflowTruthTable(~,obj)
            data=[];
            if(~isempty(obj.ActionTable)&&~isempty(obj.ConditionTable))
                data=sfprivate(...
                'truth_table_function_man','generate_html',obj.Id);
            end
        end

        function data=exportStateflowTruthTableChart(h,obj)
            data=[];
            func_id=sfprivate('truth_tables_in',obj.Id);
            if~isempty(func_id)
                ttObj=idToHandle(slroot,func_id(1));
                data=exportStateflowTruthTable(h,ttObj);
            end
        end

        function data=exportStateflowReqTable(~,obj)
            data=[];
            if Stateflow.ReqTable.internal.isRequirementsTable(obj.Id)
                exporter=Stateflow.ReqTable.internal.ReqTableHTMLExporter(obj.Id);
                data=exporter.getHTML();
            end
        end
    end

end
