function docLink=makeRptLink(fPath,action,varargin)



    dXML=get(rptgen.appdata_rg,'CurrentDocument');

    navUseMatlab=rmipref('ReportNavUseMatlab');

    if iscell(fPath)
        docLink=cell(size(fPath));
        for i=1:length(fPath)
            if iscell(action)
                docLink{i}=makeOneLink(dXML,navUseMatlab,fPath{i},action{i},varargin{:});
            else
                docLink{i}=makeOneLink(dXML,navUseMatlab,fPath{i},action,varargin{:});
            end
        end
    else
        docLink=makeOneLink(dXML,navUseMatlab,fPath,action,varargin{:});
    end
end

function link=makeOneLink(dXML,navUseMatlab,fPath,action,varargin)

    switch action

    case 'file'
        [~,~,ext]=fileparts(fPath);
        switch ext
        case{'.mat','.req'}
            link=fPath;
        otherwise
            if navUseMatlab
                url=connectorCmd(fPath);
            else
                url=rmiut.filepathToUrl(fPath);
            end

            projLocation=rmiprj.currentProject('folder');
            displayPath=strrep(fPath,projLocation,' .');
            link=dXML.makeLink(url,displayPath,'ulink');
        end

    case 'report'
        if rmiprj.hasData(fPath)
            [~,fName,ext]=fileparts(fPath);
            switch ext
            case '.m'
                RptgenRMI.mllinkMgr('mfile',fPath);
                if navUseMatlab
                    cmd=['rmiprj.slRpt(''',fPath,''');'];
                    link=dXML.makeLink(['matlab:',cmd],getString(message('Slvnv:rmiml:VIEW')),'ulink');
                else
                    link=dXML.makeLink(['./mlrpt/',fName,'_rmiml.html'],getString(message('Slvnv:rmiml:VIEW')),'matlab');
                end
            case '.sldd'
                RptgenRMI.mllinkMgr('ddfile',fPath);
                if navUseMatlab
                    cmd=['rmiprj.slRpt(''',fPath,''');'];
                    link=dXML.makeLink(['matlab:',cmd],getString(message('Slvnv:rmiml:VIEW')),'ulink');
                else
                    link=dXML.makeLink(['./ddrpt/',fName,'_rmide.html'],getString(message('Slvnv:rmiml:VIEW')),'matlab');
                end
            case '.mldatx'
                RptgenRMI.mllinkMgr('tmfile',fPath);
                if navUseMatlab
                    cmd=['rmiprj.slRpt(''',fPath,''');'];
                    link=dXML.makeLink(['matlab:',cmd],getString(message('Slvnv:rmiml:VIEW')),'ulink');
                else
                    link=dXML.makeLink(['./tmrpt/',fName,'_rmitm.html'],getString(message('Slvnv:rmiml:VIEW')),'matlab');
                end
            case{'.mdl','.slx'}
                if navUseMatlab
                    cmd=['rmiprj.slRpt(''',fPath,''');'];
                    link=dXML.makeLink(['matlab:',cmd],getString(message('Slvnv:rmiml:VIEW')),'ulink');
                else
                    link=dXML.makeLink(['./slrpt/',fName,'_requirements.html'],getString(message('Slvnv:rmiml:VIEW')),'ulink');
                end
            otherwise
                link='';
            end
        else
            link=getString(message('Slvnv:rmiml:NoLinks'));
        end

    case 'check'
        [~,~,ext]=fileparts(fPath);
        if any(strcmp(ext,{'.doc','.docx','.rtf','.xls','.xlsx'}))
            cmd=['rmiprj.slRpt(''',fPath,''');'];
            link=dXML.makeLink(['matlab:',cmd],getString(message('Slvnv:rmiml:VIEW')),'ulink');
        else
            link=getString(message('Slvnv:rmiml:NA'));
        end

    otherwise


        reqsys=action;
        refPath=fileparts(varargin{1});
        resolved=rmiprj.resolveDoc(fPath,reqsys,refPath);
        link=rmiprj.rptHyperlinkForDoc(fPath,resolved,reqsys,refPath,dXML);
    end
end


function url=connectorCmd(fPath)

    cmd=sprintf('rmi.navigate(''%s'')',fPath);
    url=rmiut.cmdToUrl(cmd);
end

