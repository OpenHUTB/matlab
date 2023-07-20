function reqReport(varargin)



    if~license_checkout_slvnv(~isempty(varargin)&&varargin{1})
        return;
    end

    prjName=rmiprj.currentProject('name');
    if isempty(prjName)
        if~isempty(varargin)&&varargin{1}
            msgString=getString(message('Slvnv:rmiml:NoProjectIsOpen'));
            dlgTitle=getString(message('Slvnv:rmiml:TraceabilityReport'));
            errordlg(msgString,dlgTitle);
            return;
        else
            error(message('Slvnv:rmiml:NoProjectIsOpen'));
        end
    end



    sourceFiles=rmiprj.currentProject('sources');
    if isempty(sourceFiles)
        if~isempty(varargin)&&varargin{1}
            msgString=getString(message('Slvnv:rmiml:ProjectHasNoTraceabilityData',prjName));
            dlgTitle=getString(message('Slvnv:rmiml:TraceabilityReport'));
            errordlg(msgString,dlgTitle);
            return;
        else
            error(message('Slvnv:rmiml:ProjectHasNoTraceabilityData',prjName));
        end
    end



    outputDir=rmiprj.getRptFolder();
    if exist(outputDir,'dir')~=7
        mkdir(outputDir);
    end


    generateSubReports(sourceFiles,outputDir);


    outputName=fullfile(outputDir,[prjName,'_rmiprj.html']);
    templateFile=fullfile(matlabroot,'toolbox','slrequirements','slrequirements','+rmiprj','rmiprj.rpt');
    origNavUseMatlab=rmipref('ReportNavUseMatlab',true);
    rptgen.report(templateFile,['-o',outputName]);
    insertHyperlinkSwitch(outputName);
    rmipref('ReportNavUseMatlab',origNavUseMatlab);
end

function success=license_checkout_slvnv(fromUI)


    invalid=builtin('_license_checkout','Simulink_Requirements','quiet');
    success=~invalid;
    if invalid
        if fromUI
            rmi.licenseErrorDlg();
        else
            error(message('Slvnv:reqmgt:licenseCheckoutFailed'));
        end
    end
end

