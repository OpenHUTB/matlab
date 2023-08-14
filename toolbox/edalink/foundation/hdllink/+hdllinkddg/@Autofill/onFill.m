function onFill(this,dialog)


    answer=this.Path;
    if(~isempty(answer))
        entityPath=answer;



        delims='[/.]';
        dindx=regexp(entityPath,delims);
        lastindx=max(dindx);
        if(isempty(lastindx))
            sigDelim='/';
        elseif(lastindx==length(entityPath))
            sigDelim='';
        else
            sigDelim=entityPath(lastindx);
        end

        pause(.1)
        cInfo=this.Parent.CommSource.GetConnInfo;
        portsPathandMode=autopopulate(...
        entityPath,...
        double(cInfo.isOnLocalHost),...
        double(cInfo.isShared),...
        cInfo.hostName,...
        cInfo.portNumber);

        assert(length(portsPathandMode)>=1,'Hdllink:Autofill:InvalidData',...
        'Received invalid data from HDL simulator');
        assert(portsPathandMode{1}~=0,'Hdllink:Autofill:InstanceNotFound',...
        ['HDL instance ',entityPath,' was not found in the loaded model.']);
        assert(portsPathandMode{1}==1||portsPathandMode{1}==2,'Hdllink:Autofill:UnsupportedRegion',...
        ['HDL instance ',entityPath,' is not supported for cosimulation.']);
        assert(portsPathandMode{2}~=0,'Hdllink:Autofill:UnsupportedRegion',...
        ['HDL instance ',entityPath,' does not contain any ports.']);

        srcData=this.Parent.PortTableSource.GetSourceData;
        rowSelect=size(srcData,1)+1;

        for i=3:2:length(portsPathandMode)
            currPortPath=[entityPath,sigDelim,portsPathandMode{i}];


            if(strcmp(portsPathandMode{i+1},'OUT')),
                srcData(end+1,:)={currPortPath,2,'1',-1,0,'0'};
            else
                srcData(end+1,:)={currPortPath,1,'-1',-1,0,'-1'};
            end
        end
        this.Parent.PortTableSource.SetSourceData(srcData,rowSelect);
    end





    this.ParentDialog.enableApplyButton(true);
    this.ParentDialog.resetSize(false);
    this.ParentDialog.refresh();

    delete(dialog);
end

