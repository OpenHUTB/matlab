classdef Report<handle



    properties
MyModelName
MyPkgFile
MyHTMLReport
MyData
MyFileID
    end

    methods

        function this=Report(pkgFile)
            this.MyModelName='';
            this.MyPkgFile=pkgFile;
            this.createHTMLReport();
        end


        function delete(obj)
            if exist(obj.MyHTMLReport,'file')>0
                delete(obj.MyHTMLReport);
            end
        end


        function dlg=getDialogSchema(this)

            webbrowser.Type='webbrowser';
            webbrowser.Tag='webkitWid';
            webbrowser.WebKit=true;
            webbrowser.WebKitToolBar={};
            webbrowser.Url=this.MyHTMLReport;
            webbrowser.DisableContextMenu=true;

            dlg.DialogTitle=DAStudio.message('Simulink:cache:reportDialogTitle',this.MyPkgFile);
            dlg.DialogTag='simulinkCache_dialog';
            dlg.Items={webbrowser};
            dlg.LayoutGrid=[1,1];
            dlg.Geometry=[100,100,800,500];
            dlg.EmbeddedButtonSet={'OK'};
            dlg.StandaloneButtonSet={'OK'};
            dlg.MinMaxButtons=true;
        end
    end

    methods(Access=private)

        function createHTMLReport(this)

            inspectorType=Simulink.packagedmodel.inspect.ContentInspectorType.REPORT;
            inspector=Simulink.packagedmodel.inspect.getInspector(inspectorType,this.MyPkgFile);
            this.MyData=inspector.populate();
            this.MyModelName=inspector.getModelName();


            this.MyHTMLReport=[tempname,'.html'];
            this.MyFileID=fopen(this.MyHTMLReport,'w','native','UTF-8');

            this.writeHeader();


            releases=sort(keys(this.MyData));
            for relIndex=1:length(releases)
                release=releases{relIndex};
                pMap=this.MyData(release);
                platforms=sort(keys(pMap));


                for archIndex=1:length(platforms)
                    platform=platforms{archIndex};
                    pStruct=pMap(platform);


                    if this.writeReleaseAndPlatform(release,platform)
                        continue;
                    end


                    this.writeVerifcationAndValidationList(release,platform,pStruct)


                    this.writeReportGenerationList(release,platform,pStruct);


                    if this.writeSimulationList(release,platform,pStruct)
                        continue;
                    end


                    this.writeCodeGenerationTable(release,platform,pStruct);
                end
            end


            this.writeFooter();
            fclose(this.MyFileID);
        end


        function writeHeader(this)
            model=this.MyModelName;
            h1Text=DAStudio.message('Simulink:cache:reportHeaderText1',model);
            h2Text=DAStudio.message('Simulink:cache:reportHeaderText2');
            fprintf(this.MyFileID,'<!DOCTYPE html>\n');
            fprintf(this.MyFileID,'<html>\n<head>\n');

            fprintf(this.MyFileID,'<meta charset="utf-8">\n');

            fprintf(this.MyFileID,'<meta http-equiv="cache-control" content="no-cache">\n');
            fprintf(this.MyFileID,'<meta http-equiv="pragma" content="no-cache">\n');
            fprintf(this.MyFileID,'<meta http-equiv="expires" content="-1">\n');

            fprintf(this.MyFileID,'<link rel="stylesheet" type="text/css" ');
            fprintf(this.MyFileID,'href="file:///%s/toolbox/simulink/core/general/+Simulink/+packagedmodel/slxcreport.css">\n</head>\n',matlabroot);
            fprintf(this.MyFileID,'<body><h1 id="title">%s</h1>\n',h1Text);
            fprintf(this.MyFileID,'<p id="Description">%s</p>\n',h2Text);
        end


        function toContinue=writeReleaseAndPlatform(this,release,platform)
            toContinue=false;
            headerID=['header_',release,'_',platform];
            if strcmp(platform,Simulink.packagedmodel.getPlatform(true))
                if slfeature('SLDataDictionaryRobustVarRef')<2
                    toContinue=true;
                end
                platformText=DAStudio.message('Simulink:cache:reportAllPlatforms');
            else
                platformText=platform;
            end
            fprintf(this.MyFileID,'<h2 id="%s">%s : %s</h2>\n',headerID,release,platformText);
        end


        function toContinue=writeSimulationList(this,release,platform,pStruct)
            toContinue=false;


            if isempty(strcat(pStruct.ACCEL,pStruct.SIM,pStruct.RAPID,pStruct.VARCACHE))
                return;
            end


            simHeaderText=DAStudio.message('Simulink:cache:reportSimulationHeaderText');
            simHeaderID=['sim_header_',release,'_',platform];
            fprintf(this.MyFileID,'<h3 id="%s">%s</h3>\n',simHeaderID,simHeaderText);


            listID=['sim_list_',release,'_',platform];
            fprintf(this.MyFileID,'<ul id=%s">\n',listID);
            if strcmp(platform,Simulink.packagedmodel.getPlatform(true))
                fprintf(this.MyFileID,'%s',pStruct.VARCACHE);
                fprintf(this.MyFileID,'</ul>\n');
                toContinue=true;
            else
                fprintf(this.MyFileID,'%s%s%s',pStruct.ACCEL,pStruct.SIM,pStruct.RAPID);
            end
            fprintf(this.MyFileID,'</ul>\n');
        end


        function writeVerifcationAndValidationList(this,release,platform,pStruct)



            if isempty(strcat(pStruct.SLDV_TG,pStruct.SLDV_PP,pStruct.SLDV_DED,pStruct.SLDV_XIL_TG))||...
                (~strcmp(platform,Simulink.packagedmodel.getPlatform(true))&&release<"R2022a")
                return;
            end


            vnvHeaderText=DAStudio.message('Simulink:cache:reportVerificationAndValidationHeaderText');
            vnvHeaderID=['vnv_header_',release,'_',platform];
            fprintf(this.MyFileID,'<h3 id="%s">%s</h3>\n',vnvHeaderID,vnvHeaderText);


            listID=['vnv_list_',release,'_',platform];
            fprintf(this.MyFileID,'<ul id=%s">\n',listID);
            fprintf(this.MyFileID,'%s',pStruct.SLDV_TG,pStruct.SLDV_PP,pStruct.SLDV_DED,pStruct.SLDV_XIL_TG);
            fprintf(this.MyFileID,'</ul>\n');
        end


        function writeReportGenerationList(this,release,platform,pStruct)



            if isempty(pStruct.SLWEBVIEW)||(~strcmp(platform,Simulink.packagedmodel.getPlatform(true))&&(release<"R2022b"))
                return;
            end


            rgHeaderText=DAStudio.message('Simulink:cache:reportReportGeneratorText');
            rgHeaderID=['rg_header_',release,'_',platform];
            fprintf(this.MyFileID,'<h3 id="%s">%s</h3>\n',rgHeaderID,rgHeaderText);


            listID=['rg_list_',release,'_',platform];
            fprintf(this.MyFileID,'<ul id=%s">\n',listID);
            fprintf(this.MyFileID,'%s',pStruct.SLWEBVIEW);
            fprintf(this.MyFileID,'</ul>\n');
        end


        function writeCodeGenerationTable(this,release,platform,pStruct)
            if isempty(pStruct.CODER)
                return;
            end


            coderHeaderText=DAStudio.message('Simulink:cache:reportCodeGenerationHeaderText');
            coderHeaderID=['coder_header_',release,'_',platform];
            fprintf(this.MyFileID,'<h3 id="%s">%s</h3>\n',coderHeaderID,coderHeaderText);


            coderTableID=['coder_table_',release,'_',platform];
            fprintf(this.MyFileID,'<table id="%s">\n',coderTableID);
            this.writeCodeGenerationTableHeader();
            for targetIndex=1:length(pStruct.CODER)
                aStruct=pStruct.CODER(targetIndex);
                fprintf(this.MyFileID,'<tr><td>%s</td> <td>%s</td> <td>%s</td>\n',aStruct.targetSuffix,...
                aStruct.context,aStruct.folderConfig);
            end
            fprintf(this.MyFileID,'</table>\n');
        end


        function writeCodeGenerationTableHeader(this)

            headerElement='<th class="tooltip">%s<span class="tooltiptext">%s</span></th>\n';
            fprintf(this.MyFileID,'<tr>\n');

            fprintf(this.MyFileID,headerElement,...
            DAStudio.message('Simulink:cache:reportHeaderTextTarget'),...
            DAStudio.message('Simulink:cache:reportHeaderTargetToolTip'));

            fprintf(this.MyFileID,headerElement,...
            DAStudio.message('Simulink:cache:reportHeaderTextContext'),...
            DAStudio.message('Simulink:cache:reportHeaderContextToolTip'));

            fprintf(this.MyFileID,headerElement,...
            DAStudio.message('Simulink:cache:reportHeaderTextFolderConfig'),...
            DAStudio.message('Simulink:slbuild:CodeGenFolderStructureToolTip'));
            fprintf(this.MyFileID,'</tr>\n');
        end


        function writeFooter(this)
            fprintf(this.MyFileID,'</body>\n</html>');
        end
    end
end



