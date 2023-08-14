classdef CodeTraceabilityManager<handle



    properties
        appmgr;
        Enabled=false;
        model2CodeTraceInfoMap=containers.Map('KeyType','double','ValueType','Any');
    end

    methods
        function this=CodeTraceabilityManager(mgr)
            this.appmgr=mgr;
        end

        function[yesno,navCmd,navArg,tooltip]=getTraceabilityInfo(this,link)
            yesno=false;
            navCmd='rtwtrace';
            navArg={};
            tooltip='';

            if~this.Enabled

                return;
            end

            srcLink=link.source;
            if~isa(srcLink,'slreq.data.SourceItem')
                return;
            end

            if~strcmp(srcLink.domain,'linktype_rmi_simulink')

                return;
            end

            blkSID=srcLink.getSID;

            navArg={blkSID};

            try

                hdl=Simulink.ID.getHandle(blkSID);
                m2c=coder.internal.model2code(hdl);
            catch ex %#ok<NASGU>

                return;
            end
            if~isempty(m2c.location)

                file2lineMap=containers.Map('KeyType','char','ValueType','Any');
                tooltip=[getString(message('Slvnv:slreq:CodedAt')),'<br>'];
                for n=1:length(m2c.location)
                    if~file2lineMap.isKey(m2c.location(n).file)
                        file2lineMap(m2c.location(n).file)=m2c.location(n).line;
                    else
                        thisLine=file2lineMap(m2c.location(n).file);
                        file2lineMap(m2c.location(n).file)=[thisLine,m2c.location(n).line];
                    end
                end
                filePaths=file2lineMap.keys;
                for k=1:length(filePaths)
                    [~,fileName,ext]=fileparts(filePaths{k});

                    lineInfo=unique(file2lineMap(filePaths{k}));

                    lineInfoStr='';
                    for m=1:length(lineInfo)
                        lineInfoStr=[lineInfoStr,num2str(lineInfo(m)),','];%#ok<AGROW>
                    end
                    lineInfoStr(end)='';

                    tooltip=[tooltip,fileName,ext,':',lineInfoStr,newline];%#ok<AGROW>
                end
                if tooltip(end)==newline

                    tooltip(end)='';
                end
                yesno=true;
            end

        end

        function traceInfo=getModel2CodeTraceInfo(this,modelH)
            if~this.model2CodeTraceInfoMap.isKey(modelH)
                this.model2CodeTraceInfoMap(modelH)=coder.trace.getTraceInfo(modelH);
            end
            traceInfo=this.model2CodeTraceInfoMap(modelH);
        end
    end

    methods(Static)
        function notifyForCodeTraceabilityIfNeeded()


            needNotify=true;
            reqData=slreq.data.ReqData.getInstance();
            linkSets=reqData.getLoadedLinkSets;
            for n=1:length(linkSets)
                if strcmp(linkSets(n).domain,'linktype_rmi_simulink')
                    [~,modelName]=fileparts(linkSets(n).artifact);
                    if dig.isProductInstalled('Simulink')&&bdIsLoaded(modelName)...
                        &&strcmpi(get_param(modelName,'GenerateTraceInfo'),'on')...
                        &&coder.internal.slcoderReport('existTrace',modelName)


                        needNotify=false;
                        break;
                    end
                end
            end
            if needNotify
                helpdlg(getString(message('Slvnv:slreq:CodedTraceabilityDialog')),...
                getString(message('Slvnv:slreq:CodedTraceabilityDialogTitle')));
            end

        end
    end
end