function generateSubReports(sourceFiles,outputDir)
    for i=1:size(sourceFiles,1)
        fPath=sourceFiles{i,1};
        if rmiprj.hasData(fPath)

            s=settings;
            origViewCommand=s.rptgen.viewcmd.html.ActiveValue;
            tempViewCommand=['disp([''',fPath,''', '' done.'']);'];
            s.rptgen.viewcmd.html.TemporaryValue=tempViewCommand;
            fType=sourceFiles{i,2};
            switch fType
            case 'matlab'
                rptSubdir=fullfile(outputDir,'mlrpt');
                if~exist(rptSubdir,'dir')==7
                    mkdir(rptSubdir);
                end
                rmiml.reqReport(fPath,rptSubdir);
            case 'simulink'
                load_system(fPath);
                rptSubdir=fullfile(outputDir,'slrpt');
                if exist(rptSubdir,'dir')~=7
                    mkdir(rptSubdir);
                end
                origDir=pwd;
                cd(rptSubdir);
                [~,fName]=fileparts(fPath);
                rmi.reqReport(fName);
                cd(origDir);
            case 'data'
                rptSubdir=fullfile(outputDir,'ddrpt');
                if~exist(rptSubdir,'dir')==7
                    mkdir(rptSubdir);
                end
                rmide.reqReport(fPath,rptSubdir);
            case 'test'
                rptSubdir=fullfile(outputDir,'tmrpt');
                if~exist(rptSubdir,'dir')==7
                    mkdir(rptSubdir);
                end
                rmitm.reqReport(fPath,rptSubdir);
            otherwise
                s.rptgen.viewcmd.html.TemporaryValue=origViewCommand;
                error('Unsupported file type: %s',fType);
            end
            s.rptgen.viewcmd.html.TemporaryValue=origViewCommand;
        end
    end
end

function insertHyperlinkSwitch(outputName)

    fin=fopen(outputName,'r');
    html=fread(fin,'*char')';
    fclose(fin);


    if~contains(html,'http://localhost:31415/matlab/feval/rmi.navigate?arguments=')&&~contains(html,'http://127.0.0.1:31415/matlab/feval/rmi.navigate?arguments=')
        return;
    end


    headTagStart=strfind(html,'<head>');
    if isempty(headTagStart)
        return;
    end
    insertScript=headTagStart(1)+length('<head>');


    bodyTagStart=strfind(html,'<body ');
    tagEnds=find(html=='>');
    if isempty(bodyTagStart)
        return;
    end
    laterEnds=tagEnds(tagEnds>bodyTagStart);
    bodyTagEnd=laterEnds(1);


    extraSpaceStart=strfind(html,'<p>.<span> </span></p></div></div></body>');
    if isempty(extraSpaceStart)
        extraSpaceStart=length(html);
    end
    extraSpaceLength=length('<p>.<span> </span></p>');


    modifiedHtml=[...
    html(1:insertScript-1),newline...
    ,hyperlinkSwitcherScript(),newline...
    ,html(insertScript:bodyTagEnd-1)...
    ,' onLoad="appendMwImage();"'...
    ,html(bodyTagEnd:extraSpaceStart-1),newline...
    ,html(extraSpaceStart+extraSpaceLength:end)];


    backupName=regexprep(outputName,'\.html$','.rptgen');
    copyfile(outputName,backupName,'f');
    fout=fopen(outputName,'w');
    fwrite(fout,modifiedHtml,'*char');
    fclose(fout);
end

function jscript=hyperlinkSwitcherScript()
    jscript=[...
    '        <script>',newline...
    ,'        function replaceFileLinks() {',newline...
    ,'            var connectorPrefix1 = "http://localhost:31415/matlab/feval/rmi.navigate?arguments=[%22";',newline...
    ,'            var connectorPrefix2 = "http://127.0.0.1:31415/matlab/feval/rmi.navigate?arguments=[%22";',newline...
    ,'            var connectorSuffix = "%22]";',newline...
    ,'            var aList = document.getElementsByTagName("a");',newline...
    ,'            for (var i = 0; i < aList.length; i++) {',newline...
    ,'                var href = aList[i].href;',newline...
    ,'                var filePathStart = href.indexOf(connectorPrefix1);',newline...
    ,'                if (filePathStart == 0) {',newline...
    ,'                    var filePathEnd = href.indexOf(connectorSuffix);',newline...
    ,'                    var filePath = href.substring(connectorPrefix1.length, filePathEnd);',newline...
    ,'                    var betterPath = filePath.replace(/%5C%5C/g, "/");',newline...
    ,'                    aList[i].setAttribute("href", "file:///" + betterPath);',newline...
    ,'                }',newline...
    ,'                filePathStart = href.indexOf(connectorPrefix2);',newline...
    ,'                if (filePathStart == 0) {',newline...
    ,'                    var filePathEnd = href.indexOf(connectorSuffix);',newline...
    ,'                    var filePath = href.substring(connectorPrefix2.length, filePathEnd);',newline...
    ,'                    var betterPath = filePath.replace(/%5C%5C/g, "/");',newline...
    ,'                    aList[i].setAttribute("href", "file:///" + betterPath);',newline...
    ,'                }',newline...
    ,'            }',newline...
    ,'            var mwImage = document.getElementById("mwImage");',newline...
    ,'            mwImage.width = 0;',newline...
    ,'            mwImage.height = 0;',newline...
    ,'        }',newline...
    ,'        function appendMwImage() {',newline...
    ,'            var mwImage = new Image();',newline...
    ,'            var randomnumber=Math.floor(Math.random()*1000001);',newline...
    ,'            mwImage.id = "mwImage";',newline...
    ,'            mwImage.onerror = replaceFileLinks;',newline...
    ,'            mwImage.src = "http://127.0.0.1:31415/images/mwlink.ico?" + randomnumber;',newline...
    ,'            document.body.appendChild(mwImage);',newline...
    ,'        }',newline...
    ,'        </script>'];
end



