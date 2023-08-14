


classdef DocCheckWord<rmiref.DocChecker

    properties
        hDocument=''
    end

    methods

        function checker=DocCheckWord(name)
            resolved_doc=rmiref.DocCheckWord.locateDocument(name);
            checker=checker@rmiref.DocChecker(resolved_doc);
            checker.type='word';
        end

        function printable_name=getDocName(this)
            [~,docName,ext]=fileparts(this.docname);
            printable_name=[docName,ext];
        end

        function printable_location=getDocLocation(this)
            [docPath,~]=fileparts(this.docname);
            printable_location=regexprep(docPath,'\','/');
        end

        function info=getModificationInfo(this)

            fileInfo=dir(this.docname);
            info=datestr(fileInfo.datenum);
        end

        function saveDocument(this)
            this.hDocument.Save();
        end

        function[reasonIdx,data]=getSkippedItems(this)%#ok<MANU>


            reasonIdx={};
            data=cell(0,4);
        end




    end


    methods(Static)

        function rptName=makeReportName(docName)

            [~,fname,~]=fileparts(docName);
            rptName=[fname,'_SLRefReport.html'];
        end

        function currentDoc=getCurrentDoc()
            currentDoc=rmiref.WordUtil.getCurrentDoc();
        end

        function located=locateDocument(doc)
            located=rmiref.locateFile(doc);
        end

        function fixed=fix(doc,item,issue,allArgs)
            [shapeobj,btnobj,~]=rmiref.WordUtil.findActxObject(doc,item);
            if isempty(shapeobj)
                error(message('Slvnv:rmiref:DocCheckWord:ItemNotFound',item));
            end
            switch issue
            case rmiref.DocChecker.UNRESOLVED_MODEL
                fixed=rmiref.fixActxModel(btnobj,allArgs);
            case rmiref.DocChecker.UNRESOLVED_OBJECT
                fixed=rmiref.fixActxObject(btnobj,allArgs);
            otherwise
                error(message('Slvnv:rmiref:DocCheckWord:UnsupportedIssue',issue));
            end
        end

        function restored=restore(doc,item,args)%#ok<INUSD>
            if isempty(doc)
                btnobj=item;
                item=btnobj.Name;
            else
                [shapeobj,btnobj,~]=rmiref.WordUtil.findActxObject(doc,item);
                if isempty(shapeobj)
                    error(message('Slvnv:rmiref:DocCheckWord:ItemNotFound',item));
                end
            end
            try
                [origCommand,origLabel]=rmiref.SLReference.parseData(btnobj.MLDataString);
                btnobj.MLEvalString=origCommand;
                btnobj.ToolTipString=origLabel;
                btnobj.MLDataString='';
                normalIcon=rmiref.SLReference.fullIconPathName('normal');
                if~isempty(normalIcon)
                    btnobj.Picture=normalIcon;
                else
                    warning(message('Slvnv:rmiref:DocCheckWord:IconBitmapMissing',item,normalIcon));
                end
                restored=true;
            catch Mex
                warning(message('Slvnv:rmiref:DocCheckWord:FailToRestore',item,Mex.message));
                restored=false;
            end
        end

    end

end

