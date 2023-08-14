classdef ExternalEditorManager<handle
















    properties(Constant)

        USERTEMPDIR=fullfile(slreq.opc.getUsrTempDir);
    end

    properties

        ExternalEditorMap=containers.Map('KeyType','char','ValueType','Any');
    end

    methods

        function this=ExternalEditorManager()

        end


        function delete(this)





            this.deleteAllExternalEditors;
        end


        function editorObj=getExternalEditor(this,dasReq,field,isCreate)
            if nargin<4
                isCreate=false;
            end

            reqKey=getExternalEditorMapKey(dasReq,field);
            if isKey(this.ExternalEditorMap,reqKey)
                editorObj=this.ExternalEditorMap(reqKey);
            elseif isCreate

                editorObj=slreq.gui.ExternalEditor(dasReq,field);
                this.ExternalEditorMap(reqKey)=editorObj;
            else
                editorObj=[];
            end
        end





        function succeed=detachExternalEditors(this,errorID)
            if this.areAnyExternalEditorsOpen()
                errordlg(getString(message(errorID)),...
                getString(message('Slvnv:slreq:RequirementSetInUseTitle')),'modal');
                succeed=false;
                return;
            end

            try
                this.deleteAllExternalEditors();
                succeed=true;
            catch ex
                errordlg(ex.message,getString(message('Slvnv:slreq:Error')));
                succeed=false;
            end
        end


        function deleteExternalEditor(this,dasReq,field)
            reqKey=getExternalEditorMapKey(dasReq,field);
            if isKey(this.ExternalEditorMap,reqKey)

                this.deleteExternalEditorObj(reqKey);
            end
        end


        function deleteExternalEditorForReqs(this,dasReqs)
            if this.ExternalEditorMap.Count~=0
                for index=1:length(dasReqs)
                    cDasReq=dasReqs{index};
                    if isa(cDasReq,'slreq.das.Requirement')
                        this.deleteExternalEditor(cDasReq,'description');
                        this.deleteExternalEditor(cDasReq,'rationale');
                    end
                end
            end
        end


        function deleteAllExternalEditors(this)
            allReqKeys=this.ExternalEditorMap.keys;
            for index=1:length(allReqKeys)
                reqKey=allReqKeys{index};
                this.deleteExternalEditorObj(reqKey);
            end
        end


        function out=hasData(this)

            out=this.ExternalEditorMap.Count~=0;
        end


        function closeAll(this)

            if this.hasData


                wordApp=rmicom.wordApp();
                if isempty(wordApp)

                    return;
                else
                    wordApp=rmicom.wordApp();
                    hDocs=wordApp.Documents;
                    allDocNames={};
                    for i=1:hDocs.Count
                        thisDoc=hDocs.Item(i);
                        if~isempty(thisDoc)
                            thisName=thisDoc.FullName;
                            if contains(thisName,this.USERTEMPDIR,'IgnoreCase',true)



                                allDocNames{end+1}=thisName;%#ok<AGROW>
                            end
                        end
                    end

                    for index=1:length(allDocNames)
                        cName=allDocNames{index};
                        rmicom.wordApp('closedoc',cName);
                    end

                end
            else

            end

        end


        function out=areAnyExternalEditorsOpen(this)


            if this.hasData

                wordApp=rmicom.wordApp();
                if isempty(wordApp)
                    out=false;
                else
                    wordApp=rmicom.wordApp();
                    hDocs=wordApp.Documents;

                    for i=1:hDocs.Count
                        thisDoc=hDocs.Item(i);
                        if~isempty(thisDoc)
                            thisName=thisDoc.FullName;




                            if contains(thisName,this.USERTEMPDIR,'IgnoreCase',true)
                                out=true;
                                return;
                            end
                        end
                    end
                    out=false;
                end
            else
                out=false;
            end
        end
    end


    methods(Access=private)

        function deleteExternalEditorObj(this,reqKey)

            editorObj=this.ExternalEditorMap(reqKey);
            this.ExternalEditorMap.remove(reqKey);
            if isvalid(editorObj)
                editorObj.delete;
            end
        end
    end
end


function reqKey=getExternalEditorMapKey(dasReq,field)

    reqFullID=dasReq.dataModelObj.getFullID;
    if strcmpi(field,'description')
        reqKey=sprintf('%s%s',reqFullID,' D');
    else
        reqKey=sprintf('%s%s',reqFullID,' R');
    end

end