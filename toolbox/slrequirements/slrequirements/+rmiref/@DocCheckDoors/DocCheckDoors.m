


classdef DocCheckDoors<rmiref.DocChecker

    properties
        modulename=''
        projectname=''
    end

    methods

        function checker=DocCheckDoors(name)
            resolved_doc=rmiref.DocCheckDoors.locateDocument(name);
            checker=checker@rmiref.DocChecker(resolved_doc);
            checker.type='doors';
            fullname=rmidoors.getModuleAttribute(checker.docname,'FullName');
            tokens=regexp(fullname,'/([^/]+)/([^/]+)$','tokens');
            parts=tokens{1,1};
            checker.projectname=parts{1};
            checker.modulename=parts{2};
        end

        function printable_name=getDocName(this)
            printable_name=this.modulename;
        end

        function printable_location=getDocLocation(this)
            printable_location=this.projectname;
        end

        function info=getModificationInfo(this)
            info=rmidoors.getModuleAttribute(this.docname,'LastModified');
        end

        function saveDocument(this)
            rmidoors.saveModule(this.docname);
        end


        function[reasonIdx,data]=getSkippedItems(this)
            reasonIdx={};
            data=cell(0,4);
            current=0;
            for i=1:size(this.skipped,1)
                row=this.skipped(i,:);
                moduleId=row{1};
                itemId=row{2};
                reason=row{3};
                match=find(strcmp(reasonIdx,reason));
                if isempty(match)
                    current=current+1;
                    reasonIdx{current}=reason;%#ok<AGROW>
                    match=current;
                end
                [linkLabel,details]=makeLabels(moduleId,itemId);
                data(end+1,:)={match,...
                ['rmi.navigate(''linktype_rmi_doors'',''',moduleId,''',''',itemId,''','''');'],...
                linkLabel,details};%#ok<AGROW>
            end

            function[linkLabel,details]=makeLabels(moduleId,objId)
                prefix=reqmgtprivate('doors_module_get',moduleId,'Prefix');
                details=reqmgtprivate('doors_obj_get',moduleId,objId,'Object Heading');
                if isempty(details)
                    details=reqmgtprivate('doors_obj_get',moduleId,objId,'Object Text');
                end
                if length(details)>50
                    details=[details(1:50),'...'];
                end
                linkLabel=['DOORS ID ',prefix,objId];
            end

        end

    end


    methods(Static)

        function rptName=makeReportName(doc)
            fullname=rmidoors.getModuleAttribute(doc,'FullName');
            fullname=strrep(fullname,'/','_');
            fullname=strrep(fullname,'.','_');
            rptName=[fullname,'.html'];
        end

        function current=getCurrentDoc()
            current=rmiref.DoorsUtil.getCurrentDoc();
        end

        function located=locateDocument(doc)
            located=rmiref.DoorsUtil.findModule(doc);
        end

        function viewLink(docitem)
            rmidoors.show(docitem.module,docitem.id,true);
        end

        function fixed=fix(doc,item,issue,allArgs)
            switch issue
            case rmiref.DocChecker.UNRESOLVED_MODEL
                fixed=rmiref.DoorsUtil.fixDoorsModel(doc,item,allArgs);
            case rmiref.DocChecker.UNRESOLVED_OBJECT
                fixed=rmiref.DoorsUtil.fixDoorsObject(doc,item,allArgs);
            otherwise
                error(message('Slvnv:rmiref:DocCheckDoors:UnsupportedIssue',issue));
            end
        end

        function restored=restore(doc,item)
            try

                data=rmidoors.getObjAttribute(doc,item,'Object Short Text');
                [origCommand,origLabel]=rmiref.SLReference.parseData(data);
                rmidoors.setObjAttribute(doc,item,'Object Text',origLabel);
                rmidoors.setObjAttribute(doc,item,'DmiSlNavCmd',origCommand);

                newBitmap=rmiref.SLReference.fullIconPathName('normal');
                rmidoors.setObjAttribute(doc,item,'picture',newBitmap);

                rmidoors.setObjAttribute(doc,item,'Object Short Text','');
                restored=true;
            catch Mex
                warning(message('Slvnv:rmiref:SLRefDoors:ItemRestoreFailed',item,doc,Mex.message));
                restored=false;
            end
        end

    end
end




