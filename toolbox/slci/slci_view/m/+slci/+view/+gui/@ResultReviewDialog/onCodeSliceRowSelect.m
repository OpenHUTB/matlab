



function onCodeSliceRowSelect(obj,data)


    src=slci.view.internal.getSource(obj.getStudio);
    modelName=src.modelName;

    if~isempty(data)&&~isempty(data.codelines)
        input=obj.prepareHiliteCodeData(data.codelines);

        title=data.name;

        slci.view.internal.hiliteCode(modelName,title,input);


        if slcifeature('SLCIJustification')==1
            conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
            fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);

            modelManager=slci.view.ModelManager(fname);
            justificationObj=modelManager.getJustificationManager(data.codelines);

            tempSidForCodeLines=justificationObj.getCodeLines();
            if~isempty(tempSidForCodeLines)
                spiltSid=split(tempSidForCodeLines,"-");
                codeSidForCodelines=spiltSid(2);
                tempFileName=split(codeSidForCodelines,':');
                blockSids="";

                if numel(tempFileName)>1
                    blockSids=append(blockSids,replace(codeSidForCodelines,",",";"));
                else
                    codeSidForCodelines=split(tempFileName(2),',');

                    tempsid=cell2text(tempFileName(1));
                    for i=1:numel(codeSidForCodelines)
                        addcolon=tempsid.append(':');
                        addBlockNum=append(addcolon,codeSidForCodelines(i),';');
                        blockSids=append(blockSids,addBlockNum);
                    end
                end
                charBlockSid=convertStringsToChars(blockSids);

            end
        end



        if isfield(data,'blocktrace')
            blockhandles=getBlockHandles(data.blocktrace);
            slci.view.internal.hiliteBlock(modelName,blockhandles);
        end

        if slcifeature('SLCIJustification')==1
            if~isempty(tempSidForCodeLines)
                blockhandles=getBlockHandles(charBlockSid);
                slci.view.internal.hiliteBlock(modelName,blockhandles);
            end





            if contains(['Warning','Justified'],getStatusCategory(data.status))
                obj.setMsgForJustificationDialog('');
            else
                key=strcat('Slci:slcireview:JustificationBlock',getStatusCategory(data.status));
                obj.setMsgForJustificationDialog(DAStudio.message(key));
            end

            data.dataFor="codeSliceGrid";
            vm=slci.view.Manager.getInstance;
            vw=vm.getView(obj.getStudio);
            ds=vw.getJustification();


            if(ds.hasDialog()&&ds.getStatus())
                obj.getJustificationForCodeLines(data);
            end
        end

    end

end


function out=getStatusCategory(status)
    statusList={'VERIFIED','FAILED_TO_VERIFY','FAILED','UNEXPECTEDDEF','PASSED'};

    if any(contains(statusList,status))
        out='PassedOrFailed';
        return;
    end

    if strcmpi(status,'JUSTIFIED')
        out='Justified';
        return;
    end

    out='Warning';
end

function out=getBlockHandles(blocktrace)
    out=[];

    blocksids=strsplit(blocktrace,';');
    idx=1;
    for i=1:numel(blocksids)
        sid=blocksids{i};
        try
            h=Simulink.URL.getHandle(sid);
            if isa(h,'Stateflow.Object')
                out(idx)=h.ID;%#ok
            else
                type=get_param(h,'type');
                if strcmp(type,'port')
                    out(idx)=get_param(h,'Line');%#ok
                else
                    out(idx)=h;%#ok
                end
            end
            idx=idx+1;
        catch
        end
    end
    out=unique(out);
end
